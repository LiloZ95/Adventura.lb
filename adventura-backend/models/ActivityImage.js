const { DataTypes } = require("sequelize");
const { sequelize } = require("../db/db");
const Activity = require("./Activity");

const ActivityImage = sequelize.define("activity_images", {
  image_id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  activity_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: Activity,
      key: "activity_id",
    },
    onDelete: "CASCADE",
  },
  image_url: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  is_primary: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
});

module.exports = ActivityImage;
