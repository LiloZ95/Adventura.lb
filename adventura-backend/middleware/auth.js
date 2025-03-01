const jwt = require("jsonwebtoken");
require("dotenv").config();

function authenticateToken(req, res, next) {
	const authHeader = req.headers["authorization"];
	const token = authHeader && authHeader.split(" ")[1];

	if (!token) {
		console.error("❌ No token found in request headers.");
		return res.status(401).json({ error: "Access token missing" });
	}

	console.log("🔍 Received Token:", token);

	jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
		if (err) {
			console.error("❌ Token verification failed:", err.message);
			return res.status(403).json({ error: "Invalid token" });
		}

		console.log("✅ Decoded User:", user);

		if (!user.userId) {
			console.error("❌ Token payload does not contain userId:", user);
			return res.status(400).json({ error: "Invalid token payload" });
		}

		req.user = user; // ✅ Attach the userId to `req.user`
		console.log("🔹 User attached to request:", req.user);
		next();
	});
}

module.exports = { authenticateToken };
