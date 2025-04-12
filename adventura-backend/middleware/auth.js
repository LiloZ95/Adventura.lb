const jwt = require("jsonwebtoken");
const Provider = require("../models/Provider");
const User = require("../models/User");
require("dotenv").config();

async function authenticateToken(req, res, next) {
	const authHeader = req.headers["authorization"];
	const token = authHeader && authHeader.split(" ")[1];

	if (!token) {
		console.error("❌ No token found in request headers.");
		return res.status(401).json({ error: "Access token missing" });
	}

	console.log("🔍 Received Token:", token);

	try {
		const decoded = jwt.verify(token, process.env.JWT_SECRET);

		if (!decoded.userId) {
			console.error("❌ Token payload does not contain userId:", decoded);
			return res.status(400).json({ error: "Invalid token payload" });
		}

		const user = await User.findByPk(decoded.userId);

		if (!user) {
			console.error("❌ User not found in database.");
			return res.status(403).json({ error: "User not found" });
		}

		// ✅ Now safely fetch provider after decoding userId
		const provider = await Provider.findOne({
			where: { user_id: user.user_id },
		});

		req.user = {
			user_id: user.user_id,
			provider_id: provider?.provider_id || null,
			user_type: user.user_type,
			email: user.email,
		};

		console.log("🔐 ✅ Final decoded user:", req.user);

		next();
	} catch (err) {
		console.error("❌ Token verification failed:", err.message);
		return res.status(403).json({ error: "Invalid token" });
	}
}

module.exports = { authenticateToken };
