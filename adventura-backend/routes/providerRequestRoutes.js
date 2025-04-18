const express = require("express");
const router = express.Router();
const multer = require("multer");
const path = require("path");
const fs = require("fs");
const controller = require("../controllers/providerRequestController");

const storage = multer.diskStorage({
	destination: function (req, file, cb) {
		const userDir = path.join(
			__dirname,
			"../uploads/provider_docs",
			req.body.user_id
		);
		fs.mkdirSync(userDir, { recursive: true });
		cb(null, userDir);
	},
	filename: function (req, file, cb) {
		const fieldName = file.fieldname;
		cb(null, `${fieldName}.jpg`);
	},
});

const upload = multer({ storage });

router.post("/provider-request", controller.submitProviderRequest);
router.get("/provider-requests", controller.getAllRequests);

router.post(
	"/provider-request/upload-documents",
	upload.fields([
		{ name: "gov_id", maxCount: 1 },
		{ name: "selfie", maxCount: 1 },
		{ name: "certificate", maxCount: 1 },
	]),
	controller.uploadDocuments
);

module.exports = router;
