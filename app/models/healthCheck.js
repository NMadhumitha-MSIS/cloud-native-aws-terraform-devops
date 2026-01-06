const { DataTypes } = require("sequelize");
const sequelize = require("../config/config");

const HealthCheck = sequelize.define("healthcheck", {
  checkId: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  datetime: {
    type: DataTypes.DATE,
    defaultValue: () => new Date().toUTCString(),
  },
}, {
  timestamps: false,
  hooks: {
    beforeCreate: (record) => {
      record.datetime = new Date().toUTCString();
    },
  },
});

module.exports = HealthCheck;
