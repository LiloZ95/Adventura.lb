const { DataTypes } = require("sequelize");
const { sequelize } = require("../db/db"); // Import your Sequelize connection
const User = require("./User"); // Import the User model

const UserPfp = sequelize.define(
	"user_pfp",
	{
		user_id: {
			type: DataTypes.INTEGER, // Match PostgreSQL 'integer' type
			primaryKey: true,
			allowNull: false,
			references: {
				model: User,
				key: "user_id",
			},
			onDelete: "CASCADE",
		},
		image_data: {
			type: DataTypes.BLOB("long"), // Equivalent to bytea in PostgreSQL
			allowNull: false,
		},
		uploaded_at: {
			type: DataTypes.DATE,
			defaultValue: DataTypes.NOW,
		},
	},
	{
		tableName: "user_pfp", // Explicitly define the table name
		timestamps: false, // Disable automatic timestamps (createdAt, updatedAt)
	}
);

module.exports = UserPfp;
