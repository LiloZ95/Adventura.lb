// db/db.js
const { Sequelize } = require("sequelize");
require("dotenv").config(); // Load environment variables

const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASSWORD,
  {
    host: process.env.DB_HOST,
    dialect: "postgres",
    logging: false, // Disable logging (set to true for debugging)
    pool: {
      max: 10, // ✅ Allow multiple connections
      min: 0,
      acquire: 30000,
      idle: 10000,
    },
    retry: {
      max: 5, // ✅ Retry connection up to 5 times before failing
    },
  }
);

// ✅ Test database connection
const connectDB = async () => {
  try {
    await sequelize.authenticate();
    console.log("✅ Database connected successfully.");
  } catch (error) {
    console.error("❌ Database connection failed:", error);
  }
};

module.exports = { sequelize, connectDB };

console.log("Database Config:", {
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT
});