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
      title: String(input.title || "").substring(0, 150),
      whatHappened: String(input.whatHappened || "").substring(0, 1000),
      expectedBehavior: String(input.expectedBehavior || "").substring(0, 1000),
      stepsToReproduce: String(input.stepsToReproduce || "").substring(0, 1000),
      idempotencyKey: String(input.idempotencyKey || ""),
      diagnostic: input.diagnostic || null,
      attachments: input.attachments || [],
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await bugRef.set(bugData);

    return {
      internalBugId: bugRef.id,
      humanBugId,
      status: "submitted",
      createdAtIso: new Date().toISOString(),
    };
  }
);

