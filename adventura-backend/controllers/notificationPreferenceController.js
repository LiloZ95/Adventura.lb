const NotificationPreference = require("../models/NotificationPreference");

const setNotificationPreference = async (req, res) => {
	const { user_id, provider_id, allow_notifications } = req.body;

	if (!user_id || !provider_id || allow_notifications === undefined) {
		return res.status(400).json({ error: "Missing required fields" });
	}

	try {
		let preference = await NotificationPreference.findOne({
			where: { user_id, provider_id },
		});

		if (preference) {
			// Update
			preference.allow_notifications = allow_notifications;
			preference.updated_at = new Date();
			await preference.save();
		} else {
			// Create
			await NotificationPreference.create({
				user_id,
				provider_id,
				allow_notifications,
			});
		}

		res.status(200).json({ success: true, message: "Preference updated" });
	} catch (err) {
		console.error(err);
		res.status(500).json({ error: "Server error" });
	}
};

const getNotificationPreference = async (req, res) => {
	const { user_id, provider_id } = req.query;

	if (!user_id || !provider_id) {
		return res.status(400).json({ error: "Missing user_id or provider_id" });
	}

	try {
		const preference = await NotificationPreference.findOne({
			where: { user_id, provider_id },
		});

		res
			.status(200)
			.json({
				allow_notifications: preference ? preference.allow_notifications : true,
			});
	} catch (err) {
		console.error(err);
		res.status(500).json({ error: "Server error" });
	}
};

module.exports = { setNotificationPreference, getNotificationPreference };
