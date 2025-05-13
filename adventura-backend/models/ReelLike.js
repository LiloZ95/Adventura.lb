const { DataTypes } = require("sequelize");
const { sequelize } = require("../db/db");

const ReelLike = sequelize.define(
	"reel_like",
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
		reel_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
		},
		timestamp: {
			type: DataTypes.DATE,
			defaultValue: DataTypes.NOW,
		},
	},
	{
		tableName: "reel_like",
		timestamps: false,
	}
);

module.exports = ReelLike;
