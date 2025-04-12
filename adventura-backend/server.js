require("dotenv").config(); // ✅ Load environment variables at the top

const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const bodyParser = require("body-parser");
const path = require("path");
const { connectDB } = require("./db/db.js");
const userRoutes = require("./routes/userRoutes"); // Import user routes
const { sequelize } = require("./models"); // ✅ Import from index.js
const recommendationRoutes = require("./routes/recommendationRoutes.js");
const { authenticateToken } = require("./middleware/auth.js");
const Client = require("./models/client"); // Import Client model
const { getUserById } = require("./controllers/userController");
const categoryRoutes = require("./routes/categoryRoutes"); // Import category routes
const activityRoutes = require("./routes/activityRoutes");
// const eventRoutes = require("./routes/eventRoutes"); // ✅ Import event routes
const availabilityRoutes = require('./routes/availabilityRoutes');
const cron = require("node-cron"); // Import cron for scheduling tasks
const { deactivatePastEvents } = require("./controllers/activityController");

const app = express();

// ✅ Middleware
app.use(bodyParser.json());
app.use(cors({
    origin: "*",
    methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization"]
}));
app.use(helmet());
app.use(express.json());

// ✅ Ensure database connection before setting up routes
connectDB()
	.then(async () => {
		try {
			await sequelize.sync({ alter: false, force: false });
			console.log("✅ Database synced with updated models.");
		} catch (err) {
			console.error("❌ Error syncing database:", err);
		}
	})
	.catch((err) => {
		console.error("❌ Error connecting to the database:", err);
	});

// ✅ Register Routes
app.use("/users", userRoutes);
app.use("/categories", categoryRoutes); // Add category routes
app.get("/users/profile", authenticateToken, getUserById); // ✅ Correct authentication usage
app.use("/recommendations", recommendationRoutes);

// ✅ Serve static files from 'public/images'
app.use("/images", express.static(path.join(__dirname, "public/images")));
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));
app.use("/activities", activityRoutes);

// app.use("/events", eventRoutes);  // ✅ Add event routes

app.use("/availability", availabilityRoutes);

// ✅ Global Error Handling Middleware (Prevents Crashes)
app.use((err, req, res, next) => {
	console.error("❌ Server Error:", err);
	res.status(500).json({ error: "Internal server error" });
});

// Run every hour at minute 0
cron.schedule("0 * * * *", () => {
	console.log("⏰ [Cron] Running scheduled cleanup for expired one-time events...");
	deactivatePastEvents();
});
deactivatePastEvents(); // Run once at boot

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

const bookingRoutes = require("./routes/bookingRoutes");
app.use("/booking", bookingRoutes);
