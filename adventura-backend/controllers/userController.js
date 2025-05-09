// controllers/userController.js
require("dotenv").config();

const bcrypt = require("bcryptjs"); // Use bcryptjs instead of bcrypt
const jwt = require("jsonwebtoken");
const { sequelize } = require("../db/db.js"); // Import Sequelize instance
const { softDeleteActivity } = require("../controllers/activityController");
const User = require("../models/User");
const UserPfp = require("../models/UserPfp");
const UserActivityInteraction = require("../models/UserActivityInteraction");
const Provider = require("../models/Provider"); // Import Provider model
const otpStore = {}; // Temporary storage for OTPs (replace with Redis or DB in production)
const { QueryTypes, where } = require("sequelize");
const { distributeUser } = require("../distributeUsers.js");
const nodemailer = require("nodemailer");
const Client = require("../models/client.js");
const Administrator = require("../models/Administrator.js");
const Booking = require("../models/Booking");
const Activity = require("../models/Activity");

const refreshTokens = new Set(); // Store refresh tokens (replace with DB for production)
const getProviderId = async (userId) => {
	const result = await sequelize.query(
		`SELECT provider_id FROM provider WHERE user_id = :userId LIMIT 1`,
		{ replacements: { userId }, type: QueryTypes.SELECT }
	);
	return result.length > 0 ? result[0].provider_id : null;
};

const getAllUsers = async (req, res) => {
	try {
		const [users] = await sequelize.query('SELECT * FROM "USER"'); // Raw query
		console.log("Fetched users:", users);
		res.status(200).json(users);
	} catch (err) {
		console.error("Database error:", err);
		res.status(500).json({ error: "Server error" });
	}
};

const getUserById = async (req, res) => {
	const userId = req.user?.userId;

	if (!userId) {
		console.error("❌ Missing user ID from token.");
		return res.status(401).json({ error: "Unauthorized" });
	}

	try {
		const user = await User.findByPk(userId);
		if (!user) {
			return res.status(404).json({ error: "User not found." });
		}
		res.status(200).json(user);
	} catch (error) {
		console.error("❌ Database error:", error);
		res.status(500).json({ error: "Server error" });
	}
};

// ✅ Admin-only: Fetch user by ID from URL
const getUserByIdPublic = async (req, res) => {
	const userId = req.params.id;

	if (!userId) {
		return res.status(400).json({ error: "User ID is required." });
	}

	try {
		const user = await User.findByPk(userId);
		if (!user) {
			return res.status(404).json({ error: "User not found." });
		}
		res.status(200).json(user);
	} catch (error) {
		console.error("❌ Error fetching user:", error);
		res.status(500).json({ error: "Server error" });
	}
};

const createUser = async (req, res) => {
	const {
		first_name,
		last_name,
		password,
		email,
		otp,
		location,
		user_type,
		phone_number, // optional now
	} = req.body;

	// ✅ Validate required fields
	if (!first_name || !last_name || !password || !email || !otp) {
		return res.status(400).json({ error: "Missing required fields." });
	}

	// ✅ Validate email format
	const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
	if (!emailRegex.test(email)) {
		return res.status(400).json({ error: "Invalid email format" });
	}

	try {
		// ✅ Check if user already exists
		const existingUser = await User.findOne({ where: { email } });
		if (existingUser) {
			return res
				.status(400)
				.json({ error: "User with this email already exists" });
		}

		// ✅ Validate OTP
		if (!otpStore[email] || otpStore[email].otp !== otp) {
			return res.status(400).json({ error: "Invalid or expired OTP" });
		}
		delete otpStore[email];

		// ✅ Hash password
		const hashedPassword = await bcrypt.hash(password, 10);

		// ✅ Create new user without requiring phone
		const newUser = await User.create({
			first_name,
			last_name,
			password_hash: hashedPassword,
			email,
			phone_number: phone_number || null, // optional
			location,
			user_type: user_type || "client",
		});

		console.log(
			`✅ New user "${newUser.first_name} ${newUser.last_name}" registered.`
		);

		await distributeUser(newUser);

		// ✅ Generate JWT
		const accessToken = jwt.sign(
			{
				userId: newUser.user_id,
				email: newUser.email,
				userType: newUser.user_type,
			},
			process.env.JWT_SECRET,
			{ expiresIn: "7d" }
		);

		const refreshToken = jwt.sign(
			{ userId: newUser.user_id },
			process.env.JWT_REFRESH_SECRET,
			{ expiresIn: "7d" }
		);

		refreshTokens.add(refreshToken);

		res.cookie("refreshToken", refreshToken, {
			httpOnly: true,
			secure: true,
			sameSite: "Strict",
		});

		res.status(201).json({
			message: "User registered successfully!",
			accessToken,
			refreshToken,
			user: {
				id: newUser.user_id,
				name: `${newUser.first_name} ${newUser.last_name}`,
				email: newUser.email,
			},
		});
	} catch (err) {
		console.error("❌ Error creating user:", err);
		res.status(500).json({ error: "Server error" });
	}
};

