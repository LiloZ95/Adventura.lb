// controllers/reelController.js

const { sequelize } = require("../db/db.js");

const Reel = require("../models/Reel");
const Provider = require("../models/Provider");
const ReelLike = require("../models/ReelLike");
const ReelComment = require("../models/ReelComment");

// ✅ Upload a new reel (Provider-only)
const uploadReel = async (req, res) => {
	try {
		const user = req.user;

		console.log("📥 Incoming uploadReel request from user:", user);

		if (!user) {
			return res.status(401).json({ error: "Unauthorized access" });
		}

		if (user.user_type !== "provider") {
			console.log("🚫 User is not a provider:", user.user_type);
			return res
				.status(403)
				.json({ error: "Only providers can upload reels." });
		}

		const providerId = user.provider_id;
		if (!providerId) {
			console.log("❌ Missing provider_id in token:", user);
			return res
				.status(403)
				.json({ error: "Only providers can upload reels." });
		}

		console.log("📦 Received fields:", req.body);

		const description = req.body.description;
		const file = req.file;

		if (!file || !description) {
			console.log("⚠️ Missing video file or description");
			return res
				.status(400)
				.json({ error: "Missing video file or description." });
		}

		// Construct public URL
		const videoUrl = `/uploads/reels/${providerId}/${file.filename}`;

		console.log("✅ Creating new reel for provider_id:", providerId);

		const newReel = await Reel.create({
			video_url: videoUrl,
			description,
			provider_id: providerId,
		});

		console.log("✅ Reel created successfully:", newReel.reel_id);

		console.log("📂 Uploaded file details:", {
			original: req.file.originalname,
			path: req.file.path,
			mimetype: req.file.mimetype,
			size: req.file.size,
		});

		return res
			.status(201)
			.json({ message: "Reel uploaded successfully!", reel: newReel });
	} catch (err) {
		console.error("❌ Error in uploadReel:", err);
		return res.status(500).json({ error: "Internal server error" });
	}
};

// ✅ Fetch all reels (public)
const getAllReels = async (req, res) => {
	try {
		const userId = req.user?.userId || null;

		const reels = await Reel.findAll({
			order: [["timestamp", "DESC"]],
			include: [{ model: Provider, attributes: ["business_name"] }],
		});

		if (userId) {
			const likedReels = await ReelLike.findAll({
				where: { user_id: userId },
				attributes: ["reel_id"],
			});

			const likedIds = likedReels.map((r) => r.reel_id);

			const likeCounts = await ReelLike.findAll({
				attributes: [
					"reel_id",
					[sequelize.fn("COUNT", sequelize.col("id")), "count"],
				],
				group: ["reel_id"],
			});
			const likeMap = Object.fromEntries(
				likeCounts.map((r) => [r.reel_id, parseInt(r.dataValues.count)])
			);

			for (const reel of reels) {
				reel.dataValues.liked = likedIds.includes(reel.reel_id);
				reel.dataValues.likeCount = likeMap[reel.reel_id] || 0;
			}
		}

		res.status(200).json(reels);
	} catch (err) {
		console.error("❌ Fetch reels error:", err);
		res.status(500).json({ error: "Failed to fetch reels." });
	}
};

const likeReel = async (req, res) => {
	const { reelId } = req.params;
	const userId = req.user.userId;

	const existing = await ReelLike.findOne({
		where: { user_id: userId, reel_id: reelId },
	});

	if (existing) {
		await existing.destroy();
		return res.json({ liked: false });
	} else {
		await ReelLike.create({ user_id: userId, reel_id: reelId });
		return res.json({ liked: true });
	}
};

const getLikes = async (req, res) => {
	const { reelId } = req.params;
	const count = await ReelLike.count({ where: { reel_id: reelId } });
	res.json({ likes: count });
};

const postComment = async (req, res) => {
	const { reelId } = req.params;
	const { text } = req.body;
	const userId = req.user.userId;

	const comment = await ReelComment.create({
		user_id: userId,
		reel_id: reelId,
		text,
	});
	res.status(201).json(comment);
};

const getComments = async (req, res) => {
	const { reelId } = req.params;
	const comments = await ReelComment.findAll({
		where: { reel_id: reelId },
		include: [{ model: User, attributes: ["first_name", "last_name"] }],
		order: [["timestamp", "ASC"]],
	});
	res.json(comments);
};

module.exports = {
	uploadReel,
	getAllReels,
	likeReel,
	getLikes,
	postComment,
	getComments,
};
