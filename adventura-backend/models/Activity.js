const { DataTypes } = require("sequelize");
const { sequelize } = require("../db/db");
const TripPlan = require('./TripPlan');

const Activity = sequelize.define("activities", {
	activity_id: {
		type: DataTypes.INTEGER,
		primaryKey: true,
		autoIncrement: true,
	  },
	name: {
		type: DataTypes.STRING,
		allowNull: false,
	},
	description: {
		type: DataTypes.TEXT,
	},
	location: {
		type: DataTypes.TEXT,
	},
	price: {
		type: DataTypes.DECIMAL(10, 2),
	},
	duration: {
		type: DataTypes.INTEGER,
	},
	availability_status: {
		type: DataTypes.BOOLEAN,
		defaultValue: true,
	},
	nb_seats: {
		type: DataTypes.INTEGER,
	},
	category_id: {
		type: DataTypes.INTEGER,
		allowNull: true,
	},
	latitude: {
		type: DataTypes.DOUBLE,
		allowNull: true,
	},
	longitude: {
		type: DataTypes.DOUBLE,
		allowNull: true,
	},
	provider_id: {
		type: DataTypes.INTEGER,
		allowNull: false,
	  },
});

module.exports = Activity;
