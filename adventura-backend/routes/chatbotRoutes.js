const express = require('express');
const router = express.Router();
const bookingController = require("../controllers/bookingController");

router.post("/booking", async (req, res) => {
  try {
    console.log("📥 Booking request received:", req.body);

    // Build the expected structure for your controller
    const transformedReq = {
      ...req,
      body: {
        activity_id: req.body.activity_id,
        client_id: req.body.user_id, // LLM sends this as user_id
        booking_date: req.body.date,
        slot: req.body.slot,
        total_price: 10, // 💡 You can make this dynamic later
      },
    };

    await bookingController.createBooking(transformedReq, res);
  } catch (err) {
    console.error("❌ Booking route error:", err);
    res.status(500).json({ message: "Internal server error" });
  }
});

module.exports = router;
