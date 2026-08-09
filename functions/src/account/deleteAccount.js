const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");
const {getAuth} = require("firebase-admin/auth");
const {getFirestore} = require("firebase-admin/firestore");
const {getStorage} = require("firebase-admin/storage");
const {deleteDiscordChannel} = require("../discord/client");

const discordBotToken = defineSecret("DISCORD_BOT_TOKEN");
const RECENT_LOGIN_SECONDS = 15 * 60;

function normalizedTagVariants(value) {
  const normalized = String(value || "").trim().toLowerCase();
  if (!normalized) return [];
  const withoutAt = normalized.replace(/^@/, "");
  return [...new Set([normalized, withoutAt, `@${withoutAt}`])];
}

async function deleteQueryTrees(db, query) {
  let hasDocuments = true;
  while (hasDocuments) {
    const snapshot = await query.limit(100).get();
    hasDocuments = !snapshot.empty;
    if (hasDocuments) {
      await Promise.all(
          snapshot.docs.map((doc) => db.recursiveDelete(doc.ref)),
      );
    }
  }
}

async function deleteKnownDocument(db, path) {
  await db.recursiveDelete(db.doc(path));
}

exports.deleteAccountAndData = onCall(
    {
      region: "europe-west1",
      enforceAppCheck: true,
      secrets: [discordBotToken],
      timeoutSeconds: 300,
    },
    async (request) => {
      if (!request.auth) {
        throw new HttpsError("unauthenticated", "Authentication required");
      }

      const uid = request.auth.uid;
      const authTime = Number(request.auth.token.auth_time || 0);
      const nowSeconds = Math.floor(Date.now() / 1000);
      if (!authTime || nowSeconds - authTime > RECENT_LOGIN_SECONDS) {
        throw new HttpsError(
            "failed-precondition",
            "recent-login-required",
        );
      }

      const db = getFirestore();
      const userRef = db.collection("users").doc(uid);
      const userSnapshot = await userRef.get();
      const tagVariants = new Set(
          normalizedTagVariants(userSnapshot.data()?.riderTag),
      );

      const tagSnapshot = await db.collection("rider_tags")
          .where("ownerId", "==", uid)
          .get();
      for (const tagDoc of tagSnapshot.docs) {
        for (const value of normalizedTagVariants(tagDoc.id)) {
          tagVariants.add(value);
        }
        for (const value of normalizedTagVariants(tagDoc.data()?.tag)) {
          tagVariants.add(value);
        }
      }

      // Remove private QA copies before deleting their Firestore source.
      // This keeps account deletion complete across processors and remains
      // retry-safe because Discord 404 is treated as success.
      const bugSnapshot = await db.collection("bug_reports")
          .where("reporterUid", "==", uid)
          .get();
      for (const bugDoc of bugSnapshot.docs) {
        const threadId = bugDoc.data()?.discord?.threadId;
        if (threadId) {
          await deleteDiscordChannel({
            channelId: String(threadId),
            botToken: discordBotToken.value(),
          });
        }
      }

      await Promise.all([
        deleteKnownDocument(db, `public_rider_cards/${uid}`),
        deleteKnownDocument(db, `friend_profiles/${uid}`),
        deleteKnownDocument(db, `entitlements/${uid}`),
        deleteKnownDocument(db, `notification_tokens/${uid}`),
        deleteQueryTrees(db, db.collection("bikes").where("userId", "==", uid)),
        deleteQueryTrees(db, db.collection("rides").where("userId", "==", uid)),
        deleteQueryTrees(db, db.collection("friendships").where("userA", "==", uid)),
        deleteQueryTrees(db, db.collection("friendships").where("userB", "==", uid)),
      ]);

      for (const bugDoc of bugSnapshot.docs) {
        await Promise.all([
          db.recursiveDelete(bugDoc.ref),
          deleteKnownDocument(db, `bug_dispatch_outbox/${bugDoc.id}`),
          deleteKnownDocument(db, `bug_report_idempotency/${bugDoc.id}`),
        ]);
      }

      // Remove hosted lobbies and the user's participant snapshot from other
      // short-lived lobbies. Lobby membership is keyed by Rider Tag, not UID.
      const lobbiesSnapshot = await db.collection("lobbies").get();
      for (const lobbyDoc of lobbiesSnapshot.docs) {
        const data = lobbyDoc.data();
        const hostVariants = normalizedTagVariants(data.hostId);
        const isHost = hostVariants.some((tag) => tagVariants.has(tag));
        if (isHost) {
          await db.recursiveDelete(lobbyDoc.ref);
          continue;
        }

        const riders = Array.isArray(data.riders) ? data.riders : [];
        const filteredRiders = riders.filter((rider) => {
          const values = [rider?.riderTag, rider?.stableId]
              .flatMap(normalizedTagVariants);
          return !values.some((tag) => tagVariants.has(tag));
        });
        if (filteredRiders.length !== riders.length) {
          await lobbyDoc.ref.update({riders: filteredRiders});
        }
      }

      for (const tag of tagVariants) {
        await deleteQueryTrees(
            db,
            db.collection("parking_notifications").where("vehicleId", "==", tag),
        );
      }

      for (const tagDoc of tagSnapshot.docs) {
        await db.recursiveDelete(tagDoc.ref);
      }

      await db.recursiveDelete(userRef);

      try {
        await getStorage().bucket().file(`avatars/${uid}`).delete();
      } catch (error) {
        if (Number(error?.code) !== 404) throw error;
      }

      // Authentication is deliberately last. Any earlier failure leaves a
      // valid account that can sign in again and safely retry cleanup.
      await getAuth().deleteUser(uid);
      return {status: "deleted"};
    },
);
