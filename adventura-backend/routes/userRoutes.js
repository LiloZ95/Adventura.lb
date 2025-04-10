// ✅ Cleaned userRoutes.js
const express = require("express");
const router = express.Router();
const multer = require("multer");
const path = require("path");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs");
const nodemailer = require("nodemailer");
require("dotenv").config();

const { authenticateToken } = require("../middleware/auth");
const userController = require("../controllers/userController");
const UserPfp = require("../models/UserPfp");
const User = require("../models/User");
const { sequelize } = require("../db/db");
const { QueryTypes } = require("sequelize");
const { distributeUsers } = require("../distributeUsers");

// ✅ Configure Multer
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 3 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png/;
    const extName = allowedTypes.test(
      path.extname(file.originalname).toLowerCase()
    );
    return extName
      ? cb(null, true)
      : cb(new Error("Only JPG, JPEG, and PNG files allowed."));
  },
});

// ✅ Basic User Routes
router.get("/", userController.getAllUsers);
router.post("/", userController.createUser);
router.get("/:id", userController.getUserById);
router.put("/:id", userController.updateUser);
router.delete("/delete-account/:id", userController.deleteUser);

// ✅ Auth
router.post("/login", userController.loginUser);
router.post("/refresh-token", userController.refreshAccessToken);
router.post("/logout", userController.logoutUser);
router.post("/validate-token", userController.validateToken);
router.get("/validate-token", authenticateToken, userController.validateToken);
router.get("/dashboard", authenticateToken, userController.getDashboard);

// ✅ OTP & Signup
router.post("/send-otp", userController.sendOtp);
router.post("/resend-otp", userController.resendOtp);
router.post("/verify-otp", userController.verifyOtp);

// ✅ Preferences
router.post("/preferences", authenticateToken, userController.updateUserPreferences);

// ✅ Profile Picture
router.post("/upload-profile-picture", upload.single("image"), userController.uploadProfilePicture);
router.get("/get-profile-picture/:id", userController.getProfilePicture);
router.delete("/delete-profile-picture/:id", userController.deleteProfilePicture);

// ✅ Activity Images
router.post(
  "/upload-activity-images/:activity_id",
  upload.array("images", 10),
  userController.uploadActivityImages
);

module.exports = router;
