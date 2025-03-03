// controllers/userController.js
const bcrypt = require("bcryptjs"); // Use bcryptjs instead of bcrypt
const jwt = require("jsonwebtoken");
const { sequelize } = require("../db/db.js"); // Import Sequelize instance
const User = require("../models/User");
const { QueryTypes } = require("sequelize");

const refreshTokens = new Set(); // Store refresh tokens (replace with DB for production)

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
	console.log("🔍 Incoming request to getUserById...");
	console.log("🔹 Checking `req.user`: ", req.user);

	if (!req.user || !req.user.userId) {
		console.error("❌ Missing userId in request.");
		return res.status(400).json({ error: "User ID is required." });
	}

	const userId = req.user.userId;

	try {
		console.log(`🔍 Fetching user with ID: ${userId}`);
		const user = await User.findByPk(userId); // ✅ Query the correct user_id

		if (!user) {
			console.log("❌ User not found.");
			return res.status(404).json({ error: "User not found." });
		}

		console.log("✅ User found:", user);
		res.status(200).json(user);
	} catch (error) {
		console.error("❌ Database error:", error);
		res.status(500).json({ error: "Server error" });
	}
};

const createUser = async (req, res) => {
	const {
		first_name,
		last_name,
		password,
		email,
		phone_number,
		location,
		user_type,
		otp,
	} = req.body;

	// Validate required fields
	if (
		!first_name ||
		!last_name ||
		!password ||
		!email ||
		!phone_number ||
		!otp
	) {
		return res
			.status(400)
			.json({ error: "All fields are required, including OTP" });
	}

	// Validate email format
	const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
	if (!emailRegex.test(email)) {
		return res.status(400).json({ error: "Invalid email format" });
	}

	try {
		// Check if user already exists
		const existingUser = await User.findOne({ where: { email } });
		if (existingUser) {
			return res
				.status(400)
				.json({ error: "User with this email already exists" });
		}

		// **Validate OTP before proceeding**
		if (!otpStore[email] || otpStore[email].otp !== otp) {
			return res.status(400).json({ error: "Invalid or expired OTP" });
		}

		// **OTP is valid, delete it from storage**
		delete otpStore[email];

		// Hash the password
		const hashedPassword = await bcrypt.hash(password, 10);

		// Create new user
		const newUser = await User.create({
			first_name,
			last_name,
			password_hash: hashedPassword,
			email,
			phone_number,
			location,
			user_type: user_type || "client", // Default to client if not specified
		});

		console.log(
			`✅ New user "${newUser.first_name} ${newUser.last_name}" registered.`
		);

		// **Distribute the user to the correct category (client, provider, admin)**
		await distributeUser(newUser);

		// **Generate JWT tokens**
		const accessToken = jwt.sign(
			{
				userId: newUser.user_id,
				email: newUser.email,
				userType: newUser.user_type,
			},
			process.env.JWT_SECRET,
			{ expiresIn: "15m" } // Access token expires in 15 minutes
		);

		const refreshToken = jwt.sign(
			{ userId: newUser.user_id },
			process.env.JWT_REFRESH_SECRET,
			{ expiresIn: "7d" } // Refresh token expires in 7 days
		);

		// Store refresh token in memory (replace with database storage in production)
		refreshTokens.add(refreshToken);

		// **Send refresh token as HTTP-only cookie**
		res.cookie("refreshToken", refreshToken, {
			httpOnly: true,
			secure: true, // Use `true` in production (requires HTTPS)
			sameSite: "Strict",
		});

		// **Return tokens to frontend**
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

		// Insert new preferences
		for (const category of preferences) {
			await sequelize.query(
				`INSERT INTO user_preferences (user_id, category_id, preference_level)
		   VALUES (:userId, :categoryId, :preferenceLevel)`,
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
const distributeUser = async (user) => {
	try {
		switch (user.user_type) {
			case "provider":
				await sequelize.query(
					`INSERT INTO provider (user_id, business_name) 
           SELECT :userId, 'Default Business' 
           WHERE NOT EXISTS (SELECT 1 FROM PROVIDER WHERE user_id = :userId)`,
					{
						replacements: { userId: user.user_id },
						type: QueryTypes.INSERT,
					}
				);
				console.log(
					`✅ User "${user.first_name} ${user.last_name}" assigned to PROVIDER`
				);
				break;

			case "admin":
				await sequelize.query(
					`INSERT INTO administrator (user_id, permissions, admin_role) 
           SELECT :userId, 'All', 'Super Admin' 
           WHERE NOT EXISTS (SELECT 1 FROM ADMINISTRATOR WHERE user_id = :userId)`,
					{
						replacements: { userId: user.user_id },
						type: QueryTypes.INSERT,
					}
				);
				console.log(
					`✅ User "${user.first_name} ${user.last_name}" assigned to ADMINISTRATOR`
				);
				break;

			default: // Default all other users to CLIENT
				await sequelize.query(
					`INSERT INTO client (user_id, preferences, loyalty_points) 
           SELECT :userId, 'No preferences', 0 
           WHERE NOT EXISTS (SELECT 1 FROM CLIENT WHERE user_id = :userId)`,
					{
						replacements: { userId: user.user_id },
						type: QueryTypes.INSERT,
					}
				);
				console.log(
					`✅ User "${user.first_name} ${user.last_name}" assigned to CLIENT (Default)`
				);
				break;
		}
	} catch (error) {
		console.error(
			`❌ Error distributing user "${user.first_name} ${user.last_name}":`,
			error
		);
	}
};

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

	const transaction = await sequelize.transaction(); // Start transaction

	try {
		// Delete from all related tables
		await sequelize.query(`DELETE FROM provider WHERE user_id = :id`, {
			replacements: { id },
			type: QueryTypes.DELETE,
			transaction,
		});

		await sequelize.query(`DELETE FROM administrator WHERE user_id = :id`, {
			replacements: { id },
			type: QueryTypes.DELETE,
			transaction,
		});

		await sequelize.query(`DELETE FROM client WHERE user_id = :id`, {
			replacements: { id },
			type: QueryTypes.DELETE,
			transaction,
		});

		console.log(`✅ Deleted related records for user ${id}.`);

		// Finally, delete user from USER table
		await User.destroy({ where: { user_id: id }, transaction });

		console.log(`✅ User ${id} deleted successfully.`);
		await transaction.commit(); // Commit transaction

		res
			.status(200)
			.json({ success: true, message: `User ${id} deleted successfully.` });
	} catch (err) {
		console.error("❌ Error deleting user:", err);
		await transaction.rollback(); // Rollback if an error occurs
		res.status(500).json({ success: false, error: "Failed to delete user." });
	}
};

const loginUser = async (req, res) => {
	const { email, password } = req.body;

	try {
		// Use Sequelize's findOne instead of raw SQL
		const user = await User.findOne({ where: { email } });

		if (!user) {
			return res.status(404).json({ message: "User not found" });
		}

		// Compare entered password with hashed password
		const isMatch = await bcrypt.compare(password, user.password_hash);
		if (!isMatch) {
			return res.status(401).json({ error: "Invalid password" });
		}

		const accessToken = jwt.sign(
			{ userId: user.user_id }, // ✅ userId should be included!
			process.env.JWT_SECRET,
			{ expiresIn: "15m" } // Access Token Expires in 15 minutes
		);

		const refreshToken = jwt.sign(
			{ userId: user.user_id },
			process.env.JWT_REFRESH_SECRET,
			{ expiresIn: "7d" } // Refresh token lasts 30 days
		);

		// Store refresh token in DB (or a Redis cache)
		refreshTokens.add(refreshToken); // Replace with DB storage

		res.cookie("refreshToken", refreshToken, {
			httpOnly: true,
			secure: true,
			sameSite: "Strict",
		});

		res
			.status(200)
			.json({ message: "Login successful!", accessToken, refreshToken });
	} catch (err) {
		console.error("Login error:", err);
		res.status(500).json({ error: "Server error" });
	}
};

const refreshAccessToken = (req, res) => {
	const { refreshToken } = req.cookies; // Read from secure HTTP-only cookie

	if (!refreshToken) {
		return res.status(401).json({ error: "Refresh token required" });
	}

	if (!refreshTokens.has(refreshToken)) {
		return res.status(403).json({ error: "Invalid refresh token" });
	}

	jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET, (err, decoded) => {
		if (err) {
			return res
				.status(403)
				.json({ error: "Invalid or expired refresh token" });
		}

		const newAccessToken = jwt.sign(
			{
				userId: decoded.userId,
				email: decoded.email,
				userType: decoded.userType,
			},
			process.env.JWT_SECRET,
			{ expiresIn: "15m" }
		);

		res.json({ accessToken: newAccessToken });
	});
};

module.exports = {
	getAllUsers,
	getUserById,
	createUser,
	updateUserPreferences,
	updateUser,
	deleteUser,
	loginUser,
	refreshAccessToken,
};
