const { SESClient, SendEmailCommand } = require("@aws-sdk/client-ses");
const logger = require("../logger"); 

const ses = new SESClient({ region: process.env.AWS_REGION });

const sendSESEmail = async ({ to, subject, body }) => {
  const params = {
    Destination: {
      ToAddresses: [to],
    },
    Message: {
      Body: {
        Text: { Data: body },
      },
      Subject: { Data: subject },
    },
    Source: process.env.SES_SENDER_EMAIL,
  };

  try {
    const command = new SendEmailCommand(params);
    const response = await ses.send(command);e
    logger.info(`SES email sent to ${to}: ${response.MessageId}`); 
    return response;
  } catch (err) {
    logger.error("SES email failed:", err.message); 
  }
};

module.exports = { sendSESEmail };
