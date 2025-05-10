// workers/followWorker.js
const { Worker } = require('bullmq');
const { connection } = require('../utils/redis');
const Notification = require('../models/Notification'); 
const User = require('../models/User');
const { pushToUser } = require('../websocketServer');

// Worker to process follow jobs
const worker = new Worker('followQueue', async job => {
  const { user_id, provider_id } = job.data;

  try {
    // Fetch user name
    const user = await User.findByPk(user_id);
    if (!user) {
      console.error(`❌ User not found: ${user_id}`);
      return;
    }

    const title = 'New Follower';
    const description = `${user.first_name} ${user.last_name} followed you.`;

    await Notification.create({
      user_id: provider_id,
      title,
      description,
      icon: 'follow', // optional icon field
    });
    pushToUser(provider_id, title, description);

    console.log(`✅ Notification sent to provider ${provider_id}`);
  } catch (error) {
    console.error('❌ Error processing follow job:', error);
  }
}, { connection });

worker.on('completed', job => {
  console.log(`✅ Completed job ${job.id}`);
});

worker.on('failed', (job, err) => {
  console.error(`❌ Failed job ${job.id}:`, err);
});
