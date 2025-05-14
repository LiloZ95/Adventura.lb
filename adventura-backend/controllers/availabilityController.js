// availabilityController.js
const Availability = require("../models/Availability");

exports.getAvailableSlots = async (req, res) => {
	const { activityId, date } = req.query;

	try {
		const slots = await Availability.findAll({
			where: {
				activity_id: activityId,
				date: date,
			},
			attributes: ["slot", "available_seats"],
		});

		const availableSlots = slots
			.filter((s) => s.available_seats > 0)
			.map((s) => s.slot);

		return res.json({ availableSlots });
	} catch (err) {
		console.error("Error fetching slots:", err);
		return res.status(500).json({ error: "Internal Server Error" });
	}
};

exports.getAvailableDates = async (req, res) => {
	const { activityId } = req.query;

	try {
		const records = await Availability.findAll({
			where: {
				activity_id: activityId,
			},
			attributes: ["date", "available_seats"],
		});

		const dateSet = new Set();

		for (const r of records) {
			if (r.available_seats > 0) {
				dateSet.add(r.date);
			}
		}

		const availableDates = Array.from(dateSet);
		return res.json({ availableDates });
	} catch (err) {
		console.error("Error fetching dates:", err);
		return res.status(500).json({ error: "Internal Server Error" });
	}
};
