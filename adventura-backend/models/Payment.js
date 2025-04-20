module.exports = (sequelize, DataTypes) => {
    const Payment = sequelize.define('Payment', {
      payment_id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
      },
      amount: {
        type: DataTypes.DECIMAL(10, 2),
        allowNull: false
      },
      payment_date: {
        type: DataTypes.DATEONLY,
        defaultValue: DataTypes.NOW
      },
      payment_status: {
        type: DataTypes.STRING,
      },
      booking_id: {
        type: DataTypes.INTEGER,
        references: {
          model: 'booking',
          key: 'booking_id'
        }
      }
    }, {
      tableName: 'payment',
      timestamps: false
    });
  
    return Payment;
  };
  