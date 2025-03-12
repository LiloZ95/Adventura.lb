import pandas as pd
import numpy as np
import pickle
import os
import time
import threading  # ✅ For scheduled background training
from sqlalchemy import create_engine
from flask import Flask, request, jsonify
from flask_cors import CORS
from sklearn.metrics.pairwise import cosine_similarity
from implicit.als import AlternatingLeastSquares
from scipy.sparse import csr_matrix
from datetime import datetime, timedelta

# ✅ Initialize Flask App
app = Flask(__name__)

CORS(app)  # ✅ Enable CORS for all routes

os.environ["OPENBLAS_NUM_THREADS"] = "1"

# ✅ Database Connection
DATABASE_URL = "postgresql://postgres:1234567890@localhost:5432/Adventura"
engine = create_engine(DATABASE_URL)

# ✅ Caching variables
interaction_count = 0  # Tracks number of new interactions
last_model_update = None  # Stores last update time
recommendation_cache = {}  # Stores last recommendations for each user
MODEL_UPDATE_INTERVAL = 3 * 60 * 60  # Retrain model every 3 hours
MODEL_FILE = "model.pkl"

# ✅ Helper: Check model last modified timestamp
def get_model_timestamp():
    """Returns last modified timestamp of model.pkl"""
    if os.path.exists(MODEL_FILE):
        return os.path.getmtime(MODEL_FILE)  # Returns last modified time
    return None

# ✅ Fetch User Preferences
def get_user_preferences(user_id):
    query = """
        SELECT category_id, preference_level, last_updated 
        FROM user_preferences WHERE user_id = %(user_id)s
    """
    df = pd.read_sql(query, engine, params={"user_id": user_id})
    
    # Apply decay function
    if not df.empty:
        df["last_updated"] = df["last_updated"].dt.tz_localize(None)
        df["days_since_update"] = (datetime.now() - df["last_updated"]).dt.days
        df["preference_level"] = df["preference_level"] * np.exp(-0.05 * df["days_since_update"])  # Exponential decay
        df["preference_level"] = df["preference_level"].clip(1, 5)  # Keep within range
    
    return df

# ✅ Fetch User Interactions
def get_user_interactions():
    query = """
        SELECT user_id, activity_id, interaction_type, rating 
        FROM user_activity_interaction
    """
    df = pd.read_sql(query, engine)

    if df.empty:
        return df

    interaction_weights = {
        "like": 3,
        "rate": 5,
        "save": 2,
        "share": 1,
        "view": 1,
        "purchase": 5
    }

    df["interaction_value"] = df["interaction_type"].map(interaction_weights).fillna(0)
    df["rating"] = df.apply(lambda row: row["rating"] if pd.notna(row["rating"]) else row["interaction_value"], axis=1)

    print("✅ RAW USER INTERACTIONS FROM DATABASE:\n", df)

    return df[["user_id", "activity_id", "rating"]]

# ✅ Train ALS Model for Collaborative Filtering
def train_als_model():
    global last_model_update

    interactions = get_user_interactions()
    if interactions.empty:
        return None, None, None

    # ✅ Convert activity_id to category index BEFORE pivoting
    interactions["activity_idx"] = interactions["activity_id"].astype("category").cat.codes

    # ✅ Store mapping BEFORE pivoting (Fix KeyError)
    activity_id_mapping = dict(zip(interactions["activity_idx"], interactions["activity_id"]))

    # ✅ Aggregate interactions (Use max rating or sum)
    interactions = interactions.groupby(["user_id", "activity_idx"])["rating"].max().reset_index()

    # ✅ Pivot to create User-Item Matrix
    user_item_matrix = interactions.pivot(index="user_id", columns="activity_idx", values="rating").fillna(0)

    user_item_sparse = csr_matrix(user_item_matrix.values)

    # ✅ Train ALS Model
    model = AlternatingLeastSquares(
        factors=150,  
        regularization=0.05,  
        iterations=40  
    )
    model.fit(user_item_sparse)

    # ✅ Save the trained model
    with open(MODEL_FILE, "wb") as f:
        pickle.dump((model, user_item_matrix, activity_id_mapping), f)
    
    last_model_update = time.time()
    print(f"✅ Trained ALS model saved at {time.ctime(last_model_update)}")

    return model, user_item_matrix, activity_id_mapping

# ✅ Fetch Most Popular Events (Fallback)
def get_popular_activities():
    query = """
        SELECT activity_id AS id, 'activity' AS type FROM activities
        ORDER BY RANDOM() LIMIT 10
    """
    df = pd.read_sql(query, engine)
    return df["activity_id"].tolist() if not df.empty else []

# ✅ Content-Based Filtering (CBF)
def content_based_recommendations(user_id):
    preferences = get_user_preferences(user_id)
    if preferences.empty:
        return []

    query = "SELECT activity_id AS id, category_id FROM activities"
    activities = pd.read_sql(query, engine)

    # ✅ Merge activities with preferences
    merged = activities.merge(preferences, on="category_id", how="left").fillna(0)
    merged["score"] = merged["preference_level"]

    # ✅ Give extra weight to categories user interacted with
    user_interactions = get_user_interactions()
    user_activities = user_interactions[user_interactions["user_id"] == user_id]["activity_id"].tolist()
    merged["score"] += merged["id"].apply(lambda x: 5 if x in user_activities else 0)

    # ✅ Sort by highest preference level
    recommendations = merged.sort_values("score", ascending=False)[["id"]].to_dict(orient="records")

    return [rec["id"] for rec in recommendations[:10]]

