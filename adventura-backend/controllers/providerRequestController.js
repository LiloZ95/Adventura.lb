const fs = require("fs");
const path = require("path");
const ProviderRequest = require("../models/providerRequest");

const submitProviderRequest = async (req, res) => {
	try {
		const { user_id, birth_date, city, address } = req.body;

		// Check if user has existing requests
		const existing = await ProviderRequest.findOne({
			where: { user_id },
			order: [["submitted_at", "DESC"]],
		});

		// Count total rejections
		const rejectedCount = await ProviderRequest.count({
			where: {
				user_id,
				status: "rejected",
			},
		});

		if (rejectedCount >= 3) {
			return res.status(400).json({
				error:
					"Maximum provider request attempts reached. You can no longer reapply.",
			});
		}

		if (existing && ["pending", "approved"].includes(existing.status)) {
			return res.status(400).json({ error: "Request already submitted." });
		}

		// ✅ Create new request even if last was rejected
		const request = await ProviderRequest.create({
			user_id,
			birth_date,
			city,
			address,
		});

		return res.status(201).json({ success: true, request });
	} catch (err) {
		console.error("❌ Error submitting provider request:", err);
		res.status(500).json({ error: "Internal server error." });
	}
};

const getAllRequests = async (req, res) => {
	try {
		const requests = await ProviderRequest.findAll();
		res.json(requests);
	} catch (err) {
		res.status(500).json({ error: "Failed to fetch requests" });
	}
};

const uploadDocuments = async (req, res) => {
	try {
		const { user_id } = req.body;
		const files = req.files;

		if (!user_id || !files.gov_id || !files.selfie) {
			return res
				.status(400)
				.json({ error: "Missing required fields or files." });
		}

		const toRelativePath = (absPath) =>
			path.relative(path.join(__dirname, ".."), absPath).replace(/\\/g, "/");

		const govIdPath = toRelativePath(files.gov_id[0].path);
		const selfiePath = toRelativePath(files.selfie[0].path);
		const certificatePath = files.certificate?.[0]
			? toRelativePath(files.certificate[0].path)
			: null;

		// 🗑 Delete old files if they exist
		const existingRequest = await ProviderRequest.findOne({
			where: { user_id },
		});
		if (existingRequest) {
			const oldPaths = [
				existingRequest.gov_id_url,
				existingRequest.selfie_url,
				existingRequest.certificate_url,
			].filter(Boolean); // skip nulls

			oldPaths.forEach((relPath) => {
				const fullPath = path.join(__dirname, "..", relPath);
				if (fs.existsSync(fullPath)) {
					fs.unlink(fullPath, (err) => {
						if (err) {
							console.warn(`⚠️ Failed to delete old file: ${fullPath}`, err);
						} else {
							console.log(`🗑 Deleted old file: ${fullPath}`);
						}
					});
				}
			});
		}

		// ✅ Save new paths
		await ProviderRequest.update(
			{
				gov_id_url: govIdPath,
				selfie_url: selfiePath,
				certificate_url: certificatePath,
			},
			{ where: { user_id } }
		);

		console.log(`📤 Documents uploaded for user: ${user_id}`);

		return res.status(200).json({
			success: true,
			message: "Files uploaded successfully.",
		});
	} catch (err) {
		console.error("❌ Error uploading documents:", err);
		res.status(500).json({ error: "Internal server error" });
	}
};

module.exports = {
	submitProviderRequest,
	getAllRequests,
	uploadDocuments,
};
