const crypto = require("crypto");

/**
 * Generates a verification token of a specified length.
 * @param {number} length - The desired length of the verification token.
 * @return {string} A randomly generated verification token.
 */
function generateVerificationToken(length = 40) {
  return crypto.randomBytes(length).toString("hex");
}

const verificationToken = generateVerificationToken();
console.log(verificationToken);
