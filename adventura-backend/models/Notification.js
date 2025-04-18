module.exports = (sequelize, DataTypes) => {
    const Notification = sequelize.define("Notification", {
      notification_id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
      },
      user_id: {
        type: DataTypes.INTEGER,
        allowNull: false
      },
      title: {
        type: DataTypes.STRING,
        allowNull: false
      },
      description: {
        type: DataTypes.TEXT,
        allowNull: false
      },
      created_at: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW
      },
      icon: {
        type: DataTypes.STRING,
        allowNull: true, // optional
      }
      
    }, {
      tableName: "notifications",
      timestamps: false
    });
  
    return Notification;
  };
  