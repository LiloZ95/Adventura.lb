const { sequelize } = require("./db/db.js"); // Import Sequelize instance
const User = require("./models/User.js"); // Import User model
const { QueryTypes } = require("sequelize");

const distributeUsers = async () => {
  try {
    const users = await User.findAll(); // Fetch all users

    if (users.length === 0) {
      console.log("No users found to distribute.");
      return;
    }

    for (const user of users) {
      const { user_id, first_name, last_name, user_type } = user;
      const normalizedUserType = user_type ? user_type.trim().toLowerCase() : "client";

      // **Check if user is already in the correct table**
      const existingRecord = await sequelize.query(
        `SELECT table_name FROM (
          SELECT 'provider' AS table_name FROM provider WHERE user_id = :userId
          UNION
          SELECT 'client' FROM client WHERE user_id = :userId
          UNION
          SELECT 'administrator' FROM administrator WHERE user_id = :userId
        ) AS tables`,
        {
          replacements: { userId: user_id },
          type: QueryTypes.SELECT,
        }
      );

      const currentTable = existingRecord.length > 0 ? existingRecord[0].table_name : null;
      const correctTable =
        normalizedUserType === "provider" ? "provider" :
        normalizedUserType === "admin" ? "administrator" :
        "client"; // Default to client

      // **If user is already in the correct table, skip them**
      if (currentTable === correctTable) {
        console.log(`✅ User "${first_name} ${last_name}" is correctly placed in ${correctTable}. Skipping.`);
        continue;
      }

      // **If user is in the wrong table, move them**
      if (currentTable) {
        await sequelize.query(`DELETE FROM ${currentTable} WHERE user_id = :userId`, {
          replacements: { userId: user_id },
          type: QueryTypes.DELETE,
        });
        console.log(`🗑 Removed user "${first_name} ${last_name}" from ${currentTable}.`);
      }

      // **Insert user into the correct table (without manually setting the primary key)**
      let insertQuery = "";
      let insertValues = {};
      if (correctTable === "provider") {
        insertQuery = `INSERT INTO provider (user_id, business_name) VALUES (:userId, 'Default Business')`;
        insertValues = { userId: user_id };
      } else if (correctTable === "administrator") {
        insertQuery = `INSERT INTO administrator (user_id, permissions, admin_role) VALUES (:userId, 'All', 'Super Admin')`;
        insertValues = { userId: user_id };
      } else {
        insertQuery = `INSERT INTO client (user_id, preferences, loyalty_points) VALUES (:userId, 'No preferences', 0)`;
        insertValues = { userId: user_id };
      }

      await sequelize.query(insertQuery, {
        replacements: insertValues,
        type: QueryTypes.INSERT,
      });

      console.log(`✅ Moved user "${first_name} ${last_name}" to ${correctTable}.`);
    }

    console.log("✅ User distribution completed successfully!");
  } catch (error) {
    console.error("❌ Error distributing users:", error);
  }
};

// Run the function
module.exports = { distributeUsers };
