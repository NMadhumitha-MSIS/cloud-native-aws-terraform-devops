const express = require("express");
const multer = require("multer");
const router = express.Router();
const controller = require("../controllers/controllers");

const upload = multer();

router.head("/", (_, res) => {
  return res.status(405).json({ error: "Method Not Allowed" });
});

router.head("/:id", (_, res) => {
  return res.status(405).json({ error: "Method Not Allowed" });
});

// Allowed methods
router.post("/", upload.single("file"), controller.uploadFile);
router.get("/", controller.getAllFiles);
router.get("/:id", controller.getFileById);
router.delete("/:id", controller.deleteFileById);

router.delete("/", (_, res) => {
  res.status(400).json({ error: "Bad Request: DELETE /v1/file not supported" });
});

router.post("/:id", (_, res) => {
  res.status(405).json({ error: "Method Not Allowed" });
});

["PUT", "PATCH", "OPTIONS"].forEach(method => {
  router.all("/", (req, res, next) => {
    if (req.method === method) {
      return res.status(405).json({ error: "Method Not Allowed" });
    }
    next();
  });

  router.all("/:id", (req, res, next) => {
    if (req.method === method) {
      return res.status(405).json({ error: "Method Not Allowed" });
    }
    next();
  });
});

module.exports = router;
