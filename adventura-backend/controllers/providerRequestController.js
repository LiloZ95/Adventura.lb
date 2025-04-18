const fs = require("fs");
const path = require("path");
const ProviderRequest = require("../models/providerRequest");

const submitProviderRequest = async (req, res) => {
	try {
		const { user_id, birth_date, city, address } = req.body;

		const existing = await ProviderRequest.findOne({ where: { user_id } });
		if (existing) {
			return res.status(400).json({ error: "Request already submitted." });
		}

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
			return res.status(400).json({ error: "Missing required fields or files." });
		}

		// Save file paths to DB
		await ProviderRequest.update(
			{
				gov_id_url: files.gov_id[0].path,
				selfie_url: files.selfie[0].path,
				certificate_url: files.certificate?.[0]?.path || null,
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
