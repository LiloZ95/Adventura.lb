const { DataTypes } = require("sequelize");
const { sequelize } = require("../db/db");
const User = require("./User"); // ✅ Import the correct User model

const UserActivityInteraction = sequelize.define(
  "UserActivityInteraction",
  {
    interaction_id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    user_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: User, // Adjust to match your actual Users table name
        key: "user_id",
      },
    },
    activity_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: "activities", // Ensure "Activities" matches your actual table name
        key: "activity_id",
      },
    },
    interaction_type: {
      type: DataTypes.STRING, // e.g., "click", "like", "booking"
      allowNull: false,
    },
    rating: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
  },
  {
    timestamps: true, // Enables createdAt and updatedAt fields
    tableName: "user_activity_interaction", // Must match PostgreSQL table name
  }
);

module.exports = UserActivityInteraction;
