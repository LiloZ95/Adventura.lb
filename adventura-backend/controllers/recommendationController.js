const { sequelize } = require("../db/db.js");
const {
	Activity,
	ActivityImage,
	UserPreferences,
	UserActivityInteraction,
	Event,
	EventImage,
} = require("../models");
const { Op, QueryTypes } = require("sequelize");
const axios = require("axios");
const redis = require("redis");

// ✅ Initialize Redis Client
const redisClient = redis.createClient();
redisClient.on("error", (err) => console.error("Redis Error:", err));

// ✅ Middleware to Cache Recommendations
const cacheMiddleware = async (req, res, next) => {
	const { user_id } = req.query;
	if (!user_id) return res.status(400).json({ error: "Missing user_id" });

	try {
		const cacheData = await redisClient.get(`recommendations:${user_id}`);
		if (cacheData) {
			return res.json(JSON.parse(cacheData));
		}
		next();
	} catch (error) {
		console.error("❌ Redis Cache Error:", error);
		next();
	}
};

// ✅ Track user interactions with activities
const trackEventInteraction = async (req, res) => {
	const { user_id, activity_id, interaction_type, rating } = req.body;

	if (!user_id || !activity_id || !interaction_type) {
		return res.status(400).json({ error: "Missing required fields." });
	}

	try {
		// ✅ Insert or update interaction
		await sequelize.query(
			`INSERT INTO user_activity_interaction (user_id, activity_id, interaction_type, rating) 
             VALUES (:user_id, :activity_id, :interaction_type, :rating) 
             ON CONFLICT (user_id, activity_id, interaction_type) 
             DO UPDATE SET rating = EXCLUDED.rating`,
			{
				replacements: {
					user_id,
					activity_id,
					interaction_type,
					rating: rating || null,
				},
				type: QueryTypes.INSERT,
			}
		);

		// ✅ Fetch the activity's category
		const categoryResult = await Activity.findOne({
			where: { activity_id },
			attributes: ["category_id"],
		});

		if (!categoryResult) {
			return res.status(404).json({ error: "Activity not found" });
		}
		const category_id = categoryResult.category_id;

		// ✅ Update User Preferences
		await sequelize.query(
			`INSERT INTO user_preferences (user_id, category_id, preference_level, interaction_count, last_updated) 
			 VALUES (:user_id, :category_id, 3, 1, NOW()) 
			 ON CONFLICT (user_id, category_id) 
			 DO UPDATE SET 
				 interaction_count = user_preferences.interaction_count + 1,
				 preference_level = 
					 CASE 
						 WHEN user_preferences.interaction_count >= 5 THEN 5
						 WHEN user_preferences.interaction_count >= 3 THEN 4
						 ELSE user_preferences.preference_level
					 END,
				 last_updated = NOW()`,
			{
				replacements: { user_id, category_id },
				type: QueryTypes.INSERT,
			}
		);

		return res.json({
			success: true,
			message: "Interaction recorded and preferences updated.",
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

// ✅ Get recommendations from ML model
const getRecommendations = async (req, res) => {
	const userId = req.query.user_id;

	if (!userId) {
		return res.status(400).json({ error: "Missing user_id" });
	}

	try {
		const response = await axios.get(
			`http://localhost:5001/recommend?user_id=${userId}`
		);

		if (
			!response.data.recommendations ||
			response.data.recommendations.length === 0
		) {
			return res.json({ success: true, activities: [] });
		}

		const activityIds = response.data.recommendations.map((rec) => rec.id);

		// ✅ Fetch full activity details in a single query
		const activities = await Activity.findAll({
			where: { activity_id: activityIds },
			include: [
				{
					model: ActivityImage,
					as: "activity_images",
					attributes: ["image_url"],
				},
			],
		});

		return res.json({ success: true, activities });
	} catch (error) {
		console.error("❌ Error fetching recommendations:", error);
		return res.status(500).json({ error: "Failed to fetch recommendations" });
	}
};

const getClicks = async (req, res) => {
	const { user_id, content_id, content_type } = req.body;

	if (!user_id || !content_id || !content_type) {
		return res.status(400).json({ error: "Missing required fields." });
	}

	try {
		await sequelize.query(
			`INSERT INTO user_clicks (user_id, content_id, content_type, click_count) 
             VALUES (:user_id, :content_id, :content_type, 1) 
             ON CONFLICT (user_id, content_id, content_type) 
             DO UPDATE SET click_count = user_clicks.click_count + 1, last_clicked = NOW()`,
			{
				replacements: { user_id, content_id, content_type },
				type: QueryTypes.INSERT,
			}
		);

		return res.json({
			success: true,
			message: "Click recorded successfully.",
		});
	} catch (error) {
		console.error("❌ Error recording click:", error);
		return res.status(500).json({ error: "Database error." });
	}
};

// ✅ Fetch recommended activities based on user preferences
async function getRecommendedActivities(userId) {
	try {
		if (typeof userId === "object") {
			console.error("⚠️ userId is an object, extracting the value...");
			userId = userId.user_id; // ✅ Extract user_id from the object
		}
		if (!Number.isInteger(userId)) {
			console.error("❌ ERROR: userId is not a valid integer:", userId);
			return [];
		}
		console.log(`🟢 Fetching recommendations for user: ${userId}`);

		// ✅ Debug: Check if Models Are Loaded
		if (!Activity) {
			console.error("❌ ERROR: Activity model is undefined!");
			return [];
		}
		if (!UserPreferences) {
			console.error("❌ ERROR: UserPreferences model is undefined!");
			return [];
		}

		// ✅ Step 1: Fetch User Preferences
		const userPreferences = await UserPreferences.findAll({
			where: { user_id: userId },
			attributes: ["category_id", "preference_level"],
		});

		console.log(`🟢 Found preferences:`, userPreferences);

		let categoryIds = userPreferences.map((pref) => pref.category_id);

		if (categoryIds.length === 0) {
			console.log("⚠️ No preferences found for user", userId);
			return [];
		}

		// ✅ Step 2: Fetch Recommended Activities (Grouped by `activity_id`)
		const recommendedActivitiesRaw = await Activity.findAll({
			where: {
				category_id: categoryIds,
				availability_status: true, // ✅ Only show available activities
			},
			include: [
				{
					model: ActivityImage,
					as: "activity_images",
					attributes: ["image_url"],
				},
			],
			order: [["createdAt", "DESC"]],
			raw: true,
			nest: true,
		});

		// ✅ Step 3: Group Activities to Avoid Duplicates
		let recommendedActivities = {};
		recommendedActivitiesRaw.forEach((activity) => {
			const {
				activity_id,
				name,
				description,
				location,
				price,
				duration,
				availability_status,
				nb_seats,
				category_id,
				createdAt,
				updatedAt,
				activity_images,
			} = activity;

			if (!recommendedActivities[activity_id]) {
				recommendedActivities[activity_id] = {
					activity_id,
					name,
					description,
					location,
					price,
					duration,
					availability_status,
					nb_seats,
					category_id,
					createdAt,
					updatedAt,
					activity_images: [],
				};
			}

			// ✅ Ensure `null` image URLs are not added
			if (activity_images && activity_images.image_url) {
				recommendedActivities[activity_id].activity_images.push(
					activity_images.image_url
				);
			}
		});

		const finalRecommendations = Object.values(recommendedActivities);
		console.log(
			`✅ Sending ${finalRecommendations.length} unique recommended activities for user ${userId}`
		);

		return finalRecommendations;
	} catch (error) {
		console.error("❌ ERROR in getRecommendedActivities:", error);
		return [];
	}
}

module.exports = {
	trackEventInteraction,
	setUserPreferences,
	getRecommendations,
	getRecommendedActivities,
	getClicks,
};
