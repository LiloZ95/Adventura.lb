const { DataTypes } = require("sequelize");
const { sequelize } = require("../db/db");

const Client = sequelize.define("client", {
  client_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  loyalty_points: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
  user_id: {
    type: DataTypes.INTEGER,
    references: {
      model: "USER",
      key: "user_id",
    },
    onDelete: "CASCADE",
  },
}, {
  timestamps: false,
  tableName: "client",
});

module.exports = Client;
