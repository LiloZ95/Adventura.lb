const { DataTypes } = require("sequelize");
const { sequelize } = require("../db/db");

const ReelComment = sequelize.define(
	"reel_comment",
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
		text: {
			type: DataTypes.TEXT,
			allowNull: false,
		},
		timestamp: {
			type: DataTypes.DATE,
			defaultValue: DataTypes.NOW,
		},
	},
	{
		tableName: "reel_comment",
		timestamps: false,
	}
);

module.exports = ReelComment;