# ✅ Collaborative Filtering (CF)
def collaborative_filtering(user_id, model, user_item_matrix, activity_id_mapping):
    if user_id not in user_item_matrix.index:
        return []  # If user has no interactions, return empty list
    
    user_idx = user_item_matrix.index.get_loc(user_id)
    user_vector = csr_matrix(user_item_matrix.values)[user_idx]

    # ✅ Get ALS Recommendations (Using Correct Mapping)
    recommendations = model.recommend(user_idx, user_vector, N=10)
    print(f"🔍 RAW ALS Recommendations for User {user_id}: {recommendations}")

    # ✅ Convert Encoded IDs Back to Original activity_id
    recommended_ids = [activity_id_mapping.get(int(rec[0]), -1) for rec in recommendations]
    recommended_ids = [rec for rec in recommended_ids if rec > 0]  # Remove any invalid ID

    # ✅ Find Top Similar Users & Add Their Activities
    user_similarities = model.user_factors @ model.user_factors[user_idx]  # Compute cosine similarity
    similar_users = np.argsort(user_similarities)[-6:]  # Take top 6 (including user)

    # ✅ Remove the current user from the similar users list
    similar_users = [u for u in similar_users if u != user_idx][-5:]  # Keep only top 5 valid similar users

    # ✅ Convert user indices back to actual user IDs
    real_user_ids = list(user_item_matrix.index)  
    similar_user_ids = [real_user_ids[sim_idx] for sim_idx in similar_users if sim_idx < len(real_user_ids)]

    print(f"✅ Corrected Similar Users for {user_id}: {similar_user_ids}")
    
    # ✅ Get activities rated highly by similar users
    for sim_user in similar_user_ids:
        if sim_user in user_item_matrix.index:
            similar_user_rated = user_item_matrix.loc[sim_user]
            highly_rated = similar_user_rated[similar_user_rated >= 4].index.tolist()
            similar_user_activities = [activity_id_mapping.get(idx, -1) for idx in highly_rated]
            recommended_ids.extend(similar_user_activities)

    return list(set(recommended_ids))[:10]


# ✅ Hybrid Recommendation System
def hybrid_recommendation(user_id):
    global recommendation_cache

    # ✅ Use cached recommendations if available
    if user_id in recommendation_cache:
        print(f"🟢 Using cached recommendations for user {user_id}")
        return recommendation_cache[user_id]
    
    cbf_recs = content_based_recommendations(user_id)  # Content-Based Filtering

    # ✅ Fix: Accept 3 values instead of 2
    als_model, user_item_matrix, activity_id_mapping = load_trained_model()

    cf_recs = collaborative_filtering(user_id, als_model, user_item_matrix, activity_id_mapping) if als_model else []

    recommendation_scores = {rec: (30 - idx) for idx, rec in enumerate(cf_recs)}

    # ✅ Assign higher weight to CF results
    for idx, rec in enumerate(cbf_recs):
        recommendation_scores[rec] = recommendation_scores.get(rec, 0) + (15 - idx)

    sorted_recommendations = sorted(recommendation_scores.items(), key=lambda x: x[1], reverse=True)
    final_recommendations = [{"id": rec[0], "type": "activity"} for rec in sorted_recommendations[:10]]

    print(f"✅ CF Raw Recommendations Before Hybrid: {cf_recs}")

    recommendation_cache[user_id] = final_recommendations
    return final_recommendations

def load_trained_model():
    if not os.path.exists(MODEL_FILE) or os.path.getsize(MODEL_FILE) == 0:
        return train_als_model()

    with open(MODEL_FILE, "rb") as f:
        return pickle.load(f)

# ✅ Scheduled Background Model Training
def schedule_model_updates():
    global last_model_update, interaction_count

    while True:
        time.sleep(60)  # Check every minute
        time_since_update = time.time() - (last_model_update or 0)

        if time_since_update >= MODEL_UPDATE_INTERVAL or interaction_count >= 50:
            if (last_model_update and time.time() - last_model_update < 5 * 60):
                print("⏳ Skipping redundant retraining (too soon)...")
                continue  # Avoid retraining multiple times within 5 minutes

            print("🔄 Retraining ALS model due to new interactions or time elapsed...")
            train_als_model()
            interaction_count = 0  # Reset interaction count

# ✅ API Endpoint
@app.route("/recommend", methods=["GET"])
def recommend():
    user_id = request.args.get("user_id")
    if not user_id:
        return jsonify({"error": "Missing user_id"}), 400

    user_id = int(user_id)
    
    recommendations = hybrid_recommendation(user_id)

    print(f"✅ Final Recommendations Sent to Frontend: {recommendations}")
    print(get_user_preferences(15))

    return jsonify({"success": True, "recommendations": recommendations})

# ✅ Start Scheduled Model Updates in a Separate Thread
threading.Thread(target=schedule_model_updates, daemon=True).start()

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001, debug=True) 
