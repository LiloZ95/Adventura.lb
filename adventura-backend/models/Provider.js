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
    birth_date: {
      type: DataTypes.DATEONLY,
      allowNull: true,
    },
    city: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    address: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    certificate_url: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    gov_id_url: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    selfie_url: {
      type: DataTypes.STRING,
      allowNull: true,
    },
  },
  {
    tableName: "provider",
    timestamps: false,
    freezeTableName: true,
  }
);

module.exports = Provider;
