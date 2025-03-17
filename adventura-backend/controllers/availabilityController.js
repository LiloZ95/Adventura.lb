// availabilityController.js
const Availability = require('../models/Availability');

exports.getAvailableSlots = async (req, res) => {
  const { activityId, date } = req.query;

  try {
    const slots = await Availability.findAll({
      where: {
        activity_id: activityId,
        date: date,
      },
      attributes: ['slot', 'available_seats'],
    });

    const availableSlots = slots
      .filter(s => s.available_seats > 0)
      .map(s => s.slot);

    return res.json({ availableSlots });
  } catch (err) {
    console.error("Error fetching slots:", err);
    return res.status(500).json({ error: "Internal Server Error" });
  }
};
