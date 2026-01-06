require("dotenv").config();
const logger = require("../logger"); 

const { sendSESEmail } = require("../services/emailService");
const { v4: uuidv4 } = require("uuid");
const path = require("path");
const { S3Client, PutObjectCommand, GetObjectCommand, DeleteObjectCommand } = require("@aws-sdk/client-s3");
const { getSignedUrl } = require("@aws-sdk/s3-request-presigner");
const File = require("../models/fileModel");
const { trackS3Latency, publishMetric } = require("../metrics");

const s3 = new S3Client({ region: process.env.AWS_REGION });
const BUCKET = process.env.S3_BUCKET;

// Upload a file to S3 and DB
exports.uploadFile = async (req, res) => {
  try {
    if (!req.file) {
      logger.warn("Upload attempt without a file");
      return res.status(400).json({ error: "No file uploaded" });
    }

    const { originalname, buffer } = req.file;
    const id = uuidv4();
    const fileExtension = path.extname(originalname);
    const key = `uploads/${id}${fileExtension}`;

    await trackS3Latency("S3Upload", () =>
      s3.send(new PutObjectCommand({ Bucket: BUCKET, Key: key, Body: buffer }))
    );

    const newFile = await File.create({
      id,
      filename: originalname,
      s3key: key,
      url: `s3://${BUCKET}/${key}`,
      uploadDate: new Date(),
    });

    logger.info(`File uploaded: ${newFile.id}`);

    res.status(201).json({
      file_name: newFile.filename,
      id: newFile.id,
      url: newFile.url,
      upload_date: newFile.uploadDate.toISOString().split("T")[0],
    });

    try {
      await sendSESEmail({
        to: process.env.SES_RECEIVER_EMAIL,
        subject: "File Uploaded!",
        body: `File "${originalname}" was successfully uploaded at ${new Date().toISOString()}.`,
      });
    } catch (err) {
      logger.error("Upload email failed:", err.message);
    }
  } catch (error) {
    logger.error("Upload failed:", error);
    res.status(500).json({ error: "Upload failed" });
  }
};

// Get file by ID
exports.getFileById = async (req, res) => {
  try {
    const { id } = req.params;
    const file = await File.findByPk(id);

    if (!file) {
      logger.warn(`File with ID ${id} not found`);
      return res.status(404).json({ error: "File not found" });
    }

    const s3Command = new GetObjectCommand({ Bucket: BUCKET, Key: file.s3key });
    const url = await trackS3Latency("S3GetURL", () =>
      getSignedUrl(s3, s3Command, { expiresIn: 3600 })
    );

    logger.info(`File retrieved: ${id}`);

    res.status(200).json({
      file_name: file.filename,
      id: file.id,
      url: file.url,
      upload_date: file.uploadDate.toISOString().split("T")[0],
      presigned_url: url,
    });
  } catch (error) {
    logger.error("Fetch failed:", error);
    res.status(500).json({ error: "Fetch failed" });
  }
};

// Delete file by ID
exports.deleteFileById = async (req, res) => {
  try {
    const { id } = req.params;
    const file = await File.findByPk(id);

    if (!file) {
      logger.warn(`File to delete not found: ${id}`);
      return res.status(404).json({ error: "File not found" });
    }

    await trackS3Latency("S3Delete", () =>
      s3.send(new DeleteObjectCommand({ Bucket: BUCKET, Key: file.s3key }))
    );

    await file.destroy();
    logger.info(`File deleted: ${id}`);
    res.status(204).send();

    try {
      await sendSESEmail({
        to: process.env.SES_RECEIVER_EMAIL,
        subject: "File Deleted",
        body: `File "${file.filename}" was deleted at ${new Date().toISOString()}.`,
      });
    } catch (err) {
      logger.error("Delete email failed:", err.message);
    }
  } catch (error) {
    logger.error("Delete failed:", error);
    res.status(500).json({ error: "Delete failed" });
  }
};

// List all files (unsupported in spec)
exports.getAllFiles = async (req, res) => {
  try {
    if (Object.keys(req.query).length > 0) {
      logger.warn("GET /v1/file called with query params (unsupported)");
      return res.status(400).json({ error: "Bad Request: query parameters not allowed" });
    }

    logger.warn("GET /v1/file without ID (unsupported)");
    res.status(400).json({ error: "Bad Request: GET /v1/file without ID is unsupported" });
  } catch (error) {
    logger.error("List failed:", error);
    res.status(500).json({ error: "List failed" });
  }
};
