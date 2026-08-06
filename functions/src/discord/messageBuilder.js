const crypto = require("crypto");
const { sanitizeUserText } = require("./sanitize");

// Anonymous, non-reversible tester code shown in Discord instead of the
// raw Firebase UID (PII protection, see CLAUDE.md invariants).
function reporterCode(uid) {
  const hash = crypto.createHash("sha256").update(String(uid || "")).digest("hex");
  return `TESTER-${hash.slice(0, 4).toUpperCase()}`;
}

function buildThreadName(bug) {
  const platform = bug.platform || "unknown";
  const title = sanitizeUserText(bug.title || "(no title)", 60);
  const raw = `[${bug.humanBugId}] [${platform}] ${title}`;
  return raw.length > 100 ? `${raw.slice(0, 97)}...` : raw;
}

function buildBugEmbed(bug) {
  const fields = [
    { name: "Category", value: sanitizeUserText(bug.category || "other", 100), inline: true },
    { name: "Priority", value: sanitizeUserText(bug.priority || "p2", 100), inline: true },
    { name: "Reporter", value: reporterCode(bug.reporterUid), inline: true },
    { name: "What happened", value: sanitizeUserText(bug.whatHappened || "-", 1024) || "-" },
    { name: "Expected behavior", value: sanitizeUserText(bug.expectedBehavior || "-", 1024) || "-" },
    { name: "Steps to reproduce", value: sanitizeUserText(bug.stepsToReproduce || "-", 1024) || "-" },
  ];

  return {
    title: sanitizeUserText(`${bug.humanBugId} - ${bug.title || "(no title)"}`, 256),
    color: 0x2E86AB,
    fields,
    footer: { text: "ApexFlow In-App Bug Report" },
  };
}

module.exports = { buildThreadName, buildBugEmbed, reporterCode };
