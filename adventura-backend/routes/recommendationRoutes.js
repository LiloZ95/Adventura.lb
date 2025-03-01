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

module.exports = router;