const updateUserPreferences = async (req, res) => {
	try {
		const { userId, preferences } = req.body;

		if (!userId || !preferences || preferences.length === 0) {
			return res
				.status(400)
				.json({ error: "User ID and preferences are required." });
		}

		// Remove old preferences
		await sequelize.query(
			`DELETE FROM user_preferences WHERE user_id = :userId`,
			{ replacements: { userId }, type: QueryTypes.DELETE }
		);

		// Insert new preferences with last_updated timestamp
		for (const category of preferences) {
			await sequelize.query(
				`INSERT INTO user_preferences (user_id, category_id, preference_level, last_updated)
		   VALUES (:userId, :categoryId, :preferenceLevel, NOW())`, // ✅ Set last_updated to current timestamp
				{
					replacements: {
						userId,
						categoryId: category.category_id,
						preferenceLevel: category.preference_level || 3, // Default level = 3
					},
					type: QueryTypes.INSERT,
				}
			);
		}

		res.status(200).json({ message: "User preferences updated successfully." });
	} catch (error) {
		console.error("❌ Error updating user preferences:", error);
		res.status(500).json({ error: "Server error updating preferences." });
	}
};

// Function to distribute user into correct table
// const distributeUser = async (user) => {
// 	try {
// 		switch (user.user_type) {
// 			case "provider":
// 				await sequelize.query(
// 					`INSERT INTO provider (user_id, business_name)
//            SELECT :userId, 'Default Business'
//            WHERE NOT EXISTS (SELECT 1 FROM PROVIDER WHERE user_id = :userId)`,
// 					{
// 						replacements: { userId: user.user_id },
// 						type: QueryTypes.INSERT,
// 					}
// 				);
// 				console.log(
// 					`✅ User "${user.first_name} ${user.last_name}" assigned to PROVIDER`
// 				);
// 				break;

// 			case "admin":
// 				await sequelize.query(
// 					`INSERT INTO administrator (user_id, permissions, admin_role)
//            SELECT :userId, 'All', 'Super Admin'
//            WHERE NOT EXISTS (SELECT 1 FROM ADMINISTRATOR WHERE user_id = :userId)`,
// 					{
// 						replacements: { userId: user.user_id },
// 						type: QueryTypes.INSERT,
// 					}
// 				);
// 				console.log(
// 					`✅ User "${user.first_name} ${user.last_name}" assigned to ADMINISTRATOR`
// 				);
// 				break;

