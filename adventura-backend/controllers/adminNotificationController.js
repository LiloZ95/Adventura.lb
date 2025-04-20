const { UniversalNotification, Notification, User } = require('../models');

// GET all notifications with user info
const getAllNotifications = async (req, res) => {
  try {
    const notifications = await Notification.findAll({
      include: [
        {
          model: User,
          attributes: ['first_name', 'last_name'],
        },
      ],
      order: [['created_at', 'DESC']],
    });
    res.json(notifications);
  } catch (err) {
    console.error('Error fetching notifications:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// POST new notification (to a specific user)
const sendNotification = async (req, res) => {
  try {
    const { user_id, title, description, icon } = req.body;

    if (!user_id || !title || !description) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const notification = await Notification.create({
      user_id,
      title,
      description,
      icon,
    });

    res.status(201).json(notification);
  } catch (err) {
    console.error('Error creating notification:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// POST broadcast notification to all users
const broadcastNotification = async (req, res) => {
  try {
    const { title, description, icon } = req.body;

    if (!title || !description) {
      return res.status(400).json({ error: 'Title and description are required' });
    }

    const users = await User.findAll({ attributes: ['user_id'] });

    const notifications = await Promise.all(
      users.map((user) =>
        Notification.create({
          user_id: user.user_id,
          title,
          description,
          icon,
        })
      )
    );

    res.status(201).json({ message: 'Broadcast sent successfully', notifications });
  } catch (err) {
    console.error('Error broadcasting notifications:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
};
const postUniversalNotification = async (req, res) => {
  try {
    const { title, description, icon } = req.body;

    if (!title || !description) {
      return res.status(400).json({ error: 'Title and description are required' });
    }

    // ✅ Just insert into universal_notifications — nothing else
    await UniversalNotification.create({ title, description, icon });

    res.status(201).json({ message: 'Universal notification sent successfully.' });
  } catch (error) {
    console.error("❌ Error posting universal notification:", error);
    res.status(500).json({ error: error.message });
  }
};

const getPersonalNotifications = async (req, res) => {
  try {
    const { userId } = req.params;

    const notifications = await Notification.findAll({
      where: { user_id: userId },
      order: [['created_at', 'DESC']],
    });

    res.json(notifications);
  } catch (err) {
    console.error("Error fetching personal notifications:", err);
    res.status(500).json({ error: 'Internal server error' });
  }
};

const getAllUniversalNotifications = async (req, res) => {
  try {
    const notifications = await UniversalNotification.findAll({
      order: [['created_at', 'DESC']],
    });
    res.json(notifications);
  } catch (err) {
    console.error("Error fetching universal notifications:", err);
    res.status(500).json({ error: err.message });
  }
};
module.exports = {
  getAllUniversalNotifications,
  getAllNotifications,
  sendNotification,
  broadcastNotification,
  postUniversalNotification,
  getPersonalNotifications
};
