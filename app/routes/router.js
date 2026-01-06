const express = require("express");
const router = express.Router();
const HealthCheck = require("../models/healthCheck");
const { apiMetricsMiddleware } = require("../metrics");
const fileRoutes = require("./fileRoutes");
const logger = require("../logger"); 

router.use((req, res, next) => {
  if (req.method === "HEAD" && req.originalUrl === "/healthz") {
    logger.warn("HEAD /healthz → 405"); 
    return res.status(405).set({
      "Allow": "GET",
      "Cache-Control": "no-cache, no-store, must-revalidate",
      "Pragma": "no-cache",
      "X-Content-Type-Options": "nosniff",
      "Content-Length": "0"
    }).end();
  }
  next();
});

router.get("/", apiMetricsMiddleware, async (req, res) => {
  if (req.headers["x-simulate-failure"] === "true") {
    return res.status(503).set({
      "Cache-Control": "no-cache, no-store, must-revalidate",
      Pragma: "no-cache",
      "X-Content-Type-Options": "nosniff",
      "Content-Length": "0"
    }).end();
  }
  
  if (Object.keys(req.query).length > 0 || (req.body && Object.keys(req.body).length > 0)) {
    return res.status(400).set({
      "Cache-Control": "no-cache, no-store, must-revalidate",
      Pragma: "no-cache",
      "X-Content-Type-Options": "nosniff",
      "Content-Length": "0"
    }).end();
  }

  try {
    await HealthCheck.create();
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

// New /cicd endpoint - same logic as /healthz
router.get("/../cicd", apiMetricsMiddleware, async (req, res) => {
  try {
    await HealthCheck.create();
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


["POST", "PUT", "DELETE", "PATCH", "OPTIONS"].forEach(method => {
  router.all("/", (req, res, next) => {
    if (req.method !== "GET") {
      logger.warn(`${req.method} /healthz → 405`); 
      res.status(405).set({
        Allow: "GET",
        "Cache-Control": "no-cache, no-store, must-revalidate",
        Pragma: "no-cache",
        "X-Content-Type-Options": "nosniff",
        "Content-Length": "0"
      }).end();
    } else {
      next(); // allow GET through
    }
  });
});

["POST", "PUT", "DELETE", "PATCH", "OPTIONS"].forEach(method => {
  router.all("/cicd", (req, res, next) => {
    if (req.method !== "GET") {
      logger.warn(`${req.method} /cicd → 405`);
      res.status(405).set({
        Allow: "GET",
        "Cache-Control": "no-cache, no-store, must-revalidate",
        Pragma: "no-cache",
        "X-Content-Type-Options": "nosniff",
        "Content-Length": "0"
      }).end();
    } else {
      next(); // allow GET through
    }
  });
});

// Mount file routes under /v1/file
router.use("/v1/file", fileRoutes);

module.exports = router;
