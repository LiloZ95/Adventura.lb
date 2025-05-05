// queues/followQueue.js
const { Queue } = require('bullmq');
const { connection } = require('../utils/redis');

// Create a new queue
const followQueue = new Queue('followQueue', { connection });

module.exports = { followQueue };
