const { onRequest } = require("firebase-functions/v2/https");
const nacl = require("tweetnacl");

// Verifies Discord's Ed25519 request signature (required for any public
// Discord Interactions endpoint, spec §6.3/§17.1).
function verifyDiscordRequest(req, publicKey) {
  const signature = req.get("X-Signature-Ed25519");
  const timestamp = req.get("X-Signature-Timestamp");
  if (!signature || !timestamp || !req.rawBody) return false;
  try {
    return nacl.sign.detached.verify(
        Buffer.from(timestamp + req.rawBody.toString("utf8")),
        Buffer.from(signature, "hex"),
        Buffer.from(publicKey, "hex"),
    );
  } catch (err) {
    console.error("Signature verification error:", err);
    return false;
  }
}

// Public Discord Interactions endpoint. Registered in the Discord Developer
// Portal as this application's "Interactions Endpoint URL" — must exist and
// answer PING/PONG or Discord marks the endpoint unhealthy, independent of
// whether button/command handling (out of Phase 1 scope) is implemented.
exports.discordInteractions = onRequest(
    {region: "europe-west1"},
    async (req, res) => {
      const publicKey = process.env.DISCORD_PUBLIC_KEY;

      if (!publicKey || !verifyDiscordRequest(req, publicKey)) {
        res.status(401).send("Invalid request signature");
        return;
      }

      const body = req.body;
      if (body && body.type === 1) {
        // PING from Discord -> PONG
        res.status(200).json({type: 1});
        return;
      }

      // Button/command handling (state transitions, role checks) is Phase 2
      // scope per AF-AG-016 §17 — acknowledge only for now.
      res.status(200).json({
        type: 4,
        data: {
          content: "ApexFlow QA Bot bu etkileşimi henüz işlemiyor.",
        },
      });
    },
);
