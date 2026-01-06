// services/sesService.js
const { SESClient, SendEmailCommand } = require("@aws-sdk/client-ses");

const sesClient = new SESClient({ region: process.env.AWS_REGION });

const sendEmail = async ({ subject, body }) => {
  const params = {
    Source: process.env.SOURCE_EMAIL,
    Destination: {
      ToAddresses: [process.env.DESTINATION_EMAIL],
    },
    Message: {
      Subject: { Data: subject },
      Body: {
        Text: { Data: body },
      },
    },
  };

  try {
    const result = await sesClient.send(new SendEmailCommand(params));
    console.log("Email sent:", result.MessageId);
    return result;
  } catch (err) {
    console.error("Email send failed:", err);
    throw err;
  }
};

module.exports = { sendEmail };
