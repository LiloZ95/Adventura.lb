const { sequelize, Activity, ActivityCategory, User } = require('../models');
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
const getRevenueByType = async (req, res) => {
  const { type = 'monthly' } = req.query;

  let groupBy, label;
  switch (type) {
    case 'daily':
      groupBy = `TO_CHAR(payment_date, 'YYYY-MM-DD')`;
      label = 'day';
      break;
    case 'weekly':
      groupBy = `TO_CHAR(DATE_TRUNC('week', payment_date), 'IYYY-IW')`; // ISO week
      label = 'week';
      break;
    case 'yearly':
      groupBy = `TO_CHAR(payment_date, 'YYYY')`;
      label = 'year';
      break;
    case 'monthly':
    default:
      groupBy = `TO_CHAR(payment_date, 'YYYY-MM')`;
      label = 'month';
      break;
  }

  try {
    const data = await sequelize.query(`
      SELECT ${groupBy} AS ${label}, SUM(amount) AS revenue
      FROM payment
      GROUP BY ${label}
      ORDER BY ${label} ASC
    `, {
      type: sequelize.QueryTypes.SELECT
    });

    res.json(data);
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
  const getTopClients = async (req, res) => {
    try {
      const topClients = await sequelize.query(`
        SELECT 
          u.first_name || ' ' || u.last_name AS client_name,
          COUNT(b.booking_id) AS booking_count
        FROM client c
        JOIN "USER" u ON u.user_id = c.user_id
        JOIN booking b ON b.client_id = c.client_id
        GROUP BY client_name
        ORDER BY booking_count DESC
        LIMIT 5;
      `, { type: sequelize.QueryTypes.SELECT });
  
      res.json(topClients);
    } catch (err) {
      console.error("Error fetching top clients:", err);
      res.status(500).json({ error: err.message });
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
        LIMIT 5;
      `, { type: sequelize.QueryTypes.SELECT });
  
      res.json(topProviders);
    } catch (err) {
      console.error("Error fetching top providers:", err);
      res.status(500).json({ error: err.message });
    }
  };
  // In adminController.js or a similar file
  const getTopCategories = async (req, res) => {
    try {
      const result = await sequelize.query(`
        SELECT c.name AS category_name, COUNT(a.activity_id) AS activity_count
        FROM category c
        LEFT JOIN activities a ON a.category_id = c.category_id
        GROUP BY c.name
        ORDER BY activity_count DESC
        LIMIT 5;
      `, { type: sequelize.QueryTypes.SELECT });
  
      res.json(result);
    } catch (err) {
      console.error('Error in getTopCategories:', err);
      res.status(500).json({ error: err.message });
    }
  };
  const getTopCategoriesByRevenue = async (req, res) => {
    try {
      const data = await sequelize.query(`
        SELECT 
          c.name AS category_name,
          SUM(p.amount) AS total_revenue
        FROM payment p
        JOIN booking b ON b.booking_id = p.booking_id
        JOIN activities a ON a.activity_id = b.activity_id
        JOIN category c ON c.category_id = a.category_id
        WHERE p.payment_status = 'paid'
        GROUP BY c.name
        ORDER BY total_revenue DESC;
      `, {
        type: sequelize.QueryTypes.SELECT
      });
  
      res.json(data);
    } catch (err) {
      console.error("Error in getTopCategoriesByRevenue:", err);
      res.status(500).json({ error: err.message });
    }
  };
  const getTopCitiesByRevenue = async (req, res) => {
    try {
      const data = await sequelize.query(`
        SELECT 
          a.location AS city,
          SUM(p.amount) AS total_revenue
        FROM payment p
        JOIN booking b ON b.booking_id = p.booking_id
        JOIN activities a ON a.activity_id = b.activity_id
        GROUP BY city
        ORDER BY total_revenue DESC
        LIMIT 5;
      `, {
        type: sequelize.QueryTypes.SELECT
      });
  
      res.json(data);
    } catch (err) {
      console.error("Error fetching top cities by revenue:", err);
      res.status(500).json({ error: err.message });
    }
  };
  
  
  
module.exports = {
    getAllUsers,
    modifyUser,
    getTopCategoriesByRevenue,
    deleteUser,
    getAllActivities,
    modifyActivity,
    deleteActivity,
    getTopCities,
    getSummaryStats,
    getTopProviders,
    getBestActivity,
    getTopClients,
    getTopCitiesByRevenue,
   // getTopGender,
    getRevenueByType,
    getTopCategories
  };
  