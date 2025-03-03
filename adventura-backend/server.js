require("dotenv").config(); // ✅ Load environment variables at the top

const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const bodyParser = require("body-parser");
const { connectDB, sequelize } = require("./db/db.js"); // Import Sequelize instance
const userRoutes = require("./routes/userRoutes"); // Import user routes
const recommendationRoutes = require("./routes/recommendationRoutes");
const { authenticateToken } = require("./middleware/auth.js");
const Client = require("./models/client"); // Import Client model
const { getUserById } = require("./controllers/userController");
const categoryRoutes = require("./routes/categoryRoutes"); // Import category routes

const app = express();

// ✅ Middleware
app.use(bodyParser.json());
app.use(cors());
app.use(helmet());
app.use(express.json());

// ✅ Ensure database connection before setting up routes
connectDB()
	.then(async () => {
		try {
			await sequelize.sync({ alter: true });
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
app.use("/recommendations", recommendationRoutes);
app.use("/categories", categoryRoutes); // Add category routes
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
