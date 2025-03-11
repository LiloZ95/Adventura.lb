const { DataTypes } = require("sequelize");
const { sequelize } = require("../db/db");

const Activity = sequelize.define("activities", {
  activity_id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
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
});

module.exports = Activity;