// 			default: // Default all other users to CLIENT
// 				await sequelize.query(
// 					`INSERT INTO client (user_id, preferences, loyalty_points)
//            SELECT :userId, 'No preferences', 0
//            WHERE NOT EXISTS (SELECT 1 FROM CLIENT WHERE user_id = :userId)`,
// 					{
// 						replacements: { userId: user.user_id },
// 						type: QueryTypes.INSERT,
// 					}
// 				);
// 				console.log(
// 					`✅ User "${user.first_name} ${user.last_name}" assigned to CLIENT (Default)`
// 				);
// 				break;
// 		}
// 	} catch (error) {
// 		console.error(
// 			`❌ Error distributing user "${user.first_name} ${user.last_name}":`,
// 			error
// 		);
// 	}
// };

const updateUser = async (req, res) => {
	const { id } = req.params;
	const { username, password, email, phone_number, location, user_type } =
		req.body;

	try {
		let password_hash = null;

		if (password) {
			password_hash = await bcrypt.hash(password, 10); // Hash new password
		}

		const { rows } = await db.query(
			'UPDATE "USER" SET username = $1, password_hash = COALESCE($2, password_hash), email = $3, phone_number = $4, location = $5, user_type = $6 WHERE user_id = $7 RETURNING *',
			[username, password_hash, email, phone_number, location, user_type, id]
		);

		if (rows.length === 0) {
			return res.status(404).send("User not found");
		}

		res.status(200).json(rows[0]);
	} catch (err) {
		console.error(err);
		res.status(500).send("Server error");
	}
};

// Delete user from every table.
const deleteUser = async (req, res) => {
	const { id } = req.params;

	if (!id) {
		return res
			.status(400)
			.json({ success: false, error: "User ID is required." });
	}

	console.log(`🗑 Attempting to delete user with ID: ${id}`);
	const transaction = await sequelize.transaction();

	try {
		// 1️⃣ Handle client bookings
		const client = await Client.findOne({
			where: { user_id: id },
			transaction,
		});
		if (client) {
			const clientId = client.client_id;
			console.log("→ Deleting bookings for client_id:", clientId);
			await Booking.destroy({ where: { client_id: clientId }, transaction });
			console.log("   ✅ Client bookings deleted");
		}

		// 2️⃣ Handle provider activity bookings & soft delete activities
		const provider = await Provider.findOne({
			where: { user_id: id },
			transaction,
		});
		if (provider) {
			const providerId = provider.provider_id;

			const activities = await Activity.findAll({
				where: { provider_id: providerId },
				transaction,
			});

			const activityIds = activities.map((a) => a.activity_id);
			if (activityIds.length > 0) {
				console.log(
					"→ Deleting bookings for provider's activities:",
					activityIds
				);
				await Booking.destroy({
					where: { activity_id: activityIds },
					transaction,
				});
				console.log("   ✅ Provider's activity bookings deleted");

				console.log("→ Soft-deleting provider's activities...");
				for (const activity of activities) {
					await activity.update(
						{ availability_status: false },
						{ transaction }
					);
					console.log(`   ⛔ Soft-deleted activity ID ${activity.activity_id}`);
				}
			}
		}

		// 3️⃣ Admins — informational only
		const admin = await Administrator.findOne({
			where: { user_id: id },
			transaction,
		});
		if (admin) {
			console.log("ℹ️ Admin account found. Proceeding with deletion.");
		}

		// 4️⃣ Delete from other tables
		await Provider.destroy({ where: { user_id: id }, transaction });
		await Administrator.destroy({ where: { user_id: id }, transaction });
		await Client.destroy({ where: { user_id: id }, transaction });
		await UserActivityInteraction.destroy({
			where: { user_id: id },
			transaction,
		});
		await User.destroy({ where: { user_id: id }, transaction });

		await transaction.commit();
		res.status(200).json({
			success: true,
			message: `User ${id} and all related data/bookings/activities deleted.`,
		});
	} catch (err) {
		console.error("❌ Error during user deletion:", err);
		await transaction.rollback();
		res.status(500).json({
			success: false,
			error: err.message || "Server error during user deletion.",
		});
	}
};

