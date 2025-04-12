const { Activity, ActivityImage } = require("../models");
const { Op, Sequelize, QueryTypes } = require("sequelize");
const { sequelize } = require("../db/db");
const TripPlan = require("../models/TripPlan");
const Feature = require("../models/Feature");

// Utility to extract latitude & longitude from Google Maps URL
function extractLatLonFromUrl(googleMapsUrl) {
	const regex = /@?(-?\d+\.\d+),\s*(-?\d+\.\d+)/;
	const match = googleMapsUrl.match(regex);
	if (match) {
		return { latitude: parseFloat(match[1]), longitude: parseFloat(match[2]) };
	}
	return null;
}

function isValid12HourTime(time) {
	return /^(0?[1-9]|1[0-2]):[0-5][0-9] (AM|PM)$/i.test(time);
}

// 🟢 Create new activity
// POST /activities/create
const createActivity = async (req, res) => {
	const t = await Activity.sequelize.transaction();

	try {
		const {
			name,
			description,
			location,
			price,
			availability_status,
			nb_seats,
			category_id,
			latitude,
			longitude,
			trip_plan,
			features,
			from_time,
			to_time,
			listing_type,
		} = req.body;

		console.log("🧠 [createActivity] req.user:", req.user);

		const provider_id = req.user?.provider_id;
		const validTypes = ["recurrent", "oneTime"];

		console.log("🧠 [createActivity] provider_id:", provider_id);

		if (!provider_id) {
			return res.status(403).json({
				success: false,
				message: "Only providers are allowed to create activities.",
			});
		}

		if (!validTypes.includes(listing_type)) {
			throw new Error("Invalid listing_type. Must be 'recurrent' or 'oneTime'");
		}

		if (!isValid12HourTime(from_time) || !isValid12HourTime(to_time)) {
			throw new Error("Invalid time format. Use HH:00 AM/PM");
		}

		const newActivity = await Activity.create(
			{
				name,
				description,
				location,
				price,
				availability_status: availability_status ?? true,
				nb_seats,
				category_id,
				latitude,
				longitude,
				from_time,
				to_time,
				provider_id,
				listing_type,
			},
			{ transaction: t }
		);

		// 🧠 Save trip plans (MUST BE valid array)
		if (trip_plan && Array.isArray(trip_plan)) {
			const validPlans = trip_plan.filter(
				(plan) => plan.time && plan.description
			);

			if (validPlans.length > 0) {
				const tripPlanData = validPlans.map((plan) => ({
					activity_id: newActivity.activity_id,
					time: plan.time,
					description: plan.description,
				}));
				console.log("🧪 tripPlanData:", tripPlanData);
				await TripPlan.bulkCreate(tripPlanData, { transaction: t });
			} else {
				throw new Error("Trip plans are missing time or description.");
			}
		}

		// ✅ Save Features
		if (features && Array.isArray(features)) {
			const cleanFeatures = features
				.map((f) => f?.toString()?.trim())
				.filter((f) => f && f.length > 0);

			if (cleanFeatures.length > 0) {
				const featureData = cleanFeatures.map((name) => ({
					activity_id: newActivity.activity_id,
					name,
				}));
				await Feature.bulkCreate(featureData, { transaction: t });
			}
		}
		console.log("📦 Received listing_type:", listing_type);

		await t.commit();

		res.status(201).json({
			success: true,
			message: "Activity created successfully",
			activity: newActivity,
		});
	} catch (error) {
		await t.rollback();
		console.error("❌ Error creating activity with trip plans:", error);
		res.status(500).json({
			success: false,
			message: error.message || "Failed to create activity.",
		});
	}
};

