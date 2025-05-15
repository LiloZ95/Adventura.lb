// const bookingService = require("../services/bookingService");

const {
	Activity,
	Booking,
	availability,
	Client,
	User,
	Notification,
} = require("../models");
const { get } = require("../routes/availabilityRoutes");

const getUserBookings = async (req, res) => {
	try {
		const { clientId } = req.params;
		const userBookings = await Booking.findAll({
			where: { client_id: clientId },
			include: [
				{
					model: Activity,
					as: "activity",
					include: ["activity_images"],
				},
				
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
		const existingBookings = await Booking.findAll({
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
		console.log("📥 Booking Payload:", req.body);

		let {
			activity_id,
			client_id,
			booking_date,
			slot,
			total_price,
			provider_id,
		} = req.body;

		// ✅ 1. Validate ticket count
		if (!total_price || total_price <= 0) {
			return res
				.status(400)
				.json({ message: "Must book at least one ticket." });
		}

		// ✅ 2. Fetch activity
		const activity = await Activity.findByPk(activity_id);
		if (!activity) {
			return res.status(404).json({ message: "Activity not found" });
		}

		// ✅ 3. Prevent provider from booking their own activity
		if (provider_id && provider_id === activity.provider_id) {
			return res
				.status(403)
				.json({ message: "You can't book your own activity." });
		}

		// ✅ 4. Determine who is making the booking
		let bookedByUserId = client_id;
		if (!client_id && provider_id) {
			const Provider = require("../models/Provider");
			const provider = await Provider.findByPk(provider_id);
			if (!provider) {
				return res.status(404).json({ message: "Provider not found" });
			}
			bookedByUserId = provider.user_id;
		}

		if (!bookedByUserId) {
			return res
				.status(400)
				.json({ message: "Invalid user making the booking." });
		}

		// ✅ 5. Handle one-time bookings
		if (activity.listing_type === "oneTime") {
			const newBooking = await Booking.create({
				activity_id,
				client_id: client_id ?? null,
				booking_date,
				slot,
				total_price,
				status: "pending",
				booked_by_provider_user_id: provider_id ?? null,
			});

			await Notification.create({
				user_id: bookedByUserId,
				title: "Booking Confirmed",
				description: `Your booking for "${activity.name}" on ${booking_date} is confirmed.`,
				icon: "book",
			});

			return res.status(201).json({
				message: "Booking successful",
				booking: newBooking,
			});
		}

		// ✅ 6. Handle recurring activity availability
		const availabilitySlot = await availability.findOne({
			where: { activity_id, date: booking_date, slot },
		});

		if (!availabilitySlot) {
			return res.status(404).json({
				message: "No availability for selected date/slot",
			});
		}

		if (availabilitySlot.available_seats <= 0) {
			return res.status(400).json({
				message: "Slot is fully booked",
			});
		}

		// ✅ 7. Proceed with booking and update seats
		const newBooking = await Booking.create({
			activity_id,
			client_id: client_id ?? null,
			booking_date,
			slot,
			total_price,
			status: "pending",
			booked_by_provider_user_id: provider_id ?? null,
		});

		availabilitySlot.available_seats -= 1;
		await availabilitySlot.save();

		await Notification.create({
			user_id: bookedByUserId,
			title: "Booking Confirmed",
			description: `Your booking for "${activity.name}" on ${booking_date} at ${slot} is confirmed.`,
			icon: "book",
		});

		return res.status(201).json({
			message: "Booking successful",
			booking: newBooking,
		});
	} catch (error) {
		console.error("❌ Booking error:", error);
		res.status(500).json({ message: "Server error", error: error.message });
	}
};

const getBookingsByProviderUserId = async (req, res) => {
	try {
		const providerUserId = req.params.userId;
		if (!providerUserId) return res.status(400).json({ message: "Missing user ID" });

		console.log("📥 Provider booking fetch for userId:", providerUserId);

		const bookings = await Booking.findAll({
			where: { booked_by_provider_user_id: providerUserId },
			include: [
				{
					model: Activity,
					as: "activity", // 👈 make sure this matches the alias in Booking.js
					include: ["activity_images"],
				},
			],
			order: [["created_at", "DESC"]],
		});

		res.json(bookings);
	} catch (error) {
		console.error("❌ Error fetching provider bookings:", error);
		res.status(500).json({ message: "Server error", error: error.message });
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
const cancelBooking = async (req, res) => {
	try {
		const { id } = req.params;
		const { reason } = req.body;

		const booking = await Booking.findByPk(id, {
			include: [{ model: Activity, as: "activity" }],
		});

		if (!booking) {
			return res.status(404).json({ message: "Booking not found" });
		}

		booking.status = "cancelled";
		booking.cancelled_at = new Date();
		booking.cancellation_reason = reason;
		await booking.save();

		// Send success response early
		res.status(200).json({ message: "Booking cancelled successfully" });

		// Create notification
		await Notification.create({
			user_id: booking.client_id,
			title: "Booking Cancelled",
			description: `Your booking for "${booking.activity.name}" on ${booking.booking_date} is cancelled.`,
			icon_type: "cancel", // 👈 correct field name and value
		});
	} catch (error) {
		console.error("❌ Error cancelling booking:", error);
		res.status(500).json({ message: "Server error" });
	}
};

module.exports = {
	checkAvailability,
	createBooking,
	getBookingById,
	updateBookingStatus,
	getUserBookings,
	getBookingsByProviderUserId,
	cancelBooking, // ✅ this MUST be here
};
