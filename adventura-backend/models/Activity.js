const { DataTypes } = require("sequelize");
const { sequelize } = require("../db/db");
const TripPlan = require("./TripPlan");

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
	from_time: {
		type: DataTypes.STRING, // or DataTypes.TEXT
	},
	to_time: {
		type: DataTypes.STRING,
	},
	provider_id: {
		type: DataTypes.INTEGER,
		allowNull: false,
	},
	listing_type: {
		type: DataTypes.ENUM("recurrent", "oneTime"),
		allowNull: false,
		validate: {
			isIn: [["recurrent", "oneTime"]],
		},
	},
	is_trending: {
		type: DataTypes.BOOLEAN,
		defaultValue: false,
	},
	
});

module.exports = Activity;
