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
    const userId = req.user.userId;

    // Get user preferences from user_preferences table
    const userPreferences = await sequelize.query(
      `SELECT category_id, preference_level FROM user_preferences WHERE user_id = :userId`,
      { replacements: { userId }, type: QueryTypes.SELECT }
    );

    if (userPreferences.length === 0) {
      return res.status(200).json({ recommendations: [], message: "No preferences found." });
    }

    // Fetch recommended events based on user preferences
    const recommendedEvents = await sequelize.query(
      `SELECT event.event_id, event.name, event.category_id, category.name AS category_name
       FROM event
       JOIN category ON event.category_id = category.category_id
       WHERE event.category_id IN (:categoryIds)
       ORDER BY RANDOM() LIMIT 10;`,
      {
        replacements: { categoryIds: userPreferences.map(p => p.category_id) },
        type: QueryTypes.SELECT,
      }
    );

    res.status(200).json({ recommendations: recommendedEvents });
  } catch (error) {
    console.error("❌ Error fetching recommendations:", error);
    res.status(500).json({ error: "Server error fetching recommendations." });
  }
};

module.exports = {
  trackEventInteraction,
  setUserPreferences,
  getRecommendations,
};
