const { sequelize } = require("./db/db.js");
const { QueryTypes } = require("sequelize");

const distributeUser = async (user) => {
  try {
    const { user_id, first_name, last_name, user_type } = user;
    const normalizedUserType = user_type ? user_type.trim().toLowerCase() : "client";

    // ✅ Determine which table the user currently exists in
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
      normalizedUserType === "provider"
        ? "provider"
        : normalizedUserType === "admin"
        ? "administrator"
        : "client";

    // ✅ Skip if already in the correct table
    if (currentTable === correctTable) {
      console.log(`✅ User "${first_name} ${last_name}" is correctly placed in ${correctTable}. Skipping.`);
      return;
    }

    // 🗑 Remove from wrong table (if any)
    if (currentTable) {
      await sequelize.query(`DELETE FROM ${currentTable} WHERE user_id = :userId`, {
        replacements: { userId: user_id },
        type: QueryTypes.DELETE,
      });
      console.log(`🗑 Removed user "${first_name} ${last_name}" from ${currentTable}.`);
    }

    // ✅ Insert into correct table
    let insertQuery = "";
    let insertValues = { userId: user_id };

    if (correctTable === "provider") {
      insertQuery = `INSERT INTO provider (user_id, business_name) VALUES (:userId, 'Default Business')`;
    } else if (correctTable === "administrator") {
      insertQuery = `INSERT INTO administrator (user_id, permissions, admin_role) VALUES (:userId, 'All', 'Super Admin')`;
    } else {
      insertQuery = `INSERT INTO client (user_id, loyalty_points) VALUES (:userId, 0)`;
    }

    await sequelize.query(insertQuery, {
      replacements: insertValues,
      type: QueryTypes.INSERT,
    });

    console.log(`✅ User "${first_name} ${last_name}" assigned to ${correctTable}`);
  } catch (error) {
    console.error(`❌ Error distributing user "${user.first_name} ${user.last_name}":`, error);
  }
};

module.exports = { distributeUser };
