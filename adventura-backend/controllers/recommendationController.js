const { sequelize } = require("../db/db.js");
const { QueryTypes } = require("sequelize");
const axios = require("axios");

// ✅ Track user interactions with events
const trackEventInteraction = async (req, res) => {
	const { user_id, event_id, interaction_type, rating } = req.body;

	if (!user_id || !event_id || !interaction_type) {
		return res.status(400).json({ error: "Missing required fields." });
	}

	try {
		await sequelize.query(
			`INSERT INTO user_event_interaction (user_id, event_id, interaction_type, rating, timestamp) 
             VALUES (:user_id, :event_id, :interaction_type, :rating, NOW()) 
             ON CONFLICT (user_id, event_id, interaction_type) 
             DO UPDATE SET rating = COALESCE(EXCLUDED.rating, user_event_interaction.rating), 
                            timestamp = NOW()`,
			{
				replacements: {
					user_id,
					event_id,
					interaction_type,
					rating: rating || null, // Default to NULL if not provided
				},
				type: QueryTypes.INSERT,
			}
		);

		return res.json({
			success: true,
			message: "Interaction recorded successfully.",
		});
	} catch (error) {
		console.error("❌ Error recording interaction:", error);
		return res.status(500).json({ error: "Database error." });
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

		await sequelize.query(
			`DELETE FROM user_preferences WHERE user_id = :user_id`,
			{
				replacements: { user_id },
				type: QueryTypes.DELETE,
			}
		);

		for (let preference of preferences) {
			await sequelize.query(
				`INSERT INTO user_preferences (user_id, category_id, preference_level)
                 VALUES (:user_id, :category_id, :preference_level)`,
				{
					replacements: {
						user_id,
						category_id: preference.category_id,
						preference_level: preference.preference_level,
					},
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

		// Call the Python ML API
		const response = await axios.get(
			`http://localhost:5001/recommend?user_id=${userId}`
		);

		return res.status(200).json(response.data);
	} catch (error) {
		console.error("❌ Error fetching recommendations:", error);
		return res.status(500).json({ error: "Failed to get recommendations." });
	}
};

module.exports = {
	trackEventInteraction,
	setUserPreferences,
	getRecommendations,
};
