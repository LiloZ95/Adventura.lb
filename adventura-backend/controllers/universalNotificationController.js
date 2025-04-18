const { UniversalNotification } = require("../models");

const getUniversalNotifications = async (req, res) => {
  try {
    const results = await UniversalNotification.findAll({
      order: [["created_at", "DESC"]],
    });
    res.status(200).json(results);
  } catch (err) {
    console.error("❌ Error fetching universal notifications:", err);
    res.status(500).json({ message: "Server error" });
  }
};

module.exports = { getUniversalNotifications };
