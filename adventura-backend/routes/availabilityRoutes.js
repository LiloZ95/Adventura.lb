// availabilityRoutes.js
const express = require('express');
const router = express.Router();
const availabilityController = require('../controllers/availabilityController');

// GET route to fetch available slots
router.get('/', availabilityController.getAvailableSlots);

// (Optional) you can later add POST, PUT, DELETE routes for managing slots here

module.exports = router;