const loginUser = async (req, res) => {
	const { email, password } = req.body;

	try {
		console.log("🔐 Attempting login for:", email);

		// Use Sequelize's findOne instead of raw SQL
		const user = await User.findOne({ where: { email } });

		if (!user) {
			console.log("❌ User not found for email:", email);
			return res.status(404).json({ message: "User not found" });
		}

		let provider_id = null;

		if (user.user_type === "provider") {
			const providerExists = await Provider.findOne({
				where: { user_id: user.user_id },
			});

			if (!providerExists) {
				await Provider.create({
					user_id: user.user_id,
					business_name: "Default Business",
				});
				console.log("🛠️ Auto-created provider record for user", user.user_id);
			}

			const fetchedProvider = await Provider.findOne({
				where: { user_id: user.user_id },
			});
			provider_id = fetchedProvider?.provider_id;
			console.log("✅ Provider ID fetched:", provider_id);
		}

		// Compare entered password with hashed password
		const isMatch = await bcrypt.compare(password, user.password_hash);
		if (!isMatch) {
			console.log("❌ Invalid password for:", email);
			return res.status(401).json({ error: "Invalid password" });
		}

		const accessToken = jwt.sign(
			{
				userId: user.user_id,
				email: user.email,
				userType: user.user_type,
				provider_id: provider_id, // ✅ now defined
			},
			process.env.JWT_SECRET,
			{ expiresIn: "7d" }
		);

		const refreshToken = jwt.sign(
			{ userId: user.user_id },
			process.env.JWT_REFRESH_SECRET,
			{ expiresIn: "7d" }
		);

		refreshTokens.add(refreshToken);
		await user.update({ lastLogin: new Date() });

		res.cookie("refreshToken", refreshToken, {
			httpOnly: true,
			secure: true,
			sameSite: "Strict",
		});

		console.log("🎟️ Login successful for:", user.email);
		console.log("🔑 JWT payload:", {
			userId: user.user_id,
			email: user.email,
			userType: user.user_type,
			provider_id,
		});

		res.status(200).json({
			message: "Login successful!",
			accessToken,
			refreshToken,
			user: {
				user_id: user.user_id,
				first_name: user.first_name,
				last_name: user.last_name,
				email: user.email,
				user_type: user.user_type,
				provider_id: provider_id,
			},
		});
	} catch (err) {
		console.error("Login error:", err);
		res.status(500).json({ error: "Server error" });
	}
};

const refreshAccessToken = async (req, res) => {
	try {
		const { refreshToken } = req.body;
		if (!refreshToken) {
			return res.status(400).json({ error: "Refresh token missing." });
		}

		if (!refreshTokens.has(refreshToken)) {
			return res.status(403).json({ error: "Unrecognized refresh token" });
		}

		// Verify the token
		jwt.verify(
			refreshToken,
			process.env.JWT_REFRESH_SECRET,
			async (err, decoded) => {
				if (err) {
					console.error("❌ Refresh token error:", err.message);
					return res
						.status(401)
						.json({ error: "Invalid or expired refresh token." });
				}

				const userId = decoded.userId;
				const user = await User.findByPk(userId);
				if (!user) {
					return res.status(404).json({ error: "User not found." });
				}

				// Check lastLogin timing
				const lastLogin = new Date(user.lastLogin || 0);
				const now = new Date();
				const diffDays = (now - lastLogin) / (1000 * 60 * 60 * 24);

				if (diffDays > 7) {
					return res
						.status(403)
						.json({ error: "Session expired. Please log in again." });
				}

				// Issue new tokens
				const newAccessToken = jwt.sign(
					{ userId: user.user_id, email: user.email },
					process.env.JWT_SECRET,
					{ expiresIn: "7d" }
				);

				const newRefreshToken = jwt.sign(
					{ userId: user.user_id },
					process.env.JWT_REFRESH_SECRET,
					{ expiresIn: "7d" }
				);

				refreshTokens.add(newRefreshToken); // Add the new one
				refreshTokens.delete(refreshToken); // Invalidate the old one
				await user.update({ lastLogin: new Date() });

				return res.status(200).json({
					success: true,
					accessToken: newAccessToken,
					refreshToken: newRefreshToken,
				});
			}
		);
	} catch (err) {
		console.error("❌ Error refreshing token:", err.message);
		res.status(500).json({ error: "Internal server error." });
	}
};

