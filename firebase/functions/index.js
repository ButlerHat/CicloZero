/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const crypto = require("crypto");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

exports.eBayChallengeResponder = onRequest(
    {timeoutSeconds: 1200, maxInstances: 10, region: ["europe-west1"]},
    (req, res) => {
      if (req.method !== "GET") {
        return res.status(405).send("Method Not Allowed"); // Only allowing GET requests
      }

      const challengeCode = req.query.challenge_code;

      const verificationToken = "6b03fc38b974a00e36efcaf3fdef5b4ffc6475e4493be746b5ba764a14162eb6a29e4d74751ec53a"; // Replace this with your verification token
      const endpoint = "https://ebaychallengeresponder-u3igyqeo6q-ew.a.run.app/eBayChallengeResponder"; // The URL of the current function

      const hash = crypto.createHash("sha256");
      logger.info("Challenge code: " + challengeCode);
      hash.update(challengeCode);
      logger.info("Verification token: " + verificationToken);
      hash.update(verificationToken);
      logger.info("Endpoint: " + endpoint);
      hash.update(endpoint);
      const responseHash = hash.digest("hex");

      return res.status(200).json({
        challengeResponse: responseHash,
      });
    });
