const { Event, EventImage } = require("../models");
const { Op, Sequelize, QueryTypes } = require("sequelize");
const { sequelize } = require("../db/db");

// 🟢 Create a new Event
const createEvent = async (req, res) => {
  try {
    const {
      name,
      description,
      location,
      price,
      category_id,
      event_date,
      nb_seats,
    } = req.body;

    if (!name || !event_date) {
      return res.status(400).json({ success: false, message: "Name and event_date are required." });
    }

    const newEvent = await Event.create({
      name,
      description,
      location,
      price,
      category_id,
      event_date,
      nb_seats,
    });

    return res.status(201).json({ success: true, event: newEvent });
  } catch (error) {
    console.error("❌ Error creating event:", error);
    return res.status(500).json({ success: false, message: "Server error." });
  }
};

// 🟢 Get all Events (with optional filters)
const getAllEvents = async (req, res) => {
  try {
    const { search, category, location, min_price, max_price } = req.query;
    const where = {};

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

    const events = await Event.findAll({
      where,
      include: [
        {
          model: EventImage,
          as: "event_images",
          attributes: ["image_url"],
        },
      ],
    });

    return res.status(200).json({ success: true, events });
  } catch (error) {
    console.error("❌ Error fetching events:", error);
    return res.status(500).json({ success: false, message: "Server error." });
  }
};

// 🟢 Get event by ID
const getEventById = async (req, res) => {
  try {
    const { id } = req.params;

    const event = await Event.findByPk(id, {
      include: [{ model: EventImage, as: "event_images" }],
    });

    if (!event) {
      return res.status(404).json({ success: false, message: "Event not found." });
    }

    return res.status(200).json({ success: true, event });
  } catch (error) {
    console.error("❌ Error fetching event:", error);
    return res.status(500).json({ success: false, message: "Server error." });
  }
};

// 🟢 Get details for multiple events
const getEventsDetails = async (req, res) => {
  try {
    const { event_ids } = req.body;

    if (!Array.isArray(event_ids) || event_ids.length === 0) {
      return res.status(400).json({ success: false, message: "Invalid event ID list." });
    }

    const events = await Event.findAll({
      where: { event_id: event_ids },
      include: [
        {
          model: EventImage,
          as: "event_images",
          attributes: ["image_url"],
        },
      ],
      order: [
        Sequelize.literal(`array_position(array[${event_ids.join(",")}], "Event"."event_id")`)
      ]
    });

    return res.json({ success: true, events });
  } catch (error) {
    console.error("❌ Error fetching event details:", error);
    return res.status(500).json({ success: false, message: "Server error." });
  }
};

// 🟢 Upload Event Images
const uploadEventImages = async (req, res) => {
  const { eventId } = req.params;
  const files = req.files;

  if (!files || files.length === 0) {
    return res.status(400).json({ message: "No images uploaded" });
  }

  try {
    const createdImages = await Promise.all(
      files.map((file) =>
        EventImage.create({
          event_id: eventId,
          image_url: `/uploads/${file.filename}`,
          createdAt: new Date(),
          updatedAt: new Date(),
        })
      )
    );
    res.status(200).json(createdImages);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Error uploading images" });
  }
};

// 🟢 Get Event Images by Event ID
const getEventImages = async (req, res) => {
  try {
    const { event_id } = req.params;

    const images = await sequelize.query(
      `SELECT image_url FROM "EventImages" WHERE event_id = :event_id`,
      { replacements: { event_id }, type: QueryTypes.SELECT }
    );

    return res.status(200).json({ success: true, images });
  } catch (error) {
    console.error("❌ Error fetching event images:", error);
    return res.status(500).json({ success: false, message: "Server error." });
  }
};

module.exports = {
  createEvent,
  getAllEvents,
  getEventById,
  getEventsDetails,
  uploadEventImages,
  getEventImages,
};
