import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:apexflow/core/i18n/app_settings_state.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/core/storage/apex_kv_store.dart';
import 'package:apexflow/core/storage/db_provider.dart';
import 'package:apexflow/core/services/firebase_service.dart'; // Added Firebase import
import 'package:apexflow/garage/application/garage_state.dart';
import 'package:apexflow/rides/application/ride_state.dart';
import 'package:apexflow/rides/domain/ride_session.dart';
import 'package:apexflow/harmony_engine/harmony_engine.dart';
import 'package:apexflow/notifications/apex_notification_service.dart';
import 'package:home_widget/home_widget.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:apexflow/fuel/application/fuel_state.dart';
import 'package:apexflow/documents/application/document_vault_state.dart';
import 'package:apexflow/insights/application/insights_state.dart';

class UserProfile {
  const UserProfile({
    this.name = '',
    this.phoneNumber = '',
    this.bloodType = '',
    this.emergencyContactName = '',
    this.emergencyContactPhone = '',
    this.riderTag = '',
    this.ridingStyle = 'Focused',
    this.avatarIndex = 0,
    this.ghostMode = false,
    this.sharePhone = false,
    this.shareEmergency = false,
    this.isPremium = false,
    this.isTagCustomized = false,
    this.cardThemeIndex = 0,
    this.selectedFrameIndex = 0,
    this.purchasedThemes = const {},
    this.city = '',
    this.instagram = '',
    this.tiktok = '',
    this.youtube = '',
    this.licensePlate = '',
    this.selectedBadges = const [],
    this.unlockedBadges = const [
      'founding_member',
    ], // Default unlocked badge for launch week
    this.isFoundingMember = true,
    this.supporterTier = 0,
    this.unlockedSupporterTiers = const {},
    this.riderXp = 0,
  });

  final int riderXp;

  final String name;
  final String phoneNumber;
  final String bloodType;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String riderTag;
  final String ridingStyle;
  final int avatarIndex;
  final bool ghostMode;
  final bool sharePhone;
  final bool shareEmergency;
  final bool isPremium;
  final bool isTagCustomized;
  final int cardThemeIndex;
  final int selectedFrameIndex;
  final Set<int> purchasedThemes;
  final String city;
  final String instagram;
  final String tiktok;
  final String youtube;
  final String licensePlate;
  final List<String> selectedBadges;
  final List<String> unlockedBadges;
  final bool isFoundingMember;
  final int supporterTier;
  final Set<int> unlockedSupporterTiers;

  UserProfile copyWith({
    String? name,
    String? phoneNumber,
    String? bloodType,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? riderTag,
    String? ridingStyle,
    int? avatarIndex,
    bool? ghostMode,
    bool? sharePhone,
    bool? shareEmergency,
    bool? isPremium,
    bool? isTagCustomized,
    int? cardThemeIndex,
    int? selectedFrameIndex,
    Set<int>? purchasedThemes,
    String? city,
    String? instagram,
    String? tiktok,
    String? youtube,
    String? licensePlate,
    List<String>? selectedBadges,
    List<String>? unlockedBadges,
    bool? isFoundingMember,
    int? supporterTier,
    Set<int>? unlockedSupporterTiers,
    int? riderXp,
  }) {
    return UserProfile(
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bloodType: bloodType ?? this.bloodType,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      riderTag: riderTag ?? this.riderTag,
      ridingStyle: ridingStyle ?? this.ridingStyle,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      ghostMode: ghostMode ?? this.ghostMode,
      sharePhone: sharePhone ?? this.sharePhone,
      shareEmergency: shareEmergency ?? this.shareEmergency,
      isPremium: isPremium ?? this.isPremium,
      isTagCustomized: isTagCustomized ?? this.isTagCustomized,
      cardThemeIndex: cardThemeIndex ?? this.cardThemeIndex,
      selectedFrameIndex: selectedFrameIndex ?? this.selectedFrameIndex,
      purchasedThemes: purchasedThemes ?? this.purchasedThemes,
      city: city ?? this.city,
      instagram: instagram ?? this.instagram,
      tiktok: tiktok ?? this.tiktok,
      youtube: youtube ?? this.youtube,
      licensePlate: licensePlate ?? this.licensePlate,
      selectedBadges: selectedBadges ?? this.selectedBadges,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
      isFoundingMember: isFoundingMember ?? this.isFoundingMember,
      supporterTier: supporterTier ?? this.supporterTier,
      unlockedSupporterTiers:
          unlockedSupporterTiers ?? this.unlockedSupporterTiers,
      riderXp: riderXp ?? this.riderXp,
    );
  }
}

final userProfileProvider =
    NotifierProvider<UserProfileController, UserProfile>(
      UserProfileController.new,
    );

class UserProfileController extends Notifier<UserProfile> {
  static const _nameKey = 'profile.name';
  static const _phoneKey = 'profile.phone';
  static const _bloodTypeKey = 'profile.blood_type';
  static const _emergencyNameKey = 'profile.emergency_name';
  static const _emergencyPhoneKey = 'profile.emergency_phone';
  static const _riderTagKey = 'profile.rider_tag';
  static const _ridingStyleKey = 'profile.riding_style';
  static const _avatarIndexKey = 'profile.avatar_index';
  static const _ghostModeKey = 'profile.ghost_mode';
  static const _sharePhoneKey = 'profile.share_phone';
  static const _shareEmergencyKey = 'profile.share_emergency';
  static const _isPremiumKey = 'profile.is_premium';
  static const _isTagCustomizedKey = 'profile.is_tag_customized';
  static const _cardThemeIndexKey = 'profile.card_theme_index';
  static const _selectedFrameIndexKey = 'profile.selected_frame_index';
  static const _purchasedThemesKey = 'profile.purchased_themes';
  static const _cityKey = 'profile.city';
  static const _instagramKey = 'profile.instagram';
  static const _tiktokKey = 'profile.tiktok';
  static const _youtubeKey = 'profile.youtube';
  static const _licensePlateKey = 'profile.license_plate';
  static const _selectedBadgesKey = 'profile.selected_badges';
  static const _unlockedBadgesKey = 'profile.unlocked_badges';
  static const _isFoundingMemberKey = 'profile.is_founding_member';
  static const _supporterTierKey = 'profile.supporter_tier';
  static const _unlockedSupporterTiersKey = 'profile.unlocked_supporter_tiers';
  static const _riderXpKey = 'profile.rider_xp';

