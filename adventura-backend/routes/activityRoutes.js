const express = require("express");
const router = express.Router();

// Controller Imports
const {
  getAllActivities,
  getActivityById,
  createActivity,
  getActivitiesDetails,
  setPrimaryImage,
  getActivityImages,
} = require("../controllers/activityController");

const {
  getRecommendedActivities,
} = require("../controllers/recommendationController");

// ==============================
// 📍 MAIN ACTIVITY ROUTES
// ==============================

// ✅ GET all activities with images
router.get("/", getAllActivities);

// ✅ GET single activity by ID
router.get("/:id", getActivityById);

// ✅ CREATE a new activity
router.post("/create", createActivity);

// ✅ POST: Get activity details by list of IDs
router.post("/details", getActivitiesDetails);

// ✅ PUT: Set an image as primary
router.put("/set-primary", setPrimaryImage);

// ✅ GET: All images for a specific activity
router.get("/activity-images/:activity_id", getActivityImages);

// ✅ GET: Recommended activities by user ID
router.get("/recommendations/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const recommendedActivities = await getRecommendedActivities(id);

    if (!recommendedActivities || recommendedActivities.length === 0) {
      return res.status(404).json({
        success: false,
        message: "No recommendations found.",
      });
    }

    res.json({ success: true, recommendations: recommendedActivities });
  } catch (error) {
    console.error("❌ Error fetching recommendations:", error);
    res.status(500).json({ success: false, message: "Internal Server Error." });
  }
});

module.exports = router;
