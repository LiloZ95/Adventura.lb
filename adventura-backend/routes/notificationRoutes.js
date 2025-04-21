const express = require("express");
const router = express.Router();
const { getNotifications } = require("../controllers/notificationController");
const { getUniversalNotifications } = require("../controllers/universalNotificationController");

router.get("/notifications/:userId", getNotifications);
router.get("/universal-notifications", getUniversalNotifications);

module.exports = router;
