const { DataTypes } = require("sequelize");
const { sequelize } = require("../db/db");

const UserPreferences = sequelize.define("user_preferences", {
  user_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    references: { model: "USER", key: "user_id" },
    onDelete: "CASCADE",
  },
  category_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    references: { model: "category", key: "category_id" },
    onDelete: "CASCADE",
  },
  preference_level: {
    type: DataTypes.INTEGER,
    defaultValue: 3, // Default preference level (1-5)
  },
}, {
  timestamps: false,
  tableName: "user_preferences",
});

module.exports = UserPreferences;
