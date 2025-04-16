const { sequelize } = require('../db/db');
const Activity = require('../models/Activity');
const ActivityCategory = require('../models/ActivityCategory');
const User = require('../models/User');

// GET all activities with category name
const getAllActivities = async (req, res) => {
  try {
    const activities = await Activity.findAll({
      include: [{ model: ActivityCategory, as: 'category', attributes: ['name'] }]
    });

    res.json(activities);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
const getAllUsers = async (req, res) => {
    try {
      const users = await User.findAll();
      res.json(users);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  };
  

// MODIFY activity
const modifyActivity = async (req, res) => {
  try {
    const { id } = req.params;
    const updated = await Activity.update(req.body, { where: { activity_id: id } });

    if (updated[0] === 0)
      return res.status(404).json({ message: 'Activity not found or no changes' });

    res.json({ message: 'Activity updated successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// DELETE activity
const deleteActivity = async (req, res) => {
  try {
    const { id } = req.params;
    const deleted = await Activity.destroy({ where: { activity_id: id } });

    if (!deleted) return res.status(404).json({ message: 'Activity not found' });

    res.json({ message: 'Activity deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
// Overall Stats
const getSummaryStats = async (req, res) => {
  try {
    const totalUsers = await User.count();
    const totalActivities = await Activity.count();

    const totalRevenue = await sequelize.query(
      "SELECT COALESCE(SUM(amount), 0) FROM payment",
      { type: sequelize.QueryTypes.SELECT }
    );

    res.json({
      totalUsers,
      totalActivities,
      totalRevenue: totalRevenue[0].coalesce,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Best-selling activity
const getBestActivity = async (req, res) => {
  try {
    const bestActivity = await sequelize.query(`
      SELECT activities.name, COUNT(booking.activity_id) AS bookings_count
      FROM booking
      JOIN activities ON booking.activity_id = activities.activity_id
      GROUP BY activities.name
      ORDER BY bookings_count DESC
      LIMIT 1;
    `, {
      type: sequelize.QueryTypes.SELECT
    });

    res.json(bestActivity[0] || { message: "No activity bookings found" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};


// Gender Distribution
/*
const getTopGender = async (req, res) => {
  try {
    const genders = await sequelize.query(`
      SELECT gender, COUNT(*) AS count
      FROM "USER"
      GROUP BY gender
      ORDER BY count DESC`,
      { type: sequelize.QueryTypes.SELECT }
    );

    res.json(genders);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
*/
// Monthly Revenue Trends
const getMonthlyRevenue = async (req, res) => {
  try {
    const revenueMonthly = await sequelize.query(`
      SELECT TO_CHAR(payment_date, 'YYYY-MM') AS month, SUM(amount) AS revenue
      FROM payment
      GROUP BY month
      ORDER BY month ASC
    `, {
      type: sequelize.QueryTypes.SELECT
    });

    res.json(revenueMonthly);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// MODIFY user
const modifyUser = async (req, res) => {
    try {
      const { id } = req.params;
      const updated = await User.update(req.body, { where: { user_id: id } });
  
      if (updated[0] === 0)
        return res.status(404).json({ message: 'User not found or no changes' });
  
      res.json({ message: 'User updated successfully' });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  };
  
  // DELETE user
  const deleteUser = async (req, res) => {
    try {
      const { id } = req.params;
      const deleted = await User.destroy({ where: { user_id: id } });
  
      if (!deleted) return res.status(404).json({ message: 'User not found' });
  
      res.json({ message: 'User deleted successfully' });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  };
  const getTopCities = async (req, res) => {
    try {
      const result = await sequelize.query(
        `SELECT location AS city, COUNT(*) AS count
         FROM activities
         WHERE location IS NOT NULL AND location != ''
         GROUP BY location
         ORDER BY count DESC
         LIMIT 5;`,
        { type: sequelize.QueryTypes.SELECT }
      );
      res.json(result);
    } catch (err) {
      console.error('Error fetching top cities:', err);
      res.status(500).json({ error: 'Internal server error' });
    }
  };


  const getTopProviders = async (req, res) => {
    try {
      const topProviders = await sequelize.query(`
        SELECT 
          u.first_name || ' ' || u.last_name AS provider_name,
          COUNT(a.activity_id) AS activity_count
        FROM provider p
        JOIN "USER" u ON u.user_id = p.user_id
        JOIN activities a ON a.provider_id = p.provider_id
        GROUP BY provider_name
        ORDER BY activity_count DESC
        LIMIT 3;
      `, { type: sequelize.QueryTypes.SELECT });
  
      res.json(topProviders);
    } catch (err) {
      console.error("Error fetching top providers:", err);
      res.status(500).json({ error: err.message });
    }
  };
  
  
  
module.exports = {
    getAllUsers,
    modifyUser,
    deleteUser,
    getAllActivities,
    modifyActivity,
    deleteActivity,
    getTopCities,
    getSummaryStats,
    getTopProviders,
    getBestActivity,
   // getTopGender,
    getMonthlyRevenue
  };
  