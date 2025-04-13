const express = require("express");
const router = express.Router();
const { Event, EventImage } = require("../models");

// ✅ Get all events
router.get("/", async (req, res) => {
  try {
    const events = await Event.findAll({
      include: [{ model: EventImage, as: "event_images", attributes: ["image_url"] }],
    });

    res.json({ success: true, events });
  } catch (error) {
    console.error("❌ Error fetching events:", error);
    res.status(500).json({ error: "Database error." });
  }
});

// ✅ Get a single event by ID
router.get("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const event = await Event.findByPk(id, {
      include: [{ model: EventImage, as: "event_images", attributes: ["image_url"] }],
    });

    if (!event) {
      return res.status(404).json({ error: "Event not found." });
    }

    res.json(event);
  } catch (error) {
    console.error("❌ Error fetching event:", error);
    res.status(500).json({ error: "Database error." });
  }
});

module.exports = router;
