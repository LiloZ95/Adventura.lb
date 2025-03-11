require("dotenv").config(); // ✅ Load environment variables FIRST

const { Sequelize } = require("sequelize");

if (!process.env.DB_NAME || !process.env.DB_USER || !process.env.DB_PASSWORD || !process.env.DB_HOST || !process.env.DB_PORT) {
  console.error("❌ Missing required database environment variables.");
  process.exit(1); // Stop execution if env variables are missing
}

const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASSWORD,
  {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT, // ✅ Now using DB_PORT
    dialect: "postgres",
    logging: false, // Set to 'true' for debugging queries
    pool: {
      max: 10, // Allow multiple connections
      min: 0,
      acquire: 30000,
      idle: 10000,
    },
    retry: {
      max: 5, // Retry connection up to 5 times
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
    process.exit(1); // Exit if database connection fails
  }
};

module.exports = { sequelize, connectDB };

console.log("Database Config:", {
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT,
});
