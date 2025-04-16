const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');

router.get('/users', adminController.getAllUsers);
router.patch('/users/:id', adminController.modifyUser);
router.patch('/activities/:id', adminController.modifyActivity);
router.delete('/users/:id', adminController.deleteUser);
router.delete('/activities/:id', adminController.deleteActivity);
router.get('/summary', adminController.getSummaryStats);
router.get('/best-activity', adminController.getBestActivity);
//router.get('/top-gender', adminController.getTopGender);
router.get('/monthly-revenue', adminController.getMonthlyRevenue);
router.get('/activities', adminController.getAllActivities);
router.get('/top-cities', adminController.getTopCities);
router.get('/top-providers', adminController.getTopProviders);

module.exports = router;
