const { DataTypes } = require("sequelize");
const { sequelize } = require("../db/db");

const EventImage = sequelize.define("EventImage", {
  image_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  event_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  image_url: {
    type: DataTypes.STRING,
    allowNull: false,
  },
});

module.exports = EventImage;
