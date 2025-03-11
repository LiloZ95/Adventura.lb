const express = require("express");
const router = express.Router();
const {
	getRecommendedActivities,
} = require("../controllers/recommendationController");
const { Activity, ActivityImage } = require("../models");
const { Sequelize } = require("sequelize");

const BASE_URL = "http://localhost:3000"; // Change if using a different backend URL

// ✅ Get all activities with images
router.get("/", async (req, res) => {
	try {
		const activities = await Activity.findAll({
			include: [
				{
					model: ActivityImage,
					as: "activity_images",
					attributes: [
						[Sequelize.cast(Sequelize.col("image_url"), "TEXT"), "image_url"],
					],
				},
			],
		});

		// ✅ Ensure images use absolute URLs
		const formattedActivities = activities.map((activity) => {
			const plainActivity = activity.get({ plain: true });

			return {
				...plainActivity,
				activity_images: plainActivity.activity_images.map((img) => ({
					image_url: img.image_url.startsWith("http")
						? img.image_url
						: `${BASE_URL}${img.image_url}`, // ✅ Convert to absolute URL
				})),
			};
		});

		console.log(
			"✅ Sending activities:",
			JSON.stringify(formattedActivities, null, 2)
		);
		res.json({ success: true, activities: formattedActivities });
	} catch (error) {
		console.error("❌ Error fetching activities:", error);
		res.status(500).json({ error: "Database error." });
	}
});

// ✅ Get single activity by ID with images
router.get("/:id", async (req, res) => {
	try {
		const { id } = req.params;
		const activity = await Activity.findByPk(id, {
			include: [
				{
					model: ActivityImage,
					as: "activity_images",
					attributes: ["image_url"],
				},
			],
		});

		if (!activity) {
			return res.status(404).json({ error: "Activity not found." });
		}

		res.json(activity);
	} catch (error) {
		console.error("❌ Error fetching activity:", error);
		res.status(500).json({ error: "Database error." });
	}
});

// ✅ Fetch All Activities with Images
router.get("/activities", async (req, res) => {
	try {
		const activities = await Activity.findAll({
			include: [
				{
					model: ActivityImage,
					as: "activity_images",
					attributes: [
						[Sequelize.cast(Sequelize.col("image_url"), "TEXT"), "image_url"],
					],
				},
			],
		});

		// ✅ Ensure `activity_images` is always an array
		const formattedActivities = activities.map((activity) => {
			const plainActivity = activity.get({ plain: true });

			return {
				...plainActivity,
				activity_images: plainActivity.activity_images
					? plainActivity.activity_images.map((img) => ({
							image_url: img.image_url.startsWith("http")
								? img.image_url
								: `${BASE_URL}${img.image_url}`,
					  }))
					: [],
			};
		});

		res.json({ success: true, activities: formattedActivities });
	} catch (error) {
		console.error("Error fetching activities:", error);
		res.status(500).json({ error: "Database error." });
	}
});

// ✅ Set an Image as Primary
router.put("/set-primary", async (req, res) => {
	try {
		const { activity_id, image_id } = req.body;

		if (!activity_id || !image_id) {
			return res
				.status(400)
				.json({ error: "Missing activity_id or image_id." });
		}

		// 🔥 Remove `is_primary` from any existing primary image for this activity
		await ActivityImage.update(
			{ is_primary: false },
			{ where: { activity_id } }
		);

		// ✅ Set the selected image as primary
		const updatedImage = await ActivityImage.update(
			{ is_primary: true },
			{ where: { image_id } }
		);

		if (updatedImage[0] === 0) {
			return res.status(404).json({ error: "Image not found." });
		}

		res.json({ success: true, message: "Primary image updated." });
	} catch (error) {
		console.error("❌ Error setting primary image:", error);
		res.status(500).json({ error: "Internal server error" });
	}
});

router.post("/details", async (req, res) => {
	try {
		const { activity_ids } = req.body;

		if (!Array.isArray(activity_ids) || activity_ids.length === 0) {
			return res.status(400).json({ error: "Invalid activity ID list." });
		}

		const activities = await Activity.findAll({
			where: { activity_id: activity_ids },
			include: [
				{
					model: ActivityImage,
					as: "activity_images",
					attributes: ["image_url", "is_primary"],
					order: [
						["is_primary", "DESC"],
						["image_id", "ASC"],
					], // 🔥 Primary first, then oldest
				},
			],
			order: [
				Sequelize.literal(
					`array_position(array[${activity_ids.join(
						","
					)}], "activities"."activity_id")`
				),
			],
		});

		res.json({ activities });
	} catch (error) {
		console.error("Error fetching activity details:", error);
		res.status(500).json({ error: "Internal server error" });
	}
});

router.get("/recommendations/:id", async (req, res) => {
	try {
		const { id } = req.params;
		const recommendedActivities = await getRecommendedActivities(id);

		if (!recommendedActivities || recommendedActivities.length === 0) {
			return res.status(404).json({ error: "No recommendations found." });
		}

		res.json({ success: true, recommendations: recommendedActivities });
	} catch (error) {
		console.error("❌ Error fetching recommendations:", error);
		res.status(500).json({ error: "Internal Server Error." });
	}
});

// Fetch images for an activity
router.get("/activity-images/:activity_id", async (req, res) => {
	const { activity_id } = req.params;

	try {
		const images = await sequelize.query(
			`SELECT image_url FROM activity_images WHERE activity_id = :activity_id`,
			{ replacements: { activity_id }, type: QueryTypes.SELECT }
		);

		// ✅ Convert relative paths to full URLs
		const formattedImages = images.map((img) => ({
			image_url: `${BASE_URL}${img.image_url}`,
		}));

		return res.status(200).json({ success: true, images: formattedImages });
	} catch (error) {
		console.error("❌ Error fetching activity images:", error);
		return res
			.status(500)
			.json({ error: "Database error while retrieving images." });
	}
});

module.exports = router;