// 🟢 Get all activities
const getAllActivities = async (req, res) => {
	try {
		const { search, category, location, min_price, max_price, rating } =
			req.query;

		const where = {};

		if (category) {
			where.category_id = parseInt(category);
		}

		if (search) {
			where.name = { [Op.iLike]: `%${search}%` };
		}

		if (location) {
			where.location = { [Op.iLike]: `%${location}%` };
		}

		if (min_price) {
			where.price = { [Op.gte]: parseFloat(min_price) };
		}

		if (max_price) {
			where.price = {
				...(where.price || {}),
				[Op.lte]: parseFloat(max_price),
			};
		}

		if (rating) {
			where.rating = { [Op.gte]: parseFloat(rating) }; // only if you have a rating column!
		}

		where.availability_status = true;

		if (req.query.type) {
			where.listing_type = req.query.type === "event" ? "oneTime" : "recurrent";
		}

		const activities = await Activity.findAll({
			where,
			attributes: [
				"activity_id", "name", "description", "location", "price", "availability_status",
				"nb_seats", "category_id", "latitude", "longitude",
				"from_time", "to_time", "provider_id", "listing_type", "event_date",
				"createdAt", "updatedAt"
			  ],
			include: [
				{
					model: ActivityImage,
					as: "activity_images",
					attributes: ["image_url"],
				},
				{
					model: TripPlan,
					as: "trip_plans",
					separate: true,
					order: [["time", "ASC"]],
				},
				{ model: Feature, as: "features" },
			],
		});

		return res.status(200).json({ success: true, activities });
	} catch (error) {
		console.error("❌ Error fetching activities:", error);
		return res.status(500).json({ success: false, message: "Server error." });
	}
};

// 🟢 Get activity by ID
const getActivityById = async (req, res) => {
	try {
		const { id } = req.params;

		const activity = await Activity.findByPk(id, {
			include: [
				{ model: ActivityImage, as: "activity_images" },
				{
					model: TripPlan,
					as: "trip_plans",
					separate: true,
					order: [["time", "ASC"]],
				},
				{ model: Feature, as: "features" },
			],
		});

		if (!activity) {
			return res
				.status(404)
				.json({ success: false, message: "Activity not found." });
		}

		return res.json({ success: true, activity });
	} catch (error) {
		console.error("❌ Error fetching activity:", error);
		return res.status(500).json({ success: false, message: "Server error." });
	}
};

// 🟢 Get details of multiple activities (by array of IDs)
const getActivitiesDetails = async (req, res) => {
	try {
		const { activity_ids } = req.body;

		if (!Array.isArray(activity_ids) || activity_ids.length === 0) {
			return res
				.status(400)
				.json({ success: false, message: "Invalid activity ID list." });
		}

		const activities = await Activity.findAll({
			where: { activity_id: activity_ids },
			include: [
				{
					model: ActivityImage,
					as: "activity_images",
					attributes: ["image_url", "is_primary"],
				},
				{
					model: TripPlan,
					as: "trip_plans",
					separate: true,
					order: [["time", "ASC"]],
				},
				{ model: Feature, as: "features" },
			],
			order: [
				Sequelize.literal(
					`array_position(array[${activity_ids.join(
						","
					)}], "activities"."activity_id")`
				),
			],
		});

		return res.json({ success: true, activities });
	} catch (error) {
		console.error("❌ Error fetching activity details:", error);
		return res.status(500).json({ success: false, message: "Server error." });
	}
};

const uploadImages = async (req, res) => {
	const { activityId } = req.params;
	const files = req.files;

	if (!files || files.length === 0) {
		return res.status(400).json({ message: "No images uploaded" });
	}

	try {
		const createdImages = await Promise.all(
			files.map((file) =>
				ActivityImage.create({
					activity_id: activityId,
					image_url: `/uploads/${file.filename}`,
					createdAt: new Date(),
					updatedAt: new Date(),
					is_primary: false,
				})
			)
		);
		res.status(200).json(createdImages);
	} catch (error) {
		console.error(error);
		res.status(500).json({ message: "Error uploading images" });
	}
};

// 🟢 Set primary image for an activity
const setPrimaryImage = async (req, res) => {
	try {
		const { activity_id, image_id } = req.body;

		if (!activity_id || !image_id) {
			return res
				.status(400)
				.json({ success: false, message: "Missing activity_id or image_id." });
		}

		// Remove is_primary from current
		await ActivityImage.update(
			{ is_primary: false },
			{ where: { activity_id } }
		);

		// Set new primary image
		const updatedImage = await ActivityImage.update(
			{ is_primary: true },
			{ where: { image_id } }
		);

		if (updatedImage[0] === 0) {
			return res
				.status(404)
				.json({ success: false, message: "Image not found." });
		}

		return res.json({ success: true, message: "Primary image updated." });
	} catch (error) {
		console.error("❌ Error setting primary image:", error);
		return res.status(500).json({ success: false, message: "Server error." });
	}
};

// 🟢 Get activity images only
const getActivityImages = async (req, res) => {
	try {
		const { activity_id } = req.params;

		const images = await sequelize.query(
			`SELECT image_url FROM activity_images WHERE activity_id = :activity_id`,
			{ replacements: { activity_id }, type: QueryTypes.SELECT }
		);

		return res.status(200).json({ success: true, images });
	} catch (error) {
		console.error("❌ Error fetching activity images:", error);
		return res.status(500).json({ success: false, message: "Server error." });
	}
};

