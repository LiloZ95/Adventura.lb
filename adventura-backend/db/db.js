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
  }
);

// Test the connection
sequelize
  .authenticate()
  .then(() => console.log("db.js Connected using Sequelize!"))
  .catch((err) => console.error("Connection error:", err));

module.exports = sequelize;

console.log("Database Config:", {
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT
});