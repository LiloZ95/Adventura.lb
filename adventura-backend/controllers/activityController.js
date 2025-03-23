const { Activity, ActivityImage } = require("../models");
const { Op, Sequelize, QueryTypes } = require("sequelize");
const { sequelize } = require("../db/db");

// Utility to extract latitude & longitude from Google Maps URL
function extractLatLonFromUrl(googleMapsUrl) {
    const regex = /@?(-?\d+\.\d+),\s*(-?\d+\.\d+)/;
    const match = googleMapsUrl.match(regex);
    if (match) {
        return { latitude: parseFloat(match[1]), longitude: parseFloat(match[2]) };
    }
    return null;
}

// 🟢 Create new activity
const createActivity = async (req, res) => {
    try {
        const { name, description, location, price, duration, nb_seats, category_id, maps_url } = req.body;

        if (!name || !maps_url) {
            return res.status(400).json({ success: false, message: "Name and maps_url are required." });
        }

        const latLon = extractLatLonFromUrl(maps_url);

        const activity = await Activity.create({
            name,
            description,
            location,
            price,
            duration,
            nb_seats,
            category_id,
            maps_url,
            latitude: latLon?.latitude || null,
            longitude: latLon?.longitude || null,
        });

        return res.status(201).json({ success: true, activity });
    } catch (error) {
        console.error("❌ Error creating activity:", error);
        return res.status(500).json({ success: false, message: "Server error." });
    }
};

// 🟢 Get all activities
const getAllActivities = async (req, res) => {
    try {
        const activities = await Activity.findAll({
            include: [{ model: ActivityImage, as: "activity_images" }],
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
            include: [{ model: ActivityImage, as: "activity_images" }],
        });

        if (!activity) {
            return res.status(404).json({ success: false, message: "Activity not found." });
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
            return res.status(400).json({ success: false, message: "Invalid activity ID list." });
        }

        const activities = await Activity.findAll({
            where: { activity_id: activity_ids },
            include: [
                {
                    model: ActivityImage,
                    as: "activity_images",
                    attributes: ["image_url", "is_primary"],
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

        return res.json({ success: true, activities });
    } catch (error) {
        console.error("❌ Error fetching activity details:", error);
        return res.status(500).json({ success: false, message: "Server error." });
    }
};

// 🟢 Set primary image for an activity
const setPrimaryImage = async (req, res) => {
    try {
        const { activity_id, image_id } = req.body;

        if (!activity_id || !image_id) {
            return res.status(400).json({ success: false, message: "Missing activity_id or image_id." });
        }

        // Remove is_primary from current
        await ActivityImage.update({ is_primary: false }, { where: { activity_id } });

        // Set new primary image
        const updatedImage = await ActivityImage.update({ is_primary: true }, { where: { image_id } });

        if (updatedImage[0] === 0) {
            return res.status(404).json({ success: false, message: "Image not found." });
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

module.exports = {
    createActivity,
    getAllActivities,
    getActivityById,
    getActivitiesDetails,
    setPrimaryImage,
    getActivityImages,
};
