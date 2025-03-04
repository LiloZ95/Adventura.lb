const express = require("express");
const { authenticateToken } = require("../middleware/auth");
const {
	trackEventInteraction,
	setUserPreferences,
	getRecommendations,
} = require("../controllers/recommendationController");

const router = express.Router();

// ✅ Track event interactions (views, likes, bookings, ratings)
router.post("/track-interaction", authenticateToken, trackEventInteraction);

// ✅ Set user category preferences
router.post("/set-preferences", authenticateToken, setUserPreferences);

// ✅ Get AI-based recommendations for a user
router.get("/recommend", authenticateToken, getRecommendations);

// ✅ Get trending/popular events
router.get("/trending", async (req, res) => {
	try {
		const trendingEvents = await sequelize.query(
			`SELECT e.event_id, e.name, e.category_id, c.name AS category_name, ep.views, ep.likes, ep.bookings, ep.avg_rating
       FROM event_popularity ep
       JOIN event e ON ep.event_id = e.event_id
       JOIN category c ON e.category_id = c.category_id
       ORDER BY ep.likes DESC, ep.bookings DESC, ep.views DESC, ep.avg_rating DESC
       LIMIT 10;`,
			{ type: QueryTypes.SELECT }
		);

		return res.status(200).json({ success: true, trendingEvents });
	} catch (error) {
		console.error("❌ Error fetching trending events:", error);
		return res
			.status(500)
			.json({ error: "Server error fetching trending events." });
	}
});

// ✅ Get user's past interactions
router.get("/user-interactions", authenticateToken, async (req, res) => {
	try {
		const userId = req.user.userId;

		const interactions = await sequelize.query(
			`SELECT event.event_id, event.name, event.category_id, category.name AS category_name, uei.interaction_type, uei.rating, uei.timestamp
       FROM user_event_interaction uei
       JOIN event ON uei.event_id = event.event_id
       JOIN category ON event.category_id = category.category_id
       WHERE uei.user_id = :userId
       ORDER BY uei.timestamp DESC
       LIMIT 20;`,
			{ replacements: { userId }, type: QueryTypes.SELECT }
		);

		return res.status(200).json({ success: true, interactions });
	} catch (error) {
		console.error("❌ Error fetching user interactions:", error);
		return res
			.status(500)
			.json({ error: "Server error fetching interactions." });
	}
});

module.exports = router;
