import pandas as pd
import numpy as np
from sqlalchemy import create_engine
from flask import Flask, request, jsonify
from flask_cors import CORS  # Import CORS
from sklearn.metrics.pairwise import cosine_similarity
from datetime import datetime, timedelta
from implicit.als import AlternatingLeastSquares
from scipy.sparse import csr_matrix  # Import sparse matrix library

# ✅ Initialize Flask App
app = Flask(__name__)

CORS(app)  # ✅ Enable CORS for all routes

# ✅ Database Connection
DATABASE_URL = "postgresql://postgres:1234567890@localhost:5432/Adventura"
engine = create_engine(DATABASE_URL)

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

# ✅ Fetch Event Interactions
def get_user_interactions():
    query = """
        SELECT user_id, activity_id, interaction_type, rating 
        FROM user_activity_interaction
    """
    df = pd.read_sql(query, engine)

    if df.empty:
        return df

    # ✅ Define interaction weights (adjust these based on importance)
    interaction_weights = {
        "like": 3,         # Moderate weight
        "rate": 5,         # High weight (user has rated activity)
        "save": 2,         # Lower weight (saved to wishlist)
        "share": 1,        # Weak weight (user just shared it)
        "view": 1,          # Weak weight (user just viewed it)
        "purchase": 5      # High weight (user purchased tickets)
    }

    # ✅ Convert interaction_type to numeric weight
    df["interaction_value"] = df["interaction_type"].map(interaction_weights).fillna(0)

    # ✅ If there's a rating, use it; otherwise, use interaction_value
    df["rating"] = df.apply(lambda row: row["rating"] if pd.notna(row["rating"]) else row["interaction_value"], axis=1)

    print("✅ RAW USER INTERACTIONS FROM DATABASE:\n", df)  # Debugging
    return df[["user_id", "activity_id", "rating"]]

# ✅ Train ALS Model for Collaborative Filtering
def train_als_model():
    interactions = get_user_interactions()
    if interactions.empty:
        return None, None

    # ✅ Convert activity_id to category index
    interactions["activity_idx"] = interactions["activity_id"].astype("category").cat.codes  # Encode categories
    activity_id_mapping = dict(zip(interactions["activity_idx"], interactions["activity_id"]))  # Mapping back

    # ✅ Convert to User-Item Matrix (using encoded indices)
    user_item_matrix = interactions.pivot(index="user_id", columns="activity_idx", values="rating").fillna(0)

    # ✅ Boost ratings (Increase impact of interactions)
    user_item_matrix = user_item_matrix * 5

    user_item_sparse = csr_matrix(user_item_matrix.values)

    # ✅ Fix numerical stability
    user_item_sparse.data = np.nan_to_num(user_item_sparse.data)

    # ✅ Train ALS Model (Ensure it learns properly)
    model = AlternatingLeastSquares(
        factors=150,  # Increase feature complexity
        regularization=0.05,  # Improve generalization
        iterations=40  # Longer training
    )
    model.fit(user_item_sparse)

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
    user_interaction_sparse = csr_matrix(user_item_matrix.values)
    user_vector = user_interaction_sparse[user_idx]  # Get user row only

    # ✅ Get ALS Recommendations (Using Correct Mapping)
    recommendations = model.recommend(user_idx, user_vector, N=10)

    # ✅ Convert Encoded IDs Back to Original activity_id
    recommended_ids = [activity_id_mapping.get(int(rec[0]), -1) for rec in recommendations]
    recommended_ids = [rec for rec in recommended_ids if rec > 0]  # Remove any invalid ID

    # ✅ Find Top Similar Users & Add Their Activities
    similar_users = np.argsort(model.user_factors[user_idx])[-3:]
    for sim_user in similar_users:
        if sim_user in user_item_matrix.index:
            similar_user_rated = user_item_matrix.loc[sim_user]
            highly_rated = similar_user_rated[similar_user_rated >= 4].index.tolist()

            # ✅ Map back to original activity_id
            similar_user_activities = [activity_id_mapping.get(idx, -1) for idx in highly_rated]
            recommended_ids.extend(similar_user_activities)

    # ✅ Ensure Unique Recommendations
    return list(set(recommended_ids))[:10]


# ✅ Hybrid Recommendation System
def hybrid_recommendation(user_id):
    cbf_recs = content_based_recommendations(user_id)  # Content-Based Filtering

    # ✅ Fix: Accept 3 values instead of 2
    als_model, user_item_matrix, activity_id_mapping = train_als_model()

    cf_recs = collaborative_filtering(user_id, als_model, user_item_matrix, activity_id_mapping) if als_model else []

    recommendation_scores = {}

    # ✅ Assign higher weight to CF results
    for idx, rec in enumerate(cf_recs):
        recommendation_scores[rec] = recommendation_scores.get(rec, 0) + (50 - idx)

    # ✅ Add CBF results with moderate weight
    for idx, rec in enumerate(cbf_recs):
        recommendation_scores[rec] = recommendation_scores.get(rec, 0) + (20 - idx)

    # ✅ Sort recommendations by final score
    sorted_recommendations = sorted(recommendation_scores.items(), key=lambda x: x[1], reverse=True)

    return [{"id": rec[0], "type": "activity"} for rec in sorted_recommendations[:10]]


# ✅ API Endpoint
@app.route("/recommend", methods=["GET"])
def recommend():
    user_id = request.args.get("user_id")
    if not user_id:
        return jsonify({"error": "Missing user_id"}), 400

    user_id = int(user_id)
    
    # ✅ Fix: Accept 3 returned values
    als_model, user_item_matrix, activity_id_mapping = train_als_model()

    cf_recs = collaborative_filtering(user_id, als_model, user_item_matrix, activity_id_mapping)
    print(f"✅ CF Raw Recommendations Before Hybrid: {cf_recs}")

    recommendations = hybrid_recommendation(user_id)

    print(f"✅ Final Recommendations Sent to Frontend: {recommendations}")

    return jsonify({"success": True, "recommendations": recommendations})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001, debug=True) 
