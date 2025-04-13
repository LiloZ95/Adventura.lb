const { DataTypes } = require('sequelize');
const { sequelize } = require('../db/db');

const Availability = sequelize.define('availability', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  activity_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  date: {
    type: DataTypes.DATEONLY,
    allowNull: false,
  },
  slot: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  available_seats: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  created_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
  updated_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
}, {
  tableName: 'availability',
  timestamps: false,
});

module.exports = Availability;
