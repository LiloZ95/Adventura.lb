const { Notification } = require("../models");

const getNotifications = async (req, res) => {
    try {
      const { userId } = req.params;
      const notifications = await Notification.findAll({
        where: { user_id: userId },
        order: [["created_at", "DESC"]],
        attributes: ["notification_id", "title", "description", "icon", "created_at"] // 👈 include icon_type
      });
      res.json(notifications);
    } catch (err) {
      res.status(500).json({ message: "Server error" });
    }
  };
  

// 🔔 Call this to send a new notification
const createNotification = async (userId, title, description) => {
  try {
    await Notification.create({
      user_id: userId,
      title,
      description,
      icon
    });
  } catch (err) {
    console.error("❌ Error creating notification:", err);
  }
};

module.exports = {
  getNotifications,
  createNotification,
};
