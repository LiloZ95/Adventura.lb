// models/Addon.js
const { DataTypes } = require("sequelize");
const { sequelize } = require("../db/db");

const Addon = sequelize.define("addons", {
	addon_id: {
		type: DataTypes.INTEGER,
		primaryKey: true,
		autoIncrement: true,
	},
	activity_id: {
		type: DataTypes.INTEGER,
		allowNull: false,
	},
	label: {
		type: DataTypes.STRING,
		allowNull: false,
	},
	price: {
		type: DataTypes.DECIMAL(10, 2),
		allowNull: false,
	},
});

module.exports = Addon;
