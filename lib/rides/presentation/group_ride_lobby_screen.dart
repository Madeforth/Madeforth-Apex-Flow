import 'dart:ui' as ui;
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apexflow/core/design/apex_colors.dart';
import 'package:apexflow/core/design/apex_spacing.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apexflow/settings/application/user_profile_state.dart';
import 'package:apexflow/garage/application/garage_state.dart';
import 'package:apexflow/rides/application/ride_location_service.dart';
import 'package:apexflow/rides/application/ride_state.dart';
import 'package:apexflow/profile/application/friends_state.dart';
import 'package:apexflow/profile/domain/friend_profile.dart';
import 'package:apexflow/shared/widgets/apex_panel.dart';
import 'package:apexflow/core/services/firebase_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:apexflow/rides/domain/meeting_point.dart';
import 'package:apexflow/rides/presentation/map_picker_dialog.dart';
import 'package:apexflow/features/dashboard/dashboard_state.dart';
import 'package:apexflow/rides/application/maps_link_parser.dart';
import 'package:apexflow/profile/presentation/profile_hub_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:apexflow/profile/presentation/qr_scanner_screen.dart';
import 'package:apexflow/core/design/theme_extensions.dart';

class GroupRideLobbyScreen extends ConsumerStatefulWidget {
  const GroupRideLobbyScreen({
    super.key,
    required this.strings,
    this.isEmbedded = false,
  });

  final AppStrings strings;
  final bool isEmbedded;

  @override
  ConsumerState<GroupRideLobbyScreen> createState() =>
      _GroupRideLobbyScreenState();
}

class _GroupRideLobbyScreenState extends ConsumerState<GroupRideLobbyScreen> {
  final List<FriendProfile> _joinedRiders = [];
  final RideLocationService _locationService = RideLocationService();
  bool _isSimulating = false;
  MeetingPoint? _meetingPoint;
  bool _isRideActive = false;

