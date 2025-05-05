const { DataTypes } = require("sequelize");
const { sequelize } = require("../db/db.js");
const User = require("./User.js");

const Followers = sequelize.define(
	"followers",
	{
		id: {
			type: DataTypes.INTEGER,
			primaryKey: true,
			autoIncrement: true,
		},
		provider_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			references: {
				model: "provider",
				key: "provider_id",
			},
		},
		user_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			references: {
				model: User,
				key: "user_id",
			},
		},
		created_at: {
			type: DataTypes.DATE,
			allowNull: false,
			defaultValue: DataTypes.NOW,
		},
	},
	{
		tableName: "followers",
		timestamps: false,
		freezeTableName: true,
	}
);

Followers.belongsTo(User, {
	foreignKey: "user_id",
	targetKey: "user_id",
});

module.exports = Followers;
