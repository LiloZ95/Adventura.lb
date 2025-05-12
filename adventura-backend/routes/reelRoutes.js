const express = require("express");
const router = express.Router();
const path = require("path");
const fs = require("fs");
const multer = require("multer");
const { authenticateToken } = require("../middleware/auth");
const {
	getAllReels,
	uploadReel,
	likeReel,
	getLikes,
	postComment,
	getComments,
} = require("../controllers/reelController");

// 🔧 Custom storage to store in `uploads/reels/{provider_id}/`
const storage = multer.diskStorage({
	destination: function (req, file, cb) {
		const providerId = req.user.provider_id;
		const uploadPath = path.join(
			__dirname,
			"..",
			"uploads",
			"reels",
			String(providerId)
		);

		// Ensure the folder exists
		fs.mkdirSync(uploadPath, { recursive: true });

		cb(null, uploadPath);
	},
	filename: function (req, file, cb) {
		const timestamp = Date.now();
		const ext = path.extname(file.originalname);
		cb(null, `reel_${timestamp}${ext}`);
	},
});

const upload = multer({ storage });

// Public: Get all reels
router.get("/", getAllReels);

// Protected: Upload a reel (Provider-only)
router.post("/upload", authenticateToken, upload.single("video"), uploadReel);

router.post("/:reelId/like", authenticateToken, likeReel);
router.get("/:reelId/likes", getLikes);
router.post("/:reelId/comments", authenticateToken, postComment);
router.get("/:reelId/comments", getComments);

module.exports = router;