  String? _activeLobbyId;
  bool _isHost = true;
  StreamSubscription<DocumentSnapshot>? _lobbySubscription;
  final TextEditingController _lobbyCodeController = TextEditingController();
  bool _isLoadingLobby = false;
  bool _isGroupRidePressed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProfile = ref.read(userProfileProvider);
      final garageState = ref.read(garageStateProvider);
      _initHostLobby(userProfile, garageState);
    });
  }

  @override
  void dispose() {
    _lobbySubscription?.cancel();
    _lobbyCodeController.dispose();
    super.dispose();
  }

  void _initHostLobby(UserProfile userProfile, GarageState garageState) {
    if (userProfile.riderTag.isEmpty) return;
    // Generate a simple, random 5-digit lobby code (e.g. 54921)
    final randomCode = (10000 + Random().nextInt(90000)).toString();
    if (_activeLobbyId == null) {
      setState(() {
        _activeLobbyId = randomCode;
        _isHost = true;
      });
      _createLobbyOnFirestore(userProfile, garageState);
      _subscribeToLobby(randomCode);
    }
  }

  Future<void> _createLobbyOnFirestore(
    UserProfile userProfile,
    GarageState garageState,
  ) async {
    if (_activeLobbyId == null) return;
    await FirebaseService.instance.createOrUpdateLobby(_activeLobbyId!, {
      'hostId': userProfile.riderTag,
      'hostName': userProfile.name.isEmpty ? 'Sürücü' : userProfile.name,
      'hostAvatarIndex': userProfile.avatarIndex,
      'hostSupporterTier': userProfile.supporterTier,
      'status': 'waiting',
      'riders': [],
    });
  }

  void _subscribeToLobby(String lobbyId) {
    _lobbySubscription?.cancel();
    _lobbySubscription = FirebaseService.instance.streamLobby(lobbyId).listen((
      snapshot,
    ) {
      if (!snapshot.exists || !mounted) return;
      final data = snapshot.data() as Map<String, dynamic>?;
      if (data == null) return;

      final status = data['status'] as String? ?? 'waiting';
      final ridersList = data['riders'] as List<dynamic>? ?? [];
      final meetingPointMap = data['meetingPoint'] as Map<dynamic, dynamic>?;

      setState(() {
        if (!_isRideActive && status == 'active') {
          ref
              .read(rideStateProvider.notifier)
              .startRide(
                mood: tInline(
                  AppStrings.currentLanguageCode,
                  'Grup Sürüşü',
                  'Group Ride',
                  'Gruppenfahrt',
                ),
              );
          _locationService.startTracking(
            isTurkish: widget.strings.locale.languageCode == 'tr',
            isMounted: false,
          );
        }

        _isRideActive = status == 'active';

        // Parse riders
        _joinedRiders.clear();
        for (final r in ridersList) {
          if (r is Map<String, dynamic>) {
            _joinedRiders.add(
              FriendProfile(
                stableId: r['stableId'] ?? r['riderTag'] ?? '',
                name: r['name'] ?? '',
                riderTag: r['riderTag'] ?? '',
                ridingStyle: r['ridingStyle'] ?? 'Focused',
                avatarIndex: r['avatarIndex'] ?? 0,
                activeBikeName: r['activeBikeName'] ?? '',
                activeBikeModel: r['activeBikeModel'] ?? '',
                weeklyKm: (r['weeklyKm'] as num?)?.toDouble() ?? 0.0,
                harmonyScore: r['harmonyScore'] ?? 95,
                ghostMode: false,
                modifications: List<String>.from(r['modifications'] ?? []),
                supporterTier: r['supporterTier'] ?? 0,
                cardThemeIndex: r['cardThemeIndex'] ?? 0,
                bloodType: r['bloodType'] ?? '—',
                phone: r['phone'],
                emergencyPhone: r['emergencyPhone'],
                city: r['city'] ?? '',
                instagram: r['instagram'] ?? '',
                tiktok: r['tiktok'] ?? '',
                licensePlate: r['licensePlate'] ?? '',
                selectedBadges: List<String>.from(r['selectedBadges'] ?? []),
              ),
            );
          }
        }

        // Parse meeting point
        if (meetingPointMap != null) {
          _meetingPoint = MeetingPoint(
            name: meetingPointMap['name'] ?? '',
            latitude: (meetingPointMap['latitude'] as num?)?.toDouble() ?? 0.0,
            longitude:
                (meetingPointMap['longitude'] as num?)?.toDouble() ?? 0.0,
          );
        } else {
          _meetingPoint = null;
        }
      });

      // If status is ended, reset participant to host lobby
      if (status == 'ended' && !_isHost && _isRideActive) {
        _endGroupRideWithTelemetry();
        _leaveLobbyAction();
      } else if (status == 'ended' && !_isHost) {
        _leaveLobbyAction();
      }
    });
  }

  void _endGroupRideWithTelemetry() {
    final tr = widget.strings.locale.languageCode == 'tr';
    final de = widget.strings.locale.languageCode == 'de';
    final gpsResult = _locationService.stopTracking(isTurkish: tr);

    final isTest = Platform.environment.containsKey('FLUTTER_TEST');
    final distanceKm = double.parse(gpsResult.distanceKm.toStringAsFixed(2));
    final averageSpeedKmh = double.parse(
      gpsResult.averageSpeedKmh.toStringAsFixed(1),
    );
    int durationMinutes = gpsResult.activeDurationMinutes;
    if (durationMinutes <= 0) durationMinutes = 1;

    final isInvalid = (!gpsResult.hasGpsData || distanceKm < 0.5) && !isTest;

    if (isInvalid) {
      ref.read(rideStateProvider.notifier).cancelRide();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tInline(
                AppStrings.currentLanguageCode,
                'Grup sürüşü çok kısa veya konum alınamadı. Kaydedilmedi.',
                'Group ride too short or no GPS. Not saved.',
                'Gruppenfahrt zu kurz oder kein GPS. Nicht gespeichert.',
              ),
            ),
            backgroundColor: context.colors.caution,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } else {
      String finalMood = tInline(
        AppStrings.currentLanguageCode,
        'Grup Sürüşü',
        'Group Ride',
        'Gruppenfahrt',
      );
      String observation = tInline(
        AppStrings.currentLanguageCode,
        'Grup sürüşü tamamlandı.',
        'Group ride completed.',
        'Gruppenfahrt abgeschlossen.',
      );

      if (gpsResult.telemetry != null) {
        final t = gpsResult.telemetry!;
        finalMood = de
            ? t.inferredMoodEN
            : (tr ? t.inferredMoodTR : t.inferredMoodEN);
        final insight = de ? (t.insightEN) : (tr ? t.insightTR : t.insightEN);
        observation += '\n$insight (Uyum: ${t.smoothnessScore}/100)';
      }

      ref
          .read(rideStateProvider.notifier)
          .endRide(
            distanceKm: distanceKm,
            durationMinutes: durationMinutes,
            averageSpeedKmh: averageSpeedKmh,
            mood: finalMood,
            mechanicalObservation: observation,
            maxSpeedKmh: gpsResult.hasGpsData ? gpsResult.maxSpeedKmh : 0,
            maxLeanAngle: gpsResult.telemetry?.maxLeanAngle ?? 0.0,
            hardAccelerations:
                gpsResult.telemetry?.rapidAccelerationEvents ?? 0,
            hardBrakes: gpsResult.telemetry?.hardBrakingEvents ?? 0,
            harmonyScore: gpsResult.telemetry?.smoothnessScore ?? 0,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tInline(
                AppStrings.currentLanguageCode,
                'Grup sürüşü tamamlandı ve garaj verilerine yansıtıldı.',
                'Group ride ended and reflected in garage data.',
                'Die Gruppenfahrt wurde beendet und in den Werkstattdaten angezeigt.',
              ),
            ),
            backgroundColor: context.colors.cyan,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _leaveLobbyAction() async {
    final userProfile = ref.read(userProfileProvider);
    if (_activeLobbyId != null && !_isHost) {
      await FirebaseService.instance.leaveLobby(
        _activeLobbyId!,
        userProfile.riderTag,
      );
    } else if (_activeLobbyId != null && _isHost) {
      await FirebaseService.instance.deleteLobby(_activeLobbyId!);
    }
    _lobbySubscription?.cancel();
    setState(() {
      _activeLobbyId = null;
      _isHost = true;
      _joinedRiders.clear();
      _meetingPoint = null;
      _isRideActive = false;
    });
    // Re-trigger host lobby creation
    final garageState = ref.read(garageStateProvider);
    _initHostLobby(userProfile, garageState);
  }

  Future<void> _joinLobbyAction(String targetLobbyId) async {
    final userProfile = ref.read(userProfileProvider);
    final garageState = ref.read(garageStateProvider);
    final harmony = ref.read(dashboardStateProvider).harmony.score;

    setState(() {
      _isLoadingLobby = true;
    });

    // First check if target lobby exists in Firestore
    final exists = await FirebaseService.instance.checkLobbyExists(
      targetLobbyId,
    );
    if (!exists) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tInline(
                AppStrings.currentLanguageCode,
                'Geçersiz lobi kodu! Böyle bir lobi bulunamadı.',
                'Invalid lobby code! No such lobby was found.',
                'Ungültiger Lobbycode! Es wurde keine solche Lobby gefunden.',
              ),
            ),
            backgroundColor: context.colors.red,
          ),
        );
      }
      setState(() {
        _isLoadingLobby = false;
      });
      return;
    }

    // First unsubscribe from current stream
    _lobbySubscription?.cancel();

    final myProfileMap = {
      'stableId': userProfile.riderTag,
      'name': userProfile.name.isEmpty ? 'Sürücü' : userProfile.name,
      'riderTag': userProfile.riderTag,
      'ridingStyle': userProfile.ridingStyle,
      'avatarIndex': userProfile.avatarIndex,
      'activeBikeName': garageState.activeBike.name != '—'
          ? garageState.activeBike.name
          : 'Motorcycle',
      'activeBikeModel': garageState.activeBike.model != '—'
          ? garageState.activeBike.model
          : '2025',
      'weeklyKm': 240.0,
      'harmonyScore': harmony,
      'modifications': const ['Standard OEM Parts'],
      'supporterTier': userProfile.supporterTier,
      'cardThemeIndex': userProfile.cardThemeIndex,
      'bloodType': userProfile.bloodType,
      'phone': userProfile.phoneNumber,
      'emergencyPhone': userProfile.emergencyContactPhone,
      'city': userProfile.city,
      'instagram': userProfile.instagram,
      'tiktok': userProfile.tiktok,
      'licensePlate': userProfile.licensePlate,
      'selectedBadges': userProfile.selectedBadges,
    };

    await FirebaseService.instance.joinLobby(targetLobbyId, myProfileMap);

    setState(() {
      _activeLobbyId = targetLobbyId;
      _isHost = false;
      _isLoadingLobby = false;
    });

    _subscribeToLobby(targetLobbyId);
  }

  Future<void> _updateMeetingPointOnFirestore(MeetingPoint? point) async {
    if (!_isHost || _activeLobbyId == null) return;
    if (point == null) {
      await FirebaseService.instance.updateLobbyMeetingPoint(
        _activeLobbyId!,
        null,
      );
    } else {
      await FirebaseService.instance.updateLobbyMeetingPoint(_activeLobbyId!, {
        'name': point.name,
        'latitude': point.latitude,
        'longitude': point.longitude,
      });
    }
  }

  void _showSocialProfileSheet(BuildContext context, FriendProfile profile) {
    final isTr = widget.strings.locale.languageCode == 'tr';
    final isDe = widget.strings.locale.languageCode == 'de';
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(ApexSpacing.x2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isTr ? 'SÜRÜCÜ PROFiLi' : 'RIDER PROFILE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: context.colors.cyan,
                          letterSpacing: 0.5,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Divider(color: context.colors.border, height: 12),
                  const SizedBox(height: 8),

                  RiderIdCard(
                    name: profile.name,
                    riderTag: profile.riderTag,
                    ridingStyle: profile.ridingStyle,
                    bloodType: profile.bloodType,
                    phoneNumber: profile.phone ?? '',
                    emergencyContactName: '',
                    emergencyContactPhone: profile.emergencyPhone ?? '',
                    activeBike: profile.activeBikeName.isNotEmpty
                        ? '${profile.activeBikeName} ${profile.activeBikeModel}'
                        : (isTr ? 'Motosiklet Yok' : 'No Motorcycle'),
                    totalRides: 14,
                    totalKm: profile.weeklyKm * 4.2,
                    harmonyScore: profile.harmonyScore,
                    avatarIndex: profile.avatarIndex,
                    tr: isTr,
                    de: isDe,
                    supporterTier: profile.supporterTier,

                    themeIndex: profile.cardThemeIndex,
                    city: profile.city,
                    instagram: profile.instagram,
                    tiktok: profile.tiktok,
                    youtube: profile.youtube,
                    licensePlate: profile.licensePlate,
                    selectedBadges: profile.selectedBadges,
                    isViewedBySelf: false,
                    sharePhone:
                        profile.phone != null && profile.phone!.isNotEmpty,
                    shareEmergency:
                        profile.emergencyPhone != null &&
                        profile.emergencyPhone!.isNotEmpty,
                  ),
                  const SizedBox(height: 16),

                  RiderHarmonyRadarChart(
                    harmonyScore: profile.harmonyScore,
                    friendStyle: profile.ridingStyle,
                    friendWeeklyKm: profile.weeklyKm,
                    friendId: profile.stableId,
                    tr: isTr,
                  ),
                  const SizedBox(height: 16),

                  Text(
                    isTr ? 'MODİFİKASYONLAR' : 'MODIFICATIONS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: context.colors.cyan,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (profile.modifications.isEmpty)
                    Text(
                      isTr
                          ? 'Henüz modifikasyon eklenmemiş.'
                          : 'No modifications added yet.',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: profile.modifications.map((mod) {
                        return Chip(
                          label: Text(
                            mod,
                            style: TextStyle(
                              fontSize: 11,
                              color: context.colors.white,
                            ),
                          ),
                          backgroundColor: context.colors.elevated,
                          side: BorderSide.none,
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = widget.strings.locale.languageCode == 'tr';
    final de = widget.strings.locale.languageCode == 'de';
    final userProfile = ref.watch(userProfileProvider);
    final garageState = ref.watch(garageStateProvider);
    final harmony = ref.watch(dashboardStateProvider).harmony.score;

    final mySocialProfile = FriendProfile(
      stableId: 'owner',
      name: userProfile.name.isNotEmpty
          ? userProfile.name
          : (tr ? 'Sürücü' : (de ? 'Fahrer' : 'Rider')),
      riderTag: userProfile.riderTag.isNotEmpty
          ? userProfile.riderTag
          : '@rider',
      ridingStyle: userProfile.ridingStyle,
      bloodType: userProfile.bloodType,
      city: userProfile.city,
      avatarIndex: userProfile.avatarIndex,
      activeBikeName:
          garageState.activeBike?.name ??
          (tr
              ? 'Bilinmeyen Motor'
              : (de ? 'Unbekanntes Motorrad' : 'Unknown Bike')),
      activeBikeModel: '',
      weeklyKm: 0,
      harmonyScore: harmony.toInt(),
      ghostMode: userProfile.ghostMode,
      modifications: const [],
      phone: '',
      emergencyPhone: userProfile.emergencyContactPhone,
      supporterTier: userProfile.supporterTier,
      cardThemeIndex: userProfile.cardThemeIndex,
      instagram: userProfile.instagram,
      tiktok: userProfile.tiktok,
      youtube: userProfile.youtube,
      licensePlate: '',
      selectedBadges: userProfile.selectedBadges,
    );

    final bikeName = garageState.activeBike?.name ?? '';

    // Default location string if not defined
    final locationText = _meetingPoint != null
        ? _meetingPoint!.name
        : (tr
              ? 'Rota henüz seçilmedi'
              : (de
                    ? 'Route noch nicht ausgewählt'
                    : 'Route not selected yet'));

    return Scaffold(
      backgroundColor: const Color(0xFF0B121A),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: ListView(
                padding: EdgeInsets.fromLTRB(16, widget.isEmbedded ? 72 : 16, 16, 100),
                children: [
                  if (!widget.isEmbedded) ...[
                    // 1. Custom App Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          tr
                              ? 'Grup Sürüşü'
                              : (de ? 'Gruppenfahrt' : 'Group Ride'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 2. Segmented Control
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                alignment: Alignment.center,
                                color: Colors.transparent,
                                child: Text(
                                  tr
                                      ? 'Solo Sürüş'
                                      : (de ? 'Solo-Fahrt' : 'Solo Ride'),
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.all(4),
                              child: Text(
                                tr
                                    ? 'Grup Sürüşü'
                                    : (de ? 'Gruppenfahrt' : 'Group Ride'),
                                style: const TextStyle(
                                  color: Colors.cyan,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 3. Lobby Title
                  Text(
                    tr
                        ? 'Grup Sürüş Lobisi'
                        : (de ? 'Gruppenfahrt-Lobby' : 'Group Ride Lobby'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tr
                            ? 'Lobi açık · Sürücüler bekleniyor'
                            : (de
                                  ? 'Lobby offen · Warten auf Fahrer'
                                  : 'Lobby open · Waiting for riders'),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  if (_isHost) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.workspace_premium,
                          color: Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          tr
                              ? 'Kurucu sensin'
                              : (de
                                    ? 'Du bist der Gastgeber'
                                    : 'You are the host'),
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),

                  // 4. Lobby Code Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr ? 'LOBİ KODU' : (de ? 'LOBBY-CODE' : 'LOBBY CODE'),
                          style: const TextStyle(
                            color: Colors.cyan,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _activeLobbyId ?? '-----',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                _IconBtn(
                                  icon: Icons.copy,
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    Clipboard.setData(
                                      ClipboardData(text: _activeLobbyId ?? ''),
                                    );
                                    ScaffoldMessenger.of(context)
                                      ..clearSnackBars()
                                      ..showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            tr
                                                ? 'Lobi kodu kopyalandı'
                                                : (de
                                                      ? 'Lobby-Code kopiert'
                                                      : 'Lobby code copied'),
                                          ),
                                        ),
                                      );
                                  },
                                ),
                                const SizedBox(width: 12),
                                _IconBtn(
                                  icon: Icons.qr_code_2,
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        backgroundColor:
                                            context.colors.elevated,
                                        title: Text(
                                          tr
                                              ? 'Hızlı Katılım QR Kodu'
                                              : (de
                                                    ? 'Schnell-Beitritt QR-Code'
                                                    : 'Quick Join QR Code'),
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              color: Colors.white,
                                              padding: const EdgeInsets.all(12),
                                              child: QrImageView(
                                                data:
                                                    'apexflow://join?lobby=$_activeLobbyId',
                                                size: 160,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              tr
                                                  ? 'Diğer sürücüler bu QR kodu taratarak lobiye anında katılabilir.'
                                                  : (de
                                                        ? 'Andere Fahrer können diesen QR-Code scannen, um sofort beizutreten.'
                                                        : 'Other riders can scan this QR code to join.'),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: context
                                                    .colors
                                                    .textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text(
                                              tr
                                                  ? 'Kapat'
                                                  : (de
                                                        ? 'Schließen'
                                                        : 'Close'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0EA5E9),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                onPressed: () {
                                  HapticFeedback.mediumImpact();
                                  final link =
                                      'apexflow://join?lobby=$_activeLobbyId';
                                  SharePlus.instance.share(
                                    ShareParams(text: link),
                                  );
                                },
                                icon: const Icon(Icons.send, size: 18),
                                label: Text(
                                  tr
                                      ? 'Davet Gönder'
                                      : (de
                                            ? 'Einladung senden'
                                            : 'Send Invite'),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 4b. Invite from Friends List
                  Builder(builder: (context) {
                    final friends = ref.watch(friendsStateProvider);
                    if (friends.isEmpty) return const SizedBox.shrink();
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFF334155),
                          width: 0.5,
                        ),
                      ),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 2,
                        ),
                        collapsedIconColor: Colors.white54,
                        iconColor: const Color(0xFF0EA5E9),
                        title: Text(
                          tr
                              ? 'Arkadaşlardan Davet Et (${friends.length})'
                              : (de
                                    ? 'Freunde einladen (${friends.length})'
                                    : 'Invite Friends (${friends.length})'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        children: friends.map((friend) {
                          return ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: const Color(0xFF334155),
                              child: Text(
                                friend.name.isNotEmpty
                                    ? friend.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              friend.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                            subtitle: Text(
                              friend.riderTag,
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.send,
                                color: Color(0xFF0EA5E9),
                                size: 18,
                              ),
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                final link =
                                    'apexflow://join?lobby=$_activeLobbyId';
                                final msg = tr
                                    ? '${friend.name}, seni grup sürüşüne davet ediyorum! Lobi kodu: $_activeLobbyId\n$link'
                                    : (de
                                          ? '${friend.name}, ich lade dich zur Gruppenfahrt ein! Lobby-Code: $_activeLobbyId\n$link'
                                          : '${friend.name}, join my group ride! Lobby code: $_activeLobbyId\n$link');
                                SharePlus.instance.share(
                                  ShareParams(text: msg),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),

                  // 5. Join Another Lobby Tile
                  InkWell(
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      showDialog(
                        context: context,
                        builder: (context) {
                          String enteredCode = '';
                          return AlertDialog(
                            backgroundColor: const Color(0xFF1E293B),
                            title: Text(
                              tr
                                  ? 'Lobiye Katıl'
                                  : (de ? 'Lobby beitreten' : 'Join Lobby'),
                              style: const TextStyle(color: Colors.white),
                            ),
                            content: TextField(
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: tr
                                    ? 'Lobi Kodunu Girin'
                                    : (de
                                          ? 'Lobby-Code eingeben'
                                          : 'Enter Lobby Code'),
                                hintStyle: const TextStyle(
                                  color: Colors.white54,
                                ),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white24),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF0EA5E9),
                                  ),
                                ),
                              ),
                              onChanged: (val) => enteredCode = val,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  final scanned = await Navigator.push<String>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => QrScannerScreen(
                                        strings: widget.strings,
                                      ),
                                    ),
                                  );
                                  if (scanned != null && scanned.isNotEmpty) {
                                    String code = scanned.trim();
                                    if (code.contains('lobby=')) {
                                      try {
                                        final uri = Uri.tryParse(code);
                                        if (uri != null) {
                                          code =
                                              uri.queryParameters['lobby'] ??
                                              code;
                                        }
                                      } catch (_) {}
                                    }
                                    _joinLobbyAction(code);
                                  }
                                },
                                child: Text(
                                  tr
                                      ? 'QR Okut'
                                      : (de ? 'QR scannen' : 'Scan QR'),
                                  style: const TextStyle(
                                    color: Color(0xFF0EA5E9),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  if (enteredCode.isNotEmpty) {
                                    _joinLobbyAction(enteredCode);
                                  }
                                },
                                child: Text(
                                  tr ? 'Katıl' : (de ? 'Beitreten' : 'Join'),
                                  style: const TextStyle(
                                    color: Color(0xFF0EA5E9),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111827),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person_add_outlined,
                            color: Colors.white54,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              tr
                                  ? 'Başka bir lobiye katıl'
                                  : (de
                                        ? 'Einer anderen Lobby beitreten'
                                        : 'Join another lobby'),
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.white54,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 6. Riders List Header
                  Row(
                    children: [
                      Text(
                        tr ? 'Sürücüler' : (de ? 'Fahrer' : 'Riders'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_joinedRiders.length + 1}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 7. Rider Cards
                  _NewLobbyRiderCard(
                    profile: mySocialProfile,
                    isOwner: true,
                    tr: tr,
                    activeBikeName: bikeName,
                    onTap: () =>
                        _showSocialProfileSheet(context, mySocialProfile),
                  ),
                  for (final friend in _joinedRiders)
                    _NewLobbyRiderCard(
                      profile: friend,
                      isOwner: friend.stableId == 'owner',
                      tr: tr,
                      activeBikeName:
                          '${friend.activeBikeName} ${friend.activeBikeModel}',
                      onTap: () => _showSocialProfileSheet(context, friend),
                    ),

                  // 8. Dashed waiting box
                  const SizedBox(height: 8),
                  CustomPaint(
                    painter: _DashedBorderPainter(
                      color: Colors.white24,
                      strokeWidth: 1.5,
                      gap: 4,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add,
                            color: Colors.white38,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            tr
                                ? 'Sürücüler katıldıkça burada görünecek'
                                : (de
                                      ? 'Fahrer erscheinen hier, wenn sie beitreten'
                                      : 'Riders will appear here as they join'),
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 9. Route Selection Card
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.route_outlined,
                            color: Colors.cyan,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            locationText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (_isHost)
                          TextButton(
                            onPressed: () async {
                              HapticFeedback.selectionClick();
                              final result = await Navigator.push<MeetingPoint>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MapPickerDialog(tr: tr),
                                ),
                              );
                              if (result != null) {
                                setState(() {
                                  _meetingPoint = result;
                                });
                                _updateMeetingPointOnFirestore(result);
                              }
                            },
                            child: Row(
                              children: [
                                Text(
                                  _meetingPoint != null
                                      ? (tr
                                            ? 'Değiştir'
                                            : (de ? 'Ändern' : 'Change'))
                                      : (tr
                                            ? 'Rota Ekle'
                                            : (de
                                                  ? 'Route hinzufügen'
                                                  : 'Add Route')),
                                  style: const TextStyle(
                                    color: Colors.cyan,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.cyan,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 10. Bottom Fixed Button
            if (_isHost)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: _buildGroupRideButton(),
              ),
          ],
        ),
      ),
    );
  }

  void _handleGroupRideToggle() {
    final tr = widget.strings.locale.languageCode == 'tr';
    final de = widget.strings.locale.languageCode == 'de';

    HapticFeedback.mediumImpact();
    if (_isRideActive) {
      setState(() {
        _isRideActive = false;
      });
      final gpsResult = _locationService.stopTracking(
        isTurkish: tr,
      );
      final distanceKm = gpsResult.hasGpsData
          ? double.parse(
              gpsResult.distanceKm.toStringAsFixed(2),
            )
          : 0.0;
      final averageSpeedKmh = gpsResult.hasGpsData
          ? double.parse(
              gpsResult.averageSpeedKmh.toStringAsFixed(1),
            )
          : 0.0;
      final durationMinutes = gpsResult.hasGpsData
          ? gpsResult.activeDurationMinutes
          : 0;

      if (distanceKm < 0.1 && averageSpeedKmh < 1.0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tr
                  ? 'Sürüş çok kısa veya hareket algılanmadı. Kaydedilmedi.'
                  : de
                  ? 'Fahrt zu kurz oder keine Bewegung erkannt. Nicht gespeichert.'
                  : 'Ride too short or no movement detected. Not saved.',
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      ref
          .read(rideStateProvider.notifier)
          .endRide(
            distanceKm: distanceKm,
            durationMinutes: durationMinutes,
            averageSpeedKmh: averageSpeedKmh,
            mood: tr
                ? 'Grup Sürüşü'
                : (de ? 'Gruppenfahrt' : 'Group Ride'),
            mechanicalObservation: tr
                ? 'Sorunsuz'
                : (de ? 'Problemlos' : 'Fine'),
            maxSpeedKmh: gpsResult.hasGpsData
                ? gpsResult.maxSpeedKmh
                : 0.0,
            maxLeanAngle:
                gpsResult.telemetry?.maxLeanAngle ?? 0.0,
            hardAccelerations:
                gpsResult
                    .telemetry
                    ?.rapidAccelerationEvents ??
                0,
            hardBrakes:
                gpsResult.telemetry?.hardBrakingEvents ?? 0,
            harmonyScore:
                gpsResult.telemetry?.smoothnessScore ?? 0,
          );
      if (_activeLobbyId != null && _isHost) {
        FirebaseService.instance.deleteLobby(_activeLobbyId!);
      }
    } else {
      setState(() {
        _isRideActive = true;
      });
      if (_activeLobbyId != null) {
        FirebaseService.instance.updateLobbyStatus(
          _activeLobbyId!,
          'active',
        );
      }
      ref
          .read(rideStateProvider.notifier)
          .startRide(
            mood: tr
                ? 'Grup Sürüşü'
                : (de ? 'Gruppenfahrt' : 'Group Ride'),
          );
      _locationService.startTracking(
        isTurkish: tr,
        isMounted: false,
      );
    }
  }

  Widget _buildGroupRideButton() {
    final tr = widget.strings.locale.languageCode == 'tr';
    final de = widget.strings.locale.languageCode == 'de';
    final buttonColor = _isRideActive ? const Color(0xFFEF4444) : const Color(0xFF0EA5E9);
    final buttonText = _isRideActive
        ? (tr ? 'Grup Sürüşünü Durdur' : (de ? 'Gruppenfahrt beenden' : 'Stop Group Ride'))
        : (tr ? 'Grup Sürüşünü Başlat' : (de ? 'Gruppenfahrt starten' : 'Start Group Ride'));

    return GestureDetector(
      onTapDown: (_) => setState(() => _isGroupRidePressed = true),
      onTapUp: (_) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            _handleGroupRideToggle();
            Future.delayed(const Duration(milliseconds: 150), () {
              if (mounted) setState(() => _isGroupRidePressed = false);
            });
          }
        });
      },
      onTapCancel: () => setState(() => _isGroupRidePressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        height: 56,
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: buttonColor, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedOpacity(
              opacity: _isGroupRidePressed ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 280),
              child: AnimatedSlide(
                offset: _isGroupRidePressed ? const Offset(0.3, 0) : Offset.zero,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(buttonText, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    if (!_isRideActive) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                    ],
                  ],
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: _isGroupRidePressed ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOut,
              child: AnimatedSlide(
                offset: _isGroupRidePressed ? Offset.zero : const Offset(-0.2, 0),
                duration: const Duration(milliseconds: 380),
                curve: Curves.easeOutCubic,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(buttonText, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processMapsInput(String input, bool isTr) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          Center(child: CircularProgressIndicator(color: context.colors.cyan)),
    );

    try {
      final point = await MapsLinkParser.parseInput(
        input,
        defaultName: isTr ? 'Buluşma Noktası' : 'Meeting Point',
      );
      if (mounted) {
        Navigator.pop(context);
      }

      if (point != null) {
        setState(() {
          _meetingPoint = point;
        });
        _updateMeetingPointOnFirestore(point);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isTr
                    ? 'Konum başarıyla tanımlandı!'
                    : 'Location defined successfully!',
              ),
              backgroundColor: context.colors.cyan,
            ),
          );
        }
      } else {
        if (mounted) {
          _showInvalidLinkAlert(input, isTr);
        }
      }
    } catch (_) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isTr
                  ? 'Konum çözümlenirken hata oluştu.'
                  : 'Error resolving location.',
            ),
            backgroundColor: context.colors.caution,
          ),
        );
      }
    }
  }

  void _showInvalidLinkAlert(String attemptedInput, bool isTr) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.surface,
        title: Text(
          isTr ? 'Geçersiz Giriş' : 'Invalid Input',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          isTr
              ? 'Yapıştırılan metinden geçerli bir koordinat veya Google Haritalar linki bulunamadı. Lütfen kopyaladığınız linki kontrol edin.\n\nDenenen metin:\n"$attemptedInput"'
              : 'Could not extract valid coordinates or Google Maps link from pasted text. Please verify the copied link.\n\nAttempted text:\n"$attemptedInput"',
          style: TextStyle(color: context.colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              isTr ? 'Tamam' : 'OK',
              style: TextStyle(color: context.colors.cyan),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showManualLinkDialog(isTr);
            },
            child: Text(
              isTr ? 'Manuel Yaz' : 'Enter Manually',
              style: TextStyle(color: context.colors.cyan),
            ),
          ),
        ],
      ),
    );
  }

  void _showManualLinkDialog(bool isTr) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.surface,
        title: Text(
          isTr ? 'Konum Yapıştır' : 'Paste Location',
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isTr
                    ? 'Google Maps paylaşım linkini veya koordinatları (enlem, boylam) buraya yapıştırın:'
                    : 'Paste the Google Maps share link or coordinates (lat, lng) here:',
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: isTr
                      ? 'Örn: https://maps.app.goo.gl/... veya 36.86, 30.64'
                      : 'E.g., https://maps.app.goo.gl/... or 36.86, 30.64',
                  hintStyle: TextStyle(color: context.colors.textSecondary),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              isTr ? 'İptal' : 'Cancel',
              style: TextStyle(color: context.colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              final input = controller.text.trim();
              Navigator.pop(context);
              if (input.isNotEmpty) {
                _processMapsInput(input, isTr);
              }
            },
            child: Text(
              isTr ? 'Çözümle' : 'Resolve',
              style: TextStyle(color: context.colors.cyan),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowingCard extends StatefulWidget {
  final Widget child;
  final bool isGlowing;
  final Color glowColor;
  final Color backgroundColor;
  final Color borderColor;

  const _GlowingCard({
    required this.child,
    required this.isGlowing,
    required this.glowColor,
    required this.backgroundColor,
    required this.borderColor,
  });

  @override
  State<_GlowingCard> createState() => _GlowingCardState();
}

class _GlowingCardState extends State<_GlowingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isGlowing) {
      return Card(
        color: widget.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ApexSpacing.radius),
          side: BorderSide(color: widget.borderColor),
        ),
        child: widget.child,
      );
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(ApexSpacing.radius),
            border: Border.all(color: widget.borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(
                  alpha: 0.1 + (_controller.value * 0.5),
                ),
                blurRadius: 8 + (_controller.value * 12),
                spreadRadius: _controller.value * 2,
              ),
            ],
          ),
          child: Card(
            color: Colors.transparent,
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ApexSpacing.radius),
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _LobbyRiderCard extends StatefulWidget {
  final FriendProfile profile;
  final VoidCallback onTap;
  final bool isOwner;
  final String activeBikeName;

  const _LobbyRiderCard({
    required this.profile,
    required this.onTap,
    required this.isOwner,
    required this.activeBikeName,
  });

  @override
  State<_LobbyRiderCard> createState() => _LobbyRiderCardState();
}

class _LobbyRiderCardState extends State<_LobbyRiderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.profile.supporterTier >= 3) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RiderIdCard(
              name: widget.profile.name,
              riderTag: widget.profile.riderTag,
              ridingStyle: widget.profile.ridingStyle,
              bloodType: widget.profile.bloodType,
              phoneNumber: widget.profile.phone ?? '',
              emergencyContactName: '',
              emergencyContactPhone: widget.profile.emergencyPhone ?? '',
              activeBike: widget.activeBikeName,
              totalRides: 14,
              totalKm: widget.profile.weeklyKm * 4.2,
              harmonyScore: widget.profile.harmonyScore,
              avatarIndex: widget.profile.avatarIndex,
              tr: true, // simplified
              de: false,
              compact: true,
              hideActiveBike: false,
              supporterTier: widget.profile.supporterTier,
              themeIndex: widget.profile.cardThemeIndex,
              city: widget.profile.city,
              instagram: widget.profile.instagram,
              tiktok: widget.profile.tiktok,
              youtube: widget.profile.youtube,
              licensePlate: widget.profile.licensePlate,
              selectedBadges: widget.profile.selectedBadges,
              isViewedBySelf: false,
              sharePhone:
                  widget.profile.phone != null &&
                  widget.profile.phone!.isNotEmpty,
              shareEmergency:
                  widget.profile.emergencyPhone != null &&
                  widget.profile.emergencyPhone!.isNotEmpty,
            ),
            if (widget.isOwner) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.cyan.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: context.colors.cyan.withValues(alpha: 0.4),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.wifi_tethering_rounded,
                          color: context.colors.cyan,
                          size: 10,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'LOBİ SAHİBİ / HOST',
                          style: TextStyle(
                            color: context.colors.cyan,
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(12),
        ),
      );

    ui.PathMetrics pathMetrics = path.computeMetrics();
    for (ui.PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        final length = gap * 2;
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + gap),
          paint,
        );
        distance += length;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _NewLobbyRiderCard extends StatelessWidget {
  final FriendProfile profile;
  final bool isOwner;
  final bool tr;
  final String activeBikeName;
  final VoidCallback onTap;

  const _NewLobbyRiderCard({
    required this.profile,
    required this.isOwner,
    required this.tr,
    required this.activeBikeName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RiderIdCard(
        name: profile.name,
        riderTag: profile.riderTag,
        ridingStyle: profile.ridingStyle,
        bloodType: profile.bloodType,
        phoneNumber: profile.phone ?? '',
        emergencyContactName: '',
        emergencyContactPhone: profile.emergencyPhone ?? '',
        activeBike: profile.activeBikeName,
        totalRides: 0,
        totalKm: profile.weeklyKm,
        harmonyScore: profile.harmonyScore,
        avatarIndex: profile.avatarIndex,
        tr: tr,
        themeIndex: profile.cardThemeIndex,
        city: profile.city,
        instagram: profile.instagram,
        tiktok: profile.tiktok,
        youtube: profile.youtube,
        licensePlate: profile.licensePlate,
        selectedBadges: profile.selectedBadges,
        supporterTier: profile.supporterTier,
        compact: true,
        onTap: onTap,
      ),
    );
  }
}
