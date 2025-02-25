// routes/userRoutes.js
const express = require("express");
const jwt = require("jsonwebtoken"); // ✅ Add this line
const authenticateToken = require("../middleware/auth"); // Import JWT middleware
require("dotenv").config();
const userController = require("../controllers/userController"); // Direct import
const nodemailer = require("nodemailer");
const crypto = require("crypto");
const bcrypt = require("bcryptjs");
const multer = require("multer");
const path = require("path");
const UserPfp = require("../models/UserPfp");
const User = require("../models/User"); // Adjust path as needed
const router = express.Router();
const { distributeUsers } = require("../distributeUsers");

const refreshTokens = new Set(); // Temporary storage for refresh tokens (use DB in production)
const otpStore = {}; // Store OTPs temporarily

// ✅ Multer Storage Configuration (Memory Storage)
const storage = multer.memoryStorage();
const upload = multer({
	storage: storage,
	limits: { fileSize: 3 * 1024 * 1024 }, // ✅ Limit file size to 3MB
	fileFilter: (req, file, cb) => {
		const fileTypes = /jpeg|jpg|png/;
		const extName = fileTypes.test(
			path.extname(file.originalname).toLowerCase()
		);
		if (extName) {
			return cb(null, true);
		} else {
			return cb(
				new Error("Invalid file type. Only JPG, JPEG, and PNG are allowed!")
			);
		}
	},
});

// Define routes
router.get("/", userController.getAllUsers);
router.post("/", userController.createUser);

router.post("/login", async (req, res) => {
	const { email, password } = req.body;

	try {
		const user = await User.findOne({ where: { email } });

		if (!user) {
			return res.status(401).json({ success: false, error: "User not found" });
		}

		const isPasswordValid = await bcrypt.compare(password, user.password_hash);
		if (!isPasswordValid) {
			return res
				.status(401)
				.json({ success: false, error: "Invalid credentials" });
		}

		// ✅ Generate Access Token and Refresh Token
		const accessToken = jwt.sign(
			{ userId: user.user_id },
			process.env.JWT_SECRET,
			{ expiresIn: "1h" }
		);
		const refreshToken = jwt.sign(
			{ userId: user.user_id },
			process.env.JWT_SECRET,
			{ expiresIn: "30d" }
		);

		console.log(`✅ Login Successful: ${user.email}`);

		res.status(200).json({
			success: true,
			user: {
				user_id: user.user_id,
				name: user.first_name + " " + user.last_name,
				email: user.email,
				profilePicture: user.profile_picture || "", // ✅ Include profile picture URL
			},
			accessToken,
			refreshToken,
		});
	} catch (error) {
		console.error("❌ Login Error:", error);
		res
			.status(500)
			.json({ success: false, error: "Server error. Try again later." });
	}
});

router.post("/logout", (req, res) => {
	const { refreshToken } = req.cookies; // Read from secure HTTP-only cookie

	if (!refreshToken) {
		return res.status(400).json({ message: "No refresh token provided" });
	}

	refreshTokens.delete(refreshToken); // Remove token from DB or cache

	res.clearCookie("refreshToken", {
		httpOnly: true,
		secure: true,
		sameSite: "Strict",
	});

	res.status(200).json({ message: "Logged out successfully!" });
});

// 🔹 Configure Zoho Mail SMTP Transporter
const transporter = nodemailer.createTransport({
	host: process.env.SMTP_HOST, // smtp.zoho.com
	port: process.env.SMTP_PORT, // 465 (SSL) or 587 (TLS)
	secure: process.env.SMTP_PORT == 465, // Use SSL if port is 465
	auth: {
		user: process.env.EMAIL, // ✅ Your Zoho Email
		pass: process.env.EMAIL_PASSWORD, // ✅ Your Zoho Application-Specific Password
	},
});

router.post("/send-otp", async (req, res) => {
	const { email, isForSignup } = req.body;
	console.log(
		`🔍 Received OTP request for ${email} (isForSignup: ${isForSignup})`
	);

	try {
		if (!isForSignup) {
			const user = await User.findOne({ where: { email } });
			if (!user) {
				console.log("❌ User not found for password reset");
				return res.status(404).json({ error: "User not found" });
			}
		}

		// Generate a 6-digit OTP
		const otp = Math.floor(100000 + Math.random() * 900000).toString();
		const expiresAt = Date.now() + 5 * 60 * 1000; // 5 minutes expiration

		// Store OTP in memory
		otpStore[email] = { otp, expiresAt };

		console.log(
			`✅ OTP for ${email}: ${otp} (Expires at: ${new Date(
				expiresAt
			).toISOString()})`
		);

		const mailOptions = {
			from: process.env.EMAIL,
			to: email,
			subject: isForSignup
				? "Adventura Signup OTP"
				: "Adventura Password Reset OTP",
			text: `Your OTP is: ${otp}. It will expire in 5 minutes.`,
		};

		await transporter.sendMail(mailOptions);
		res.status(200).json({ success: true, message: "OTP sent successfully!" });
	} catch (error) {
		console.error("❌ Error sending OTP:", error);
		res.status(500).json({ error: "Failed to send OTP" });
	}
});

