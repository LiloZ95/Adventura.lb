const { DataTypes } = require("sequelize");
const { sequelize } = require("../db/db.js");

const Provider = sequelize.define(
  "provider",
  {
    provider_id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    business_name: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    service_description: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    rating: {
      type: DataTypes.DOUBLE,
      allowNull: true,
    },
    user_id: {
      type: DataTypes.INTEGER,
      allowNull: true,
      references: {
        model: "USER",
        key: "user_id",
      },
    },
  },
  {
    tableName: "provider",
    timestamps: false,
    freezeTableName: true,
  }
);

module.exports = Provider;
