const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");

admin.initializeApp();

// Set the global region to europe-west1 to support eur3 databases
setGlobalOptions({ region: "europe-west1" });

exports.onParkingNotificationCreated = onDocumentCreated("parking_notifications/{docId}", async (event) => {
  const snap = event.data;
  if (!snap) return null;

  const data = snap.data();
  const vehicleId = data.vehicleId; // This is the rider tag, e.g., @apex_dev#1881

  // Reason keys sent by the app (qr_contact_web/main.js and the in-app
  // Smart Park Alert flow) since they were switched from raw Turkish text
  // to translation keys. Legacy raw-Turkish values are kept as a fallback
  // for any in-flight documents written before that change.
  const REASON_TEXT_BY_KEY = {
    blocked: "Aracınız yolu/kapıyı kapatıyor",
    fallen: "Aracınız devrildi",
    crash: "Aracınıza çarpıldı / hasar var",
    towed: "Aracınız çekiliyor",
    // Legacy raw-Turkish values (pre-key-based reason system)
    "Yolu Kapattı": "Aracınız yolu/kapıyı kapatıyor",
    "Devrildi": "Aracınız devrildi",
    "Çarpıldı": "Aracınıza çarpıldı / hasar var",
    "Çekici": "Aracınız çekiliyor",
  };

  let rawReason = String(data.reason || "").trim();
  if (rawReason.length > 100) {
    rawReason = rawReason.substring(0, 100);
  }

  const safeReason = REASON_TEXT_BY_KEY[rawReason] || "Araç güvenlik uyarısı";

  if (!vehicleId || typeof vehicleId !== "string" || vehicleId.length > 50) {
    console.error("Invalid vehicleId provided.");
    return null;
  }

  const tagLowerCase = vehicleId.trim().toLowerCase();

  try {
    // 1. Get the ownerId from rider_tags
    const tagDoc = await admin.firestore()
        .collection("rider_tags")
        .doc(tagLowerCase)
        .get();

    if (!tagDoc.exists) {
      console.error(`Tag ${tagLowerCase} not found.`);
      return null;
    }

    const ownerId = tagDoc.data().ownerId;
    let fcmToken = null;

    // 2. Get FCM token from private notification_tokens subcollection
    const tokensSnap = await admin.firestore()
        .collection("notification_tokens")
        .doc(ownerId)
        .collection("devices")
        .limit(1)
        .get();

    if (!tokensSnap.empty) {
      fcmToken = tokensSnap.docs[0].data().fcmToken;
    }

    // Legacy fallback for transition
    if (!fcmToken) {
      const userDoc = await admin.firestore()
          .collection("users")
          .doc(ownerId)
          .get();
      if (userDoc.exists) {
        fcmToken = userDoc.data().fcmToken;
      }
    }

    if (!fcmToken) {
      console.error(`User ${ownerId} does not have an fcmToken.`);
      return null;
    }

    // 3. Send the notification securely
    const message = {
      notification: {
        title: "ApexFlow: Aracınıza Bildirim Var!",
        body: `Birisi QR kodunuzu okutarak bildirim gönderdi: ${safeReason}`,
      },
      token: fcmToken,
      data: {
        reason: safeReason,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
    };

    const response = await admin.messaging().send(message);
    console.log("Successfully sent message:", response);
    return null;

  } catch (error) {
    console.error("Error sending notification:", error);
    return null;
  }
});

// Madeforth Discord QA & In-App Bug Report Engine Endpoint
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { sanitizeUserText } = require("./src/discord/sanitize");

exports.createBugReportDraft = onCall(
  {
    region: "europe-west1",
    enforceAppCheck: false,
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Authentication required");
    }
    const uid = request.auth.uid;
    const input = request.data || {};

    const year = new Date().getFullYear();
    const randomSeq = Math.floor(100000 + Math.random() * 900000);
    const humanBugId = `AFB-${year}-${randomSeq}`;
    const db = admin.firestore();

    const bugRef = db.collection("bug_reports").doc();
    const bugData = {
      internalBugId: bugRef.id,
      humanBugId,
      reporterUid: uid,
      category: input.category || "other",
      priority: input.priority || "p2",
      status: "submitted",
      title: sanitizeUserText(input.title, 150),
      whatHappened: sanitizeUserText(input.whatHappened, 1000),
      expectedBehavior: sanitizeUserText(input.expectedBehavior, 1000),
      stepsToReproduce: sanitizeUserText(input.stepsToReproduce, 1000),
      idempotencyKey: String(input.idempotencyKey || ""),
      diagnostic: input.diagnostic || null,
      attachments: input.attachments || [],
      discord: {
        syncStatus: "pending",
        threadId: null,
        messageId: null,
        lastErrorCode: null,
      },
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    const outboxRef = db.collection("bug_dispatch_outbox").doc(bugRef.id);
    const batch = db.batch();
    batch.set(bugRef, bugData);
    batch.set(outboxRef, {
      bugRef: bugRef.path,
      bugId: humanBugId,
      state: "pending",
      attemptCount: 0,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    await batch.commit();

    return {
      internalBugId: bugRef.id,
      humanBugId,
      status: "submitted",
      createdAtIso: new Date().toISOString(),
    };
  }
);

exports.dispatchBugReportToDiscord =
  require("./src/discord/dispatchWorker").dispatchBugReportToDiscord;

exports.discordInteractions =
  require("./src/discord/interactions").discordInteractions;

// Telemetry DNA & Badge Engine Callable: verifyRideContribution
exports.verifyRideContribution = onCall(
  { region: "europe-west1", enforceAppCheck: false },
  async (request) => {
    if (!request.auth) throw new HttpsError("unauthenticated", "Authentication required");
    const uid = request.auth.uid;
    const input = request.data || {};
    if (!input.rideId || typeof input.rideId !== "string") {
      throw new HttpsError("invalid-argument", "rideId is required");
    }

    const db = admin.firestore();
    const eventRef = db.doc(`users/${uid}/telemetry_dna_events/${input.rideId}`);
    const stateRef = db.doc(`users/${uid}/telemetry_dna/state/current`);

    return db.runTransaction(async (tx) => {
      const eventSnap = await tx.get(eventRef);
      if (eventSnap.exists) {
        return { status: "duplicate", rideId: input.rideId };
      }

      const previousSnap = await tx.get(stateRef);
      const previousState = previousSnap.exists ? previousSnap.data() : { lifetime: {}, count: 0 };
      const newCount = (previousState.count || 0) + (input.dnaEligible ? 1 : 0);

      const nextState = {
        schemaVersion: 1,
        algorithmVersion: 1,
        computedAtIso: new Date().toISOString(),
        eligibleRideCount: newCount,
        lastAppliedEventId: input.rideId,
      };

      tx.set(eventRef, {
        rideId: input.rideId,
        submittedAt: admin.firestore.FieldValue.serverTimestamp(),
        dnaEligible: Boolean(input.dnaEligible),
        reasons: input.reasons || [],
      });

      tx.set(stateRef, nextState, { merge: true });

      return { status: "accepted", rideId: input.rideId, count: newCount };
    });
  }
);

// Apex Pass Engine Callable: claimAchievementMilestone
exports.claimAchievementMilestone = onCall(
  { region: "europe-west1", enforceAppCheck: false },
  async (request) => {
    if (!request.auth) throw new HttpsError("unauthenticated", "Authentication required");
    const uid = request.auth.uid;
    const milestoneId = String(request.data?.milestoneId || "");

    const REWARD_CATALOG = {
      ACH_100: { durationSeconds: 72 * 3600, requiredCount: 100 },
      ACH_200: { durationSeconds: 168 * 3600, requiredCount: 200 },
    };

    const rewardConfig = REWARD_CATALOG[milestoneId];
    if (!rewardConfig) {
      throw new HttpsError("invalid-argument", "Invalid milestone ID");
    }

    const db = admin.firestore();
    const rewardRef = db.doc(`users/${uid}/reward_wallet/${milestoneId}`);
    const stateRef = db.doc(`users/${uid}/achievement_private/state`);

    return db.runTransaction(async (tx) => {
      const rewardSnap = await tx.get(rewardRef);
      if (rewardSnap.exists) {
        throw new HttpsError("already-exists", "Milestone reward already claimed");
      }

      const stateSnap = await tx.get(stateRef);
      const coreCompletedCount = stateSnap.exists ? (stateSnap.data()?.coreCompletedCount || 0) : 0;
      if (coreCompletedCount < rewardConfig.requiredCount) {
        throw new HttpsError("failed-precondition", "Milestone criteria not met");
      }

      tx.create(rewardRef, {
        milestoneId,
        durationSeconds: rewardConfig.durationSeconds,
        status: "AVAILABLE",
        earnedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return { status: "AVAILABLE", milestoneId };
    });
  }
);

// Apex Pass Engine Callable: activateApexPass
exports.activateApexPass = onCall(
  { region: "europe-west1", enforceAppCheck: false },
  async (request) => {
    if (!request.auth) throw new HttpsError("unauthenticated", "Authentication required");
    const uid = request.auth.uid;
    const rewardId = String(request.data?.rewardId || "");

    const db = admin.firestore();
    const rewardRef = db.doc(`users/${uid}/reward_wallet/${rewardId}`);

    return db.runTransaction(async (tx) => {
      const rewardSnap = await tx.get(rewardRef);
      if (!rewardSnap.exists || rewardSnap.data()?.status !== "AVAILABLE") {
        throw new HttpsError("failed-precondition", "Reward is not available for activation");
      }

      const now = admin.firestore.Timestamp.now();
      const durationSec = rewardSnap.data().durationSeconds || 72 * 3600;
      const expiresAt = admin.firestore.Timestamp.fromMillis(now.toMillis() + durationSec * 1000);

      const entitlementRef = db.collection(`users/${uid}/entitlements`).doc();

      tx.update(rewardRef, {
        status: "ACTIVATED",
        activatedAt: now,
        expiresAt,
      });

      tx.create(entitlementRef, {
        source: "ACHIEVEMENT_PASS",
        status: "ACTIVE",
        rewardId,
        startsAt: now,
        expiresAt,
        issuedAt: now,
      });

      return { status: "ACTIVE", expiresAtIso: expiresAt.toDate().toISOString() };
    });
  }
);

