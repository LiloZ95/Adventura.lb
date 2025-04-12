// const bookingService = require("../services/bookingService");

const { Activity, Booking, availability, Client, User  } = require("../models");

const getUserBookings = async (req, res) => {
	try {
	  const { clientId } = req.params;
	  const userBookings = await Booking.findAll({
		where: { client_id: clientId },
		include: [
		  {
			model: Activity,
			as: "activity"
		  }
		],
		order: [["booking_date", "DESC"]],
	  });
  
	  res.status(200).json(userBookings);
	} catch (err) {
	  console.error("❌ Fetch error:", err);
	  res.status(500).json({ message: "Server error" });
	}
  };
  

  const getBookingById = async (req, res) => {
	const { id } = req.params;
	try {
		const bookingInfo = await Booking.findOne({
			where: { booking_id: id },
			include: [
				{
					model: Activity,
					as: "activity",
				},
				{
					model: Client,
					as: "client",
					include: [
						{
							model: User,
							as: "user", // alias must match the one you used in the association
							attributes: ["first_name", "last_name"],
						},
					],
				},
			],
		});

		if (!bookingInfo) {
			return res.status(404).json({ message: "Booking not found" });
		}

		res.json({
			booking_id: bookingInfo.booking_id,
			event_name: bookingInfo.activity?.name || "Unknown",
			client_name: `${bookingInfo.client?.user?.first_name} ${bookingInfo.client?.user?.last_name}`,
			event_time: bookingInfo.slot,
			status: bookingInfo.status,
		});
	} catch (error) {
		console.error("❌ Error fetching booking by ID:", error);
		res.status(500).json({ message: "Server error" });
	}
};



const checkAvailability = async (req, res) => {
	try {
		const { activity_id, date } = req.query;

		if (!activity_id || !date) {
			return res.status(400).json({ message: "Missing activity_id or date" });
		}

		const activity = await Activity.findByPk(activity_id);
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
const { Op } = require("sequelize");
const createBooking = async (req, res) => {
	try {
		console.log("📥 Booking Payload:", req.body); // <-- ADD THIS

		const { activity_id, client_id, booking_date, slot, total_price } = req.body;

		// Check if the activity exists
		const activity = await Activity.findByPk(activity_id);
		if (!activity)
			return res.status(404).json({ message: "Activity not found" });

		// Check for valid availability
		const availabilitySlot = await availability.findOne({
			where: {
				activity_id,
				date: booking_date,
				slot,
			},
		});

		if (!availabilitySlot) {
			return res.status(404).json({ message: "No availability for selected date/slot" });
		}

		if (availabilitySlot.available_seats <= 0) {
			return res.status(400).json({ message: "Slot is fully booked" });
		}

		// Create booking
		const newBooking = await Booking.create({
			activity_id,
			client_id,
			booking_date,
			slot,
			total_price,
			status: "pending",
		});

		// Decrease available seats
		availabilitySlot.available_seats -= 1;
		await availabilitySlot.save();

		res.status(201).json({ message: "Booking successful", booking: newBooking });
	} catch (error) {
		console.error("❌ Booking error:", error);
		console.error("🪵 Full stack:", error.stack);
		res.status(500).json({ message: "Server error" });
	}
};

const updateBookingStatus = async (req, res) => {
	try {
		const { id } = req.params;
		const { status } = req.body;

		const bookingData = await Booking.findByPk(id);
		if (!bookingData) {
			return res.status(404).json({ message: "Booking not found" });
		}

		bookingData.status = status;
		await bookingData.save();

		res.json({ message: "Booking status updated", status: status });
	} catch (error) {
		console.error("❌ Error updating booking status:", error);
		res.status(500).json({ message: "Server error" });
	}
};

module.exports = {
	checkAvailability,
	createBooking,
	getBookingById,
	updateBookingStatus,
	getUserBookings, // ✅ this MUST be here
};
