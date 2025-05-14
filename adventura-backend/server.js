// ===========================================================
// ✅ Load Environment Variables & Modules
// ===========================================================
require("dotenv").config();
const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const bodyParser = require("body-parser");
const path = require("path");
const cron = require("node-cron");
const mime = require("mime-types");
const serveStatic = require("serve-static");
const uploadsPath = path.join(__dirname, "uploads");
// ===========================================================
// ✅ Database & ORM Setup
// ===========================================================
const { connectDB } = require("./db/db.js");
const { sequelize } = require("./models");

// ===========================================================
// ✅ Cron Tasks
// ===========================================================
const { deactivatePastEvents } = require("./controllers/activityController");
const updateTrendingActivities = require("./controllers/trendingUpdater");

// Run once on server boot
// updateTrendingActivities();
// deactivatePastEvents();

// Schedule periodic jobs
cron.schedule("0 * * * *", () => {
	console.log("⏰ [Cron] Cleaning expired one-time events...");
	deactivatePastEvents();
});

cron.schedule("0 */6 * * *", () => {
	console.log("🔥 [Cron] Updating trending activities...");
	updateTrendingActivities();
});

// ===========================================================
// ✅ Initialize Express App
// ===========================================================
const app = express();

// ===========================================================
// ✅ Middleware Setup
// ===========================================================
app.use(bodyParser.json());
app.use(
	cors({
		origin: "*",
		methods: ["GET", "POST", "PATCH", "PUT", "DELETE", "OPTIONS"],
		allowedHeaders: ["Content-Type", "Authorization"],
	})
);
app.use(
	helmet({
		crossOriginResourcePolicy: false,
	})
);

app.use(express.json());

// ===========================================================
// ✅ Static File Serving
// ===========================================================
app.use("/images", express.static(path.join(__dirname, "public/images")));

// ===========================================================
// ✅ Route Imports
// ===========================================================
const userRoutes = require("./routes/userRoutes");
const categoryRoutes = require("./routes/categoryRoutes");
const activityRoutes = require("./routes/activityRoutes");
const eventRoutes = require("./routes/eventRoutes");
const recommendationRoutes = require("./routes/recommendationRoutes");
const interactionRoutes = require("./routes/interactionRoutes");
const availabilityRoutes = require("./routes/availabilityRoutes");
const bookingRoutes = require("./routes/bookingRoutes");
const adminRoutes = require("./routes/adminRoutes");
const providerRequestRoutes = require("./routes/providerRequestRoutes");
const notificationRoutes = require("./routes/notificationRoutes");
const adminNotificationRoutes = require("./routes/adminNotificationRoutes");
const followerRoutes = require("./routes/followerRoutes");
const notificationPreferenceRoutes = require("./routes/notificationPreferenceRoutes");
const reelRoutes = require("./routes/reelRoutes");

// const socialAuthRoutes = require('./routes/socialAuthRoutes'); // optional

// ===========================================================
// ✅ Register API Routes
// ===========================================================
const { authenticateToken } = require("./middleware/auth.js");
const { getUserById } = require("./controllers/userController");

app.use("/users", userRoutes);
app.get("/users/profile", authenticateToken, getUserById);
app.use("/categories", categoryRoutes);
app.use("/activities", activityRoutes);
app.use("/events", eventRoutes); // ✅ Place after activities to avoid path collisions
app.use("/recommendations", recommendationRoutes);
app.use("/api", interactionRoutes); // Interaction endpoints
app.use("/availability", availabilityRoutes);
app.use("/booking", bookingRoutes);
app.use("/admin", adminRoutes); // ← important to keep this prefix!
app.use("/api", providerRequestRoutes); // Provider request routes
app.use("/followers", followerRoutes); // Follower routes
app.use("/", notificationRoutes);
app.use("/admin", adminNotificationRoutes);
app.use("/notification-preferences", notificationPreferenceRoutes);
app.use(
  "/uploads",
  serveStatic(uploadsPath, {
    setHeaders: (res, filePath) => {
      res.setHeader("Access-Control-Allow-Origin", "*");
      res.setHeader("Access-Control-Allow-Methods", "GET, OPTIONS");
      res.setHeader("Access-Control-Allow-Headers", "Origin, Content-Type, Accept");

      const contentType = mime.lookup(filePath);
      if (contentType) {
        res.setHeader("Content-Type", contentType);
      }
    },
    acceptRanges: true, // 🔥 this is important for video streaming
  })
);
app.use("/reels", reelRoutes); // Reel routes

// ===========================================================
app.use((err, req, res, next) => {
	console.error("❌ Server Error:", err);
	res.status(500).json({ error: "Internal server error" });
});

// ===========================================================
// ✅ Database Connection & Sync
// ===========================================================
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

// ===========================================================
// ✅ Start Server
// ===========================================================
const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || "0.0.0.0";

app.listen(PORT, HOST, () => {
	console.log(`🚀 Server running on http://${HOST}:${PORT}`);
});

// ===========================================================
// ✅ Handle Fatal Errors Gracefully
// ===========================================================
process.on("uncaughtException", (err) => {
	console.error("❌ Uncaught Exception:", err);
});

process.on("unhandledRejection", (reason, promise) => {
	console.error("❌ Unhandled Promise Rejection:", reason);
});
