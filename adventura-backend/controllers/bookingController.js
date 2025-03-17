const bookingService = require("../services/bookingService");

const checkAvailability = async (req, res) => {
	try {
		const { activity_id, date } = req.query;

		if (!activity_id || !date) {
			return res.status(400).json({ message: "Missing activity_id or date" });
		}

		const activity = await activities.findByPk(activity_id);
		if (!activity)
			return res.status(404).json({ message: "Activity not found" });

		const capacity = activity.capacity || 0;
		const existingBookings = await booking.findAll({
			where: {
				activity_id,
				booking_date: date,
				cancelled_at: null, // Ignore cancelled bookings
			},
		});

		const slotCounts = {};
		existingBookings.forEach((b) => {
			slotCounts[b.slot] = (slotCounts[b.slot] || 0) + 1;
		});

		const availableSlots = ["10:00 AM", "1:00 PM", "4:00 PM"].filter(
			(slot) => (slotCounts[slot] || 0) < capacity
		);

		res.status(200).json({ availableSlots });
	} catch (error) {
		console.error("❌ Availability check error:", error);
		res.status(500).json({ message: "Server error" });
	}
};

const createBooking = async (req, res) => {
	try {
		const { activity_id, client_id, booking_date, slot, total_price } =
			req.body;

		const activity = await activities.findByPk(activity_id);
		if (!activity)
			return res.status(404).json({ message: "Activity not found" });

		const existingCount = await booking.count({
			where: {
				activity_id,
				booking_date,
				slot,
				cancelled_at: null,
			},
		});

		if (existingCount >= activity.capacity) {
			return res.status(400).json({ message: "Slot is fully booked" });
		}

		const newBooking = await booking.create({
			activity_id,
			client_id,
			booking_date,
			slot,
			total_price,
			status: "confirmed",
		});

		res
			.status(201)
			.json({ message: "Booking successful", booking: newBooking });
	} catch (error) {
		console.error("❌ Booking error:", error);
		res.status(500).json({ message: "Server error" });
	}
};

module.exports = {
	checkAvailability,
	createBooking,
};
