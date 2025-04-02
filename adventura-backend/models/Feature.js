// models/ActivityFeature.js
const { DataTypes } = require("sequelize");
const { sequelize } = require("../db/db");

const ActivityFeature = sequelize.define(
  "activity_features",
  {
    feature_id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    activity_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: "activities",
        key: "activity_id",
      },
      onDelete: "CASCADE",
    },
    name: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
  },
  {
    timestamps: true, // ✅ auto-generates createdAt and updatedAt
  }
);

module.exports = ActivityFeature;
