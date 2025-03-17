const express = require("express");
const { body, query } = require("express-validator");
const rateLimit = require("express-rate-limit");
const bookingController = require("../controllers/bookingController");

const router = express.Router();

const limiter = rateLimit({
	windowMs: 10 * 60 * 1000, // 10 min
	max: 20, // max 20 requests per 10 min
	message: "Too many requests, try again later",
});

// Check availability route
router.get(
	"/check-availability",
	limiter,
	[
		query("activity_id").isInt().withMessage("Invalid activity ID"),
		query("date").isISO8601().withMessage("Invalid date format"),
	],
	bookingController.checkAvailability
);

// Create booking route
router.post(
	"/create",
	limiter,
	[
		body("activity_id").isInt(),
		body("client_id").isInt(),
		body("booking_date").isISO8601(),
		body("slot").isString().notEmpty(),
		body("total_price").isDecimal(),
	],
	bookingController.createBooking
);

module.exports = router;
