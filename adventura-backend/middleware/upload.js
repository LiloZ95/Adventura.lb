const multer = require("multer");
const path = require("path");
const fs = require("fs");

// 🔧 Dynamic storage function
const dynamicStorage = (folder = "") =>
	multer.diskStorage({
		destination: function (req, file, cb) {
			const target = path.join("uploads", folder);
			fs.mkdirSync(target, { recursive: true }); // ✅ ensure folder exists
			cb(null, target);
		},
		filename: function (req, file, cb) {
			const ext = path.extname(file.originalname);
			const fileName = `${Date.now()}-${Math.round(Math.random() * 1e9)}${ext}`;
			cb(null, fileName);
		},
	});

// ✅ File filter for images only
const fileFilter = (req, file, cb) => {
	console.log("🧾 Uploaded file info:", {
		originalname: file.originalname,
		mimetype: file.mimetype,
	});

	const allowedTypes = /jpeg|jpg|png|gif/;
	const extname = allowedTypes.test(
		path.extname(file.originalname).toLowerCase()
	);
	const mimetype = allowedTypes.test(file.mimetype);

	if (extname && mimetype) {
		return cb(null, true);
	} else {
		console.error("❌ Rejected file:", file.originalname, file.mimetype);
		cb(new Error("Only image files are allowed"));
	}
};

// ✅ Factory function to generate customized uploader
const createUploader = (folder = "") =>
	multer({
		storage: dynamicStorage(folder),
		fileFilter,
		limits: { fileSize: 5 * 1024 * 1024 }, // 5MB max
	});

module.exports = createUploader;
