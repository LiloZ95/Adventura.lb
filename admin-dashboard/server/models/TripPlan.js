// models/TripPlan.js
const { DataTypes } = require("sequelize");
const { sequelize } = require("../db/db");

const TripPlan = sequelize.define(
	"trip_plans",
	{
		trip_plan_id: {
			type: DataTypes.INTEGER,
			primaryKey: true,
			autoIncrement: true,
		},
		activity_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			references: {
				model: "activities",
				key: "activity_id",
			},
			onDelete: "CASCADE",
		},
		time: {
			type: DataTypes.STRING(10),
			allowNull: false,
		},
		description: {
			type: DataTypes.TEXT,
			allowNull: false,
		},
	},
	{
		timestamps: true, // ✅ this auto-generates createdAt and updatedAt
	}
);

module.exports = TripPlan;
