const express = require('express');
const router = express.Router();
const interactionController = require('../controllers/interactioncontroller');

router.post('/interactions', interactionController.logInteraction);

module.exports = router;
