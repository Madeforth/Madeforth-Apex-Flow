const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { defineSecret, defineString } = require("firebase-functions/params");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { buildThreadName, buildBugEmbed } = require("./messageBuilder");
const { createForumThread } = require("./client");

const discordBotToken = defineSecret("DISCORD_BOT_TOKEN");
const discordForumId = defineString("DISCORD_BUG_REPORT_FORUM_ID");

// Delivers a bug_dispatch_outbox entry to the Discord QA forum as a new
// thread, and records the resulting thread id back onto the bug_reports
// doc. Phase 1 scope (AF-AG-016): one-way delivery only, no buttons/roles/
// interaction endpoint yet.
exports.dispatchBugReportToDiscord = onDocumentCreated(
    {
      document: "bug_dispatch_outbox/{internalBugId}",
      region: "europe-west1",
      secrets: [discordBotToken],
      retry: true,
    },
    async (event) => {
      const {internalBugId} = event.params;
      const db = getFirestore();
      const bugRef = db.collection("bug_reports").doc(internalBugId);
      const outboxRef = db.collection("bug_dispatch_outbox").doc(internalBugId);

      const bugSnap = await bugRef.get();
      if (!bugSnap.exists) {
        console.error(`bug_reports/${internalBugId} missing for outbox entry; dropping.`);
        await outboxRef.update({
          state: "dead_letter",
          lastErrorCode: "bug_missing",
          updatedAt: FieldValue.serverTimestamp(),
        });
        return;
      }

      const bug = bugSnap.data();

      // Duplicate protection: a prior attempt may have already delivered
      // this bug before crashing/retrying on a later step.
      if (bug.discord && bug.discord.threadId) {
        await outboxRef.update({
          state: "delivered",
          updatedAt: FieldValue.serverTimestamp(),
        }).catch(() => {});
        return;
      }

      const forumId = discordForumId.value();
      if (!forumId) {
        throw new Error("DISCORD_BUG_REPORT_FORUM_ID is not configured");
      }

      try {
        const thread = await createForumThread({
          forumId,
          botToken: discordBotToken.value(),
          threadName: buildThreadName(bug),
          embed: buildBugEmbed(bug),
        });

        const batch = db.batch();
        batch.update(bugRef, {
          "discord.syncStatus": "delivered",
          "discord.threadId": thread.id,
          "discord.messageId": thread.last_message_id || null,
          "discord.lastErrorCode": null,
          updatedAt: FieldValue.serverTimestamp(),
        });
        batch.update(outboxRef, {
          state: "delivered",
          deliveredAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        });
        await batch.commit();
      } catch (error) {
        console.error(`Discord dispatch failed for ${internalBugId}:`, error);
        const errorCode = String((error && error.status) || "unknown");
        await Promise.all([
          bugRef.update({
            "discord.syncStatus": "error",
            "discord.lastErrorCode": errorCode,
            updatedAt: FieldValue.serverTimestamp(),
          }),
          outboxRef.update({
            state: "pending",
            attemptCount: FieldValue.increment(1),
            lastErrorCode: errorCode,
            updatedAt: FieldValue.serverTimestamp(),
          }),
        ]);
        // Rethrow so Cloud Functions v2's built-in retry (exponential
        // backoff) reattempts delivery instead of silently dropping it.
        throw error;
      }
    },
);
