require('dotenv').config();
const express = require("express");
const sequelize = require("./config/config");
const healthzRouter = require("./routes/router");
const fileRouter = require("./routes/fileRoutes");
const { apiMetricsMiddleware } = require("./metrics");
const logger = require("./logger");

const port = process.env.PORT || 8080;
const app = express();

app.use(express.json());

app.use((req, res, next) => {
  const start = Date.now();
  res.on("finish", () => {
    const duration = Date.now() - start;
    logger.info(`${req.method} ${req.originalUrl} ${res.statusCode} - ${duration}ms`);
  });
  next();
});

app.use("/healthz", healthzRouter);
app.use("/v1/file", fileRouter);
app.use(apiMetricsMiddleware);
 
sequelize
  .sync()
  .then(() => {
    logger.info("Database synced");
    app.get("/cicd", apiMetricsMiddleware, async (req, res) => {
      try {
        await sequelize.models.healthcheck.create();
        res.status(200).set({
          "Cache-Control": "no-cache, no-store, must-revalidate",
          Pragma: "no-cache",
          "X-Content-Type-Options": "nosniff",
          "Content-Length": "0"
        }).end();
      } catch (err) {
        res.status(503).set({
          "Cache-Control": "no-cache, no-store, must-revalidate",
          Pragma: "no-cache",
          "X-Content-Type-Options": "nosniff",
          "Content-Length": "0"
        }).end();
      }
    });
    
    app.listen(port, () => {
      logger.info(`Server running on port ${port}`);
    });
    
  })
  .catch((err) => {
    logger.error("Unable to sync database:", err);
  });
module.exports = { app, sequelize };