const jwt = require("jsonwebtoken");

const authenticateToken = (req, res, next) => {
  const token = req.header("Authorization")?.split(" ")[1];

  console.log("Received Token:", token); // DEBUG: See if token is received

  if (!token) {
    return res.status(401).json({ error: "Access denied. No token provided." });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (err) {
    console.error("JWT Verification Failed:", err); // Debug JWT errors
    res.status(403).json({ error: "Invalid token" });
  }
};

module.exports = authenticateToken;