router.post("/resend-otp", async (req, res) => {
	const { email, isForSignup } = req.body;

	console.log(
		`🔍 Resend OTP request for ${email} (isForSignup: ${isForSignup})`
	);

	try {
		if (!isForSignup) {
			const user = await User.findOne({ where: { email } });
			if (!user) {
				console.log("❌ User not found for password reset");
				return res.status(404).json({ error: "User not found" });
			}
		}

		// Generate a new OTP
		const otp = Math.floor(100000 + Math.random() * 900000).toString();
		const expiresAt = Date.now() + 5 * 60 * 1000; // Expires in 5 minutes

		// Update OTP storage
		otpStore[email] = { otp, expiresAt };

		console.log(
			`✅ Resent OTP for ${email}: ${otp} (Expires at: ${new Date(
				expiresAt
			).toISOString()})`
		);

		const mailOptions = {
			from: process.env.EMAIL,
			to: email,
			subject: "Adventura OTP Resend Request",
			text: `Your new OTP is: ${otp}. It will expire in 5 minutes.`,
		};

		await transporter.sendMail(mailOptions);
		res
			.status(200)
			.json({ success: true, message: "OTP resent successfully!" });
	} catch (error) {
		console.error("❌ Error resending OTP:", error);
		res.status(500).json({ error: "Failed to resend OTP" });
	}
});

