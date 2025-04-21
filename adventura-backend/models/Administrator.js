const { DataTypes } = require("sequelize");
const { sequelize } = require("../db/db.js");

const Administrator = sequelize.define(
	"administrator",
	{
		administrator_id: {
			type: DataTypes.INTEGER,
			primaryKey: true,
			autoIncrement: true,
		},
		permissions: {
			type: DataTypes.TEXT,
			allowNull: true,
		},
		admin_role: {
			type: DataTypes.STRING(50),
			allowNull: true,
		},
		user_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: "USER",
				key: "user_id",
			},
		},
	},
	{
		tableName: "administrator",
		timestamps: false,
		freezeTableName: true,
	}
);

module.exports = Administrator;
