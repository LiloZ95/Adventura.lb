const { DataTypes } = require("sequelize");
const { sequelize } = require("../db/db");

const Event = sequelize.define("event", {
  event_id: {
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
    allowNull: true,
  },
  location: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  price: {
    type: DataTypes.FLOAT,
    allowNull: false,
    defaultValue: 0.0,
  },
  duration: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  availability_status: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
  nb_seats: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  category_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
});

module.exports = Event;
