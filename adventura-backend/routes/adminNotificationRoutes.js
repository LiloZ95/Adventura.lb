const express = require('express');
const router = express.Router();
const {
  getAllNotifications,
  sendNotification,
  broadcastNotification,
  postUniversalNotification, 
  getAllUniversalNotifications,
  getPersonalNotifications
} = require('../controllers/adminNotificationController');

router.get('/notifications', getAllNotifications);
router.post('/notifications', sendNotification);
router.post('/notifications/broadcast', broadcastNotification);
router.post('/universal-notifications', postUniversalNotification);
router.get('/universal-notifications', getAllUniversalNotifications);
router.get('/personal-notifications/:userId', getPersonalNotifications);

module.exports = router;
