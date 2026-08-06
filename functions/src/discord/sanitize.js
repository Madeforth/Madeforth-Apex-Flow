// Strips mention-injection and webhook-leak vectors from user-supplied text
// before it is stored or sent to Discord. Per AF-AG-016 section 14.4.
const NULL_BYTE_PATTERN = new RegExp(String.fromCharCode(0), "g");

function sanitizeUserText(value, maxLength) {
  const normalized = String(value === undefined || value === null ? "" : value)
      .normalize("NFKC")
      .replace(NULL_BYTE_PATTERN, "")
      .trim()
      .slice(0, maxLength);
  return normalized
      .replace(/@everyone/gi, "@ everyone")
      .replace(/@here/gi, "@ here")
      .replace(/<@&?\d+>/g, "[mention removed]")
      .replace(/https:\/\/discord(?:app)?\.com\/api\/webhooks\/[^\s]+/gi,
          "[webhook removed]");
}

module.exports = { sanitizeUserText };
