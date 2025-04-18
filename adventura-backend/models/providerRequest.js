const { DataTypes } = require("sequelize");
const { sequelize } = require("../db/db.js");

const ProviderRequest = sequelize.define(
	"provider_request",
	{
		request_id: {
			type: DataTypes.INTEGER,
			primaryKey: true,
			autoIncrement: true,
		},
		user_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			unique: true,
		},
		birth_date: {
			type: DataTypes.DATEONLY,
			allowNull: false,
		},
		city: {
			type: DataTypes.STRING,
			allowNull: false,
		},
		address: {
			type: DataTypes.STRING,
		},
		gov_id_url: {
			type: DataTypes.STRING,
			allowNull: true,
		},
		selfie_url: {
			type: DataTypes.STRING,
			allowNull: true,
		},
		certificate_url: {
			type: DataTypes.STRING,
			allowNull: true,
		},
		status: {
			type: DataTypes.ENUM("pending", "approved", "rejected"),
			defaultValue: "pending",
		},
		submitted_at: {
			type: DataTypes.DATE,
			defaultValue: DataTypes.NOW,
		},
	},
	{
		tableName: "provider_request",
		timestamps: false,
		freezeTableName: true,
	}
);

module.exports = ProviderRequest;
