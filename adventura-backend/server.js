require("dotenv").config(); // ✅ Load environment variables at the top

const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const bodyParser = require("body-parser");
const { connectDB, sequelize } = require("./db/db.js"); // Import Sequelize instance
const userRoutes = require("./routes/userRoutes"); // Import user routes
const recommendationRoutes = require("./routes/recommendationRoutes");
const { authenticateToken } = require("./middleware/auth.js");
const { getUserById } = require("./controllers/userController");

const app = express();

// ✅ Middleware
app.use(bodyParser.json());
app.use(cors());
app.use(helmet());
app.use(express.json());

// ✅ Ensure database connection before setting up routes
connectDB().then(async () => {
    try {
        await sequelize.sync(); // ✅ Sync models
        console.log("✅ Database connected & models synced.");
    } catch (err) {
        console.error("❌ Error syncing database:", err);
        process.exit(1); // Exit if DB sync fails
    }
});

// ✅ Register Routes
app.use("/users", userRoutes);
app.use("/recommendations", recommendationRoutes);
app.get("/users/profile", authenticateToken, getUserById); // ✅ Correct authentication usage

// ✅ Global Error Handling Middleware (Prevents Crashes)
app.use((err, req, res, next) => {
    console.error("❌ Server Error:", err);
    res.status(500).json({ error: "Internal server error" });
});

// ✅ Start Server
const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || "0.0.0.0"; // ✅ Use ENV for flexibility

app.listen(PORT, HOST, async () => {
    console.log(`🚀 Server running on http://${HOST}:${PORT}`);
});

// ✅ Handle Unexpected Errors
process.on("uncaughtException", (err) => {
    console.error("❌ Uncaught Exception:", err);
});

process.on("unhandledRejection", (reason, promise) => {
    console.error("❌ Unhandled Promise Rejection:", reason);
});