// ✅ Logout Handler
const logoutUser = (req, res) => {
	const { refreshToken } = req.body;
	if (!refreshToken || !refreshTokens.has(refreshToken)) {
		return res
			.status(403)
			.json({ message: "Invalid or missing refresh token" });
	}
	refreshTokens.delete(refreshToken);
	res.status(200).json({ message: "Logged out successfully!" });
};

// ✅ Token Validation
const validateToken = (req, res) => {
	const token = req.header("Authorization")?.split(" ")[1];
	if (!token) return res.status(401).json({ error: "No token provided." });
	try {
		const decoded = jwt.verify(token, process.env.JWT_SECRET);
		res.status(200).json({
			success: true,
			message: "Token is valid.",
			userId: decoded.userId,
		});
	} catch (err) {
		res.status(401).json({ error: "Invalid or expired token." });
	}
};

// ✅ Dashboard Example
const getDashboard = (req, res) => {
	res.json({
		message: `Welcome ${req.user.email}, your role is ${req.user.userType}`,
	});
};

// ✅ OTP Handlers
const sendOtp = async (req, res) => {
	const { email, isForSignup } = req.body;

	try {
		if (!isForSignup) {
			const user = await User.findOne({ where: { email } });
			if (!user) return res.status(404).json({ error: "User not found" });
		}

		const otp = Math.floor(100000 + Math.random() * 900000).toString();
		otpStore[email] = { otp, expiresAt: Date.now() + 5 * 60 * 1000 };

		const transporter = nodemailer.createTransport({
			host: process.env.SMTP_HOST,
			port: process.env.SMTP_PORT,
			secure: true,
			auth: {
				user: process.env.EMAIL,
				pass: process.env.EMAIL_PASSWORD,
			},
		});

		const subject = isForSignup
			? "Welcome to Adventura! Verify Your Email"
			: "Adventura Password Reset Request";

		const actionText = isForSignup
			? "sign up for Adventura"
			: "reset your Adventura password";

		const htmlContent = `
			<div style="font-family: Arial, sans-serif; color: #333;">
				<h2>${subject}</h2>
				<p>We received a request to ${actionText} using this email address.</p>
				<p><strong>Your One-Time Password (OTP):</strong></p>
				<p style="font-size: 24px; font-weight: bold;">${otp}</p>
				<p>This OTP will expire in <strong>5 minutes</strong>.</p>
				<p>If you didn't request this, please ignore this message.</p>
				<p>— The Adventura Team</p>
			</div>
		`;

		await transporter.sendMail({
			from: `"noreply-Adventura" <${process.env.EMAIL}>`,
			to: email,
			subject,
			html: htmlContent,
		});

		console.log(`🔐 OTP sent to ${email}: ${otp}`);
		res.status(200).json({ success: true, message: "OTP sent successfully" });
	} catch (error) {
		console.error("❌ Error sending OTP:", error);
		res.status(500).json({ error: "Failed to send OTP" });
	}
};

const resendOtp = sendOtp;

