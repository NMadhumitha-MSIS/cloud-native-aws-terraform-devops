const { Sequelize } = require('sequelize');
const logger = require("../logger");
const { instrumentSequelize } = require("../metrics");
require('dotenv').config();

const useSSL = process.env.DB_SSL === 'true';

const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USERNAME,
  process.env.DB_PASSWORD,
  {
    host: process.env.DB_HOST,
    dialect: 'postgres',
    logging: (msg) => logger.info(msg),
    timezone: '+00:00',
    dialectOptions: useSSL
      ? {
          ssl: {
            require: true,
            rejectUnauthorized: false,
          },
          useUTC: true,
        }
      : {
          useUTC: true,
        },
  }
);

instrumentSequelize(sequelize);
module.exports = sequelize;