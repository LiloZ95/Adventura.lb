const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const bodyParser = require("body-parser");
const dotenv = require("dotenv");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const User = require("./models/User.js"); // User model
const sequelize = require("./db/db.js"); // Import Sequelize instance
const userRoutes = require("./routes/userRoutes"); // Import user routes
const { QueryTypes } = require("sequelize");


dotenv.config();


const app = express();
app.use(bodyParser.json());

app.use(cors());
app.use(helmet());
app.use(express.json());

// JWT Authentication Middleware
function verifyToken(req, res, next) {
  const token = req.headers["authorization"];

  if (!token) {
    return res.status(403).json({ message: "No token provided." });
  }

  jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
    if (err) {
      return res.status(401).json({ message: "Unauthorized" });
    }
    req.userId = decoded.id; // Store user ID in request object
    next(); // Proceed to the next middleware or route
  });
}

// // Routes
app.use("/users", userRoutes);

// ✅ Ensure userRoutes.js is correctly registered
// app.use("/", userRoutes);

// Start the server after database connection
sequelize
  .authenticate()
  .then(() => {
    console.log("✅ Connected to PostgreSQL using Sequelize!");
    app.listen(3000, () => console.log("🚀 Server running on port 3000"));
  })
  .catch((err) => console.error("❌ Database connection error:", err));