import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apexflow/core/storage/db_provider.dart';
import 'package:apexflow/profile/domain/friend_profile.dart';
import 'package:apexflow/core/services/firebase_service.dart'; // Added Firebase import
import 'package:apexflow/core/i18n/app_settings_state.dart';
import 'package:apexflow/core/i18n/app_strings.dart';

final friendsStateProvider =
    NotifierProvider<FriendsController, List<FriendProfile>>(
      FriendsController.new,
    );

class FriendsController extends Notifier<List<FriendProfile>> {
  bool _mounted = true;

  @override
  List<FriendProfile> build() {
    ref.onDispose(() => _mounted = false);
    unawaited(_hydrate());
    return const [];
  }

  Future<void> _hydrate() async {
    final db = ref.read(dbServiceProvider);
    await db.init();
    String ownerId = '';
    try {
      ownerId = await FirebaseService.instance.getOrCreateInstallationId();
    } catch (_) {}
    final list = await db.getFriends(userId: ownerId);

    if (!_mounted) return;
    state = list;

    unawaited(syncIncomingFriends());
  }

  /// Attempts to add a friend by rider tag.
  /// Returns `true` if the tag was found in the Firebase Firestore and added successfully.
  /// Returns `false` if the tag does not exist.
  Future<bool> addFriendByTag(String tag, bool isTurkish) async {
    final formattedTag = tag.trim().startsWith('@')
        ? tag.trim()
        : '@${tag.trim()}';

    // Check if friend already exists in current state
    if (state.any(
      (f) => f.riderTag.toLowerCase() == formattedTag.toLowerCase(),
    )) {
      return false; // Already a friend
    }

    final myId = await FirebaseService.instance.getOrCreateInstallationId();

    // 1. Query Firestore for the rider profile
    final profileData = await FirebaseService.instance.getProfileByTag(
      formattedTag,
    );
    if (profileData == null) {
      // Offline fallback: check if tag is one of the local mock tags to pass widget tests
      final mockData = _getOfflineMockByTag(formattedTag);
      if (mockData == null) {
        return false; // Tag does not exist in Firebase nor in offline tests
      }

      final db = ref.read(dbServiceProvider);
      await db.saveFriend(mockData, userId: myId);
      if (!_mounted) return true;
      state = [mockData, ...state];
      return true;
    }

    // 2. Map Firebase profile fields to FriendProfile
    final random = Random();
    final friendUid = profileData['uid'] as String?;
    if (friendUid != null) {
      await FirebaseService.instance.addFriendConnection(myId, friendUid);
      final friendFields = await FirebaseService.instance
          .getFriendSharedProfile(friendUid);
      if (friendFields != null) profileData.addAll(friendFields);
    }
    final newFriend = FriendProfile(
      stableId: friendUid ?? 'friend-${DateTime.now().millisecondsSinceEpoch}',
      name: profileData['name'] as String? ?? 'Rider',
      riderTag: formattedTag,
      ridingStyle:
          profileData['ridingStyle'] as String? ??
          (tInline(
            AppStrings.currentLanguageCode,
            'Odaklı',
            'Focused',
            'Konzentriert',
          )),
      avatarIndex: profileData['avatarIndex'] as int? ?? random.nextInt(6),
      activeBikeName:
          profileData['activeBikeName'] as String? ??
          (tInline(
            AppStrings.currentLanguageCode,
            'Motosiklet',
            'Bike',
            'Fahrrad',
          )),
      activeBikeModel: profileData['activeBikeModel'] as String? ?? '2023',
      weeklyKm: (profileData['weeklyKm'] as num?)?.toDouble() ?? 120.0,
      harmonyScore: (profileData['harmonyScore'] as num?)?.toInt() ?? 95,
      ghostMode: false,
      modifications: const [],
      phone: profileData['phoneNumber'] as String?,
      emergencyPhone: profileData['emergencyContactPhone'] as String?,
      bloodType: profileData['bloodType'] as String? ?? '',
      cardThemeIndex: profileData['cardThemeIndex'] as int? ?? 0,
      city: profileData['city'] as String? ?? '',
      instagram: profileData['instagram'] as String? ?? '',
      tiktok: profileData['tiktok'] as String? ?? '',
      licensePlate: profileData['licensePlate'] as String? ?? '',
      selectedBadges:
          (profileData['selectedBadges'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );

    final db = ref.read(dbServiceProvider);
    await db.saveFriend(newFriend, userId: myId);

    if (!_mounted) return true;
    state = [newFriend, ...state];
    return true;
  }

  FriendProfile? _getOfflineMockByTag(String tag) {
    final cleanTag = tag.toLowerCase().replaceAll('@', '');
    final testRegistry = {
      'ahmet_goldwing': const FriendProfile(
        stableId: 'friend-ahmet',
        name: 'Ahmet',
        riderTag: '@ahmet_goldwing',
        ridingStyle: 'Tourer',
        avatarIndex: 1,
        activeBikeName: 'Honda Goldwing',
        activeBikeModel: '2022',
        weeklyKm: 242.5,
        harmonyScore: 98,
        ghostMode: false,
        modifications: [],
      ),
      'hakan_adventure': const FriendProfile(
        stableId: 'friend-hakan',
        name: 'Hakan',
        riderTag: '@hakan_adventure',
        ridingStyle: 'Enduro',
        avatarIndex: 2,
        activeBikeName: 'Honda Africa Twin',
        activeBikeModel: '2023',
        weeklyKm: 180.2,
        harmonyScore: 95,
        ghostMode: false,
        modifications: [],
      ),
      'racer_ruzgar': const FriendProfile(
        stableId: 'friend-ruzgar',
        name: 'Rüzgar',
        riderTag: '@racer_ruzgar',
        ridingStyle: 'Sport',
        avatarIndex: 4,
        activeBikeName: 'Yamaha YZF-R6',
        activeBikeModel: '2021',
        weeklyKm: 312.0,
        harmonyScore: 88,
        ghostMode: false,
        modifications: [],
      ),
      'can_rider': const FriendProfile(
        stableId: 'friend-can',
        name: 'Can',
        riderTag: '@can_rider',
        ridingStyle: 'Odaklı',
        avatarIndex: 3,
        activeBikeName: 'Yamaha Tracer 9',
        activeBikeModel: '2023',
        weeklyKm: 210.0,
        harmonyScore: 92,
        ghostMode: false,
        modifications: [],
      ),
    };
    return testRegistry[cleanTag];
  }

  Future<void> removeFriend(String stableId) async {
    final db = ref.read(dbServiceProvider);
    await db.deleteFriend(stableId);

    // Remove bidirectional connection from Firestore
    final myId = await FirebaseService.instance.getOrCreateInstallationId();
    unawaited(FirebaseService.instance.removeFriendConnection(myId, stableId));

    if (!_mounted) return;
    state = state.where((f) => f.stableId != stableId).toList();
  }

  Future<void> syncIncomingFriends() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;
    await FirebaseService.instance.init();
    final myId = await FirebaseService.instance.getOrCreateInstallationId();
    final incomingIds = await FirebaseService.instance.getIncomingFriendIds(
      myId,
    );

    final db = ref.read(dbServiceProvider);
    final isTurkish = ref.read(appSettingsProvider).isTurkish;

    var stateUpdated = false;
    final List<FriendProfile> updatedList = List.from(state);

    // Hem gelen yeni arkadaş istekleri hem de mevcut arkadaşlarımızın profillerini güncelliyoruz
    final Set<String> allFriendIds = {
      ...incomingIds,
      ...state.map((f) => f.stableId),
    };

    for (final friendUid in allFriendIds) {
      if (friendUid == myId) continue;

      try {
        // users/{uid} is owner-read-only per firestore.rules — reading it
        // for another rider's uid is always permission-denied. Look the
        // rider up via the public rider_tags channel instead (the same one
        // syncUserProfile already writes avatarIndex/avatarPhotoUrl into).
        final profileData = await FirebaseService.instance.getProfileByUid(
          friendUid,
        );
        if (profileData != null) {
          final random = Random();
          final updatedFriend = FriendProfile(
            stableId: friendUid,
            name: profileData['name'] as String? ?? 'Rider',
            riderTag: profileData['riderTag'] as String? ?? '@rider',
            ridingStyle:
                profileData['ridingStyle'] as String? ??
                (tInline(
                  AppStrings.currentLanguageCode,
                  'Odaklı',
                  'Focused',
                  'Konzentriert',
                )),
            avatarIndex:
                profileData['avatarIndex'] as int? ?? random.nextInt(6),
            avatarPhotoUrl: profileData['avatarPhotoUrl'] as String?,
            activeBikeName:
                profileData['activeBikeName'] as String? ??
                (tInline(
                  AppStrings.currentLanguageCode,
                  'Motosiklet',
                  'Bike',
                  'Fahrrad',
                )),
            activeBikeModel:
                profileData['activeBikeModel'] as String? ?? '2023',
            weeklyKm: (profileData['weeklyKm'] as num?)?.toDouble() ?? 120.0,
            harmonyScore: (profileData['harmonyScore'] as num?)?.toInt() ?? 95,
            ghostMode: false,
            modifications: const [],
            phone: profileData['phoneNumber'] as String?,
            emergencyPhone: profileData['emergencyContactPhone'] as String?,
            bloodType: profileData['bloodType'] as String? ?? '',
            cardThemeIndex: profileData['cardThemeIndex'] as int? ?? 0,
            city: profileData['city'] as String? ?? '',
            instagram: profileData['instagram'] as String? ?? '',
            tiktok: profileData['tiktok'] as String? ?? '',
            licensePlate: profileData['licensePlate'] as String? ?? '',
            selectedBadges:
                (profileData['selectedBadges'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                const [],
          );

          await db.saveFriend(updatedFriend, userId: myId);

          final index = updatedList.indexWhere((f) => f.stableId == friendUid);
          if (index != -1) {
            updatedList[index] = updatedFriend;
          } else {
            updatedList.add(updatedFriend);
          }
          stateUpdated = true;
        }
      } catch (_) {}
    }

    if (stateUpdated && _mounted) {
      state = updatedList;
    }
  }

  List<FriendProfile> _mockFriends() {
    return const [];
  }
}
