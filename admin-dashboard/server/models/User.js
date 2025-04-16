const { DataTypes } = require("sequelize");
const { sequelize } = require("../db/db.js");

const User = sequelize.define(
	"USER",
	{
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
			type: DataTypes.STRING, // ✅ Correct
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
		auth_provider_type: {
			type: DataTypes.STRING,
			allowNull: true,
		  },
		  auth_provider_id: {
			type: DataTypes.STRING,
			allowNull: true,
		  },
		  external_profile_picture: {
			type: DataTypes.TEXT,
			allowNull: true,
		  },
		  
	},

	{
		tableName: "USER", // **Ensure this matches the table name in pgAdmin**
		timestamps: false, // **Disable timestamps if not present in your DB**
		freezeTableName: true, // Prevent Sequelize from pluralizing table names
	}
);


module.exports = User ;
