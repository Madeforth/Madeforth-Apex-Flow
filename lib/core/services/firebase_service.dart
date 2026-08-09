import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseService {
  FirebaseService._privateConstructor();
  static final FirebaseService instance = FirebaseService._privateConstructor();

  bool _initialized = false;

  // Local cache key for developer unique installation ID
  static const _installationIdKey = 'firebase.installation_id';

  Future<void> init() async {
    if (_initialized) return;
    try {
      await Firebase.initializeApp();
      _initialized = true;
    } catch (_) {
      // Fail-safe if google-services.json is not configured yet
      return;
    }
    try {
      // Wait for Firebase Auth to finish restoring any persisted sign-in
      // session before any caller reads `.currentUser`. Reading it
      // synchronously right after Core init can race and return null even
      // though a session is about to be restored — this previously made
      // account-scoped local data (profile fields, garage/motorcycle
      // records) look wiped/guest-mode right after a cold start.
      await FirebaseAuth.instance.authStateChanges().first.timeout(
        const Duration(seconds: 5),
      );
    } catch (_) {
      // Timed out or failed to resolve — proceed with whatever
      // currentUser already reflects rather than blocking startup.
    }
  }

  /// Generates or retrieves a unique persistent client installation ID.
  /// Used to uniquely bind the developer tag without requiring a full Auth register process.
  Future<String> getOrCreateInstallationId() async {
    if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST'))
      return 'test_inst_id';
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    }
    final prefs = await SharedPreferences.getInstance();
    var instId = prefs.getString(_installationIdKey);
    if (instId == null) {
      instId =
          'inst_${DateTime.now().millisecondsSinceEpoch}_${(100 + (DateTime.now().microsecondsSinceEpoch % 900))}';
      await prefs.setString(_installationIdKey, instId);
    }
    return instId;
  }

  /// Checks if a Rider Tag is already registered in Firestore. A tag is
  /// available if unclaimed, or already owned by this installation.
  Future<bool> isTagAvailable(String tag, String installationId) async {
    if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST'))
      return true;
    if (!_initialized) return true; // Offline fallback for local testing

    try {
      final docRef = FirebaseFirestore.instance
          .collection('rider_tags')
          .doc(tag.toLowerCase());
      final doc = await docRef.get();

      if (!doc.exists) {
        // Tag is free to be registered
        return true;
      }

      final data = doc.data();
      if (data == null) return false;

      final registeredOwner = data['ownerId'] as String?;

      // If tag is already registered, it is only available to the owner
      return registeredOwner == installationId;
    } catch (_) {
      // In case of Firestore permission errors or offline state, default to true for offline mode
      return true;
    }
  }

  /// Registers a user using email and password in Firebase Authentication.
  /// Sends an email verification link to their address.
  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    await init();
    if (!_initialized) return null;
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await credential.user?.sendEmailVerification();
      return credential.user;
    } catch (_) {
      rethrow;
    }
  }

  /// Signs in a user using their Google Account.
  Future<User?> signInWithGoogle() async {
    await init();
    if (!_initialized) return null;
    try {
      final GoogleSignIn googleSignIn;
      if (kIsWeb) {
        googleSignIn = GoogleSignIn(
          clientId:
              '29839209813-ulc1uos0dt50n4u0oa4mq0ssdp662fl4.apps.googleusercontent.com',
        );
      } else {
        googleSignIn = GoogleSignIn();
      }
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      return userCredential.user;
    } catch (_) {
      rethrow;
    }
  }

  /// Synchronizes user profile status to Firestore database.
  /// Binds the tag ownerId securely to prevent tag hijacking.
  Future<bool> syncUserProfile({
    required String name,
    required String tag,
    required bool isPremium,
    required String phone,
    required String bloodType,
    required String emergencyName,
    required String emergencyPhone,
    String? oldTag,
    String? email,
    String? activeBikeName,
    String? activeBikeModel,
    int? activeBikeOdometer,
    int? activeBikeLastService,
    int? activeBikeServiceInterval,
    double? weeklyKm,
    int? harmonyScore,
    String? ridingStyle,
    int? avatarIndex,
    String? avatarPhotoUrl,
    int? cardThemeIndex,
    String? city,
    String? instagram,
    String? tiktok,
    String? youtube,
    String? licensePlate,
    List<String>? selectedBadges,
    List<String>? unlockedBadges,
    bool? isFoundingMember,
    int? supporterTier,
    List<int>? unlockedSupporterTiers,
    int? chainWearPercent,
    int? tireWearPercent,
    int? brakeWearPercent,
    int? oilHealthPercent,
    int? batteryHealthPercent,
    String? fcmToken,
    int? totalRidesCount,
    double? totalKm,
    bool? sharePhone,
    bool? shareEmergency,
    bool? shareBloodType,
    bool? shareLicensePlate,
    List<Map<String, dynamic>>? fuelLogs,
    List<Map<String, dynamic>>? motorcycles,
    List<Map<String, dynamic>>? serviceLogs,
    List<Map<String, dynamic>>? dailyChecks,
  }) async {
    if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST'))
      return true;
    await init();
    if (!_initialized) return true;

    try {
      final instId = await getOrCreateInstallationId();

      // 1. Double check tag availability
      final available = await isTagAvailable(tag, instId);
      if (!available) {
        return false; // Hijack attempt or tag collision
      }

      final batch = FirebaseFirestore.instance.batch();

      // 2. Set tag ownership document (Public Rider Card view for friends)
      final tagDocRef = FirebaseFirestore.instance
          .collection('rider_tags')
          .doc(tag.toLowerCase());
      final Map<String, dynamic> tagData = {
        'tag': tag,
        'name': name,
        'ownerId': instId,
        'isPremium': isPremium,
        // Never retain private identifiers in this public lookup document.
        // FieldValue.delete also scrubs legacy values on the next sync.
        'email': FieldValue.delete(),
        'licensePlate': FieldValue.delete(),
        'phoneNumber': FieldValue.delete(),
        'bloodType': FieldValue.delete(),
        'emergencyContactName': FieldValue.delete(),
        'emergencyContactPhone': FieldValue.delete(),
      };
      if (city != null) tagData['city'] = city;
      if (activeBikeName != null) tagData['activeBikeName'] = activeBikeName;
      if (avatarIndex != null) tagData['avatarIndex'] = avatarIndex;
      if (avatarPhotoUrl != null) {
        tagData['avatarPhotoUrl'] = avatarPhotoUrl.isEmpty
            ? FieldValue.delete()
            : avatarPhotoUrl;
      }
      if (cardThemeIndex != null) tagData['cardThemeIndex'] = cardThemeIndex;
      if (selectedBadges != null) tagData['selectedBadges'] = selectedBadges;
      if (ridingStyle != null) tagData['ridingStyle'] = ridingStyle;
      if (totalRidesCount != null) tagData['totalRidesCount'] = totalRidesCount;
      if (totalKm != null) tagData['totalKm'] = totalKm;
      if (harmonyScore != null) tagData['harmonyScore'] = harmonyScore;
      if (isFoundingMember != null)
        tagData['isFoundingMember'] = isFoundingMember;
      batch.set(tagDocRef, tagData, SetOptions(merge: true));

      // Sensitive fields live in an authenticated, friendship-gated
      // projection. They never belong in the anonymously readable Rider Tag
      // registry, even when the owner has opted to share them with friends.
      final friendProfileRef = FirebaseFirestore.instance
          .collection('friend_profiles')
          .doc(instId);
      final friendProfileData = <String, dynamic>{
        'ownerId': instId,
        'sharePhone': sharePhone ?? false,
        'shareEmergency': shareEmergency ?? false,
        'shareBloodType': shareBloodType ?? false,
        'shareLicensePlate': shareLicensePlate ?? false,
        'phoneNumber': sharePhone == true && phone.isNotEmpty
            ? phone
            : FieldValue.delete(),
        'bloodType': shareBloodType == true && bloodType.isNotEmpty
            ? bloodType
            : FieldValue.delete(),
        'emergencyContactName': FieldValue.delete(),
        'emergencyContactPhone':
            shareEmergency == true && emergencyPhone.isNotEmpty
            ? emergencyPhone
            : FieldValue.delete(),
        'licensePlate':
            shareLicensePlate == true && (licensePlate?.isNotEmpty ?? false)
            ? licensePlate
            : FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      batch.set(friendProfileRef, friendProfileData, SetOptions(merge: true));

      // Delete the old Rider Tag document from Firestore if it is different
      if (oldTag != null &&
          oldTag.trim().isNotEmpty &&
          oldTag.toLowerCase() != tag.toLowerCase()) {
        final oldTagDocRef = FirebaseFirestore.instance
            .collection('rider_tags')
            .doc(oldTag.trim().toLowerCase());
        batch.delete(oldTagDocRef);
      }

      // 3. Save comprehensive profile document
      final profileDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(instId);
      final Map<String, dynamic> profileData = {
        'name': name,
        'riderTag': tag,
        'isPremium': isPremium,
        'phoneNumber': phone,
        'bloodType': bloodType,
        'emergencyContactName': emergencyName,
        'emergencyContactPhone': emergencyPhone,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (email != null && email.isNotEmpty) {
        profileData['email'] = email;
      }
      if (fcmToken != null && fcmToken.isNotEmpty) {
        profileData['fcmToken'] = fcmToken;
      }

      if (activeBikeName != null)
        profileData['activeBikeName'] = activeBikeName;
      if (activeBikeModel != null)
        profileData['activeBikeModel'] = activeBikeModel;
      if (activeBikeOdometer != null)
        profileData['activeBikeOdometer'] = activeBikeOdometer;
      if (activeBikeLastService != null)
        profileData['activeBikeLastService'] = activeBikeLastService;
      if (activeBikeServiceInterval != null)
        profileData['activeBikeServiceInterval'] = activeBikeServiceInterval;
      if (chainWearPercent != null)
        profileData['chainWearPercent'] = chainWearPercent;
      if (tireWearPercent != null)
        profileData['tireWearPercent'] = tireWearPercent;
      if (brakeWearPercent != null)
        profileData['brakeWearPercent'] = brakeWearPercent;
      if (oilHealthPercent != null)
        profileData['oilHealthPercent'] = oilHealthPercent;
      if (batteryHealthPercent != null)
        profileData['batteryHealthPercent'] = batteryHealthPercent;
      if (weeklyKm != null) profileData['weeklyKm'] = weeklyKm;
      if (harmonyScore != null) profileData['harmonyScore'] = harmonyScore;
      if (ridingStyle != null) profileData['ridingStyle'] = ridingStyle;
      if (avatarIndex != null) profileData['avatarIndex'] = avatarIndex;
      if (avatarPhotoUrl != null) {
        profileData['avatarPhotoUrl'] = avatarPhotoUrl.isEmpty
            ? FieldValue.delete()
            : avatarPhotoUrl;
      }
      if (cardThemeIndex != null)
        profileData['cardThemeIndex'] = cardThemeIndex;
      if (city != null) profileData['city'] = city;
      if (instagram != null) profileData['instagram'] = instagram;
      if (tiktok != null) profileData['tiktok'] = tiktok;
      if (youtube != null) profileData['youtube'] = youtube;
      if (licensePlate != null) profileData['licensePlate'] = licensePlate;
      if (selectedBadges != null)
        profileData['selectedBadges'] = selectedBadges;
      if (unlockedBadges != null)
        profileData['unlockedBadges'] = unlockedBadges;
      if (isFoundingMember != null)
        profileData['isFoundingMember'] = isFoundingMember;
      if (supporterTier != null) profileData['supporterTier'] = supporterTier;
      if (unlockedSupporterTiers != null)
        profileData['unlockedSupporterTiers'] = unlockedSupporterTiers;
      if (totalRidesCount != null)
        profileData['totalRidesCount'] = totalRidesCount;
      if (totalKm != null) profileData['totalKm'] = totalKm;
      if (sharePhone != null) profileData['sharePhone'] = sharePhone;
      if (shareEmergency != null)
        profileData['shareEmergency'] = shareEmergency;
      if (shareBloodType != null)
        profileData['shareBloodType'] = shareBloodType;
      if (shareLicensePlate != null)
        profileData['shareLicensePlate'] = shareLicensePlate;
      if (fuelLogs != null) profileData['fuelLogs'] = fuelLogs;
      if (motorcycles != null) profileData['motorcycles'] = motorcycles;
      if (serviceLogs != null) profileData['serviceLogs'] = serviceLogs;
      if (dailyChecks != null) profileData['dailyChecks'] = dailyChecks;

      batch.set(profileDocRef, profileData, SetOptions(merge: true));

      await batch.commit();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Logs in a user using their Rider Tag and password.
  /// Requires the tag to be bound to an email (real Firebase Auth sign-in);
  /// throws 'legacy-unbound-account' for tags with no associated email.
  Future<Map<String, dynamic>?> loginWithTag(
    String tag,
    String password,
  ) async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return {'name': 'Test User', 'riderTag': tag, 'isPremium': false};
    }
    await init();
    if (!_initialized) return null;

    try {
      final tagDocRef = FirebaseFirestore.instance
          .collection('rider_tags')
          .doc(tag.toLowerCase());
      final tagDoc = await tagDocRef.get();

      if (!tagDoc.exists) return null; // Tag not registered

      final tagData = tagDoc.data();
      if (tagData == null) return null;

      final associatedEmail = tagData['email'] as String?;
      final ownerId = tagData['ownerId'] as String?;
      if (ownerId == null) return null;
      if (associatedEmail != null && associatedEmail.isNotEmpty) {
        // Authenticate securely using real Firebase Authentication SDK
        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: associatedEmail,
              password: password,
            );
        // Verify email status
        if (credential.user != null && !credential.user!.emailVerified) {
          throw 'email-not-verified';
        }
      } else {
        throw 'legacy-unbound-account';
      }

      // Fetch the actual profile of the owner
      final profileDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(ownerId)
          .get();
      if (!profileDoc.exists) return null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _installationIdKey,
        ownerId,
      ); // Bind local device to this user ID

      return profileDoc.data();
    } catch (e) {
      if (e == 'email-not-verified') {
        rethrow;
      }
      return null;
    }
  }

  /// Logs in a user using their Email and password.
  /// Logs in a user using their Email and password.
  /// Authenticates via FirebaseAuth and retrieves their profile from Firestore with multi-tier recovery.
  Future<Map<String, dynamic>?> loginWithEmail(
    String email,
    String password,
  ) async {
    if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) {
      return {
        'name': 'Test User',
        'riderTag': '@test#1234',
        'isPremium': false,
      };
    }
    await init();
    if (!_initialized) return null;

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) return null;

      // Verify email status
      if (!user.emailVerified) {
        throw 'email-not-verified';
      }

      final cleanEmail = email.trim().toLowerCase();
      Map<String, dynamic> data = {};

      // 1. Fetch user profile from Firestore using uid
      final uidDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (uidDoc.exists && uidDoc.data() != null && uidDoc.data()!.isNotEmpty) {
        data = Map<String, dynamic>.from(uidDoc.data()!);
      }

      // 2. Fallback: If profile doc under uid does not exist or has empty
      // data, search users collection by email. This only ever recovers
      // pre-existing legacy records — firestore.rules scopes `/users/{uid}`
      // reads to `isOwner(uid)`, so a collection-level query filtered by
      // `email` (not `uid`) is always rejected with permission-denied for
      // every account, including brand-new ones that simply don't have a
      // profile doc yet. Never let that abort login — fall through to the
      // "fill in defaults" branch below exactly as if nothing were found.
      if (data.isEmpty || (data['name'] as String? ?? '').isEmpty) {
        try {
          final emailQuery1 = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: cleanEmail)
              .get();
          if (emailQuery1.docs.isNotEmpty) {
            data = Map<String, dynamic>.from(emailQuery1.docs.first.data());
          } else {
            final emailQuery2 = await FirebaseFirestore.instance
                .collection('users')
                .where('email', isEqualTo: email.trim())
                .get();
            if (emailQuery2.docs.isNotEmpty) {
              data = Map<String, dynamic>.from(emailQuery2.docs.first.data());
            }
          }
        } catch (_) {
          // Permission-denied (or any other Firestore error) here means
          // no legacy record was recoverable this way — proceed with
          // defaults instead of failing the whole login.
        }
      }

      // Fill in fallback email and name if still empty
      if (data.isEmpty) {
        data = {
          'email': cleanEmail,
          'name': user.displayName ?? '',
          'riderTag': '',
          'isPremium': false,
        };
      } else {
        data['email'] = cleanEmail;
      }

      // 3. Safeguard: recover the tag by authenticated owner UID. Email is
      // deliberately never stored in the public rider_tags registry.
      var currentTag = data['riderTag'] as String? ?? '';
      if (currentTag.isEmpty) {
        final tagQueryByOwner = await FirebaseFirestore.instance
            .collection('rider_tags')
            .where('ownerId', isEqualTo: user.uid)
            .get();
        if (tagQueryByOwner.docs.isNotEmpty) {
          currentTag =
              tagQueryByOwner.docs.first.data()['tag'] as String? ?? '';
        }
      }

      // 4. Ultimate Fallback: If riderTag is STILL empty, generate a clean tag from email prefix
      if (currentTag.isEmpty) {
        final emailPrefix = cleanEmail.contains('@')
            ? cleanEmail.split('@')[0]
            : 'rider';
        var cleanPrefix = emailPrefix.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
        if (cleanPrefix.isEmpty) cleanPrefix = 'rider';
        if (cleanPrefix.length > 10) cleanPrefix = cleanPrefix.substring(0, 10);
        final randomNum =
            (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();
        currentTag = '@$cleanPrefix#$randomNum';
      }

      data['riderTag'] = currentTag;

      // 5. Save installation ID and migrate/cement profile under users/{user.uid}
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_installationIdKey, user.uid);

      // Write consolidated profile back to users/{user.uid} and rider_tags
      final batch = FirebaseFirestore.instance.batch();
      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      batch.set(userDocRef, data, SetOptions(merge: true));

      final tagDocRef = FirebaseFirestore.instance
          .collection('rider_tags')
          .doc(currentTag.toLowerCase());
      batch.set(tagDocRef, {
        'tag': currentTag,
        'ownerId': user.uid,
        'email': FieldValue.delete(),
        'licensePlate': FieldValue.delete(),
        'phoneNumber': FieldValue.delete(),
        'bloodType': FieldValue.delete(),
        'emergencyContactName': FieldValue.delete(),
        'emergencyContactPhone': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await batch.commit();

      return data;
    } catch (_) {
      rethrow;
    }
  }

  /// Queries Firestore to find a user profile by their registered Rider Tag.
  /// Used during Friend Additions to fetch real user details from the database.
  Future<Map<String, dynamic>?> getProfileByTag(String tag) async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return null;
    await init();
    if (!_initialized) return null;

    try {
      // 1. Find the ownerId for this tag
      final tagDocRef = FirebaseFirestore.instance
          .collection('rider_tags')
          .doc(tag.toLowerCase());
      final tagDoc = await tagDocRef.get();

      if (!tagDoc.exists) return null; // Tag not registered

      final tagData = tagDoc.data();
      final ownerId = tagData?['ownerId'] as String?;
      if (ownerId == null) return null;

      // 2. Fetch the public card projection (never private users/{ownerId})
      final publicCardDoc = await FirebaseFirestore.instance
          .collection('public_rider_cards')
          .doc(ownerId)
          .get();

      final Map<String, dynamic> publicData;
      if (publicCardDoc.exists && publicCardDoc.data() != null) {
        publicData = Map<String, dynamic>.from(publicCardDoc.data()!);
      } else {
        // Fallback to public fields from rider_tags
        publicData = {
          'tag': tagData?['tag'] ?? tag,
          'name': tagData?['name'] ?? 'Rider',
          'isPremium': tagData?['isPremium'] ?? false,
          'city': tagData?['city'],
          'avatarIndex': tagData?['avatarIndex'] ?? 0,
          'cardThemeIndex': tagData?['cardThemeIndex'] ?? 0,
          'selectedBadges': tagData?['selectedBadges'] ?? [],
          'ridingStyle': tagData?['ridingStyle'] ?? 'Zen',
          'totalRidesCount': tagData?['totalRidesCount'] ?? 0,
          'totalKm': tagData?['totalKm'] ?? 0.0,
          'harmonyScore': tagData?['harmonyScore'] ?? 85,
        };
      }

      publicData['uid'] = ownerId;
      publicData['avatarPhotoUrl'] ??= tagData?['avatarPhotoUrl'];

      // Strict PII sanitization - never leak private fields
      publicData.remove('phoneNumber');
      publicData.remove('bloodType');
      publicData.remove('emergencyContactName');
      publicData.remove('emergencyContactPhone');
      publicData.remove('fcmToken');
      publicData.remove('password');

      final friendFields = await getFriendSharedProfile(ownerId);
      if (friendFields != null) {
        publicData.addAll(friendFields);
      }

      return publicData;
    } catch (_) {
      return null;
    }
  }

  /// Returns only the fields the owner explicitly exposed to connected
  /// friends. Firestore rules reject this read when no friendship exists.
  Future<Map<String, dynamic>?> getFriendSharedProfile(String uid) async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return null;
    await init();
    if (!_initialized || FirebaseAuth.instance.currentUser == null) return null;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('friend_profiles')
          .doc(uid)
          .get();
      if (!snapshot.exists || snapshot.data() == null) return null;

      final data = snapshot.data()!;
      return {
        if (data['phoneNumber'] is String) 'phoneNumber': data['phoneNumber'],
        if (data['bloodType'] is String) 'bloodType': data['bloodType'],
        if (data['emergencyContactPhone'] is String)
          'emergencyContactPhone': data['emergencyContactPhone'],
        if (data['licensePlate'] is String)
          'licensePlate': data['licensePlate'],
      };
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied') return null;
      rethrow;
    }
  }

  /// Looks up a rider's public profile fields by Firebase UID instead of
  /// tag — reverse-queries `rider_tags` (public read, the only channel a
  /// non-owner can actually read per firestore.rules) by `ownerId`. Use
  /// this instead of reading `users/{uid}` directly for another rider:
  /// that collection's rule is owner-scoped and denies every other caller.
  Future<Map<String, dynamic>?> getProfileByUid(String uid) async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return null;
    await init();
    if (!_initialized) return null;

    try {
      final tagQuery = await FirebaseFirestore.instance
          .collection('rider_tags')
          .where('ownerId', isEqualTo: uid)
          .limit(1)
          .get();
      if (tagQuery.docs.isEmpty) return null;

      final tagData = tagQuery.docs.first.data();
      return getProfileByTag(
        tagData['tag'] as String? ?? tagQuery.docs.first.id,
      );
    } catch (_) {
      return null;
    }
  }

  /// Sends a password reset email via Firebase Authentication
  Future<void> sendPasswordResetEmail(String email) async {
    await init();
    if (!_initialized) return;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (_) {
      rethrow;
    }
  }

  /// Adds a bidirectional friend link document in Firestore
  Future<void> addFriendConnection(String myId, String friendId) async {
    await init();
    if (!_initialized) return;
    try {
      final docId = myId.compareTo(friendId) < 0
          ? '${myId}_$friendId'
          : '${friendId}_$myId';
      await FirebaseFirestore.instance.collection('friendships').doc(docId).set(
        {
          'userA': myId,
          'userB': friendId,
          'createdAt': FieldValue.serverTimestamp(),
        },
      );
    } catch (_) {}
  }

  /// Removes the bidirectional friend link document in Firestore
  Future<void> removeFriendConnection(String myId, String friendId) async {
    await init();
    if (!_initialized) return;
    try {
      final docId = myId.compareTo(friendId) < 0
          ? '${myId}_$friendId'
          : '${friendId}_$myId';
      await FirebaseFirestore.instance
          .collection('friendships')
          .doc(docId)
          .delete();
    } catch (_) {}
  }

  /// Uploads a rider's profile photo to Storage at a single overwritable
  /// path per user (avatars/{uid}) and returns a fresh download URL. No
  /// file extension in the path — Storage security rules can't match a
  /// wildcard segment plus a literal suffix in one path segment, so the
  /// content type is carried entirely via metadata instead.
  /// The caller is responsible for keeping the image small before calling
  /// this (image_picker's maxWidth/maxHeight/imageQuality) — storage.rules
  /// additionally rejects anything over 300 KB or not an image as
  /// defense-in-depth.
  Future<String> uploadAvatarPhoto(Uint8List bytes, String uid) async {
    await init();
    final ref = FirebaseStorage.instance.ref('avatars/$uid');
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }

  /// Deletes the active account through the App Check-protected backend.
  ///
  /// Backend ownership is required because several records (entitlements,
  /// public rider cards, QA outbox/Discord copies and Auth itself) correctly
  /// reject client-side deletion in Firestore rules.
  Future<void> deleteUserAccount(String targetUid, String riderTag) async {
    await init();
    if (!_initialized) throw StateError('Firebase is not initialized.');

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.uid != targetUid) {
      throw Exception('Oturum açmış kullanıcı ile silinecek hesap uyuşmuyor.');
    }

    await FirebaseFunctions.instanceFor(
      region: 'europe-west1',
    ).httpsCallable('deleteAccountAndData').call<void>();
  }

  /// Queries all friendships where the current user is a participant
  Future<List<String>> getIncomingFriendIds(String myId) async {
    await init();
    if (!_initialized) return const [];
    try {
      // Query where userA is myId
      final queryA = await FirebaseFirestore.instance
          .collection('friendships')
          .where('userA', isEqualTo: myId)
          .get();
      // Query where userB is myId
      final queryB = await FirebaseFirestore.instance
          .collection('friendships')
          .where('userB', isEqualTo: myId)
          .get();

      final List<String> results = [];
      for (final doc in queryA.docs) {
        final other = doc.data()['userB'] as String?;
        if (other != null && other != myId) results.add(other);
      }
      for (final doc in queryB.docs) {
        final other = doc.data()['userA'] as String?;
        if (other != null && other != myId) results.add(other);
      }
      return results;
    } catch (_) {
      return const [];
    }
  }

  /// Completely deletes a lobby from Firestore
  Future<void> deleteLobby(String lobbyId) async {
    await init();
    if (!_initialized) return;
    try {
      await FirebaseFirestore.instance
          .collection('lobbies')
          .doc(lobbyId)
          .delete();
    } catch (_) {}
  }

  /// Creates or updates a group ride lobby in Firestore
  Future<void> createOrUpdateLobby(
    String lobbyId,
    Map<String, dynamic> lobbyData,
  ) async {
    await init();
    if (!_initialized) return;
    try {
      await FirebaseFirestore.instance.collection('lobbies').doc(lobbyId).set({
        ...lobbyData,
        'updatedAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(hours: 12)),
        ),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  /// Adds a rider's profile data to the riders list of a lobby
  Future<void> joinLobby(
    String lobbyId,
    Map<String, dynamic> riderProfileData,
  ) async {
    await init();
    if (!_initialized) return;
    try {
      final docRef = FirebaseFirestore.instance
          .collection('lobbies')
          .doc(lobbyId);
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final snapshot = await tx.get(docRef);
        if (!snapshot.exists) return;
        final data = snapshot.data();
        if (data == null) return;
        final ridersList = List<dynamic>.from(data['riders'] ?? []);

        // Remove existing if any (by stableId)
        final stableId =
            riderProfileData['stableId'] ?? riderProfileData['riderTag'];
        ridersList.removeWhere(
          (r) =>
              (r is Map) &&
              (r['stableId'] == stableId || r['riderTag'] == stableId),
        );

        // Add new
        ridersList.add(riderProfileData);
        tx.update(docRef, {
          'riders': ridersList,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (_) {}
  }

  /// Removes a rider from the lobby riders list
  Future<void> leaveLobby(String lobbyId, String stableId) async {
    await init();
    if (!_initialized) return;
    try {
      final docRef = FirebaseFirestore.instance
          .collection('lobbies')
          .doc(lobbyId);
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final snapshot = await tx.get(docRef);
        if (!snapshot.exists) return;
        final data = snapshot.data();
        if (data == null) return;
        final ridersList = List<dynamic>.from(data['riders'] ?? []);

        ridersList.removeWhere(
          (r) =>
              (r is Map) &&
              (r['stableId'] == stableId || r['riderTag'] == stableId),
        );

        tx.update(docRef, {
          'riders': ridersList,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (_) {}
  }

  /// Updates the status field of a lobby
  Future<void> updateLobbyStatus(String lobbyId, String status) async {
    await init();
    if (!_initialized) return;
    try {
      await FirebaseFirestore.instance
          .collection('lobbies')
          .doc(lobbyId)
          .update({
            'status': status,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (_) {}
  }

  /// Updates the meetingPoint field of a lobby
  Future<void> updateLobbyMeetingPoint(
    String lobbyId,
    Map<String, dynamic>? point,
  ) async {
    await init();
    if (!_initialized) return;
    try {
      await FirebaseFirestore.instance
          .collection('lobbies')
          .doc(lobbyId)
          .update({
            'meetingPoint': point,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (_) {}
  }

  /// Streams real-time updates for a specific lobby document
  Stream<DocumentSnapshot> streamLobby(String lobbyId) {
    if (!_initialized) {
      // Offline fallback: empty stream
      return const Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('lobbies')
        .doc(lobbyId)
        .snapshots();
  }

  /// Checks if a lobby exists in Firestore
  Future<bool> checkLobbyExists(String lobbyId) async {
    await init();
    if (!_initialized) return false;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('lobbies')
          .doc(lobbyId)
          .get();
      return doc.exists;
    } catch (_) {
      return false;
    }
  }
}
