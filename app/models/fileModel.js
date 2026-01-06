const { DataTypes } = require("sequelize");
const sequelize = require("../config/config");

const FileUpload = sequelize.define("fileupload", {
  id: {
    type: DataTypes.UUID,
    primaryKey: true,
  },
  filename: {
    type: DataTypes.STRING,
    allowNull: false,
    field: "filename", 
  },
  s3key: {
    type: DataTypes.STRING,
    allowNull: false,
    field: "s3key",
  },
  uploadDate: {
    type: DataTypes.DATE,
    allowNull: false,
    field: "uploadDate", 
  },
  mimetype: {
    type: DataTypes.STRING,
    field: "mimetype",
  },
  size: {
    type: DataTypes.INTEGER,
    field: "size",
  },
  url: {
    type: DataTypes.STRING,
    allowNull: false,
    field: "url",
  }
}, {
  timestamps: true,
  tableName: "fileuploads" 
});
module.exports = FileUpload;
