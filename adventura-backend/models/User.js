const { DataTypes } = require("sequelize");
const sequelize = require("../db/db.js");;


const User = sequelize.define("USER", {
  user_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  first_name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  last_name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  email: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true,
    validate: { isEmail: true },
  },
  password_hash: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  phone_number: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  location: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  user_type: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  // // Adding OTP field
  // otp: {
  //   type: DataTypes.INTEGER,
  //   allowNull: true,  // Allowing null initially as OTP is only set when requested
  // },
  // // Adding OTP expiration field (optional)
  // otp_expiration: {
  //   type: DataTypes.DATE,
  //   allowNull: true,  // Set to null initially
  // },
}, {
  tableName: "USER", // **Ensure this matches the table name in pgAdmin**
  timestamps: false, // **Disable timestamps if not present in your DB**
  freezeTableName: true, // Prevent Sequelize from pluralizing table names
});

module.exports = User;
