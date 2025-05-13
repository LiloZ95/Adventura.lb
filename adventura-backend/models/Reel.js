const { DataTypes } = require("sequelize");
const { sequelize } = require("../db/db");

const Reel = sequelize.define(
	"reel",
	{
		reel_id: {
			type: DataTypes.INTEGER,
			primaryKey: true,
			autoIncrement: true,
		},
		video_url: {
			type: DataTypes.STRING,
			allowNull: false,
		},
		description: {
			type: DataTypes.TEXT,
			allowNull: false,
		},
		provider_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			references: {
				model: "provider",
				key: "provider_id",
			},
		},
		timestamp: {
			type: DataTypes.DATE,
			allowNull: false,
			defaultValue: DataTypes.NOW,
		},
	},
	{
		tableName: "reel",
		timestamps: false,
		freezeTableName: true,
	}
);

module.exports = Reel;
