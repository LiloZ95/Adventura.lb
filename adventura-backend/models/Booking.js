const { DataTypes } = require("sequelize");
const { sequelize }= require("../db/db");

const booking = sequelize.define("booking", {
  booking_id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  activity_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  booking_date: {
    type: DataTypes.DATEONLY,
    defaultValue: DataTypes.NOW,
  },
  total_price: {
    type: DataTypes.DECIMAL(10, 2),
  },
  status: {
    type: DataTypes.ENUM("confirmed", "pending", "cancelled"),
    allowNull: false,
    defaultValue: "pending",
    field: "status",
  },
  client_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
}, {
  tableName: "booking",
  timestamps: true,
  createdAt: "created_at",
  updatedAt: "updated_at",
});

module.exports = booking;