// 🟢 Get all activities by provider_id
const getActivitiesByProvider = async (req, res) => {
	try {
		const { provider_id } = req.params;

		if (!provider_id) {
			return res
				.status(400)
				.json({ success: false, message: "Missing provider_id." });
		}

		const activities = await Activity.findAll({
			where: {
				provider_id,
				availability_status: true, // ✅ hide soft-deleted listings
			},
			include: [
				{
					model: ActivityImage,
					as: "activity_images",
					attributes: ["image_url", "is_primary"],
				},
				{ model: TripPlan, as: "trip_plans" },
				{
					model: Feature, // Your join model
					as: "features", // This must match your alias
					attributes: ["name"],
				},
			],
			order: [["createdAt", "DESC"]], // Optional: order newest first
		});

		return res.status(200).json({ success: true, activities });
	} catch (error) {
		console.error("❌ Error fetching provider activities:", error);
		return res.status(500).json({ success: false, message: "Server error." });
	}
};

const softDeleteActivity = async (req, res) => {
	try {
		const { id } = req.params;

		const activity = await Activity.findByPk(id);
		if (!activity) {
			return res
				.status(404)
				.json({ success: false, message: "Activity not found." });
		}

		await activity.update({ availability_status: false });

		return res
			.status(200)
			.json({ success: true, message: "Activity soft-deleted (hidden)." });
	} catch (error) {
		console.error("❌ Error soft-deleting activity:", error);
		return res.status(500).json({ success: false, message: "Server error." });
	}
};

async function deactivatePastEvents() {
	// try {
	// 	const now = new Date();

	// 	const expiredEvents = await Activity.update(
	// 		{ availability_status: false },
	// 		{
	// 			where: {
	// 				listing_type: "oneTime",
	// 				to_time: { [Op.lt]: now },
	// 				availability_status: true,
	// 			},
	// 		}
	// 	);

	// 	console.log(`🕒 Deactivated ${expiredEvents[0]} expired one-time events`);
	// } catch (error) {
	// 	console.error("❌ Error deactivating past events:", error);
	// }
}

const getExpiredActivitiesByProvider = async (req, res) => {
	try {
		const { provider_id } = req.params;

		if (!provider_id) {
			return res
				.status(400)
				.json({ success: false, message: "Missing provider_id." });
		}

		const activities = await Activity.findAll({
			where: {
				provider_id,
				availability_status: false,
			},
			include: [
				{
					model: ActivityImage,
					as: "activity_images",
					attributes: ["image_url", "is_primary"],
				},
				{ model: TripPlan, as: "trip_plans" },
				{ model: Feature, as: "features" },
			],
			order: [["to_time", "DESC"]],
		});

		return res.status(200).json({ success: true, activities });
	} catch (error) {
		console.error("❌ Error fetching expired activities:", error);
		return res.status(500).json({ success: false, message: "Server error." });
	}
};

const getAllEvents = async (req, res) => {
	try {
	  const { search, category, location, min_price, max_price } = req.query;
	  const where = {
		listing_type: 'one_time', // 🎯 fetch events only
	  };
  
	  if (category) where.category_id = parseInt(category);
	  if (search) where.name = { [Op.iLike]: `%${search}%` };
	  if (location) where.location = { [Op.iLike]: `%${location}%` };
	  if (min_price) where.price = { [Op.gte]: parseFloat(min_price) };
	  if (max_price) {
		where.price = {
		  ...(where.price || {}),
		  [Op.lte]: parseFloat(max_price),
		};
	  }
  
	  const events = await Activity.findAll({
		where,
		include: [
		  {
			model: ActivityImage,
			as: "activity_images",
			attributes: ["image_url"],
		  },
		],
	  });
  
	  res.status(200).json({ events }); // ⚠️ important: wrap in `events` for frontend
	} catch (error) {
	  console.error("❌ Error fetching events:", error);
	  res.status(500).json({ error: "Server error." });
	}
  };
  
module.exports = {
	createActivity,
	getAllActivities,
	getActivityById,
	getActivitiesDetails,
	setPrimaryImage,
	getActivityImages,
	uploadImages,
	getActivitiesByProvider,
	softDeleteActivity,
	deactivatePastEvents,
	getExpiredActivitiesByProvider,
	getAllEvents
};
