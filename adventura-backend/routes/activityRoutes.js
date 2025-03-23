const express = require("express");
const router = express.Router();
const {
  createActivity,
  getAllActivities,
  getActivityById,
  getActivitiesDetails,
  setPrimaryImage,
  getActivityImages,
} = require("../controllers/activityController");

const { getRecommendedActivities } = require("../controllers/recommendationController");

// 📍 GET all activities with images
router.get("/", getAllActivities);

// 📍 CREATE activity (with lat/lon extracted)
router.post("/create", createActivity);

// 📍 GET single activity by ID
router.get("/:id", getActivityById);

// 📍 POST - fetch multiple activities by array of IDs
router.post("/details", getActivitiesDetails);

// 📍 PUT - set an image as primary
router.put("/set-primary", setPrimaryImage);

// 📍 GET - recommended activities
router.get("/recommendations/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const recommendedActivities = await getRecommendedActivities(id);

    if (!recommendedActivities || recommendedActivities.length === 0) {
      return res.status(404).json({ success: false, message: "No recommendations found." });
    }

    res.json({ success: true, recommendations: recommendedActivities });
  } catch (error) {
    console.error("❌ Error fetching recommendations:", error);
    res.status(500).json({ success: false, message: "Internal Server Error." });
  }
});

// 📍 GET - images for a specific activity
router.get("/activity-images/:activity_id", getActivityImages);

module.exports = router;
