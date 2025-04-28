const rateLimit = require('express-rate-limit');

const followLimiter = rateLimit({
  windowMs: 10 * 1000, // 10 seconds
  max: 5, // Max 5 requests per window
  message: { error: "Too many follow/unfollow actions. Please slow down." }
});

module.exports = { followLimiter };
