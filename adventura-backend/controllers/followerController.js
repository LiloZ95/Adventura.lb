// controllers/followerController.js
const Followers = require("../models/Followers");
const { followQueue } = require("../queues/followQueue");
// const Provider = require("../models/Provider");
const { User, UserPfp, Provider} = require("../models/index");
// const UserPfp = require("../models/UserPfp");

// Follow Organizer
const followOrganizer = async (req, res) => {
	const { user_id, provider_id } = req.body;

	if (!user_id || !provider_id) {
		return res.status(400).json({ error: "Missing user_id or provider_id" });
	}

	try {
		const provider = await Provider.findByPk(provider_id);

		if (!provider) {
			return res.status(404).json({ error: "Provider not found" });
		}

		// Check if the user owns this provider account
		if (provider.user_id === parseInt(user_id)) {
			return res.status(400).json({ error: "You cannot follow yourself." });
		}

		const alreadyFollowed = await Followers.findOne({
			where: { user_id, provider_id },
		});
		if (alreadyFollowed) {
			return res.status(400).json({ error: "Already following" });
		}

		await Followers.create({ user_id, provider_id });
		await followQueue.add("follow", { user_id, provider_id });

		res.status(201).json({ success: true, message: "Followed successfully." });
	} catch (err) {
		console.error(err);
		res.status(500).json({ error: "Server error" });
	}
};

// Unfollow Organizer
const unfollowOrganizer = async (req, res) => {
	const { user_id, provider_id } = req.body;

	if (!user_id || !provider_id) {
		return res.status(400).json({ error: "Missing user_id or provider_id" });
	}

	try {
		const deleted = await Followers.destroy({
			where: { user_id, provider_id },
		});

		if (!deleted) {
			return res.status(404).json({ error: "Not following" });
		}

		res
			.status(200)
			.json({ success: true, message: "Unfollowed successfully." });
	} catch (err) {
		console.error(err);
		res.status(500).json({ error: "Server error" });
	}
};

// Get Followers Count
const getFollowersCount = async (req, res) => {
	const { provider_id } = req.params;

	try {
		const count = await Followers.count({ where: { provider_id } });
		res.status(200).json({ success: true, followersCount: count });
	} catch (err) {
		console.error(err);
		res.status(500).json({ error: "Server error" });
	}
};

// Check if User is Following
const isFollowing = async (req, res) => {
	const { user_id, provider_id } = req.query;

	if (!user_id || !provider_id) {
		return res.status(400).json({ error: "Missing user_id or provider_id" });
	}

	try {
		const following = await Followers.findOne({
			where: { user_id, provider_id },
		});
		res.status(200).json({ isFollowing: !!following });
	} catch (err) {
		console.error(err);
		res.status(500).json({ error: "Server error" });
	}
};

const getFollowersList = async (req, res) => {
	const { provider_id } = req.params;

	try {
		const followers = await Followers.findAll({
			where: { provider_id },
			include: [
				{
					model: User,
					as: "user", // 🔥 ADD THIS
					attributes: ["user_id", "first_name", "last_name"],
					include: [
						{
							model: UserPfp,
							attributes: ["image_data"],
							as: "user_pfp",
						},
					],
				},
			],
		});

		const mappedFollowers = followers.map((f) => ({
			user_id: f.user.user_id,
			firstName: f.user.first_name,
			lastName: f.user.last_name,
			profilePicture: f.user.user_pfp ? f.user.user_pfp.image_data : null,
		}));

		res.status(200).json({ success: true, followers: mappedFollowers });
	} catch (error) {
		console.error(error);
		res.status(500).json({ error: "Server Error" });
	}
};

module.exports = {
	followOrganizer,
	unfollowOrganizer,
	getFollowersCount,
	isFollowing,
	getFollowersList,
};