  @override
  UserProfile build() {
    ref.listen(garageStateProvider, (previous, next) {
      final wasHydrating = previous == null || previous.isHydrating;
      if (wasHydrating && !next.isHydrating) {
        _syncProfileToFirestore();
      } else if (previous?.activeBike != next.activeBike) {
        _syncProfileToFirestore();
      }
    });

    ref.listen(rideStateProvider, (previous, next) {
      final wasHydrating = previous == null || previous.isHydrating;
      if (wasHydrating && !next.isHydrating) {
        _syncProfileToFirestore();
      } else if (previous?.sessions.length != next.sessions.length) {
        _syncProfileToFirestore();
      }
    });

    unawaited(_hydrate());
    return const UserProfile();
  }

  Future<void> _hydrate() async {
    await ApexKvStore.init();
    await FirebaseService.instance.init(); // Initialize Firebase service
    final name = await ApexKvStore.getString(_nameKey) ?? '';
    final phone = await ApexKvStore.getString(_phoneKey) ?? '';
    final blood = await ApexKvStore.getString(_bloodTypeKey) ?? '';
    final emName = await ApexKvStore.getString(_emergencyNameKey) ?? '';
    final emPhone = await ApexKvStore.getString(_emergencyPhoneKey) ?? '';
    final ridingStyle =
        await ApexKvStore.getString(_ridingStyleKey) ?? 'Focused';
    final avatarIndex =
        int.tryParse(await ApexKvStore.getString(_avatarIndexKey) ?? '') ?? 0;
    final ghostMode = await ApexKvStore.getBool(_ghostModeKey) ?? false;
    final sharePhone = await ApexKvStore.getBool(_sharePhoneKey) ?? false;
    final shareEmergency =
        await ApexKvStore.getBool(_shareEmergencyKey) ?? false;
    var riderTag = await ApexKvStore.getString(_riderTagKey) ?? '';
    // Format the tag according to rules during hydration if empty or malformed
    var rawTag = riderTag.trim();
    rawTag = rawTag.replaceAll(RegExp(r'\s+'), '');
    if (rawTag.startsWith('@')) {
      rawTag = rawTag.substring(1);
    }
    if (rawTag.contains('#')) {
      rawTag = rawTag.split('#')[0];
    }
    if (rawTag.isEmpty) {
      rawTag = 'rider';
    }

    // Check if it is the authorized developer tag
    final isDevTag = riderTag == '@apex_dev#1881';

    // If not authorized developer tag and contains apex_dev, reset it to rider
    if (!isDevTag && rawTag.toLowerCase().contains('apex_dev')) {
      rawTag = 'rider';
    }

    if (rawTag.length > 10) {
      rawTag = rawTag.substring(0, 10);
    }

    final randomNum = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000))
        .toString();
    if (riderTag.isEmpty || !riderTag.contains('#')) {
      riderTag = isDevTag ? '@apex_dev#1881' : '@$rawTag#$randomNum';
      await ApexKvStore.setString(_riderTagKey, riderTag);
    } else {
      // Re-assemble formatted tag to apply max-length / spaces constraints
      final existingSuffix = riderTag.split('#')[1];
      riderTag = isDevTag ? '@apex_dev#1881' : '@$rawTag#$existingSuffix';
      await ApexKvStore.setString(_riderTagKey, riderTag);
    }

    final isPremium = isDevTag
        ? true
        : (await ApexKvStore.getBool(_isPremiumKey) ?? false);
    final isTagCustomized =
        (await ApexKvStore.getBool(_isTagCustomizedKey)) ??
        (riderTag.isNotEmpty && !riderTag.startsWith('@rider#'));

    final themeIndex =
        int.tryParse(await ApexKvStore.getString(_cardThemeIndexKey) ?? '') ??
        0;
    final selectedFrameIndex =
        int.tryParse(
          await ApexKvStore.getString(_selectedFrameIndexKey) ?? '',
        ) ??
        0;
    final purchasedRaw = await ApexKvStore.getString(_purchasedThemesKey) ?? '';
    Set<int> purchasedSet = {};
    if (purchasedRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(purchasedRaw) as List<dynamic>;
        purchasedSet = decoded.map((e) => e as int).toSet();
      } catch (_) {}
    }

    final city = await ApexKvStore.getString(_cityKey) ?? '';
    final instagram = await ApexKvStore.getString(_instagramKey) ?? '';
    final tiktok = await ApexKvStore.getString(_tiktokKey) ?? '';
    final youtube = await ApexKvStore.getString(_youtubeKey) ?? '';
    final licensePlate = await ApexKvStore.getString(_licensePlateKey) ?? '';

    List<String> selectedBadges = [];
    final selectedBadgesRaw =
        await ApexKvStore.getString(_selectedBadgesKey) ?? '';
    if (selectedBadgesRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(selectedBadgesRaw) as List<dynamic>;
        selectedBadges = decoded.map((e) => e.toString()).toList();
      } catch (_) {}
    }

    List<String> unlockedBadges = ['founding_member'];
    final unlockedBadgesRaw =
        await ApexKvStore.getString(_unlockedBadgesKey) ?? '';
    if (unlockedBadgesRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(unlockedBadgesRaw) as List<dynamic>;
        unlockedBadges = decoded.map((e) => e.toString()).toList();
      } catch (_) {}
    }

    final isFoundingMember =
        await ApexKvStore.getBool(_isFoundingMemberKey) ?? true;
    final supporterTier =
        int.tryParse(await ApexKvStore.getString(_supporterTierKey) ?? '') ?? 0;

    Set<int> unlockedSupporterTiers = supporterTier > 0 ? {supporterTier} : {};
    final unlockedTiersRaw =
        await ApexKvStore.getString(_unlockedSupporterTiersKey) ?? '';
    if (unlockedTiersRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(unlockedTiersRaw) as List<dynamic>;
        unlockedSupporterTiers = decoded.map((e) => e as int).toSet();
      } catch (_) {}
    }

    final riderXp = int.tryParse(await ApexKvStore.getString(_riderXpKey) ?? '') ?? 0;

    state = UserProfile(
      name: name,
      phoneNumber: phone,
      bloodType: blood,
      emergencyContactName: emName,
      emergencyContactPhone: emPhone,
      riderTag: riderTag,
      ridingStyle: ridingStyle,
      avatarIndex: avatarIndex,
      ghostMode: ghostMode,
      sharePhone: sharePhone,
      shareEmergency: shareEmergency,
      isPremium: isPremium,
      isTagCustomized: isTagCustomized,
      cardThemeIndex: themeIndex,
      selectedFrameIndex: selectedFrameIndex,
      purchasedThemes: purchasedSet,
      city: city,
      instagram: instagram,
      tiktok: tiktok,
      youtube: youtube,
      licensePlate: licensePlate,
      selectedBadges: selectedBadges,
      unlockedBadges: unlockedBadges,
      isFoundingMember: isFoundingMember,
      supporterTier: supporterTier,
      unlockedSupporterTiers: unlockedSupporterTiers,
      riderXp: riderXp,
    );

    // Sync state back to Firebase asynchronously as a background operation if Firebase is initialized
    if (Firebase.apps.isNotEmpty) {
      unawaited(_syncProfileToFirestore());
    }
  }

  Future<void> addXp(int xpAmount) async {
    if (xpAmount <= 0) return;
    final newXp = state.riderXp + xpAmount;
    state = state.copyWith(riderXp: newXp);
    await ApexKvStore.setString(_riderXpKey, newXp.toString());
    _syncProfileToFirestore();
  }

  Future<void> updatePremiumStatus(bool isPremium) async {
    state = state.copyWith(isPremium: isPremium);
    await ApexKvStore.setBool(_isPremiumKey, isPremium);

    // Sync to Firestore
    if (Firebase.apps.isNotEmpty) {
      unawaited(_syncProfileToFirestore());
    }
  }

  Future<void> updateSupporterTier(int tier) async {
    final updatedUnlockedTiers = Set<int>.from(state.unlockedSupporterTiers)
      ..add(tier);
    state = state.copyWith(
      supporterTier: tier,
      unlockedSupporterTiers: updatedUnlockedTiers,
    );
    await ApexKvStore.setString(_supporterTierKey, tier.toString());
    await ApexKvStore.setString(
      _unlockedSupporterTiersKey,
      jsonEncode(updatedUnlockedTiers.toList()),
    );

    // Sync to Firestore
    if (Firebase.apps.isNotEmpty) {
      unawaited(_syncProfileToFirestore());
    }
  }

  Future<bool> loginUser(String tag, String password) async {
    final profileData = await FirebaseService.instance.loginWithTag(
      tag,
      password,
    );
    if (profileData == null) return false;

    // Successfully authenticated! Restore the profile state.
    final name = profileData['name'] as String? ?? '';
    final restoredTag = profileData['riderTag'] as String? ?? tag;
    final isPremium = profileData['isPremium'] as bool? ?? false;
    final phone = profileData['phoneNumber'] as String? ?? '';
    final blood = profileData['bloodType'] as String? ?? '';
    final emName = profileData['emergencyContactName'] as String? ?? '';
    final emPhone = profileData['emergencyContactPhone'] as String? ?? '';

    final city = profileData['city'] as String? ?? '';
    final instagram = profileData['instagram'] as String? ?? '';
    final tiktok = profileData['tiktok'] as String? ?? '';
    final youtube = profileData['youtube'] as String? ?? '';
    final licensePlate = profileData['licensePlate'] as String? ?? '';

    state = UserProfile(
      name: name,
      riderTag: restoredTag,
      isPremium: isPremium,
      phoneNumber: phone,
      bloodType: blood,
      emergencyContactName: emName,
      emergencyContactPhone: emPhone,
      city: city,
      instagram: instagram,
      tiktok: tiktok,
      youtube: youtube,
      licensePlate: licensePlate,
    );

    // Save to local key-value store
    await ApexKvStore.setString(_nameKey, name);
    await ApexKvStore.setString(_phoneKey, phone);
    await ApexKvStore.setString(_bloodTypeKey, blood);
    await ApexKvStore.setString(_emergencyNameKey, emName);
    await ApexKvStore.setString(_emergencyPhoneKey, emPhone);
    await ApexKvStore.setString(_riderTagKey, restoredTag);
    await ApexKvStore.setBool(_isPremiumKey, isPremium);

    await ApexKvStore.setString(_cityKey, city);
    await ApexKvStore.setString(_instagramKey, instagram);
    await ApexKvStore.setString(_tiktokKey, tiktok);
    await ApexKvStore.setString(_youtubeKey, youtube);
    await ApexKvStore.setString(_licensePlateKey, licensePlate);

    // Check if there are active motorcycle details inside the retrieved profile
    _restoreActiveBike(profileData);

    return true;
  }

  Future<bool> loginUserWithEmail(String email, String password) async {
    final profileData = await FirebaseService.instance.loginWithEmail(
      email,
      password,
    );
    if (profileData == null) return false;

    // Successfully authenticated! Restore the profile state.
    final name = profileData['name'] as String? ?? '';
    final restoredTag = profileData['riderTag'] as String? ?? '';
    final isPremium = profileData['isPremium'] as bool? ?? false;
    final phone = profileData['phoneNumber'] as String? ?? '';
    final blood = profileData['bloodType'] as String? ?? '';
    final emName = profileData['emergencyContactName'] as String? ?? '';
    final emPhone = profileData['emergencyContactPhone'] as String? ?? '';
    final isTagCustomized =
        profileData['isTagCustomized'] as bool? ??
        (restoredTag.isNotEmpty && !restoredTag.startsWith('@rider#'));

    final city = profileData['city'] as String? ?? '';
    final instagram = profileData['instagram'] as String? ?? '';
    final tiktok = profileData['tiktok'] as String? ?? '';
    final youtube = profileData['youtube'] as String? ?? '';
    final licensePlate = profileData['licensePlate'] as String? ?? '';

    final avatarIndex = profileData['avatarIndex'] as int? ?? 0;
    final cardThemeIndex = profileData['cardThemeIndex'] as int? ?? 0;
    final ridingStyle = profileData['ridingStyle'] as String? ?? 'Focused';
    final isFoundingMember = profileData['isFoundingMember'] as bool? ?? false;
    final supporterTier = profileData['supporterTier'] as int? ?? 0;

    List<String> selectedBadges = [];
    if (profileData['selectedBadges'] != null) {
      selectedBadges = List<String>.from(profileData['selectedBadges']);
    }
    List<String> unlockedBadges = [];
    if (profileData['unlockedBadges'] != null) {
      unlockedBadges = List<String>.from(profileData['unlockedBadges']);
    }

    Set<int> unlockedSupporterTiers = supporterTier > 0 ? {supporterTier} : {};
    if (profileData['unlockedSupporterTiers'] != null) {
      unlockedSupporterTiers = List<int>.from(
        profileData['unlockedSupporterTiers'],
      ).toSet();
    }

    final String activeTag = (restoredTag.isNotEmpty)
        ? restoredTag
        : ((state.riderTag.isNotEmpty && !state.riderTag.startsWith('@rider#'))
              ? state.riderTag
              : restoredTag);

    state = UserProfile(
      name: name,
      riderTag: activeTag,
      isPremium: isPremium,
      phoneNumber: phone,
      bloodType: blood,
      emergencyContactName: emName,
      emergencyContactPhone: emPhone,
      isTagCustomized: isTagCustomized,
      city: city,
      instagram: instagram,
      tiktok: tiktok,
      youtube: youtube,
      licensePlate: licensePlate,
      avatarIndex: avatarIndex,
      cardThemeIndex: cardThemeIndex,
      ridingStyle: ridingStyle,
      isFoundingMember: isFoundingMember,
      supporterTier: supporterTier,
      selectedBadges: selectedBadges,
      unlockedBadges: unlockedBadges,
      unlockedSupporterTiers: unlockedSupporterTiers,
    );

    // Save to local key-value store
    await ApexKvStore.setString(_nameKey, name);
    await ApexKvStore.setString(_phoneKey, phone);
    await ApexKvStore.setString(_bloodTypeKey, blood);
    await ApexKvStore.setString(_emergencyNameKey, emName);
    await ApexKvStore.setString(_emergencyPhoneKey, emPhone);
    await ApexKvStore.setString(_riderTagKey, activeTag);
    await ApexKvStore.setBool(_isPremiumKey, isPremium);
    await ApexKvStore.setBool(_isTagCustomizedKey, isTagCustomized);

    await ApexKvStore.setString(_cityKey, city);
    await ApexKvStore.setString(_instagramKey, instagram);
    await ApexKvStore.setString(_tiktokKey, tiktok);
    await ApexKvStore.setString(_youtubeKey, youtube);
    await ApexKvStore.setString(_licensePlateKey, licensePlate);

    await ApexKvStore.setString(_avatarIndexKey, avatarIndex.toString());
    await ApexKvStore.setString(_cardThemeIndexKey, cardThemeIndex.toString());
    await ApexKvStore.setString(_ridingStyleKey, ridingStyle);
    await ApexKvStore.setBool(_isFoundingMemberKey, isFoundingMember);
    await ApexKvStore.setString(_selectedBadgesKey, jsonEncode(selectedBadges));
    await ApexKvStore.setString(_unlockedBadgesKey, jsonEncode(unlockedBadges));
    await ApexKvStore.setString(
      _unlockedSupporterTiersKey,
      jsonEncode(unlockedSupporterTiers.toList()),
    );

    // Check if there are active motorcycle details inside the retrieved profile
    _restoreActiveBike(profileData);

    // Ensure profile is immediately synced to Firestore
    if (Firebase.apps.isNotEmpty) {
      unawaited(_syncProfileToFirestore());
    }

    return true;
  }

  Future<bool> loginUserWithGoogle() async {
    final user = await FirebaseService.instance.signInWithGoogle();
    if (user == null) return false;

    // Check if user has an existing profile in Firestore
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (doc.exists) {
      final profileData = doc.data();
      if (profileData != null) {
        final name = profileData['name'] as String? ?? user.displayName ?? '';
        final tag = profileData['riderTag'] as String? ?? '';
        final isPremium = profileData['isPremium'] as bool? ?? false;
        final phone = profileData['phoneNumber'] as String? ?? '';
        final blood = profileData['bloodType'] as String? ?? '';
        final emName = profileData['emergencyContactName'] as String? ?? '';
        final emPhone = profileData['emergencyContactPhone'] as String? ?? '';

        final city = profileData['city'] as String? ?? '';
        final instagram = profileData['instagram'] as String? ?? '';
        final tiktok = profileData['tiktok'] as String? ?? '';
        final youtube = profileData['youtube'] as String? ?? '';
        final licensePlate = profileData['licensePlate'] as String? ?? '';

        final cardThemeIndex = profileData['cardThemeIndex'] as int? ?? 0;
        final ridingStyle = profileData['ridingStyle'] as String? ?? 'Focused';
        final isFoundingMember =
            profileData['isFoundingMember'] as bool? ?? false;
        final supporterTier = profileData['supporterTier'] as int? ?? 0;
        final avatarIndex = profileData['avatarIndex'] as int? ?? 0;

        List<String> selectedBadges = [];
        if (profileData['selectedBadges'] != null) {
          selectedBadges = List<String>.from(profileData['selectedBadges']);
        }
        List<String> unlockedBadges = [];
        if (profileData['unlockedBadges'] != null) {
          unlockedBadges = List<String>.from(profileData['unlockedBadges']);
        }

        Set<int> unlockedSupporterTiers = supporterTier > 0
            ? {supporterTier}
            : {};
        if (profileData['unlockedSupporterTiers'] != null) {
          unlockedSupporterTiers = List<int>.from(
            profileData['unlockedSupporterTiers'],
          ).toSet();
        }

        state = UserProfile(
          name: name,
          riderTag: tag,
          isPremium: isPremium,
          phoneNumber: phone,
          bloodType: blood,
          emergencyContactName: emName,
          emergencyContactPhone: emPhone,
          city: city,
          instagram: instagram,
          tiktok: tiktok,
          youtube: youtube,
          licensePlate: licensePlate,
          avatarIndex: avatarIndex,
          cardThemeIndex: cardThemeIndex,
          ridingStyle: ridingStyle,
          isFoundingMember: isFoundingMember,
          selectedBadges: selectedBadges,
          unlockedBadges: unlockedBadges,
          supporterTier: supporterTier,
          unlockedSupporterTiers: unlockedSupporterTiers,
        );

        await ApexKvStore.setString(_nameKey, name);
        await ApexKvStore.setString(_phoneKey, phone);
        await ApexKvStore.setString(_bloodTypeKey, blood);
        await ApexKvStore.setString(_emergencyNameKey, emName);
        await ApexKvStore.setString(_emergencyPhoneKey, emPhone);
        await ApexKvStore.setString(_riderTagKey, tag);
        await ApexKvStore.setBool(_isPremiumKey, isPremium);

        await ApexKvStore.setString(_cityKey, city);
        await ApexKvStore.setString(_instagramKey, instagram);
        await ApexKvStore.setString(_tiktokKey, tiktok);
        await ApexKvStore.setString(_youtubeKey, youtube);
        await ApexKvStore.setString(_licensePlateKey, licensePlate);

        await ApexKvStore.setString(_avatarIndexKey, avatarIndex.toString());
        await ApexKvStore.setString(
          _cardThemeIndexKey,
          cardThemeIndex.toString(),
        );
        await ApexKvStore.setString(_ridingStyleKey, ridingStyle);
        await ApexKvStore.setBool(_isFoundingMemberKey, isFoundingMember);
        await ApexKvStore.setString(
          _supporterTierKey,
          supporterTier.toString(),
        );
        await ApexKvStore.setString(
          _selectedBadgesKey,
          jsonEncode(selectedBadges),
        );
        await ApexKvStore.setString(
          _unlockedBadgesKey,
          jsonEncode(unlockedBadges),
        );
        await ApexKvStore.setString(
          _unlockedSupporterTiersKey,
          jsonEncode(unlockedSupporterTiers.toList()),
        );

        // Restore motorcycle if present
        _restoreActiveBike(profileData);
        return true;
      }
    }

    // User does not have a profile, initialize basic one
    final cleanEmail = user.email ?? '';
    final baseName = user.displayName ?? 'Google Rider';
    final randomNum = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000))
        .toString();
    final generatedTag = '@google_randomNum}';

    state = UserProfile(
      name: baseName,
      riderTag: generatedTag,
      isPremium: false,
    );

    await ApexKvStore.setString(_nameKey, baseName);
    await ApexKvStore.setString(_riderTagKey, generatedTag);

    // Sync to Firestore
    unawaited(
      FirebaseService.instance.syncUserProfile(
        name: baseName,
        tag: generatedTag,
        isPremium: false,
        phone: '',
        bloodType: '',
        emergencyName: '',
        emergencyPhone: '',
        email: cleanEmail,
      ),
    );

    return true;
  }

  Future<bool> updateProfile({
    required String name,
    required String phoneNumber,
    required String bloodType,
    required String emergencyContactName,
    required String emergencyContactPhone,
    String? riderTag,
    String? ridingStyle,
    int? avatarIndex,
    bool? ghostMode,
    bool? sharePhone,
    bool? shareEmergency,
    bool? isPremium,
    String? email,
    String? city,
    String? instagram,
    String? tiktok,
    String? youtube,
    String? licensePlate,
    List<String>? selectedBadges,
    List<String>? unlockedBadges,
    bool? isFoundingMember,
    int? selectedFrameIndex,
  }) async {
    final oldTag = state.riderTag;
    var updatedTag = state.riderTag;
    var newlyCustomized = false;

    if (riderTag != null && riderTag.trim().isNotEmpty) {
      var rawInput = riderTag.trim();
      final cleanLowerInput = rawInput.toLowerCase();
      final isSecretDevPin =
          cleanLowerInput == '@apex_dev#1881' ||
          cleanLowerInput == 'apex_dev#1881';

      if (isSecretDevPin) {
        updatedTag = '@apex_dev#1881';
        newlyCustomized = true;
      } else if (!state.isTagCustomized || rawInput != state.riderTag) {
        // Format the tag according to rules
        var rawTag = rawInput.replaceAll(RegExp(r'\s+'), '');

        // Strip existing '@' prefix and '#' suffix if present to compute the clean tag name
        if (rawTag.startsWith('@')) {
          rawTag = rawTag.substring(1);
        }
        if (rawTag.contains('#')) {
          rawTag = rawTag.split('#')[0];
        }

        // Default to 'rider' if empty
        if (rawTag.isEmpty) {
          rawTag = 'rider';
        }

        final cleanLower = rawTag.toLowerCase();

        // Strictly ban any attempt to type plain 'apex_dev' tag without #1881 PIN
        if (cleanLower.contains('apex_dev')) {
          rawTag = 'rider';
        }

        // Limit length to maximum of 10 characters (excluding @ and #xxxx)
        if (rawTag.length > 10) {
          rawTag = rawTag.substring(0, 10);
        }

        // Append random 4-digit numeric suffix
        final randomNum =
            (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();
        updatedTag = '@$rawTag#$randomNum';

        if (updatedTag != oldTag) {
          // Tag is changing, checking uniqueness
          final instId = await FirebaseService.instance
              .getOrCreateInstallationId();
          final available = await FirebaseService.instance.isTagAvailable(
            updatedTag,
            instId,
          );
          if (!available) {
            return false; // Abort: Tag already claimed by another installation ID
          }
          newlyCustomized = true;
        }
      }
    }

    final isDevTag = updatedTag == '@apex_dev#1881';
    final isCustomized = state.isTagCustomized || newlyCustomized;

    state = UserProfile(
      name: name.trim(),
      phoneNumber: phoneNumber.trim(),
      bloodType: bloodType.trim(),
      emergencyContactName: emergencyContactName.trim(),
      emergencyContactPhone: emergencyContactPhone.trim(),
      riderTag: updatedTag,
      ridingStyle: ridingStyle ?? state.ridingStyle,
      avatarIndex: avatarIndex ?? state.avatarIndex,
      ghostMode: ghostMode ?? state.ghostMode,
      sharePhone: sharePhone ?? state.sharePhone,
      shareEmergency: shareEmergency ?? state.shareEmergency,
      isPremium: isDevTag ? true : (isPremium ?? state.isPremium),
      isTagCustomized: isCustomized,
      cardThemeIndex: state.cardThemeIndex,
      selectedFrameIndex: selectedFrameIndex ?? state.selectedFrameIndex,
      purchasedThemes: state.purchasedThemes,
      city: city ?? state.city,
      instagram: instagram ?? state.instagram,
      tiktok: tiktok ?? state.tiktok,
      youtube: youtube ?? state.youtube,
      licensePlate: licensePlate ?? state.licensePlate,
      selectedBadges: selectedBadges ?? state.selectedBadges,
      unlockedBadges: unlockedBadges ?? state.unlockedBadges,
      isFoundingMember: isFoundingMember ?? state.isFoundingMember,
      supporterTier: state.supporterTier,
      unlockedSupporterTiers: state.unlockedSupporterTiers,
    );

    // Save to key-value store
    await ApexKvStore.setString(_nameKey, state.name);
    await ApexKvStore.setString(_phoneKey, state.phoneNumber);
    await ApexKvStore.setString(_bloodTypeKey, state.bloodType);
    await ApexKvStore.setString(_emergencyNameKey, state.emergencyContactName);
    await ApexKvStore.setString(
      _emergencyPhoneKey,
      state.emergencyContactPhone,
    );
    await ApexKvStore.setString(_riderTagKey, state.riderTag);
    await ApexKvStore.setString(_ridingStyleKey, state.ridingStyle);
    await ApexKvStore.setString(_avatarIndexKey, state.avatarIndex.toString());
    await ApexKvStore.setBool(_ghostModeKey, state.ghostMode);
    await ApexKvStore.setBool(_sharePhoneKey, state.sharePhone);
    await ApexKvStore.setBool(_shareEmergencyKey, state.shareEmergency);
    await ApexKvStore.setBool(_isPremiumKey, state.isPremium);
    await ApexKvStore.setBool(_isTagCustomizedKey, state.isTagCustomized);
    await ApexKvStore.setString(_cityKey, state.city);
    await ApexKvStore.setString(_instagramKey, state.instagram);
    await ApexKvStore.setString(_tiktokKey, state.tiktok);
    await ApexKvStore.setString(_youtubeKey, state.youtube);
    await ApexKvStore.setString(_licensePlateKey, state.licensePlate);
    await ApexKvStore.setString(
      _selectedBadgesKey,
      jsonEncode(state.selectedBadges),
    );
    await ApexKvStore.setString(
      _unlockedBadgesKey,
      jsonEncode(state.unlockedBadges),
    );
    await ApexKvStore.setBool(_isFoundingMemberKey, state.isFoundingMember);
    await ApexKvStore.setString(
      _selectedFrameIndexKey,
      state.selectedFrameIndex.toString(),
    );
    await ApexKvStore.setString(
      _supporterTierKey,
      state.supporterTier.toString(),
    );
    await ApexKvStore.setString(
      _unlockedSupporterTiersKey,
      jsonEncode(state.unlockedSupporterTiers.toList()),
    );

    // Sync to Firestore database
    await _syncProfileToFirestore(oldTag: oldTag, email: email);

    // Sync with home_widget for Android home screen widget display
    try {
      if (!kIsWeb && !Platform.environment.containsKey('FLUTTER_TEST')) {
        await HomeWidget.saveWidgetData<String>('blood_type', state.bloodType);
        await HomeWidget.saveWidgetData<String>(
          'emergency_name',
          state.emergencyContactName,
        );
        await HomeWidget.saveWidgetData<String>(
          'emergency_phone',
          state.emergencyContactPhone,
        );
        await HomeWidget.updateWidget(
          name: 'EmergencyWidgetProvider',
          androidName: 'EmergencyWidgetProvider',
        );
      }
    } catch (_) {
      // Fail-safe for desktop testing or non-supported platforms
    }

    return true;
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}

    // Clear all profile data in KV store
    await ApexKvStore.remove(_nameKey);
    await ApexKvStore.remove(_phoneKey);
    await ApexKvStore.remove(_bloodTypeKey);
    await ApexKvStore.remove(_emergencyNameKey);
    await ApexKvStore.remove(_emergencyPhoneKey);
    await ApexKvStore.remove(_riderTagKey);
    await ApexKvStore.remove(_ridingStyleKey);
    await ApexKvStore.remove(_avatarIndexKey);
    await ApexKvStore.remove(_ghostModeKey);
    await ApexKvStore.remove(_sharePhoneKey);
    await ApexKvStore.remove(_shareEmergencyKey);
    await ApexKvStore.remove(_isPremiumKey);
    await ApexKvStore.remove(_isTagCustomizedKey);
    await ApexKvStore.remove(_selectedFrameIndexKey);
    await ApexKvStore.remove(_cityKey);
    await ApexKvStore.remove(_instagramKey);
    await ApexKvStore.remove(_tiktokKey);
    await ApexKvStore.remove(_licensePlateKey);
    await ApexKvStore.remove(_selectedBadgesKey);
    await ApexKvStore.remove(_unlockedBadgesKey);
    await ApexKvStore.remove(_isFoundingMemberKey);
    await ApexKvStore.remove(_cardThemeIndexKey);
    await ApexKvStore.remove(_purchasedThemesKey);

    // Reset local state
    state = const UserProfile();

    // Clear ride-related KV keys
    await ApexKvStore.remove('rides.is_active');
    await ApexKvStore.remove('rides.active_mood');
    await ApexKvStore.remove('rides.started_at_iso');

    // Invalidate data providers to reset in-memory state
    ref.invalidate(rideStateProvider);
    ref.invalidate(garageStateProvider);
    ref.invalidate(fuelStateProvider);
    ref.invalidate(documentVaultProvider);
    ref.invalidate(insightsStateProvider);

    // Reset onboarding flag
    ref.read(appSettingsProvider.notifier).resetOnboarding();
  }

  Future<void> deleteAccount() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final riderTag = state.riderTag;

    if (uid != null) {
      await FirebaseService.instance.deleteUserAccount(uid, riderTag);
    }

    await logout();
  }

  double _calculateWeeklyKm(List<RideSession> sessions) {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    double sum = 0.0;
    for (final s in sessions) {
      try {
        final date = DateTime.parse(s.loggedAtIso);
        if (date.isAfter(sevenDaysAgo)) {
          sum += s.distanceKm;
        }
      } catch (_) {}
    }
    return sum;
  }

  void checkAndUnlockAchievements() {
    final rides = ref.read(rideStateProvider);
    final totalDistance = rides.sessions.fold<double>(
      0,
      (acc, s) => acc + s.distanceKm,
    );
    final hasRides = rides.sessions.isNotEmpty;

    final newUnlocked = List<String>.from(state.unlockedBadges);
    bool changed = false;

    void unlock(String id, String nameTr, String nameEn) {
      if (!newUnlocked.contains(id)) {
        newUnlocked.add(id);
        changed = true;

        final strings = AppStrings(ref.read(appSettingsProvider).locale);
        final localizedName = strings.languageCode == 'tr'
            ? nameTr
            : nameEn; // we don't have German names for achievements locally yet, defaulting to En

        unawaited(
          ApexNotificationService.instance.showNotification(
            id: id.hashCode,
            title: strings.notifAchievementTitle,
            body: strings.notifAchievementBody(localizedName),
          ),
        );
      }
    }

    unlock('founding_member', 'Kurucu Üye', 'Founding Member');

    if (hasRides) {
      unlock('first_ride', 'İlk Marş', 'First Ride');
    }

    if (totalDistance >= 100) {
      unlock('mileage_100', 'Yol Arkadaşı', '100 Km Mileage');
    }

    final hasAggressive = rides.sessions.any(
      (s) =>
          s.mood.toLowerCase().contains('aggressive') ||
          s.mood.toLowerCase().contains('saldırgan') ||
          s.mood.toLowerCase().contains('hızlı') ||
          s.mood.toLowerCase().contains('fast'),
    );
    if (hasAggressive) {
      unlock('speed_demon', 'Viraj Avcısı', 'Speed Demon');
    }

    final hasNight = rides.sessions.any((s) {
      try {
        final date = DateTime.parse(s.loggedAtIso).toLocal();
        return date.hour >= 20 || date.hour < 5;
      } catch (_) {
        return false;
      }
    });
    if (hasNight) {
      unlock('night_rider', 'Gece Savaşçısı', 'Night Rider');
    }

    if (changed) {
      state = state.copyWith(unlockedBadges: newUnlocked);
      unawaited(
        ApexKvStore.setString(_unlockedBadgesKey, jsonEncode(newUnlocked)),
      );
      unawaited(_syncProfileToFirestore());
    }
  }

  Future<void> _syncProfileToFirestore({String? oldTag, String? email}) async {
    if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) return;
    await FirebaseService.instance.init();
    if (Firebase.apps.isEmpty) return;

    final garage = ref.read(garageStateProvider);
    final rides = ref.read(rideStateProvider);
    final bike = garage.activeBike;

    final isBikeEmpty = bike.id == 'empty' || bike.name == '—';

    final weeklyKm = _calculateWeeklyKm(rides.sessions);
    final harmonyScore = isBikeEmpty
        ? 95
        : const HarmonyEngine().evaluate(bike, rides.latestRide).score;

    final cleanEmail = email ?? FirebaseAuth.instance.currentUser?.email;

    String? fcmToken;
    try {
      // Request permission on iOS (no-op on Android)
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      fcmToken = await FirebaseMessaging.instance.getToken();
    } catch (_) {
      // Ignore FCM errors if not configured yet
    }

    unawaited(
      FirebaseService.instance.syncUserProfile(
        name: state.name,
        tag: state.riderTag,
        isPremium: state.isPremium,
        phone: state.phoneNumber,
        bloodType: state.bloodType,
        emergencyName: state.emergencyContactName,
        emergencyPhone: state.emergencyContactPhone,
        email: cleanEmail,
        oldTag: oldTag,
        fcmToken: fcmToken,
        activeBikeName: isBikeEmpty ? null : bike.name,
        activeBikeModel: isBikeEmpty ? null : bike.model,
        activeBikeOdometer: isBikeEmpty ? null : bike.odometerKm,
        activeBikeLastService: isBikeEmpty ? null : bike.lastServiceKm,
        activeBikeServiceInterval: isBikeEmpty ? null : bike.serviceIntervalKm,
        chainWearPercent: isBikeEmpty ? null : bike.chainWearPercent,
        tireWearPercent: isBikeEmpty ? null : bike.tireWearPercent,
        brakeWearPercent: isBikeEmpty ? null : bike.brakeWearPercent,
        oilHealthPercent: isBikeEmpty ? null : bike.oilHealthPercent,
        batteryHealthPercent: isBikeEmpty ? null : bike.batteryHealthPercent,
        weeklyKm: weeklyKm,
        harmonyScore: harmonyScore,
        ridingStyle: state.ridingStyle,
        avatarIndex: state.avatarIndex,
        cardThemeIndex: state.cardThemeIndex,
        city: state.city,
        instagram: state.instagram,
        tiktok: state.tiktok,
        youtube: state.youtube,
        licensePlate: state.licensePlate,
        selectedBadges: state.selectedBadges,
        unlockedBadges: state.unlockedBadges,
        isFoundingMember: state.isFoundingMember,
        supporterTier: state.supporterTier,
        unlockedSupporterTiers: state.unlockedSupporterTiers.toList(),
      ),
    );
  }

  void _restoreActiveBike(Map<String, dynamic> profileData) {
    final activeBikeName = profileData['activeBikeName'] as String?;
    if (activeBikeName != null &&
        activeBikeName.isNotEmpty &&
        activeBikeName != '—') {
      final activeBikeModel = profileData['activeBikeModel'] as String? ?? '';
      final activeBikeOdometer = profileData['activeBikeOdometer'] as int? ?? 0;
      final activeBikeLastService =
          profileData['activeBikeLastService'] as int? ?? 0;
      final activeBikeServiceInterval =
          profileData['activeBikeServiceInterval'] as int? ?? 6000;
      final chainWearPercent = profileData['chainWearPercent'] as int?;
      final tireWearPercent = profileData['tireWearPercent'] as int?;
      final brakeWearPercent = profileData['brakeWearPercent'] as int?;
      final oilHealthPercent = profileData['oilHealthPercent'] as int?;
      final batteryHealthPercent = profileData['batteryHealthPercent'] as int?;

      final garageController = ref.read(garageStateProvider.notifier);
      final exists = ref
          .read(garageStateProvider)
          .motorcycles
          .any(
            (m) =>
                m.name.toLowerCase() == activeBikeName.toLowerCase() &&
                m.model.toLowerCase() == activeBikeModel.toLowerCase(),
          );

      if (!exists) {
        garageController.addMotorcycle(
          name: activeBikeName,
          model: activeBikeModel,
          odometerKm: activeBikeOdometer,
          lastServiceKm: activeBikeLastService,
          serviceIntervalKm: activeBikeServiceInterval,
          chainWearPercent: chainWearPercent,
          tireWearPercent: tireWearPercent,
          brakeWearPercent: brakeWearPercent,
          oilHealthPercent: oilHealthPercent,
          batteryHealthPercent: batteryHealthPercent,
        );
      } else {
        final existingBike = ref
            .read(garageStateProvider)
            .motorcycles
            .firstWhere(
              (m) =>
                  m.name.toLowerCase() == activeBikeName.toLowerCase() &&
                  m.model.toLowerCase() == activeBikeModel.toLowerCase(),
            );
        garageController.setActiveMotorcycle(existingBike);
      }
    }
  }

  Future<void> selectTheme(int index) async {
    state = state.copyWith(cardThemeIndex: index);
    await ApexKvStore.setString(_cardThemeIndexKey, index.toString());
  }

  Future<void> purchaseTheme(int index) async {
    final nextPurchased = {...state.purchasedThemes, index};
    state = state.copyWith(purchasedThemes: nextPurchased);
    await ApexKvStore.setString(
      _purchasedThemesKey,
      jsonEncode(nextPurchased.toList()),
    );
  }
}
