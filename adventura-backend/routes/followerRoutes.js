// routes/followerRoutes.js
const express = require("express");
const router = express.Router();
const controller = require("../controllers/followerController");
const { followLimiter } = require('../middleware/rateLimiter');

router.post("/follow", followLimiter, controller.followOrganizer);
router.post("/unfollow", followLimiter, controller.unfollowOrganizer);
router.get("/followers-count/:provider_id", controller.getFollowersCount);
router.get("/is-following", controller.isFollowing);
router.get('/list/:provider_id', controller.getFollowersList);


module.exports = router;