const verifyOtp = async (req, res) => {
	const {
		email,
		otp,
		isForSignup,
		firstName,
		lastName,
		phoneNumber,
		password,
	} = req.body;
	const stored = otpStore[email];
	if (!stored || stored.otp !== otp || Date.now() > stored.expiresAt) {
		return res.status(400).json({ error: "Invalid or expired OTP" });
	}
	delete otpStore[email];

	let user = await User.findOne({ where: { email } });
	if (isForSignup && !user) {
		const hashedPassword = await bcrypt.hash(password, 10);
		user = await User.create({
			first_name: firstName,
			last_name: lastName,
			email,
			phone_number: phoneNumber,
			password_hash: hashedPassword,
			user_type: "client",
		});
		await distributeUser(user);
	}

	const accessToken = jwt.sign(
		{ userId: user.user_id },
		process.env.JWT_SECRET,
		{ expiresIn: "7d" }
	);
	const refreshToken = jwt.sign(
		{ userId: user.user_id },
		process.env.JWT_REFRESH_SECRET,
		{ expiresIn: "7d" }
	);
	refreshTokens.add(refreshToken);

	res.cookie("refreshToken", refreshToken, {
		httpOnly: true,
		secure: true,
		sameSite: "Strict",
	});
	res.status(200).json({ success: true, accessToken, refreshToken, user });
};

// ✅ Profile Picture Handling
const uploadProfilePicture = async (req, res) => {
	const user_id = req.body.user_id || req.query.user_id;
	const imageBuffer = req.file?.buffer;
	if (!user_id || !imageBuffer)
		return res.status(400).json({ error: "Missing user ID or image." });

	const existing = await UserPfp.findOne({ where: { user_id } });
	if (existing)
		await UserPfp.update({ image_data: imageBuffer }, { where: { user_id } });
	else await UserPfp.create({ user_id, image_data: imageBuffer });
	res.status(200).json({ success: true, message: "Profile picture saved." });
};

const getProfilePicture = async (req, res) => {
	const userPfp = await UserPfp.findOne({ where: { user_id: req.params.id } });
	if (!userPfp) return res.status(404).json({ error: "Not found" });
	const imageBase64 = userPfp.image_data.toString("base64");
	res.status(200).json({ image: `data:image/png;base64,${imageBase64}` });
};

const deleteProfilePicture = async (req, res) => {
	const deleted = await UserPfp.destroy({ where: { user_id: req.params.id } });
	if (!deleted) return res.status(404).json({ error: "Not found" });
	res.status(200).json({ message: "Profile picture deleted" });
};
const resetPassword = async (req, res) => {
	const { email, newPassword } = req.body;

	if (!email || !newPassword) {
		return res.status(400).json({ error: "Email and new password are required." });
	}

	try {
		const user = await User.findOne({ where: { email } });
		if (!user) {
			return res.status(404).json({ error: "User not found." });
		}

		const hashedPassword = await bcrypt.hash(newPassword, 10);
		await user.update({ password_hash: hashedPassword });

		res.status(200).json({ success: true, message: "Password reset successful." });
	} catch (error) {
		console.error("❌ Error resetting password:", error);
		res.status(500).json({ error: "Server error." });
	}
};

// ✅ Activity Image Upload
// const uploadActivityImages = async (req, res) => {
// 	const { activity_id } = req.params;
// 	if (!req.files?.length)
// 		return res.status(400).json({ error: "No images uploaded." });

// 	for (const file of req.files) {
// 		await sequelize.query(
// 			`INSERT INTO activity_images (activity_id, image_url) VALUES (:activity_id, :image_url)`,
// 			{
// 				replacements: {
// 					activity_id,
// 					image_url: `data:image/png;base64,${file.buffer.toString("base64")}`,
// 				},
// 				type: QueryTypes.INSERT,
// 			}
// 		);
// 	}
// 	res.status(200).json({ message: "Images uploaded successfully." });
// };

module.exports = {
	getAllUsers,
	getUserById,
	getUserByIdPublic,
	createUser,
	updateUserPreferences,
	updateUser,
	deleteUser,
	loginUser,
	refreshAccessToken,
	logoutUser,
	validateToken,
	getDashboard,
	sendOtp,
	resendOtp,
	verifyOtp,
	uploadProfilePicture,
	getProfilePicture,
	deleteProfilePicture,
	resetPassword,

	// uploadActivityImages,
};
