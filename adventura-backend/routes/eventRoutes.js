const express = require("express");
const router = express.Router();
const { getAllActivities } = require("../controllers/activityController");

// ✅ This will act as your "events" endpoint by filtering one-time activities
router.get("/", (req, res) => {
  req.query.type = "event"; // Force event filtering
  return getAllActivities(req, res);
});

module.exports = router;