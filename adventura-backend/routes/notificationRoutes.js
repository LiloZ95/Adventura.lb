const express = require("express");
const router = express.Router();
const redis = require("../utils/redis");

const { getNotifications } = require("../controllers/notificationController");
const {
	getUniversalNotifications,
} = require("../controllers/universalNotificationController");

router.get("/notifications/:userId", getNotifications);
router.get("/universal-notifications", getUniversalNotifications);

router.get("/offline-messages/:userId", async (req, res) => {
	const { userId } = req.params;
	const key = `offline_msgs:${userId}`;

	try {
		const stored = await redis.lrange(key, 0, -1);
		const parsed = stored.map(JSON.parse);
		await redis.del(key); // clear after sending

		res.json(parsed);
	} catch (err) {
		console.error("❌ Redis error:", err);
		res.status(500).json({ error: "Failed to fetch offline messages" });
	}
});

module.exports = router;
