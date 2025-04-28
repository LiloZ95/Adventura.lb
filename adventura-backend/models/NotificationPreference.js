const { DataTypes } = require("sequelize");
const { sequelize } = require("../db/db");

const NotificationPreference = sequelize.define(
	"notification_preferences",
	{
		id: {
			type: DataTypes.INTEGER,
			primaryKey: true,
			autoIncrement: true,
		},
		user_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
		},
		provider_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
		},
		allow_notifications: {
			type: DataTypes.BOOLEAN,
			defaultValue: true,
		},
		created_at: {
			type: DataTypes.DATE,
			defaultValue: DataTypes.NOW,
		},
		updated_at: {
			type: DataTypes.DATE,
			defaultValue: DataTypes.NOW,
		},
	},
	{
		timestamps: false,
		freezeTableName: true,
		tableName: "notification_preferences",
	}
);

module.exports = NotificationPreference;