router.post("/verify-otp", async (req, res) => {
  const {
      email,
      otp,
      isForSignup,
      firstName,
      lastName,
      phoneNumber,
      password,
  } = req.body;

  console.log(`🔍 OTP Verification Request - Email: ${email}, Entered OTP: ${otp}`);

  if (!otpStore[email]) {
      console.log("❌ No OTP found for this email.");
      return res.status(400).json({ error: "No OTP found for this email" });
  }

  const { otp: storedOtp, expiresAt } = otpStore[email];

  if (Date.now() > expiresAt) {
      console.log("❌ OTP Expired.");
      delete otpStore[email];
      return res.status(400).json({ error: "OTP has expired. Please request a new one." });
  }

  if (storedOtp !== otp) {
      console.log(`❌ Invalid OTP entered. Expected: ${storedOtp}, Received: ${otp}`);
      return res.status(400).json({ error: "Invalid OTP" });
  }

  console.log("✅ OTP Verified Successfully!");
  delete otpStore[email]; 

  let user;

  if (isForSignup) {
      if (!firstName || !lastName || !phoneNumber || !password) {
          console.log("❌ Missing required signup fields.");
          return res.status(400).json({ error: "All fields are required for signup." });
      }

      try {
          user = await User.findOne({ where: { email } });
          if (user) {
              return res.status(400).json({ error: "User with this email already exists." });
          }

          const hashedPassword = await bcrypt.hash(password, 10);

          user = await User.create({
              first_name: firstName,
              last_name: lastName,
              email,
              phone_number: phoneNumber,
              password_hash: hashedPassword,
              user_type: "client",
          });

          console.log(`✅ User "${user.first_name} ${user.last_name}" created successfully!`);
          
          await distributeUsers(user);

          user = await User.findOne({ where: { email } });

      } catch (err) {
          console.error("❌ Error creating user:", err);
          return res.status(500).json({ error: "User creation failed" });
      }
  } else {
      user = await User.findOne({ where: { email } });

      if (!user) {
          return res.status(404).json({ error: "User not found." });
      }
  }

  // ✅ Debugging: Log the user object before sending response
  console.log("🔍 Final user object before response:", user);

  if (!user || !user.user_id) {
      console.error("❌ User ID is missing in response!");
      return res.status(500).json({ error: "User ID is missing." });
  }

  let profilePicture = "";
  const userProfile = await UserPfp.findOne({ where: { user_id: user.user_id } });

  if (userProfile && userProfile.image_data) {
      profilePicture = `data:image/png;base64,${userProfile.image_data.toString("base64")}`;
      console.log(`✅ Retrieved Profile Picture for User ID: ${user.user_id}`);
  } else {
      console.log(`❌ No profile picture found for User ID: ${user.user_id}`);
  }

  const accessToken = jwt.sign(
      { userId: user.user_id, email: user.email, userType: user.user_type },
      process.env.JWT_SECRET,
      { expiresIn: "15m" }
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

  // ✅ Debugging: Log the full response before sending it
  console.log("✅ Final API Response:", {
      success: true,
      message: isForSignup ? "User registered and logged in successfully!" : "OTP verified successfully!",
      accessToken,
      refreshToken,
      user: {
          user_id: user.user_id,
          first_name: user.first_name,
          last_name: user.last_name,
          email: user.email,
          profilePicture: profilePicture,
      },
  });

  return res.status(200).json({
      success: true,
      message: isForSignup ? "User registered and logged in successfully!" : "OTP verified successfully!",
      accessToken,
      refreshToken,
      user: {
          user_id: user.user_id,
          first_name: user.first_name,
          last_name: user.last_name,
          email: user.email,
          profilePicture: profilePicture,
      },
  });
});


router.post("/refresh-token", userController.refreshAccessToken);

router.get("/dashboard", authenticateToken, (req, res) => {
	res.json({
		message: `Welcome ${req.user.email}, your role is ${req.user.userType}`,
	});
	// res.json({ message: "Dashboard is working!" });
});

// ✅ Profile Picture Upload Route
router.post(
	"/upload-profile-picture",
	upload.single("image"),
	async (req, res) => {
		try {
			const user_id = req.body.user_id || req.query.user_id; // ✅ Ensure user_id is retrieved

			if (!req.file) {
				return res
					.status(400)
					.json({ success: false, error: "No file uploaded" });
			}

			const imageBuffer = req.file.buffer;
			if (!imageBuffer) {
				return res
					.status(400)
					.json({ success: false, error: "Failed to process image data." });
			}

			// ✅ Ensure user_id exists
			if (!user_id) {
				console.log("❌ User ID missing from request.");
				return res
					.status(400)
					.json({ success: false, error: "User ID is required." });
			}

			console.log(`📡 Storing Profile Picture for User ID: ${user_id}`);

			// ✅ Check if a record exists for the user
			const existingProfile = await UserPfp.findOne({ where: { user_id } });

			if (existingProfile) {
				// ✅ Update profile picture
				await UserPfp.update(
					{ image_data: imageBuffer },
					{ where: { user_id } }
				);
				console.log("✅ Profile picture updated successfully!");
				return res.status(200).json({
					success: true,
					message: "✅ Profile picture updated successfully!",
				});
			} else {
				// ✅ Insert new profile picture
				await UserPfp.create({ user_id, image_data: imageBuffer });
				console.log("✅ New profile picture added successfully!");
				return res.status(201).json({
					success: true,
					message: "New profile picture uploaded successfully!",
				});
			}
		} catch (error) {
			console.error("❌ Upload Error:", error.message);
			res
				.status(500)
				.json({ success: false, error: "Server error uploading image." });
		}
	}
);

// ✅ Fetch Profile Picture for User
router.get("/get-profile-picture/:id", async (req, res) => {
	const { id } = req.params; // ✅ Extract the correct param name

	if (!id || id === "null") {
		console.log("❌ Invalid user ID received.");
		return res.status(400).json({ error: "Invalid user ID provided" });
	}

	try {
		const userPfp = await UserPfp.findOne({
			where: { user_id: id }, // ✅ Ensure it's correctly referenced
			attributes: ["image_data", "uploaded_at"],
		});

		if (!userPfp || !userPfp.image_data) {
			console.log(`❌ No profile picture found for user: ${id}`);
			return res
				.status(404)
				.json({ success: false, error: "No profile picture found" });
		}

		console.log(`✅ Retrieved profile picture for user: ${id}`);

		// ✅ Convert image data to Base64 for Flutter
		const imageBase64 = userPfp.image_data.toString("base64");
		res
			.status(200)
			.json({ success: true, image: `data:image/png;base64,${imageBase64}` });
	} catch (error) {
		console.error("❌ Error fetching profile picture:", error);
		res.status(500).json({
			success: false,
			error: "Server error retrieving profile picture.",
		});
	}
});

// ✅ Delete User Profile Picture
router.delete("/delete-profile-picture/:id", async (req, res) => {
	try {
		const { user_id } = req.params;

		const deleted = await UserPfp.destroy({ where: { user_id } });

		if (!deleted) {
			return res
				.status(404)
				.json({ success: false, error: "Profile picture not found" });
		}

		res
			.status(200)
			.json({ success: true, message: "Profile picture deleted successfully" });
	} catch (error) {
		console.error("❌ Error deleting profile picture:", error.message);
		res.status(500).json({ success: false, error: "Server error" });
	}
});

router.get("/:id", userController.getUserById);
router.put("/:id", userController.updateUser);
router.delete("/:id", async (req, res) => {
	try {
		const userId = req.params.id;
		console.log(`🗑 Deleting user with ID: ${userId}`);

		// ✅ Check if user exists
		const user = await User.findByPk(userId);
		if (!user) {
			console.log("❌ User not found.");
			return res.status(404).json({ success: false, error: "User not found" });
		}

		// ✅ Delete user and profile picture
		await UserPfp.destroy({ where: { user_id: userId } }); // Delete Profile Pic
		await User.destroy({ where: { user_id: userId } }); // Delete User Account

		console.log("✅ User deleted successfully!");
		res
			.status(200)
			.json({ success: true, message: "User deleted successfully" });
	} catch (error) {
		console.error("❌ Error deleting user:", error);
		res.status(500).json({ success: false, error: "Server error" });
	}
});

router.get("/validate-token", authenticateToken, (req, res) => {
	return res.status(200).json({ message: "Token is valid" });
});

module.exports = router;
