const express = require("express");
const router = express.Router();
const controller = require("../controllers/notificationPreferenceController");

router.post("/set", controller.setNotificationPreference);
router.get("/get", controller.getNotificationPreference);

module.exports = router;
