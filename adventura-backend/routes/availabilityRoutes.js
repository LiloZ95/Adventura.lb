// availabilityRoutes.js
const express = require('express');
const router = express.Router();
const availabilityController = require('../controllers/availabilityController');

// GET route to fetch available slots
router.get('/', availabilityController.getAvailableSlots);

// GET route to fetch available dates
router.get('/dates-with-slots', availabilityController.getAvailableDates);

// (Optional) you can later add POST, PUT, DELETE routes for managing slots here

module.exports = router;
