import pandas as pd
import numpy as np
import psycopg2
from sqlalchemy import create_engine
from flask import Flask, request, jsonify
from sklearn.metrics.pairwise import cosine_similarity

# ✅ Initialize Flask App
app = Flask(__name__)

# ✅ Database Connection
DATABASE_URL = "postgresql://postgres:1234567890@localhost:5432/Adventura"
engine = create_engine(DATABASE_URL)

# ✅ Fetch User Preferences
def get_user_preferences(user_id):
    query = "SELECT category_id, preference_level FROM user_preferences WHERE user_id = %(user_id)s"
    df = pd.read_sql(query, engine, params={"user_id": user_id})
    return df

# ✅ Fetch Event Interactions
def get_user_interactions():
    query = """SELECT user_id, event_id, interaction_type, rating FROM user_event_interaction"""
    df = pd.read_sql(query, engine)
    
    print("🔍 Raw Interaction Data:\n", df)  # Debugging
    return df

# ✅ Fetch Most Popular Events (Fallback)
def get_popular_events():
    query = "SELECT event_id FROM event ORDER BY RANDOM() LIMIT 10"
    df = pd.read_sql(query, engine)
    return df["event_id"].tolist() if not df.empty else []

# ✅ Content-Based Filtering (CBF)
def content_based_recommendations(user_id):
    preferences = get_user_preferences(user_id)
    if preferences.empty:
        return get_popular_events()  # Fallback

    query = "SELECT event_id, category_id FROM event"
    events = pd.read_sql(query, engine)

    # Merge events with preferences
    merged = events.merge(preferences, on="category_id", how="left").fillna(0)
    merged["score"] = merged["preference_level"]

    # Sort by highest preference level
    recommendations = merged.sort_values("score", ascending=False)["event_id"].tolist()
    return recommendations[:10]

# ✅ Collaborative Filtering (CF)
def collaborative_filtering(user_id):
    interactions = get_user_interactions()
    
    if interactions.empty:
        return []

    # Create user-event matrix with ratings (not just likes)
    user_event_matrix = interactions.pivot_table(index="user_id", columns="event_id", values="rating").fillna(0)
    
    if user_id not in user_event_matrix.index:
        return []  # If user has no interactions, return empty list

    # Compute cosine similarity between users
    similarity = cosine_similarity(user_event_matrix)
    user_index = list(user_event_matrix.index).index(user_id)
    similar_users = similarity[user_index]

    # Find similar users (excluding the user itself)
    top_users = np.argsort(similar_users)[::-1][1:6]  
    similar_user_ids = [user_event_matrix.index[i] for i in top_users]

    # Get events liked by similar users, prioritize events with **higher ratings**
    recommended_events = interactions[
        interactions["user_id"].isin(similar_user_ids) & (interactions["rating"] >= 4)
    ]["event_id"].unique().tolist()

    return recommended_events[:10]  # Return top 10


# ✅ Hybrid Recommendation System
def hybrid_recommendation(user_id):
    cbf_recs = content_based_recommendations(user_id)  # Content-Based Filtering results
    cf_recs = collaborative_filtering(user_id)  # Collaborative Filtering results
    
    # Assigning weights: Events in both lists get the highest priority
    event_scores = {}

    for event in cbf_recs:
        event_scores[event] = event_scores.get(event, 0) + 1  # Score 1 for CBF
    
    for event in cf_recs:
        event_scores[event] = event_scores.get(event, 0) + 2  # Score 2 for CF (higher priority)

    # Sort events by score in descending order (higher score = more priority)
    sorted_events = sorted(event_scores.keys(), key=lambda e: event_scores[e], reverse=True)

    return sorted_events[:10]  # Return top 10 recommendations


# ✅ API Endpoint
@app.route("/recommend", methods=["GET"])
def recommend():
    user_id = request.args.get("user_id")
    if not user_id:
        return jsonify({"error": "Missing user_id"}), 400

    user_id = int(user_id)
    recommendations = hybrid_recommendation(user_id)

    return jsonify({"success": True, "recommendations": recommendations})

if __name__ == "__main__":
    app.run(port=5001, debug=True)
