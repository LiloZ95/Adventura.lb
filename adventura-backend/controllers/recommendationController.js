const { sequelize } = require("../db/db.js");
const { QueryTypes } = require("sequelize");

// ✅ Track user interactions with events
const trackEventInteraction = async (req, res) => {
  try {
    const { event_id, interaction_type, rating } = req.body;
    const user_id = req.user.userId; // Extracted from JWT token

    if (!event_id || !interaction_type) {
      return res.status(400).json({ error: "Missing required parameters." });
    }

    await sequelize.query(
      `INSERT INTO user_event_interaction (user_id, event_id, interaction_type, rating)
      VALUES (:user_id, :event_id, :interaction_type, :rating)`,
      {
        replacements: { user_id, event_id, interaction_type, rating },
        type: QueryTypes.INSERT,
      }
    );

    console.log(`✅ Interaction logged: ${interaction_type} on event ${event_id} by user ${user_id}`);

    res.status(201).json({ message: "Interaction recorded successfully." });
  } catch (error) {
    console.error("❌ Error logging interaction:", error);
    res.status(500).json({ error: "Server error" });
  }
};

// ✅ Save user category preferences
const setUserPreferences = async (req, res) => {
  try {
    const { preferences } = req.body;
    const user_id = req.user.userId;

    if (!preferences || !Array.isArray(preferences)) {
      return res.status(400).json({ error: "Invalid preferences format." });
    }

    await sequelize.query(`DELETE FROM user_preferences WHERE user_id = :user_id`, {
      replacements: { user_id },
      type: QueryTypes.DELETE,
    });

    for (let preference of preferences) {
      await sequelize.query(
        `INSERT INTO user_preferences (user_id, category_id, preference_level)
        VALUES (:user_id, :category_id, :preference_level)`,
        {
          replacements: { user_id, category_id: preference.category_id, preference_level: preference.preference_level },
          type: QueryTypes.INSERT,
        }
      );
    }

    console.log(`✅ User preferences updated for user ${user_id}`);

    res.status(201).json({ message: "Preferences saved successfully." });
  } catch (error) {
    console.error("❌ Error saving preferences:", error);
    res.status(500).json({ error: "Server error" });
  }
};

// ✅ Get event recommendations based on AI
const getRecommendations = async (req, res) => {
  try {
    const user_id = req.user.userId;

    // 🛠 Call AI Model (To be implemented in Python)
    const recommendations = await fetchRecommendationsFromAI(user_id);

    res.status(200).json({ recommendations });
  } catch (error) {
    console.error("❌ Error fetching recommendations:", error);
    res.status(500).json({ error: "Server error" });
  }
};

// 🛠 Placeholder function for AI-based recommendations
const fetchRecommendationsFromAI = async (user_id) => {
  // 🔹 This should call the Python ML model
  console.log(`🔍 Fetching AI recommendations for user ${user_id}...`);
  return [
    { event_id: 5, name: "Music Festival", category: "Music", score: 0.92 },
    { event_id: 12, name: "Tech Conference", category: "Technology", score: 0.88 },
  ];
};

module.exports = {
  trackEventInteraction,
  setUserPreferences,
  getRecommendations,
};
