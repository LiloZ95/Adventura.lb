const { DataTypes } = require('sequelize');
const { sequelize } = require('../db/db');

const ActivityCategory = sequelize.define('category', {
  category_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  description: {
    type: DataTypes.TEXT,
  },
  image: {
    type: DataTypes.BLOB, // bytea
  }
}, {
  timestamps: false,
  tableName: 'category' // 🔥 important fix
});

module.exports = ActivityCategory;
