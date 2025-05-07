const { DataTypes } = require("sequelize");
const { sequelize } = require("../db/db.js");

const Notification = sequelize.define(
	"Notification",
	{
		notification_id: {
			type: DataTypes.INTEGER,
			autoIncrement: true,
			primaryKey: true,
		},
		user_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
		},
		title: {
			type: DataTypes.STRING,
			allowNull: false,
		},
		description: {
			type: DataTypes.TEXT,
			allowNull: false,
		},
		created_at: {
			type: DataTypes.DATE, // ✅ correct type
			defaultValue: DataTypes.NOW, // ✅ correct default
		},
		icon: {
			type: DataTypes.STRING,
			allowNull: true, // optional
		},
	},
	{
		tableName: "notifications",
		timestamps: false,
	}
);

module.exports = Notification;
