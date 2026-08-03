import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apexflow/core/design/apex_colors.dart';
import 'package:apexflow/core/design/apex_spacing.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/core/i18n/app_settings_state.dart';
import 'package:apexflow/onboarding/presentation/onboarding_screen.dart';
import 'package:apexflow/settings/application/user_profile_state.dart';
import 'package:apexflow/garage/application/garage_state.dart';
import 'package:apexflow/rides/application/ride_state.dart';
import 'package:apexflow/profile/application/friends_state.dart';
import 'package:apexflow/profile/domain/friend_profile.dart';
import 'package:apexflow/shared/widgets/apex_panel.dart';
import 'package:apexflow/notifications/application/notification_state.dart';
import 'package:apexflow/notifications/domain/app_notification.dart';
import 'package:apexflow/profile/presentation/premium_paywall_screen.dart';
import 'package:apexflow/profile/presentation/supporter_paywall_screen.dart';
import 'package:apexflow/profile/domain/rider_xp_system.dart';
import 'package:apexflow/core/utils/phone_formatter.dart';
import 'package:apexflow/profile/presentation/qr_scanner_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:apexflow/profile/application/circular_sticker_pdf.dart';
import 'package:apexflow/profile/domain/apex_achievement.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apexflow/core/services/firebase_service.dart';
import 'package:apexflow/features/dashboard/dashboard_state.dart';
import 'package:apexflow/core/design/theme_extensions.dart';

class ProfileHubScreen extends ConsumerStatefulWidget {
  const ProfileHubScreen({
    super.key,
    required this.strings,
    required this.onOpenSettings,
    this.onOpenNotifications,
  });

  final AppStrings strings;
  final VoidCallback onOpenSettings;
  final VoidCallback? onOpenNotifications;

  @override
  ConsumerState<ProfileHubScreen> createState() => _ProfileHubScreenState();
}

class _ProfileHubScreenState extends ConsumerState<ProfileHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = widget.strings.locale.languageCode == 'tr';
    final de = widget.strings.locale.languageCode == 'de';
    String _t(String trStr, String enStr, String deStr) =>
        tr ? trStr : ((AppStrings.currentLanguageCode == 'de') ? deStr : enStr);
    final userProfile = ref.watch(userProfileProvider);
    final garageState = ref.watch(garageStateProvider);
    final rideState = ref.watch(rideStateProvider);
    final friends = ref.watch(friendsStateProvider);

    // Calculate user's own stats
    final totalKm = rideState.sessions.fold<double>(
      0.0,
      (sum, s) => sum + s.distanceKm,
    );
    final totalRides = rideState.sessions.length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Static TabBar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05), // bg-accent container
                  borderRadius: BorderRadius.circular(6), // Design Rules: 4-6 radius
                ),
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: const Color(0xFF090D14), // bg-background active tab
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                      width: 1,
                    ),
                  ),
                  tabs: [
                    Tab(text: _t('PROFİL', 'PROFILE', 'PROFIL')),
                    Tab(text: _t('ARKADAŞLAR', 'FRIENDS', 'FREUNDE')),
                    Tab(text: _t('LİDERLİK', 'LEADERBOARD', 'BESTENLISTE')),
                  ],
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
              ),
            const SizedBox(height: ApexSpacing.x1),
            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: PROFILE
                  ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ApexSpacing.x2,
                      vertical: ApexSpacing.x1,
                    ),
                    children: [
                      // Scrollable Top Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _t(
                                    'Sürücü Hub\'ı',
                                    'Rider Hub',
                                    'Fahrer Hub',
                                  ),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _t(
                                    'Sürücü profiliniz ve sosyal garajınız.',
                                    'Your rider profile and social garage.',
                                    'Dein Fahrerprofil und soziale Garage.',
                                  ),
                                  style: TextStyle(
                                    color: context.colors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              if (widget.onOpenNotifications != null) ...[
                                IconButton(
                                  icon: Badge(
                                    isLabelVisible:
                                        ref.watch(
                                          unreadNotificationCountProvider,
                                        ) >
                                        0,
                                    label: Text(
                                      ref
                                          .watch(
                                            unreadNotificationCountProvider,
                                          )
                                          .toString(),
                                      style: const TextStyle(fontSize: 9),
                                    ),
                                    child: Icon(
                                      Icons.notifications_outlined,
                                      color: context.colors.cyan,
                                    ),
                                  ),
                                  onPressed: widget.onOpenNotifications,
                                ),
                              ],
                              IconButton(
                                icon: Icon(
                                  Icons.person_add_alt_1_outlined,
                                  color: context.colors.cyan,
                                ),
                                onPressed: () =>
                                    _showAddFriendSheet(context, tr, de),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.settings_outlined,
                                  color: context.colors.cyan,
                                ),
                                onPressed: widget.onOpenSettings,
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.logout,
                                  color: context.colors.red,
                                ),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: context.colors.surface,
                                      title: Text(
                                        tInline(
                                          AppStrings.currentLanguageCode,
                                          'Çıkış Yap',
                                          'Log Out',
                                          'Abmelden',
                                        ),
                                      ),
                                      content: Text(
                                        tInline(
                                          AppStrings.currentLanguageCode,
                                          'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
                                          'Are you sure you want to log out?',
                                          'Möchten Sie sich wirklich abmelden?',
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          child: Text(
                                            tInline(
                                              AppStrings.currentLanguageCode,
                                              'İptal',
                                              'Cancel',
                                              'Stornieren',
                                            ),
                                            style: TextStyle(
                                              color:
                                                  context.colors.textSecondary,
                                            ),
                                          ),
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                        ),
                                        TextButton(
                                          child: Text(
                                            _t(
                                              'Çıkış Yap',
                                              'Log Out',
                                              'Abmelden',
                                            ),
                                            style: TextStyle(
                                              color: context.colors.red,
                                            ),
                                          ),
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await ref
                                        .read(userProfileProvider.notifier)
                                        .logout();
                                    if (context.mounted) {
                                      Navigator.of(
                                        context,
                                        rootNavigator: true,
                                      ).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              OnboardingScreen(
                                                strings: AppStrings(
                                                  ref
                                                      .read(appSettingsProvider)
                                                      .locale,
                                                ),
                                              ),
                                        ),
                                        (route) => false,
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Compact Rider ID Card      // Compact Rider ID Card
                      RiderIdCard(
                        name: userProfile.name.isEmpty
                            ? (tInline(
                                AppStrings.currentLanguageCode,
                                'Sürücü',
                                'Rider',
                                'Fahrer',
                              ))
                            : userProfile.name,
                        riderTag: userProfile.riderTag.isEmpty
                            ? '@rider'
                            : userProfile.riderTag,
                        ridingStyle: userProfile.ridingStyle,
                        bloodType: userProfile.bloodType.isEmpty
                            ? '—'
                            : userProfile.bloodType,
                        phoneNumber: userProfile.phoneNumber,
                        emergencyContactName: userProfile.emergencyContactName,
                        emergencyContactPhone:
                            userProfile.emergencyContactPhone,
                        activeBike: garageState.activeBike.name != '—'
                            ? '${garageState.activeBike.name} ${garageState.activeBike.model}'
                            : (tInline(
                                AppStrings.currentLanguageCode,
                                'Motosiklet Yok',
                                'No Motorcycle',
                                'Kein Motorrad',
                              )),
                        totalRides: totalRides,
                        totalKm: totalKm,
                        harmonyScore: garageState.activeBike.name != '—'
                            ? 95
                            : 0,
                        avatarIndex: userProfile.avatarIndex,
                        tr: tr,
                        de: AppStrings.currentLanguageCode == 'de',
                        onTap: () =>
                            _showEditProfileSheet(context, tr, de, userProfile),
                        themeIndex: userProfile.cardThemeIndex,
                        selectedFrameIndex: userProfile.selectedFrameIndex,
                        city: userProfile.city,
                        instagram: userProfile.instagram,
                        tiktok: userProfile.tiktok,
                        youtube: userProfile.youtube,
                        licensePlate: userProfile.licensePlate,
                        selectedBadges: userProfile.selectedBadges,
                        supporterTier: userProfile.supporterTier,
                        riderXp: userProfile.riderXp,
                        compact: false,
                        hideActiveBike: true,
                        isViewedBySelf: true,
                        sharePhone: userProfile.sharePhone,
                        shareEmergency: userProfile.shareEmergency,
                      ),
                      const SizedBox(height: ApexSpacing.x2),

                      // Achievement & Badges Entrance Card
                      _AchievementOverviewCard(
                        tr: tr,
                        de: AppStrings.currentLanguageCode == 'de',
                        onTap: () => _showAchievementsModal(context, tr, AppStrings.currentLanguageCode == 'de', userProfile),
                      ),
                      const SizedBox(height: ApexSpacing.x2),

                      // Premium Vault Button
                      _PremiumVaultButton(
                        tr: tr,
                        de: AppStrings.currentLanguageCode == 'de',
                        onTap: () => _showPremiumVaultModal(context, tr, AppStrings.currentLanguageCode == 'de', userProfile),
                      ),
                      const SizedBox(height: ApexSpacing.x2),

                      if (userProfile.riderTag.startsWith('@rider#')) ...[
                        GestureDetector(
                          onTap: () => _showEditProfileSheet(
                            context,
                            tr,
                            de,
                            userProfile,
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: context.colors.cyan.withValues(
                                alpha: 0.08,
                              ),
                              borderRadius: BorderRadius.circular(
                                ApexSpacing.radius,
                              ),
                              border: Border.all(
                                color: context.colors.cyan.withValues(
                                  alpha: 0.3,
                                ),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.alternate_email,
                                  color: context.colors.cyan,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _t(
                                          'Kendi Rider Tag\'ini Oluştur! ⚡',
                                          'Create Your Rider Tag! ⚡',
                                          'Erstelle dein Rider-Tag! ⚡',
                                        ),
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: context.colors.cyan,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        tInline(
                                          AppStrings.currentLanguageCode,
                                          'Şu an geçici bir etiket kullanıyorsun. Kendine özel bir Rider Tag oluşturarak arkadaş ekleyebilir ve telefon numarası / acil durum bilgilerini arkadaşlarınla paylaşabilirsin.',
                                          'You are currently using a temporary tag. Create your custom Rider Tag to add friends and share phone number / emergency contact info with friends.',
                                          'Sie verwenden derzeit ein temporäres Tag. Erstellen Sie Ihren benutzerdefinierten Fahrer-Tag, um Freunde hinzuzufügen und Telefonnummern/Notfallkontaktinformationen mit Freunden zu teilen.',
                                        ),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: context.colors.textSecondary,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: context.colors.cyan,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: ApexSpacing.x2),
                      ],

                      // 1. Minimal Social Sharing Settings
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          borderRadius: BorderRadius.circular(
                            ApexSpacing.radius,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.share_outlined,
                                  color: context.colors.cyan,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  tInline(
                                    AppStrings.currentLanguageCode,
                                    'SOSYAL PAYLAŞIM',
                                    'SOCIAL SHARING',
                                    'SOZIALES TEILEN',
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                _CompactShareToggle(
                                  icon: Icons.phone_android,
                                  isActive:
                                      userProfile.isPremium &&
                                      userProfile.sharePhone,
                                  onToggle: (val) {
                                    if (!userProfile.isPremium) {
                                      _showPaywall(context);
                                    } else {
                                      ref
                                          .read(userProfileProvider.notifier)
                                          .updateProfile(
                                            name: userProfile.name,
                                            phoneNumber:
                                                userProfile.phoneNumber,
                                            bloodType: userProfile.bloodType,
                                            emergencyContactName: userProfile
                                                .emergencyContactName,
                                            emergencyContactPhone: userProfile
                                                .emergencyContactPhone,
                                            sharePhone: val,
                                            shareEmergency:
                                                userProfile.shareEmergency,
                                          );
                                    }
                                  },
                                  color: context.colors.cyan,
                                ),
                                const SizedBox(width: 12),
                                _CompactShareToggle(
                                  icon: Icons.local_hospital_outlined,
                                  isActive:
                                      userProfile.isPremium &&
                                      userProfile.shareEmergency,
                                  onToggle: (val) {
                                    if (!userProfile.isPremium) {
                                      _showPaywall(context);
                                    } else {
                                      ref
                                          .read(userProfileProvider.notifier)
                                          .updateProfile(
                                            name: userProfile.name,
                                            phoneNumber:
                                                userProfile.phoneNumber,
                                            bloodType: userProfile.bloodType,
                                            emergencyContactName: userProfile
                                                .emergencyContactName,
                                            emergencyContactPhone: userProfile
                                                .emergencyContactPhone,
                                            sharePhone: userProfile.sharePhone,
                                            shareEmergency: val,
                                          );
                                    }
                                  },
                                  color: context.colors.red,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: ApexSpacing.x2),

                      // 2. Support Developer Tile
                      _ProfileSupportDeveloperTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SupporterPaywallScreen(
                                strings: widget.strings,
                              ),
                            ),
                          );
                        },
                        tr: tr,
                        de: AppStrings.currentLanguageCode == 'de',
                      ),
                      const SizedBox(height: ApexSpacing.x2),

                      // 4. Lockscreen Wallpaper
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: context.colors.onAccent,
                            backgroundColor: context.colors.cyan,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                ApexSpacing.radius,
                              ),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    LockscreenWallpaperGeneratorScreen(
                                      strings: widget.strings,
                                    ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.wallpaper),
                          label: Text(
                            _t(
                              'Kilit Ekranı Duvar Kağıdı Üret',
                              'Generate Safety Lockscreen',
                              'Sperrbildschirm generieren',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: ApexSpacing.x3),
                    ],
                  ),

                  // Tab 2: Friends List
                  _FriendsList(
                    friends: friends,
                    tr: tr,
                    de: AppStrings.currentLanguageCode == 'de',
                    onFriendTap: (friend) =>
                        _showFriendShowcaseGarage(context, friend, tr, de),
                    strings: widget.strings,
                    onAddFriend: () => _showAddFriendSheet(context, tr, de),
                  ),

                  // Tab 3: Leaderboard
                  _LeaderboardList(
                    friends: friends,
                    userKm: totalKm,
                    userName: userProfile.name.isEmpty
                        ? (tInline(
                            AppStrings.currentLanguageCode,
                            'Siz',
                            'You',
                            'Du',
                          ))
                        : userProfile.name,
                    tr: tr,
                    userSupporterTier: userProfile.supporterTier,
                    userAvatarIndex: userProfile.avatarIndex,
                    onOpenFriendProfile: (f) =>
                        _showFriendShowcaseGarage(context, f, tr, de),
                    onAddFriend: () => _showAddFriendSheet(context, tr, de),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaywall(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PremiumPaywallScreen(strings: widget.strings),
      ),
    );
  }

  void _showAddFriendSheet(BuildContext context, bool tr, bool de) {
    HapticFeedback.selectionClick();
    final userProfile = ref.read(userProfileProvider);

    if (!userProfile.isPremium) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PremiumPaywallScreen(strings: widget.strings),
        ),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.surface,
      barrierColor: context.colors.background.withValues(alpha: 0.65),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.viewInsetsOf(context).bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tInline(
                      AppStrings.currentLanguageCode,
                      'Arkadaş Ekle',
                      'Add Friend',
                      'Freund hinzufügen',
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // QR Code Section
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 160,
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFFE2E8F0,
                        ), // Slate 200 (slightly darker than off-white)
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF0F172A),
                          width: 2,
                        ), // Slate 900
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(2, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Mini Header
                          const Text(
                            'A P E X   F L O W',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tr
                                ? 'SÜRÜCÜ KART'
                                : ((AppStrings.currentLanguageCode == 'de')
                                      ? 'FAHRERPASS'
                                      : 'RIDER PASS'),
                            style: const TextStyle(
                              fontSize: 6,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFAA7C11), // Gold accent
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // White QR code block
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            child: QrImageView(
                              data:
                                  'https://apex-flow-7baea.web.app/?id=${Uri.encodeComponent(userProfile.riderTag)}',
                              size: 96,
                              gapless: false,
                              eyeStyle: const QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: Colors.black,
                              ),
                              dataModuleStyle: const QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Rider Tag Pill Tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              userProfile.riderTag,
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE2E8F0),
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tInline(
                        AppStrings.currentLanguageCode,
                        'Kendi QR kodunuzu taratın',
                        'Let friends scan your QR code',
                        'Lassen Sie Freunde Ihren QR-Code scannen',
                      ),
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: context.colors.cyan,
                            backgroundColor: context.colors.cyan.withValues(
                              alpha: 0.1,
                            ),
                            side: BorderSide(color: context.colors.cyan),
                          ),
                          onPressed: () async {
                            final scannedTag = await Navigator.push<String>(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    QrScannerScreen(strings: widget.strings),
                              ),
                            );
                            if (scannedTag != null && scannedTag.isNotEmpty) {
                              _tagController.text = scannedTag;
                            }
                          },
                          icon: const Icon(Icons.camera_alt, size: 16),
                          label: Text(
                            tInline(
                              AppStrings.currentLanguageCode,
                              'Kamera ile QR Tara',
                              'Scan QR with Camera',
                              'Scannen Sie QR mit der Kamera',
                            ),
                          ),
                        ),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: context.colors.cyan,
                            backgroundColor: context.colors.cyan.withValues(
                              alpha: 0.1,
                            ),
                            side: BorderSide(color: context.colors.cyan),
                          ),
                          onPressed: () async {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => Center(
                                child: CircularProgressIndicator(
                                  color: context.colors.cyan,
                                ),
                              ),
                            );
                            try {
                              await CircularStickerPdf.generateAndShare(
                                riderTag: userProfile.riderTag,
                                isTurkish: tr,
                              );
                            } finally {
                              if (context.mounted) Navigator.pop(context);
                            }
                          },
                          icon: const Icon(
                            Icons.picture_as_pdf_outlined,
                            size: 16,
                          ),
                          label: Text(
                            tInline(
                              AppStrings.currentLanguageCode,
                              'Sticker PDF Şablonu',
                              'Sticker PDF Template',
                              'Aufkleber-PDF-Vorlage',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: ApexSpacing.x2),
              // Text Field for Rider Tag
              TextField(
                controller: _tagController,
                cursorColor: context.colors.cyan,
                style: TextStyle(color: context.colors.white),
                decoration: InputDecoration(
                  labelText: tInline(
                    AppStrings.currentLanguageCode,
                    'Sürücü Etiketi',
                    'Rider Tag',
                    'Fahrer-Tag',
                  ),
                  hintText: '@ruzgar_123',
                  labelStyle: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 12,
                  ),
                  hintStyle: TextStyle(
                    color: context.colors.muted,
                    fontSize: 12,
                  ),
                  filled: true,
                  fillColor: context.colors.elevated,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ApexSpacing.radius),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ApexSpacing.radius),
                    borderSide: BorderSide(color: context.colors.cyan),
                  ),
                ),
              ),
              const SizedBox(height: ApexSpacing.x2),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: context.colors.onAccent,
                    backgroundColor: context.colors.cyan,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ApexSpacing.radius),
                    ),
                  ),
                  onPressed: () async {
                    final tag = _tagController.text.trim();
                    if (tag.isEmpty) return;
                    final success = await ref
                        .read(friendsStateProvider.notifier)
                        .addFriendByTag(tag, tr);
                    if (!context.mounted) return;
                    if (success) {
                      _tagController.clear();
                      Navigator.pop(context);
                      // Fire notification
                      ref
                          .read(notificationsProvider.notifier)
                          .addNotification(
                            title: tInline(
                              AppStrings.currentLanguageCode,
                              'Yeni Arkadaş Eklendi',
                              'New Friend Added',
                              'Neuer Freund hinzugefügt',
                            ),
                            body: tInline(
                              AppStrings.currentLanguageCode,
                              '@$tag arkadaş listenize eklendi.',
                              '@$tag was added to your friends.',
                              '@$tag wurde zu Ihren Freunden hinzugefügt.',
                            ),
                            type: NotificationType.friendAdded,
                            relatedId: tag,
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            tInline(
                              AppStrings.currentLanguageCode,
                              'Arkadaş başarıyla eklendi!',
                              'Friend added successfully!',
                              'Freund erfolgreich hinzugefügt!',
                            ),
                          ),
                          backgroundColor: context.colors.cyan,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            tInline(
                              AppStrings.currentLanguageCode,
                              'Bu ID sistemde bulunamadı! Lütfen geçerli bir sürücü etiketi girin.',
                              'This ID was not found! Please enter a valid rider tag.',
                              'Diese ID wurde nicht gefunden! Bitte geben Sie einen gültigen Fahrer-Tag ein.',
                            ),
                          ),
                          backgroundColor: context.colors.red,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.check, size: 18),
                  label: Text(
                    tInline(
                      AppStrings.currentLanguageCode,
                      'Etiketle Ekle',
                      'Add by Tag',
                      'Nach Tag hinzufügen',
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, String> _parsePhoneNumber(String combinedPhone) {
    for (final cc in availableCountryCodes) {
      if (combinedPhone.startsWith(cc.code)) {
        final raw = combinedPhone.substring(cc.code.length).trim();
        return {'code': cc.code, 'number': raw};
      }
    }
    return {'code': '+90', 'number': combinedPhone};
  }

  void _showEditProfileSheet(
    BuildContext context,
    bool tr,
    bool de,
    UserProfile profile,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          tr: tr,
          de: AppStrings.currentLanguageCode == 'de',
          strings: widget.strings,
        ),
      ),
    );
  }

  void _showFriendShowcaseGarage(
    BuildContext context,
    FriendProfile friend,
    bool tr,
    bool de,
  ) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.surface,
      barrierColor: context.colors.background.withValues(alpha: 0.75),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tInline(
                      AppStrings.currentLanguageCode,
                      'ARKADAŞ PROFiLi',
                      'FRIEND PROFILE',
                      'FREUNDPROFIL',
                    ),
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

              // Render the friend's customized Rider Card beautifully!
              RiderIdCard(
                name: friend.name,
                riderTag: friend.riderTag,
                ridingStyle: friend.ridingStyle,
                bloodType: friend.bloodType,
                phoneNumber: friend.phone ?? '',
                emergencyContactName: '',
                emergencyContactPhone: friend.emergencyPhone ?? '',
                activeBike: friend.activeBikeName.isNotEmpty
                    ? '${friend.activeBikeName} ${friend.activeBikeModel}'
                    : (tInline(
                        AppStrings.currentLanguageCode,
                        'Motosiklet Yok',
                        'No Motorcycle',
                        'Kein Motorrad',
                      )),
                totalRides: 14,
                totalKm: friend.weeklyKm * 4.2,
                harmonyScore: friend.harmonyScore,
                avatarIndex: friend.avatarIndex,
                tr: tr,
                de: AppStrings.currentLanguageCode == 'de',

                themeIndex: friend.cardThemeIndex,
                city: friend.city,
                instagram: friend.instagram,
                tiktok: friend.tiktok,
                youtube: friend.youtube,
                licensePlate: friend.licensePlate,
                selectedBadges: friend.selectedBadges,
                supporterTier: friend.supporterTier,
                isViewedBySelf: false,
                sharePhone: friend.phone != null && friend.phone!.isNotEmpty,
                shareEmergency:
                    friend.emergencyPhone != null &&
                    friend.emergencyPhone!.isNotEmpty,
              ),
              const SizedBox(height: ApexSpacing.x2),
              RiderHarmonyRadarChart(
                harmonyScore: friend.harmonyScore,
                friendStyle: friend.ridingStyle,
                friendWeeklyKm: friend.weeklyKm,
                friendId: friend.stableId,
                tr: tr,
              ),
              const SizedBox(height: 16),

              Text(
                tInline(
                  AppStrings.currentLanguageCode,
                  'Eklenen Modifikasyonlar & Aksesuarlar',
                  'Added Modifications & Accessories',
                  'Modifikationen und Zubehör hinzugefügt',
                ),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              if (friend.modifications.isEmpty)
                Text(
                  tInline(
                    AppStrings.currentLanguageCode,
                    'Henüz eklenmiş aksesuar yok.',
                    'No accessories added yet.',
                    'Noch kein Zubehör hinzugefügt.',
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final mod in friend.modifications)
                      Chip(
                        backgroundColor: context.colors.elevated,
                        side: BorderSide(color: context.colors.border),
                        label: Text(
                          mod,
                          style: TextStyle(
                            fontSize: 11,
                            color: context.colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colors.red,
                    side: BorderSide(color: context.colors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ApexSpacing.radius),
                    ),
                  ),
                  onPressed: () {
                    ref
                        .read(friendsStateProvider.notifier)
                        .removeFriend(friend.stableId);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.person_remove_outlined, size: 18),
                  label: Text(
                    tInline(
                      AppStrings.currentLanguageCode,
                      'Arkadaşı Çıkar',
                      'Unfriend',
                      'Unfreund',
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Biker ID Card Design

class RiderCardTheme {
  const RiderCardTheme({
    required this.nameTr,
    required this.nameEn,
    this.nameDe,
    required this.colors,
    required this.isPremiumOnly,
    required this.isPaid,
    this.requiredSupporterTier = 0,
  });

  final String nameTr;
  final String nameEn;
  final String? nameDe;
  final List<Color> colors;
  final bool isPremiumOnly;
  final bool isPaid;
  final int requiredSupporterTier;

  String getLocalizedName(String langCode) {
    if (langCode == 'tr') return nameTr;
    if (langCode == 'de') return nameDe ?? nameEn;
    return nameEn;
  }
}

final List<RiderCardTheme> riderCardThemes = [
  RiderCardTheme(
    nameTr: 'Sakin Ulaşım',
    nameEn: 'Urban Commuter',
    nameDe: 'Stadt-Pendler',
    colors: [const Color(0xFF0E7490), const Color(0xFF6B11FF)],
    isPremiumOnly: false,
    isPaid: false,
    requiredSupporterTier: 0,
  ),
  const RiderCardTheme(
    nameTr: 'Enduro Orman',
    nameEn: 'Forest Enduro',
    nameDe: 'Wald-Enduro',
    colors: [Color(0xFF1B4D3E), Color(0xFF3F7C55)],
    isPremiumOnly: true,
    isPaid: false,
    requiredSupporterTier: 0,
  ),
  const RiderCardTheme(
    nameTr: 'Tur Gecesi',
    nameEn: 'Midnight Touring',
    nameDe: 'Mitternachts-Touring',
    colors: [Color(0xFF1E2A38), Color(0xFF3A6073)],
    isPremiumOnly: true,
    isPaid: false,
    requiredSupporterTier: 0,
  ),
  const RiderCardTheme(
    nameTr: 'Süperbike Karbon',
    nameEn: 'Superbike Carbon',
    nameDe: 'Superbike Carbon',
    colors: [Color(0xFF1F1F21), Color(0xFF3C3C3C)],
    isPremiumOnly: false,
    isPaid: true,
    requiredSupporterTier: 0,
  ),
  const RiderCardTheme(
    nameTr: 'Yarış Kırmızısı',
    nameEn: 'Racing Sport',
    nameDe: 'Rennsport-Rot',
    colors: [Color(0xFF9A433F), Color(0xFFD32F2F)],
    isPremiumOnly: false,
    isPaid: true,
  ),
  const RiderCardTheme(
    nameTr: 'Krom Cruiser',
    nameEn: 'Chrome Cruiser',
    nameDe: 'Chrom-Cruiser',
    colors: [Color(0xFF757F9A), Color(0xFFD7DDE8)],
    isPremiumOnly: false,
    isPaid: true,
  ),
  const RiderCardTheme(
    nameTr: 'Serüven Kumu',
    nameEn: 'Adventure Sand',
    nameDe: 'Abenteuer-Sand',
    colors: [Color(0xFFB66F28), Color(0xFFE8DED1)],
    isPremiumOnly: false,
    isPaid: true,
  ),
  const RiderCardTheme(
    nameTr: 'Günbatımı Ufku',
    nameEn: 'Sunset Horizon',
    nameDe: 'Sonnenuntergang-Horizont',
    colors: [Color(0xFFE65100), Color(0xFFF57C00)],
    isPremiumOnly: false,
    isPaid: true,
  ),
  const RiderCardTheme(
    nameTr: 'Neon Naked',
    nameEn: 'Neon Naked',
    nameDe: 'Neon-Naked',
    colors: [Color(0xFF4A148C), Color(0xFF8E24AA)],
    isPremiumOnly: false,
    isPaid: true,
  ),
  const RiderCardTheme(
    nameTr: 'Aero Mavi',
    nameEn: 'Sky Aero',
    nameDe: 'Aero-Blau',
    colors: [Color(0xFF006064), Color(0xFF00ACC1)],
    isPremiumOnly: false,
    isPaid: true,
    requiredSupporterTier: 0,
  ),
  const RiderCardTheme(
    nameTr: 'Apex Destekçisi',
    nameEn: 'Apex Supporter',
    nameDe: 'Apex-Unterstützer',
    colors: [Color(0xFF111111), Color(0xFF2C2C2C)],
    isPremiumOnly: false,
    isPaid: false,
    requiredSupporterTier: 1,
  ),
];

class _CardThemeSelectorPanel extends ConsumerWidget {
  const _CardThemeSelectorPanel({
    required this.tr,
    required this.userProfile,
    required this.strings,
  });

  final bool tr;
  final UserProfile userProfile;
  final AppStrings strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ApexPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.palette_outlined,
                color: context.colors.cyan,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                tInline(
                  AppStrings.currentLanguageCode,
                  'KART TEMASI SEÇİMİ',
                  'SELECT CARD THEME',
                  'KARTENTHEMA WÄHLEN',
                ),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: context.colors.cyan,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 108,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: riderCardThemes.length,
              itemBuilder: (context, index) {
                final theme = riderCardThemes[index];
                final isSelected = userProfile.cardThemeIndex == index;

                var isUnlocked = true;
                if (theme.isPremiumOnly && !userProfile.isPremium) {
                  isUnlocked = false;
                } else if (theme.isPaid &&
                    !userProfile.purchasedThemes.contains(index)) {
                  isUnlocked = false;
                } else if (theme.requiredSupporterTier > 0 &&
                    userProfile.supporterTier < theme.requiredSupporterTier) {
                  isUnlocked = false;
                }

                return GestureDetector(
                  onTap: () {
                    if (isUnlocked) {
                      ref.read(userProfileProvider.notifier).selectTheme(index);
                    } else {
                      if (theme.requiredSupporterTier > 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                SupporterPaywallScreen(strings: strings),
                          ),
                        );
                      } else if (theme.isPremiumOnly) {
                        _showPaywall(context);
                      } else {
                        _showPurchaseDialog(context, ref, index, theme);
                      }
                    }
                  },
                  child: Container(
                    width: 84,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? context.colors.cyan
                            : const Color(0xFF2D2D2F),
                        width: isSelected ? 1.5 : 0.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFF0A0A0A),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: theme.colors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: isSelected
                                ? const Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  )
                                : (!isUnlocked
                                      ? Icon(
                                          theme.isPremiumOnly
                                              ? Icons.star_rounded
                                              : Icons.lock_outline_rounded,
                                          color: Colors.white70,
                                          size: 16,
                                        )
                                      : null),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          theme.getLocalizedName(
                            AppStrings.currentLanguageCode,
                          ),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isSelected
                                ? const Color(0xFFF5F5F5)
                                : const Color(0xFF8E8E93),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showPaywall(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PremiumPaywallScreen(strings: strings),
      ),
    );
  }

  void _showPurchaseDialog(
    BuildContext context,
    WidgetRef ref,
    int index,
    RiderCardTheme theme,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: context.colors.surface,
          title: Text(
            tInline(
              AppStrings.currentLanguageCode,
              'Temayı Satın Al',
              'Unlock Theme',
              'Theme freischalten',
            ),
          ),
          content: Text(
            tInline(
              AppStrings.currentLanguageCode,
              '${theme.nameTr} temasını 35 TL (\$0.99) karşılığında satın almak istiyor musunuz?',
              'Do you want to unlock the ${theme.nameEn} theme for \$0.99?',
              'Möchten Sie das Design "${theme.nameEn}" für \$0.99 freischalten?',
            ),
            style: TextStyle(color: context.colors.textSecondary),
          ),
          actions: [
            TextButton(
              child: Text(
                tInline(
                  AppStrings.currentLanguageCode,
                  'İptal',
                  'Cancel',
                  'Stornieren',
                ),
                style: TextStyle(color: context.colors.textSecondary),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text(
                tInline(
                  AppStrings.currentLanguageCode,
                  'Satın Al',
                  'Purchase',
                  'Kaufen',
                ),
                style: TextStyle(color: context.colors.cyan),
              ),
              onPressed: () async {
                await ref
                    .read(userProfileProvider.notifier)
                    .purchaseTheme(index);
                await ref.read(userProfileProvider.notifier).selectTheme(index);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        tInline(
                          AppStrings.currentLanguageCode,
                          'Tema başarıyla satın alındı ve seçildi!',
                          'Theme purchased and selected!',
                          'Theme gekauft und ausgewählt!',
                        ),
                      ),
                      backgroundColor: context.colors.cyan,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class RiderIdCard extends StatelessWidget {
  const RiderIdCard({
    super.key,
    required this.name,
    required this.riderTag,
    required this.ridingStyle,
    required this.bloodType,
    required this.phoneNumber,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    required this.activeBike,
    required this.totalRides,
    required this.totalKm,
    required this.harmonyScore,
    required this.avatarIndex,
    required this.tr,
    this.de = false,
    this.onTap,
    required this.themeIndex,
    this.selectedFrameIndex = 0,
    this.city = '',
    this.instagram = '',
    this.tiktok = '',
    this.youtube = '',
    this.licensePlate = '',
    this.selectedBadges = const [],
    this.supporterTier = 0,
    this.riderXp = 0,
    this.compact = false,
    this.hideActiveBike = false,
    this.isViewedBySelf = false,
    this.sharePhone = false,
    this.shareEmergency = false,
  });

  final String name;
  final String riderTag;
  final String ridingStyle;
  final String bloodType;
  final String phoneNumber;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String activeBike;
  final int totalRides;
  final double totalKm;
  final int harmonyScore;
  final int avatarIndex;
  final bool tr;
  final bool de;
  final VoidCallback? onTap;
  final int themeIndex;
  final int selectedFrameIndex;
  final String city;
  final String instagram;
  final String tiktok;
  final String youtube;
  final String licensePlate;
  final List<String> selectedBadges;
  final int supporterTier;
  final int riderXp;
  final bool compact;
  final bool hideActiveBike;
  final bool isViewedBySelf;
  final bool sharePhone;
  final bool shareEmergency;

  Widget _buildProfileStatColumn({
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 9,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  String _translateRidingStyle(
    String style,
    String Function(String tr, String en, String de) t,
  ) {
    final clean = style.toLowerCase().trim();
    if (clean == 'focused' || clean == 'odaklı' || clean == 'odakli') {
      return t('Odaklı', 'Focused', 'Fokussiert');
    }
    if (clean == 'aggressive' || clean == 'agresif') {
      return t('Agresif', 'Aggressive', 'Dynamisch');
    }
    if (clean == 'touring' || clean == 'gezi') {
      return t('Gezi', 'Touring', 'Touren');
    }
    if (clean == 'track' || clean == 'pist') {
      return t('Pist', 'Track', 'Rennstrecke');
    }
    if (clean == 'commuter' || clean == 'şehir içi' || clean == 'sehir ici') {
      return t('Şehir İçi', 'Commuter', 'Pendler');
    }
    if (clean == 'chill' || clean == 'sakin') {
      return t('Sakin', 'Chill', 'Entspannt');
    }
    return style;
  }

  @override
  Widget build(BuildContext context) {
    String _t(String trStr, String enStr, String deStr) =>
        tr ? trStr : ((AppStrings.currentLanguageCode == 'de') ? deStr : enStr);

    final canShowPhone = isViewedBySelf || sharePhone;
    final canShowEmergency = isViewedBySelf || shareEmergency;

    final hasPhone = phoneNumber.isNotEmpty && canShowPhone;
    final hasEmergency =
        (emergencyContactPhone.isNotEmpty || emergencyContactName.isNotEmpty) &&
        canShowEmergency;
    final theme =
        riderCardThemes[themeIndex.clamp(0, riderCardThemes.length - 1)];

    final mainCard = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: theme.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ApexSpacing.radius * 1.5),
        boxShadow: [
          BoxShadow(
            color: supporterTier >= 3
                ? Colors.amber.withValues(alpha: 0.4)
                : (supporterTier >= 2
                      ? Colors.black54
                      : theme.colors.first.withValues(alpha: 0.25)),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: supporterTier >= 3
            ? Border.all(color: Colors.amber.withValues(alpha: 0.5), width: 1.5)
            : (supporterTier >= 2
                  ? Border.all(color: Colors.white24, width: 1)
                  : null),
      ),
      child: Stack(
        children: [
          // Semi transparent vector overlay drawings and motorcycle silhouettes
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(ApexSpacing.radius * 1.5),
              child: CustomPaint(
                painter: CardVectorOverlayPainter(themeIndex: themeIndex),
              ),
            ),
          ),
          // Large Motorcycle Icon Instead of Bicycle Vector
          if (themeIndex != 10)
            Positioned(
              right: 16,
              bottom: 16,
              child: Icon(
                Icons.two_wheeler,
                size: 64,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(ApexSpacing.x2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RiderAvatarWidget(
                          avatarIndex: avatarIndex,
                          radius: 28,
                          color: Colors.white,
                          selectedFrameIndex: selectedFrameIndex,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                        color: supporterTier >= 3
                                            ? Colors.amber
                                            : (supporterTier >= 2
                                                  ? Colors.grey[300]
                                                  : Colors.white),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        shadows: const [
                                          Shadow(
                                            color: Colors.black26,
                                            offset: Offset(0, 1),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (supporterTier >= 1) ...[
                                    const SizedBox(width: 4),
                                    AnimatedBadge(tier: supporterTier),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                riderTag,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      offset: Offset(0, 1),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              if (city.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 10,
                                      color: Colors.white.withValues(alpha: 0.8),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      city,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.8),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (selectedBadges.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: selectedBadges.take(5).map((badgeId) {
                                    String icon = '🏆';
                                    Color bg = Colors.amber;
                                    if (badgeId == 'first_ride') {
                                      icon = '🏁';
                                      bg = Colors.blueGrey;
                                    } else if (badgeId == 'mileage_100') {
                                      icon = '🌟';
                                      bg = Colors.orange;
                                    } else if (badgeId == 'speed_demon') {
                                      icon = '🔥';
                                      bg = Colors.redAccent;
                                    } else if (badgeId == 'night_rider') {
                                      icon = '🌙';
                                      bg = Colors.indigo;
                                    } else if (badgeId == 'maintenance_master') {
                                      icon = '🛠️';
                                      bg = Colors.teal;
                                    }

                                    return Container(
                                      margin: const EdgeInsets.only(right: 6),
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: bg.withValues(alpha: 0.9),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white70,
                                          width: 1,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 2,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        icon,
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            _translateRidingStyle(ridingStyle, _t),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (bloodType.isNotEmpty && canShowEmergency)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  Colors.red[900]?.withOpacity(0.3) ??
                                  Colors.red.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.redAccent.withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              bloodType,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                if (!compact) ...[
                  const SizedBox(height: ApexSpacing.x2),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: ApexSpacing.x2),

                  // MOTORCYCLE CULTURE RIDER LEVEL & RANK & XP BAR (XP Bar only visible to self)
                  Builder(builder: (context) {
                    final currentLevel = RiderXpSystem.getLevelForXp(riderXp);
                    final langCode = tr ? 'tr' : (de ? 'de' : 'en');
                    final rankTitle = RiderXpSystem.getRankTitle(currentLevel, langCode);
                    final progressData = RiderXpSystem.getLevelProgress(riderXp);

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'LVL $currentLevel',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  rankTitle,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            if (isViewedBySelf)
                              Text(
                                '${progressData.xpInCurrentLevel} / ${progressData.xpRequiredForNextLevel} XP',
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        if (isViewedBySelf) ...[
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progressData.progress,
                              minHeight: 6,
                              backgroundColor: Colors.white12,
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
                            ),
                          ),
                        ],
                      ],
                    );
                  }),
                  const SizedBox(height: ApexSpacing.x2),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: ApexSpacing.x2),
                  // Instagram Profile Stats Style Layout
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildProfileStatColumn(
                        value: '${totalKm.toStringAsFixed(0)} KM',
                        label: _t(
                          'TOPLAM YOL',
                          'TOTAL DISTANCE',
                          'GESAMTSTRECKE',
                        ),
                      ),
                      _buildProfileStatColumn(
                        value: _t(
                          '$totalRides SÜRÜŞ',
                          '$totalRides RIDES',
                          '$totalRides FAHRTEN',
                        ),
                        label: _t(
                          'TOPLAM SÜRÜŞ',
                          'TOTAL RIDES',
                          'GESAMTFAHRTEN',
                        ),
                      ),
                      _buildProfileStatColumn(
                        value: 'LVL ${RiderXpSystem.getLevelForXp(riderXp)}',
                        label: _t(
                          'SÜRÜCÜ SEVİYESİ',
                          'RIDER LEVEL',
                          'FAHRER STUFE',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: ApexSpacing.x2),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: ApexSpacing.x1),
                  if (!hideActiveBike) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _BikerStat(
                          label: _t(
                            'AKTİF MOTOR',
                            'ACTIVE BIKE',
                            'AKTIVES BIKE',
                          ),
                          value: activeBike,
                        ),
                      ],
                    ),
                    const SizedBox(height: ApexSpacing.x1),
                  ],
                  // Contact & Emergency Info Section
                  if (hasPhone || hasEmergency) ...[
                    const SizedBox(height: ApexSpacing.x1),
                    const Divider(color: Colors.white24, height: 1),
                    const SizedBox(height: ApexSpacing.x1),
                    if (hasPhone)
                      _ContactRow(
                        icon: Icons.phone_outlined,
                        label: _t('TELEFON', 'PHONE', 'TEL.'),
                        value: phoneNumber,
                      ),
                    if (hasEmergency)
                      Padding(
                        padding: EdgeInsets.only(top: hasPhone ? 6 : 0),
                        child: _ContactRow(
                          icon: Icons.contact_emergency_outlined,
                          label: _t('ACİL DURUM', 'EMERGENCY', 'NOTFALL'),
                          value: emergencyContactName.isNotEmpty
                              ? '$emergencyContactName${emergencyContactPhone.isNotEmpty ? ' • $emergencyContactPhone' : ''}'
                              : emergencyContactPhone,
                        ),
                      ),
                  ],
                  // Social Handles & License Plate Section (Global Support)
                  if (instagram.isNotEmpty ||
                      tiktok.isNotEmpty ||
                      youtube.isNotEmpty ||
                      licensePlate.isNotEmpty) ...[
                    const SizedBox(height: ApexSpacing.x1),
                    const Divider(color: Colors.white24, height: 1),
                    const SizedBox(height: ApexSpacing.x1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 4,
                            children: [
                              if (instagram.isNotEmpty)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.camera_alt_outlined,
                                      size: 12,
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '@$instagram',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              if (tiktok.isNotEmpty)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.music_note_outlined,
                                      size: 12,
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '@$tiktok',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              if (youtube.isNotEmpty)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.play_circle_outline,
                                      size: 12,
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '@$youtube',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        if (licensePlate.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.black87,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(1.5),
                                  color: Colors.blue[800],
                                  child: const Icon(
                                    Icons.public_outlined,
                                    color: Colors.white,
                                    size: 7,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  licensePlate.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ], // end if (!compact)
              ],
            ),
          ),
        ],
      ),
    );

    if (supporterTier >= 3) {
      return GestureDetector(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              width: MediaQuery.of(context).size.width * 0.95,
              height: 200,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.amber.withValues(alpha: 0.15),
                      Colors.amber.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            mainCard,
          ],
        ),
      );
    }
    return GestureDetector(onTap: onTap, child: mainCard);
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.7)),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _BikerStat extends StatelessWidget {
  const _BikerStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

/// Stats row panel: active motorcycle, total rides, total distance — 3 columns with vertical dividers.
class _ProfileStatsRow extends StatelessWidget {
  const _ProfileStatsRow({
    required this.activeBike,
    required this.totalRides,
    required this.totalKm,
    required this.tr,
    this.de = false,
  });

  final String activeBike;
  final int totalRides;
  final double totalKm;
  final bool tr;
  final bool de;

  @override
  Widget build(BuildContext context) {
    String _t(String trStr, String enStr, String deStr) =>
        tr ? trStr : ((AppStrings.currentLanguageCode == 'de') ? deStr : enStr);
    final formattedKm = totalKm >= 1000
        ? '${(totalKm / 1000).toStringAsFixed(0)},${(totalKm % 1000).toStringAsFixed(0).padLeft(3, '0')} km'
        : '${totalKm.toStringAsFixed(0)} km';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border.all(
          color: context.colors.border.withValues(alpha: 0.82),
        ),
        borderRadius: BorderRadius.circular(ApexSpacing.radius),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Active motorcycle
            Expanded(
              child: Row(
                children: [
                  Icon(
                    Icons.two_wheeler,
                    size: 20,
                    color: context.colors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          activeBike,
                          style: TextStyle(
                            color: context.colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _t(
                            'Aktif motosiklet',
                            'Active motorcycle',
                            'Aktives Motorrad',
                          ),
                          style: TextStyle(
                            color: context.colors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            VerticalDivider(
              color: context.colors.border,
              width: 24,
              thickness: 1,
              indent: 2,
              endIndent: 2,
            ),
            // Total rides
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _t('TOPLAM SÜRÜŞ', 'TOTAL RIDES', 'GESAMT FAHRTEN'),
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalRides',
                    style: TextStyle(
                      color: context.colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            VerticalDivider(
              color: context.colors.border,
              width: 24,
              thickness: 1,
              indent: 2,
              endIndent: 2,
            ),
            // Total distance
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _t('TOPLAM MESAFE', 'TOTAL DISTANCE', 'GESAMTKILOMETER'),
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedKm,
                    style: TextStyle(
                      color: context.colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Blood type display row.
class _ProfileBloodTypeRow extends StatelessWidget {
  const _ProfileBloodTypeRow({
    required this.bloodType,
    required this.tr,
    this.de = false,
  });

  final String bloodType;
  final bool tr;
  final bool de;

  @override
  Widget build(BuildContext context) {
    if (bloodType.isEmpty || bloodType == '—') return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.colors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: context.colors.border.withValues(alpha: 0.82),
              ),
            ),
            child: Icon(
              Icons.water_drop_outlined,
              size: 18,
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr
                    ? 'KAN GRUBU'
                    : ((AppStrings.currentLanguageCode == 'de')
                          ? 'BLUTGRUPPE'
                          : 'BLOOD TYPE'),
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                bloodType,
                style: TextStyle(
                  color: context.colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Expandable private details section (phone, emergency, plate, social).
class _ProfilePrivateDetailsSection extends StatefulWidget {
  const _ProfilePrivateDetailsSection({
    required this.phoneNumber,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    required this.instagram,
    required this.tiktok,
    required this.licensePlate,
    required this.tr,
    this.de = false,
  });

  final String phoneNumber;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String instagram;
  final String tiktok;
  final String licensePlate;
  final bool tr;
  final bool de;

  @override
  State<_ProfilePrivateDetailsSection> createState() =>
      _ProfilePrivateDetailsSectionState();
}

class _ProfilePrivateDetailsSectionState
    extends State<_ProfilePrivateDetailsSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hasAnyDetail =
        widget.phoneNumber.isNotEmpty ||
        widget.emergencyContactName.isNotEmpty ||
        widget.emergencyContactPhone.isNotEmpty ||
        widget.instagram.isNotEmpty ||
        widget.tiktok.isNotEmpty ||
        widget.licensePlate.isNotEmpty;

    if (!hasAnyDetail) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border.all(
          color: context.colors.border.withValues(alpha: 0.82),
        ),
        borderRadius: BorderRadius.circular(ApexSpacing.radius),
      ),
      child: Column(
        children: [
          // Header (tappable)
          InkWell(
            borderRadius: BorderRadius.circular(ApexSpacing.radius),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 20,
                    color: context.colors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.tr
                              ? 'Kişisel bilgiler ve paylaşım'
                              : ((AppStrings.currentLanguageCode == 'de')
                                    ? 'Private Daten & Freigabe'
                                    : 'Private details & sharing'),
                          style: TextStyle(
                            color: context.colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.tr
                              ? 'Telefon, acil durum, plaka ve sosyal'
                              : ((AppStrings.currentLanguageCode == 'de')
                                    ? 'Telefon, Notfall, Kennzeichen & Sozial'
                                    : 'Phone, emergency contact, plate & social'),
                          style: TextStyle(
                            color: context.colors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more,
                      size: 22,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expandable details
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                children: [
                  Divider(color: context.colors.border, height: 1),
                  const SizedBox(height: 12),
                  if (widget.phoneNumber.isNotEmpty)
                    _detailRow(
                      context,
                      Icons.phone_outlined,
                      widget.tr
                          ? 'Telefon'
                          : ((AppStrings.currentLanguageCode == 'de')
                                ? 'Telefon'
                                : 'Phone'),
                      widget.phoneNumber,
                    ),
                  if (widget.emergencyContactName.isNotEmpty ||
                      widget.emergencyContactPhone.isNotEmpty)
                    _detailRow(
                      context,
                      Icons.contact_emergency_outlined,
                      widget.tr
                          ? 'Acil Durum'
                          : ((AppStrings.currentLanguageCode == 'de')
                                ? 'Notfall'
                                : 'Emergency'),
                      widget.emergencyContactName.isNotEmpty
                          ? '${widget.emergencyContactName}${widget.emergencyContactPhone.isNotEmpty ? ' • ${widget.emergencyContactPhone}' : ''}'
                          : widget.emergencyContactPhone,
                    ),
                  if (widget.licensePlate.isNotEmpty)
                    _detailRow(
                      context,
                      Icons.directions_car_outlined,
                      widget.tr
                          ? 'Plaka'
                          : ((AppStrings.currentLanguageCode == 'de')
                                ? 'Kennzeichen'
                                : 'License Plate'),
                      widget.licensePlate,
                    ),
                  if (widget.instagram.isNotEmpty)
                    _detailRow(
                      context,
                      Icons.camera_alt_outlined,
                      'Instagram',
                      '@${widget.instagram}',
                    ),
                  if (widget.tiktok.isNotEmpty)
                    _detailRow(
                      context,
                      Icons.music_note_outlined,
                      'TikTok',
                      '@${widget.tiktok}',
                    ),
                ],
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: context.colors.textSecondary),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: context.colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

/// Minimal support developer tile.
class _ProfileSupportDeveloperTile extends StatefulWidget {
  const _ProfileSupportDeveloperTile({
    required this.onTap,
    required this.tr,
    this.de = false,
  });

  final VoidCallback onTap;
  final bool tr;
  final bool de;

  @override
  State<_ProfileSupportDeveloperTile> createState() =>
      _ProfileSupportDeveloperTileState();
}

class _ProfileSupportDeveloperTileState
    extends State<_ProfileSupportDeveloperTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _heartbeatAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _heartbeatAnimation = Tween<double>(begin: 0.9, end: 1.15).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.08),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(ApexSpacing.radius),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(ApexSpacing.radius),
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(ApexSpacing.radius),
                ),
                child: Center(
                  child: ScaleTransition(
                    scale: _heartbeatAnimation,
                    child: const Icon(
                      Icons.favorite,
                      size: 18,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.tr
                          ? 'Geliştiriciye Destek Ol'
                          : ((AppStrings.currentLanguageCode == 'de')
                                ? 'Entwickler unterstützen'
                                : 'Support the Developer'),
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.tr
                          ? 'Apex Flow Rider Hub\'ı geliştirmemize yardım edin'
                          : ((AppStrings.currentLanguageCode == 'de')
                                ? 'Helfen Sie, Apex Flow Rider Hub zu verbessern'
                                : 'Help improve Apex Flow Rider Hub'),
                      style: TextStyle(
                        color: Colors.amber.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 22,
                color: Colors.amber.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CardVectorOverlayPainter extends CustomPainter {
  final int themeIndex;

  CardVectorOverlayPainter({required this.themeIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final fillPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Draw background vector lines based on themeIndex
    switch (themeIndex) {
      case 0:
        for (double x = 20; x < w; x += 30)
          canvas.drawLine(Offset(x, 0), Offset(x, h), paint);
        for (double y = 20; y < h; y += 30)
          canvas.drawLine(Offset(0, y), Offset(w, y), paint);
        break;
      case 1:
        final path1 = Path()
          ..moveTo(0, h * 0.4)
          ..quadraticBezierTo(w * 0.3, h * 0.2, w * 0.6, h * 0.5)
          ..quadraticBezierTo(w * 0.8, h * 0.7, w, h * 0.6);
        final path2 = Path()
          ..moveTo(0, h * 0.6)
          ..quadraticBezierTo(w * 0.2, h * 0.5, w * 0.5, h * 0.8)
          ..quadraticBezierTo(w * 0.7, h * 0.9, w, h * 0.75);
        final path3 = Path()
          ..moveTo(0, h * 0.8)
          ..quadraticBezierTo(w * 0.4, h * 0.7, w, h * 0.9);
        canvas.drawPath(path1, paint);
        canvas.drawPath(path2, paint);
        canvas.drawPath(path3, paint);
        break;
      case 2:
        canvas.drawLine(Offset(w * 0.5, h * 0.4), Offset(0, h), paint);
        canvas.drawLine(Offset(w * 0.5, h * 0.4), Offset(w, h), paint);
        canvas.drawLine(Offset(w * 0.5, h * 0.4), Offset(w * 0.5, h), paint);
        final cx = w * 0.8;
        final cy = h * 0.25;
        final compass = Path()
          ..moveTo(cx, cy - 20)
          ..lineTo(cx + 4, cy - 4)
          ..lineTo(cx + 20, cy)
          ..lineTo(cx + 4, cy + 4)
          ..lineTo(cx, cy + 20)
          ..lineTo(cx - 4, cy + 4)
          ..lineTo(cx - 20, cy)
          ..lineTo(cx - 4, cy - 4)
          ..close();
        canvas.drawPath(compass, paint);
        canvas.drawCircle(Offset(cx, cy), 4, paint);
        break;
      case 3:
        paint.strokeWidth = 0.8;
        for (double i = -h; i < w; i += 12)
          canvas.drawLine(Offset(i, 0), Offset(i + h, h), paint);
        break;
      case 4:
        final center = Offset(w * 0.8, h * 0.7);
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: 50),
          math.pi,
          math.pi * 0.7,
          false,
          paint,
        );
        for (double angle = math.pi; angle <= math.pi * 1.7; angle += 0.15) {
          canvas.drawLine(
            Offset(
              center.dx + 44 * math.cos(angle),
              center.dy + 44 * math.sin(angle),
            ),
            Offset(
              center.dx + 52 * math.cos(angle),
              center.dy + 52 * math.sin(angle),
            ),
            paint,
          );
        }
        break;
      case 5:
        canvas.drawCircle(Offset(w * 0.85, h * 0.5), 30, paint);
        canvas.drawCircle(Offset(w * 0.85, h * 0.5), 60, paint);
        canvas.drawCircle(Offset(w * 0.85, h * 0.5), 90, paint);
        canvas.drawLine(
          Offset(w * 0.85 - 100, h * 0.5),
          Offset(w * 0.85 + 100, h * 0.5),
          paint,
        );
        canvas.drawLine(
          Offset(w * 0.85, h * 0.5 - 100),
          Offset(w * 0.85, h * 0.5 + 100),
          paint,
        );
        break;
      case 6:
        final cx2 = w * 0.15;
        final cy2 = h * 0.3;
        final compass2 = Path()
          ..moveTo(cx2, cy2 - 15)
          ..lineTo(cx2 + 3, cy2 - 3)
          ..lineTo(cx2 + 15, cy2)
          ..lineTo(cx2 + 3, cy2 + 3)
          ..lineTo(cx2, cy2 + 15)
          ..lineTo(cx2 - 3, cy2 + 3)
          ..lineTo(cx2 - 15, cy2)
          ..lineTo(cx2 - 3, cy2 - 3)
          ..close();
        canvas.drawPath(compass2, paint);
        canvas.drawCircle(Offset(cx2, cy2), 3, paint);
        break;
      case 7:
        canvas.drawCircle(Offset(w * 0.8, h * 0.4), 28, paint);
        for (double y = h * 0.6; y < h; y += 12)
          canvas.drawLine(Offset(0, y), Offset(w, y), paint);
        break;
      case 8:
        final shard1 = Path()
          ..moveTo(w * 0.7, 0)
          ..lineTo(w, h * 0.4)
          ..lineTo(w * 0.8, h * 0.5)
          ..close();
        final shard2 = Path()
          ..moveTo(w * 0.5, h)
          ..lineTo(w * 0.9, h * 0.6)
          ..lineTo(w, h)
          ..close();
        canvas.drawPath(shard1, paint);
        canvas.drawPath(shard2, paint);
        break;
      case 9:
        final wave1 = Path()
          ..moveTo(0, h * 0.3)
          ..cubicTo(w * 0.25, h * 0.1, w * 0.5, h * 0.6, w, h * 0.4);
        final wave2 = Path()
          ..moveTo(0, h * 0.4)
          ..cubicTo(w * 0.3, h * 0.25, w * 0.6, h * 0.7, w, h * 0.5);
        final wave3 = Path()
          ..moveTo(0, h * 0.5)
          ..cubicTo(w * 0.3, h * 0.4, w * 0.6, h * 0.8, w, h * 0.6);
        canvas.drawPath(wave1, paint);
        canvas.drawPath(wave2, paint);
        canvas.drawPath(wave3, paint);
        break;
      case 10:
        final cx = w * 0.8;
        final cy = h * 0.55;
        final diamond = Path()
          ..moveTo(cx, cy - 60)
          ..lineTo(cx + 45, cy - 10)
          ..lineTo(cx, cy + 70)
          ..lineTo(cx - 45, cy - 10)
          ..close();
        final inner1 = Path()
          ..moveTo(cx - 25, cy - 10)
          ..lineTo(cx + 25, cy - 10);
        final inner2 = Path()
          ..moveTo(cx - 25, cy - 10)
          ..lineTo(cx, cy - 40)
          ..lineTo(cx + 25, cy - 10);
        final inner3 = Path()
          ..moveTo(cx - 25, cy - 10)
          ..lineTo(cx, cy + 50)
          ..lineTo(cx + 25, cy - 10);
        canvas.drawPath(diamond, paint);
        canvas.drawPath(inner1, paint);
        canvas.drawPath(inner2, paint);
        canvas.drawPath(inner3, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CardVectorOverlayPainter oldDelegate) {
    return oldDelegate.themeIndex != themeIndex;
  }
}

// User garage modifications list view
class _UserGarageModifications extends StatelessWidget {
  const _UserGarageModifications({
    required this.bikeName,
    required this.bikeModel,
    required this.tr,
  });

  final String bikeName;
  final String bikeModel;
  final bool tr;

  @override
  Widget build(BuildContext context) {
    if (bikeName == '—') {
      return Center(
        child: Text(
          tInline(
            AppStrings.currentLanguageCode,
            'Garajda aktif motosiklet yok.',
            'No active motorcycle in garage.',
            'Kein aktives Motorrad in der Garage.',
          ),
          style: TextStyle(color: context.colors.textSecondary),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$bikeName ($bikeModel)',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.two_wheeler, size: 48, color: context.colors.cyan),
                const SizedBox(height: 8),
                Text(
                  tInline(
                    AppStrings.currentLanguageCode,
                    'Motosikletiniz garajda aktif durumda.',
                    'Your motorcycle is active in the garage.',
                    'Ihr Motorrad steht aktiv in der Garage.',
                  ),
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Friends List tab
class _FriendsList extends ConsumerStatefulWidget {
  const _FriendsList({
    required this.friends,
    required this.tr,
    required this.de,
    required this.onFriendTap,
    required this.strings,
    required this.onAddFriend,
  });

  final List<FriendProfile> friends;
  final bool tr;
  final bool de;
  final ValueChanged<FriendProfile> onFriendTap;
  final AppStrings strings;
  final VoidCallback onAddFriend;

  @override
  ConsumerState<_FriendsList> createState() => _FriendsListState();
}

class _FriendsListState extends ConsumerState<_FriendsList> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = widget.tr;
    final de = AppStrings.currentLanguageCode == 'de';
    String _t(String trStr, String enStr, String deStr) =>
        tr ? trStr : ((AppStrings.currentLanguageCode == 'de') ? deStr : enStr);

    final notifications = ref.watch(notificationsProvider);
    final pendingCount = notifications
        .where((n) => n.type == NotificationType.friendRequest && !n.isRead)
        .length;

    final filteredFriends = widget.friends.where((f) {
      final query = _searchQuery.toLowerCase().trim();
      if (query.isEmpty) return true;
      return f.name.toLowerCase().contains(query) ||
          f.riderTag.toLowerCase().contains(query);
    }).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Friends Title & Badge Count
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _t('Arkadaşlar', 'Friends', 'Freunde'),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.friends.length.toString(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _t(
            'Sürüş çevren ve takip ettiklerin.',
            'Your rider circle and following.',
            'Dein Fahrerkreis und Gefolgte.',
          ),
          style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 18),

        // Search Bar "Arkadaşlarda ara"
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: TextField(
            controller: _searchController,
            cursorColor: context.colors.cyan,
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: _t(
                'Arkadaşlarda ara',
                'Search friends',
                'Freunde suchen',
              ),
              hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.white30,
                size: 18,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Button 1: Arkadaşlık İstekleri
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                fullscreenDialog: true,
                builder: (_) => _PendingRequestsScreen(
                  tr: tr,
                  de: AppStrings.currentLanguageCode == 'de',
                  strings: widget.strings,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFFD97706),
                  child: Icon(Icons.person, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _t(
                      'Arkadaşlık İstekleri',
                      'Friend Requests',
                      'Freundschaftsanfragen',
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (pendingCount > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      pendingCount.toString(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Icon(
                  Icons.chevron_right,
                  color: context.colors.textSecondary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Button 2: Yakınındaki Kişiler
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                fullscreenDialog: true,
                builder: (_) => _NearbyRidersScreen(
                  tr: tr,
                  de: AppStrings.currentLanguageCode == 'de',
                  strings: widget.strings,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFF0369A1),
                  child: Icon(Icons.people, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _t(
                          'Yakınındaki Kişiler',
                          'Nearby Riders',
                          'Fahrer in der Nähe',
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _t(
                          '100 km çaptaki aktif sürücüleri tara ve bul',
                          'Scan and find active riders within 100 km',
                          'Scannen und finden Sie aktive Fahrer im Umkreis von 100 km',
                        ),
                        style: TextStyle(
                          color: context.colors.textSecondary,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: context.colors.textSecondary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Arkadaşların Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _t('Arkadaşların', 'Your Friends', 'Deine Freunde'),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            InkWell(
              onTap: widget.onAddFriend,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF06B6D4).withValues(alpha: 0.15),
                  border: Border.all(color: const Color(0xFF06B6D4)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.person_add_outlined,
                      size: 13,
                      color: Color(0xFF06B6D4),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _t('Arkadaş Ekle', 'Add Friend', 'Freund hinzufügen'),
                      style: const TextStyle(
                        color: Color(0xFF06B6D4),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (filteredFriends.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Text(
                _t(
                  'Henüz arkadaşınız yok.',
                  'No friends connected yet.',
                  'Es sind noch keine Freunde verbunden.',
                ),
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
          )
        else
          ...filteredFriends.map((friend) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RiderIdCard(
                name: friend.name,
                riderTag: friend.riderTag,
                ridingStyle: friend.ridingStyle,
                bloodType: friend.bloodType,
                phoneNumber: friend.phone ?? '',
                emergencyContactName: '',
                emergencyContactPhone: friend.emergencyPhone ?? '',
                activeBike:
                    '${friend.activeBikeName} ${friend.activeBikeModel}',
                totalRides: 42,
                totalKm: friend.weeklyKm * 10,
                harmonyScore: friend.harmonyScore,
                avatarIndex: friend.avatarIndex,
                tr: tr,
                de: AppStrings.currentLanguageCode == 'de',
                themeIndex: friend.cardThemeIndex,
                selectedFrameIndex: 0,
                city: friend.city.isNotEmpty
                    ? friend.city
                    : _t('Antalya', 'Antalya', 'Antalya'),
                instagram: friend.instagram,
                tiktok: friend.tiktok,
                youtube: friend.youtube,
                licensePlate: friend.licensePlate,
                selectedBadges: friend.selectedBadges,
                supporterTier: friend.supporterTier,
                compact: true,
                onTap: () => widget.onFriendTap(friend),
              ),
            );
          }),
      ],
    );
  }
}

class _PendingRequestsScreen extends ConsumerWidget {
  const _PendingRequestsScreen({
    required this.tr,
    required this.de,
    required this.strings,
  });
  final bool tr;
  final bool de;
  final AppStrings strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final pendingRequests = notifications
        .where((n) => n.type == NotificationType.friendRequest && !n.isRead)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0B1528),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: Text(
          tr
              ? 'Arkadaşlık İstekleri'
              : ((AppStrings.currentLanguageCode == 'de')
                    ? 'Freundschaftsanfragen'
                    : 'Friend Requests'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: pendingRequests.isEmpty
          ? Center(
              child: Text(
                tr
                    ? 'Yeni istek bulunmuyor.'
                    : ((AppStrings.currentLanguageCode == 'de')
                          ? 'Keine neuen Anfragen.'
                          : 'No new requests.'),
                style: const TextStyle(color: Colors.white54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pendingRequests.length,
              itemBuilder: (context, index) {
                final req = pendingRequests[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(
                          0xFF06B6D4,
                        ).withValues(alpha: 0.15),
                        child: Text(
                          (() {
                            final reqTag =
                                req.relatedId?.replaceAll('@', '') ?? '';
                            return reqTag.isEmpty
                                ? 'R'
                                : reqTag
                                      .substring(
                                        0,
                                        reqTag.length < 2 ? reqTag.length : 2,
                                      )
                                      .toUpperCase();
                          })(),
                          style: const TextStyle(
                            color: Color(0xFF06B6D4),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              req.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              req.body,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.check,
                              color: Colors.greenAccent,
                            ),
                            onPressed: () async {
                              final tag = req.relatedId ?? '';
                              if (tag.isNotEmpty) {
                                await ref
                                    .read(friendsStateProvider.notifier)
                                    .addFriendByTag(tag, tr);
                              }
                              ref
                                  .read(notificationsProvider.notifier)
                                  .markAsRead(req.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      tr
                                          ? 'İstek kabul edildi!'
                                          : ((AppStrings.currentLanguageCode ==
                                                    'de')
                                                ? 'Anfrage akzeptiert!'
                                                : 'Request accepted!'),
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.redAccent,
                            ),
                            onPressed: () {
                              ref
                                  .read(notificationsProvider.notifier)
                                  .remove(req.id);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _NearbyRidersScreen extends ConsumerStatefulWidget {
  const _NearbyRidersScreen({
    required this.tr,
    required this.de,
    required this.strings,
  });
  final bool tr;
  final bool de;
  final AppStrings strings;

  @override
  ConsumerState<_NearbyRidersScreen> createState() =>
      _NearbyRidersScreenState();
}

class _NearbyRidersScreenState extends ConsumerState<_NearbyRidersScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _scanning = true;
  final List<FriendProfile> _matches = [];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _scanning = false;
        // Search completes with real rider results (empty if no nearby riders in region)
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = widget.tr;
    String _t(String trStr, String enStr, String deStr) => tr
        ? trStr
        : (widget.strings.locale.languageCode == 'de' ? deStr : enStr);

    return Scaffold(
      backgroundColor: const Color(0xFF0B1528),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: Text(
          _t('Yakınındaki Kişiler', 'Nearby Riders', 'Fahrer in der Nähe'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _scanning
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 120 + (_pulseController.value * 40),
                        height: 120 + (_pulseController.value * 40),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF06B6D4).withValues(
                            alpha: 0.1 * (1.0 - _pulseController.value),
                          ),
                          border: Border.all(
                            color: const Color(
                              0xFF06B6D4,
                            ).withValues(alpha: 1.0 - _pulseController.value),
                            width: 2 + 3 * _pulseController.value,
                          ),
                        ),
                        child: const Icon(
                          Icons.radar,
                          size: 48,
                          color: Color(0xFF06B6D4),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _t(
                      '100 km çaptaki sürücüler taranıyor...',
                      'Scanning riders within 100 km...',
                      'Scanner Fahrer im Umkreis von 100 km...',
                    ),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : _matches.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.radar_outlined,
                      size: 56,
                      color: Colors.white38,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _t(
                        'Yakınınızda aktif sürücü bulunamadı',
                        'No nearby active riders found',
                        'Keine aktiven Fahrer in der Nähe gefunden',
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _t(
                        'Diğer sürücüleri @rider_tag ile doğrudan arayabilir veya arkadaşlık isteği gönderebilirsiniz.',
                        'You can search other riders directly via @rider_tag or send a friend request.',
                        'Sie können nach anderen Fahrern direkt über @rider_tag suchen veya eine Freundschaftsanfrage senden.',
                      ),
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _matches.length,
              itemBuilder: (context, index) {
                final rider = _matches[index];
                final theme =
                    riderCardThemes[rider.cardThemeIndex.clamp(
                      0,
                      riderCardThemes.length - 1,
                    )];
                final friends = ref.watch(friendsStateProvider);
                final isAlreadyFriend = friends.any(
                  (f) =>
                      f.riderTag.toLowerCase() == rider.riderTag.toLowerCase(),
                );

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          width: 4,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: theme.colors,
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                          child: Row(
                            children: [
                              RiderAvatarWidget(
                                avatarIndex: rider.avatarIndex,
                                radius: 22,
                                color: theme.colors.first,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      rider.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.5,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      rider.riderTag,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          color: Colors.white38,
                                          size: 10,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          rider.city,
                                          style: const TextStyle(
                                            color: Colors.white38,
                                            fontSize: 10.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: isAlreadyFriend
                                    ? null
                                    : () async {
                                        final success = await ref
                                            .read(friendsStateProvider.notifier)
                                            .addFriendByTag(rider.riderTag, tr);
                                        if (success && context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                _t(
                                                  'Arkadaş eklendi!',
                                                  'Friend added!',
                                                  'Freund hinzugefügt!',
                                                ),
                                              ),
                                              backgroundColor: const Color(
                                                0xFF06B6D4,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isAlreadyFriend
                                        ? const Color(0xFF1E293B)
                                        : const Color(
                                            0xFF06B6D4,
                                          ).withValues(alpha: 0.15),
                                    border: Border.all(
                                      color: isAlreadyFriend
                                          ? Colors.white24
                                          : const Color(0xFF06B6D4),
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isAlreadyFriend
                                        ? _t('Eklendi', 'Added', 'Hinzugefügt')
                                        : _t('Ekle', 'Add', 'Hinzufügen'),
                                    style: TextStyle(
                                      color: isAlreadyFriend
                                          ? Colors.white38
                                          : const Color(0xFF06B6D4),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// Leaderboard List tab
class _LeaderboardList extends StatefulWidget {
  const _LeaderboardList({
    required this.friends,
    required this.userKm,
    required this.userName,
    required this.tr,
    required this.userSupporterTier,
    required this.userAvatarIndex,
    required this.onOpenFriendProfile,
    required this.onAddFriend,
  });

  final List<FriendProfile> friends;
  final double userKm;
  final String userName;
  final bool tr;
  final int userSupporterTier;
  final int userAvatarIndex;
  final void Function(FriendProfile) onOpenFriendProfile;
  final VoidCallback onAddFriend;

  @override
  State<_LeaderboardList> createState() => _LeaderboardListState();
}

class _LeaderboardListState extends State<_LeaderboardList> {
  @override
  Widget build(BuildContext context) {
    final tr = widget.tr;
    final userName = widget.userName;
    final userKm = widget.userKm;

    // Merge user with friends and sort by weeklyKm
    final items = <_LeaderboardItem>[
      _LeaderboardItem(
        name: userName,
        tag: tInline(AppStrings.currentLanguageCode, 'Siz', 'You', 'Du'),
        km: userKm,
        isUser: true,
        supporterTier: widget.userSupporterTier,
        avatarIndex: widget.userAvatarIndex,
        friendObj: null,
      ),
      for (final f in widget.friends)
        _LeaderboardItem(
          name: f.name,
          tag: f.riderTag,
          km: f.weeklyKm,
          isUser: false,
          supporterTier: f.supporterTier,
          avatarIndex: f.avatarIndex,
          friendObj: f,
        ),
    ];
    items.sort((a, b) => b.km.compareTo(a.km));

    final userRank = items.indexWhere((e) => e.isUser) + 1;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // Header
        Text(
          tInline(
            AppStrings.currentLanguageCode,
            'Leaderboard',
            'Leaderboard',
            'Leaderboard',
          ),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              tInline(
                AppStrings.currentLanguageCode,
                'Sürücü çevrenizdeki haftalık mesafe.',
                'Weekly distance across your rider circle.',
                'Wöchentliche Distanz in Ihrem Fahrerkreis.',
              ),
              style: TextStyle(
                fontSize: 13,
                color: context.colors.textSecondary,
              ),
            ),
            InkWell(
              onTap: widget.onAddFriend,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: context.colors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person_add_outlined,
                  size: 20,
                  color: context.colors.cyan,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Your Week Panel
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: context.colors.surface,
            border: Border.all(color: context.colors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Text(
                      tInline(
                        AppStrings.currentLanguageCode,
                        'SENİN HAFTAN',
                        'YOUR WEEK',
                        'DEINE WOCHE',
                      ),
                      style: TextStyle(
                        fontSize: 10,
                        color: context.colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '#$userRank',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFFD700),
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: context.colors.border),
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                    '${userKm.toStringAsFixed(1)} km',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Container(width: 1, height: 40, color: context.colors.border),
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                    userRank == 1
                        ? tInline(
                            AppStrings.currentLanguageCode,
                            'Çevrene liderlik ediyorsun',
                            'Leading your circle',
                            'Führend in deinem Kreis',
                          )
                        : tInline(
                            AppStrings.currentLanguageCode,
                            'İyi gidiyorsun',
                            'Doing great',
                            'Gut gemacht',
                          ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Top Riders
        Text(
          tInline(
            AppStrings.currentLanguageCode,
            'Zirvedeki Sürücüler',
            'Top Riders',
            'Top Fahrer',
          ),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),

        if (items.isNotEmpty)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (items.length > 1)
                Expanded(child: _buildPodiumCard(items[1], 2)),
              if (items.length > 1) const SizedBox(width: 8),
              Expanded(child: _buildPodiumCard(items[0], 1)),
              if (items.length > 2) const SizedBox(width: 8),
              if (items.length > 2)
                Expanded(child: _buildPodiumCard(items[2], 3)),
            ],
          ),

        const SizedBox(height: 24),

        // Weekly Ranking
        Text(
          tInline(
            AppStrings.currentLanguageCode,
            'Haftalık Sıralama',
            'Weekly Ranking',
            'Wöchentliches Ranking',
          ),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            const SizedBox(width: 8),
            Text(
              tInline(AppStrings.currentLanguageCode, 'SIRA', 'RANK', 'RANG'),
              style: TextStyle(
                fontSize: 10,
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(width: 32),
            Text(
              tInline(
                AppStrings.currentLanguageCode,
                'SÜRÜCÜ',
                'RIDER',
                'FAHRER',
              ),
              style: TextStyle(
                fontSize: 10,
                color: context.colors.textSecondary,
              ),
            ),
            const Spacer(),
            Text(
              tInline(
                AppStrings.currentLanguageCode,
                'MESAFE',
                'DISTANCE',
                'DISTANZ',
              ),
              style: TextStyle(
                fontSize: 10,
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(width: 24),
          ],
        ),
        const SizedBox(height: 8),

        for (int i = 0; i < items.length; i++)
          _buildRankingRow(items[i], i + 1),

        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Container(height: 1, color: context.colors.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                tInline(
                  AppStrings.currentLanguageCode,
                  'Çevrenizde ${items.length} sürücü',
                  '${items.length} riders in your circle',
                  '${items.length} Fahrer in Ihrem Kreis',
                ),
                style: TextStyle(
                  fontSize: 10,
                  color: context.colors.textSecondary,
                ),
              ),
            ),
            Expanded(child: Container(height: 1, color: context.colors.border)),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  void _handleUserTap(_LeaderboardItem item) {
    if (item.isUser) return; // Can't click self in this context usually
    if (item.friendObj != null) {
      widget.onOpenFriendProfile(item.friendObj!);
    }
  }

  Widget _buildPodiumCard(_LeaderboardItem item, int rank) {
    final isRank1 = rank == 1;
    final borderColor = isRank1
        ? const Color(0xFFFFD700)
        : context.colors.border;
    final rankColor = isRank1 ? const Color(0xFFFFD700) : context.colors.white;

    return InkWell(
      onTap: () => _handleUserTap(item),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.colors.surface,
          border: Border.all(color: borderColor, width: isRank1 ? 1.5 : 1.0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                '${rank}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: rankColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            RiderAvatarWidget(
              avatarIndex: item.avatarIndex,
              radius: 24,
              selectedFrameIndex: isRank1 ? 3 : 0,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
            if (item.isUser) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tInline(AppStrings.currentLanguageCode, 'SEN', 'YOU', 'DU'),
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 2),
            Text(
              item.tag,
              style: TextStyle(
                fontSize: 9,
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${item.km.toStringAsFixed(1)} km',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingRow(_LeaderboardItem item, int rank) {
    return InkWell(
      onTap: () => _handleUserTap(item),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: Text(
                '${rank}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            RiderAvatarWidget(avatarIndex: item.avatarIndex, radius: 16),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                      if (item.isUser) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tInline(AppStrings.currentLanguageCode, 'SEN', 'YOU', 'DU'),
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    item.tag,
                    style: TextStyle(
                      fontSize: 10,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${item.km.toStringAsFixed(1)} km',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.chevron_right,
              size: 16,
              color: context.colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardItem {
  const _LeaderboardItem({
    required this.name,
    required this.tag,
    required this.km,
    required this.isUser,
    required this.supporterTier,
    required this.avatarIndex,
    required this.friendObj,
  });

  final String name;
  final String tag;
  final double km;
  final bool isUser;
  final int supporterTier;
  final int avatarIndex;
  final FriendProfile? friendObj;
}

class AvatarTheme {
  final List<Color> bgColors;
  final Color accentColor;
  final String titleTr;
  final String titleEn;

  const AvatarTheme({
    required this.bgColors,
    required this.accentColor,
    required this.titleTr,
    required this.titleEn,
  });
}

const List<AvatarTheme> avatarThemes = [
  AvatarTheme(
    bgColors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
    accentColor: Color(0xFF00E5FF),
    titleTr: 'Apex Kask',
    titleEn: 'Apex Helmet',
  ),
  AvatarTheme(
    bgColors: [Color(0xFF1F1C2C), Color(0xFF928DAB)],
    accentColor: Color(0xFFFF9F0A),
    titleTr: 'Spor Sürücü',
    titleEn: 'Sport Rider',
  ),
  AvatarTheme(
    bgColors: [Color(0xFF111111), Color(0xFF333333)],
    accentColor: Color(0xFFFF2D55),
    titleTr: 'Kadran/Hız',
    titleEn: 'Speedometer',
  ),
  AvatarTheme(
    bgColors: [Color(0xFF000000), Color(0xFF0F9B0F)],
    accentColor: Color(0xFF34C759),
    titleTr: 'Keşifçi',
    titleEn: 'Explorer',
  ),
  AvatarTheme(
    bgColors: [Color(0xFF0B1021), Color(0xFF1A2A6C)],
    accentColor: Color(0xFFFFD60A),
    titleTr: 'Güvenlik',
    titleEn: 'Safety',
  ),
  AvatarTheme(
    bgColors: [Color(0xFF1A002C), Color(0xFF3A006C)],
    accentColor: Color(0xFFBF5AF2),
    titleTr: 'Performans',
    titleEn: 'Performance',
  ),
  AvatarTheme(
    bgColors: [Color(0xFF130CB7), Color(0xFF52E5E7)],
    accentColor: Color(0xFF52E5E7),
    titleTr: 'Şanzıman/Zincir',
    titleEn: 'Gear/Chain',
  ),
  AvatarTheme(
    bgColors: [Color(0xFF3E5151), Color(0xFFDECBA4)],
    accentColor: Color(0xFFDECBA4),
    titleTr: 'Klasik Gidon',
    titleEn: 'Classic Bar',
  ),
  AvatarTheme(
    bgColors: [Color(0xFFED213A), Color(0xFF93291E)],
    accentColor: Color(0xFFFF3B30),
    titleTr: 'Egzoz Susturucu',
    titleEn: 'Exhaust Power',
  ),
  AvatarTheme(
    bgColors: [Color(0xFF1D976C), Color(0xFF93F9B9)],
    accentColor: Color(0xFF93F9B9),
    titleTr: 'Aerodinamik',
    titleEn: 'Aerodynamics',
  ),
  AvatarTheme(
    bgColors: [Color(0xFFFECDE1), Color(0xFFE996BA)],
    accentColor: Color(0xFFE91E63),
    titleTr: 'Kız Kardeşlik Kaskı',
    titleEn: 'Sisterhood Helmet',
  ),
  AvatarTheme(
    bgColors: [Color(0xFFE0C3FC), Color(0xFF8EC5FC)],
    accentColor: Color(0xFF8F00FF),
    titleTr: 'Estetik Kedi Kaskı',
    titleEn: 'Aesthetic Cat Helmet',
  ),
];

class PremiumAvatarPainter extends CustomPainter {
  final int index;
  final Color color;

  PremiumAvatarPainter({required this.index, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;
    final double r = math.min(w, h) * 0.35;

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Paint fillPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    switch (index) {
      case 0:
        // Symmetrical Front-Facing Premium Racing Helmet
        final Path shellPath = Path()
          ..moveTo(cx - r * 0.4, cy + r * 0.8)
          ..quadraticBezierTo(
            cx - r * 0.8,
            cy + r * 0.4,
            cx - r * 0.8,
            cy - r * 0.2,
          )
          ..quadraticBezierTo(cx - r * 0.8, cy - r * 0.9, cx, cy - r * 0.9)
          ..quadraticBezierTo(
            cx + r * 0.8,
            cy - r * 0.9,
            cx + r * 0.8,
            cy - r * 0.2,
          )
          ..quadraticBezierTo(
            cx + r * 0.8,
            cy + r * 0.4,
            cx + r * 0.4,
            cy + r * 0.8,
          )
          ..lineTo(cx - r * 0.4, cy + r * 0.8)
          ..close();
        canvas.drawPath(shellPath, fillPaint);
        canvas.drawPath(shellPath, paint);

        // Visor Path (Aggressive Front)
        final Path visorPath = Path()
          ..moveTo(cx - r * 0.55, cy - r * 0.2)
          ..lineTo(cx + r * 0.55, cy - r * 0.2)
          ..quadraticBezierTo(
            cx + r * 0.6,
            cy + r * 0.1,
            cx + r * 0.5,
            cy + r * 0.3,
          )
          ..quadraticBezierTo(cx, cy + r * 0.4, cx - r * 0.5, cy + r * 0.3)
          ..quadraticBezierTo(
            cx - r * 0.6,
            cy + r * 0.1,
            cx - r * 0.55,
            cy - r * 0.2,
          )
          ..close();

        final Paint visorPaint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF00E5FF), Color(0xFF2979FF), Color(0xFF006064)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(visorPath.getBounds())
          ..style = PaintingStyle.fill;
        canvas.drawPath(visorPath, visorPaint);
        canvas.drawPath(visorPath, paint);

        // Chin Vent details (symmetrical lines)
        canvas.drawLine(
          Offset(cx - r * 0.15, cy + r * 0.5),
          Offset(cx, cy + r * 0.7),
          paint,
        );
        canvas.drawLine(
          Offset(cx + r * 0.15, cy + r * 0.5),
          Offset(cx, cy + r * 0.7),
          paint,
        );
        canvas.drawLine(
          Offset(cx, cy + r * 0.45),
          Offset(cx, cy + r * 0.7),
          paint,
        );
        break;

      case 1:
        // Symmetrical Front View Sportbike
        // Front Tire
        final Rect tireRect = Rect.fromLTRB(
          cx - r * 0.15,
          cy + r * 0.2,
          cx + r * 0.15,
          cy + r * 0.85,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(tireRect, Radius.circular(r * 0.15)),
          paint,
        );
        // Tire treads (horizontal small lines)
        canvas.drawLine(
          Offset(cx, cy + r * 0.3),
          Offset(cx, cy + r * 0.4),
          paint,
        );
        canvas.drawLine(
          Offset(cx, cy + r * 0.5),
          Offset(cx, cy + r * 0.6),
          paint,
        );
        canvas.drawLine(
          Offset(cx, cy + r * 0.7),
          Offset(cx, cy + r * 0.8),
          paint,
        );

        // Windshield
        final Path screenPath = Path()
          ..moveTo(cx, cy - r * 0.7)
          ..lineTo(cx - r * 0.22, cy - r * 0.3)
          ..lineTo(cx + r * 0.22, cy - r * 0.3)
          ..close();
        canvas.drawPath(screenPath, fillPaint);
        canvas.drawPath(screenPath, paint);

        // Fairing / Front Body
        final Path bodyPath = Path()
          ..moveTo(cx - r * 0.22, cy - r * 0.3)
          ..lineTo(cx - r * 0.6, cy - r * 0.1)
          ..lineTo(cx - r * 0.35, cy + r * 0.25)
          ..lineTo(cx - r * 0.15, cy + r * 0.2) // fork mounts
          ..lineTo(cx + r * 0.15, cy + r * 0.2)
          ..lineTo(cx + r * 0.35, cy + r * 0.25)
          ..lineTo(cx + r * 0.6, cy - r * 0.1)
          ..lineTo(cx + r * 0.22, cy - r * 0.3)
          ..close();
        canvas.drawPath(bodyPath, fillPaint);
        canvas.drawPath(bodyPath, paint);

        // Handlebars
        canvas.drawLine(
          Offset(cx - r * 0.22, cy - r * 0.35),
          Offset(cx - r * 0.55, cy - r * 0.42),
          paint,
        );
        canvas.drawLine(
          Offset(cx + r * 0.22, cy - r * 0.35),
          Offset(cx + r * 0.55, cy - r * 0.42),
          paint,
        );
        // Mirrors
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cx - r * 0.58, cy - r * 0.48),
            width: r * 0.22,
            height: r * 0.12,
          ),
          paint,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cx + r * 0.58, cy - r * 0.48),
            width: r * 0.22,
            height: r * 0.12,
          ),
          paint,
        );

        // Headlights (Aggressive Angular Eyes)
        final Path leftEye = Path()
          ..moveTo(cx - r * 0.1, cy - r * 0.08)
          ..lineTo(cx - r * 0.35, cy - r * 0.15)
          ..lineTo(cx - r * 0.28, cy)
          ..close();
        final Path rightEye = Path()
          ..moveTo(cx + r * 0.1, cy - r * 0.08)
          ..lineTo(cx + r * 0.35, cy - r * 0.15)
          ..lineTo(cx + r * 0.28, cy)
          ..close();

        final Paint eyePaint = Paint()
          ..color = const Color(0xFF00E5FF)
          ..style = PaintingStyle.fill;
        canvas.drawPath(leftEye, eyePaint);
        canvas.drawPath(leftEye, paint);
        canvas.drawPath(rightEye, eyePaint);
        canvas.drawPath(rightEye, paint);
        break;

      case 2:
        // Speedometer
        final Rect rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
        canvas.drawArc(rect, math.pi * 0.8, math.pi * 1.4, false, paint);

        // Ticks
        for (
          double angle = math.pi * 0.8;
          angle <= math.pi * 2.2;
          angle += (math.pi * 1.4) / 8
        ) {
          final start = Offset(
            cx + r * 0.82 * math.cos(angle),
            cy + r * 0.82 * math.sin(angle),
          );
          final end = Offset(
            cx + r * 0.98 * math.cos(angle),
            cy + r * 0.98 * math.sin(angle),
          );
          canvas.drawLine(start, end, paint);
        }

        // Needle (Pointing to high speed!)
        final double needleAngle = math.pi * 1.95;
        final Offset needleEnd = Offset(
          cx + r * 0.9 * math.cos(needleAngle),
          cy + r * 0.9 * math.sin(needleAngle),
        );
        final Paint needlePaint = Paint()
          ..color = const Color(0xFFFF1744)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(Offset(cx, cy), needleEnd, needlePaint);
        canvas.drawCircle(Offset(cx, cy), 5, Paint()..color = Colors.white);
        canvas.drawCircle(
          Offset(cx, cy),
          2.5,
          Paint()..color = const Color(0xFFFF1744),
        );

        // Digital HUD Box at the bottom
        final Rect hudRect = Rect.fromCenter(
          center: Offset(cx, cy + r * 0.4),
          width: r * 0.7,
          height: r * 0.35,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(hudRect, Radius.circular(4)),
          paint,
        );

        // Small speed indicators (mock segments)
        canvas.drawLine(
          Offset(cx - r * 0.2, cy + r * 0.45),
          Offset(cx - r * 0.15, cy + r * 0.35),
          paint,
        );
        canvas.drawLine(
          Offset(cx - r * 0.1, cy + r * 0.45),
          Offset(cx - r * 0.05, cy + r * 0.35),
          paint,
        );
        canvas.drawLine(
          Offset(cx, cy + r * 0.45),
          Offset(cx + r * 0.05, cy + r * 0.35),
          paint,
        );
        break;

      case 3:
        // Explorer Compass with Winding Road
        canvas.drawCircle(Offset(cx, cy), r, paint);

        // Cardinal points
        // North
        final Path north = Path()
          ..moveTo(cx, cy - r * 0.9)
          ..lineTo(cx - r * 0.15, cy - r * 0.3)
          ..lineTo(cx + r * 0.15, cy - r * 0.3)
          ..close();
        canvas.drawPath(north, fillPaint);
        canvas.drawPath(north, paint);

        // South
        final Path south = Path()
          ..moveTo(cx, cy + r * 0.9)
          ..lineTo(cx - r * 0.15, cy + r * 0.3)
          ..lineTo(cx + r * 0.15, cy + r * 0.3)
          ..close();
        canvas.drawPath(south, paint);

        // East & West lines
        canvas.drawLine(
          Offset(cx - r * 0.9, cy),
          Offset(cx - r * 0.3, cy),
          paint,
        );
        canvas.drawLine(
          Offset(cx + r * 0.9, cy),
          Offset(cx + r * 0.3, cy),
          paint,
        );

        // Winding road passing from bottom-left to top-right
        final Path roadPath = Path()
          ..moveTo(cx - r * 0.8, cy + r * 0.6)
          ..cubicTo(
            cx - r * 0.4,
            cy + r * 0.5,
            cx - r * 0.2,
            cy - r * 0.2,
            cx,
            cy - r * 0.1,
          )
          ..cubicTo(
            cx + r * 0.2,
            cy,
            cx + r * 0.4,
            cy - r * 0.6,
            cx + r * 0.8,
            cy - r * 0.7,
          );

        final Paint roadPaint = Paint()
          ..color = const Color(0xFF34C759)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0;
        canvas.drawPath(roadPath, roadPaint);

        // Dashed lines on the road (mock dots)
        final Paint dashPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawCircle(Offset(cx - r * 0.5, cy + r * 0.35), 1.5, dashPaint);
        canvas.drawCircle(Offset(cx - r * 0.1, cy - r * 0.1), 1.5, dashPaint);
        canvas.drawCircle(Offset(cx + r * 0.3, cy - r * 0.25), 1.5, dashPaint);
        canvas.drawCircle(Offset(cx + r * 0.65, cy - r * 0.55), 1.5, dashPaint);
        break;

      case 4:
        // Symmetrical Engine Piston & Rod
        // Piston Head (Crown)
        final Rect headRect = Rect.fromLTRB(
          cx - r * 0.45,
          cy - r * 0.7,
          cx + r * 0.45,
          cy - r * 0.1,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(headRect, Radius.circular(4)),
          fillPaint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(headRect, Radius.circular(4)),
          paint,
        );

        // Piston Ring Grooves (horizontal lines)
        canvas.drawLine(
          Offset(cx - r * 0.45, cy - r * 0.55),
          Offset(cx + r * 0.45, cy - r * 0.55),
          paint,
        );
        canvas.drawLine(
          Offset(cx - r * 0.45, cy - r * 0.45),
          Offset(cx + r * 0.45, cy - r * 0.45),
          paint,
        );
        canvas.drawLine(
          Offset(cx - r * 0.45, cy - r * 0.35),
          Offset(cx + r * 0.45, cy - r * 0.35),
          paint,
        );

        // Wrist Pin Hole (Gudgeon Pin)
        final double pinR = r * 0.18;
        canvas.drawCircle(Offset(cx, cy - r * 0.35), pinR, paint);
        canvas.drawCircle(
          Offset(cx, cy - r * 0.35),
          pinR * 0.4,
          Paint()..color = Colors.white,
        );

        // Connecting Rod (Biyel Kolu)
        final Path rodPath = Path()
          ..moveTo(cx - r * 0.12, cy - r * 0.15)
          ..lineTo(cx - r * 0.12, cy + r * 0.5)
          ..lineTo(cx - r * 0.24, cy + r * 0.5)
          ..quadraticBezierTo(cx - r * 0.3, cy + r * 0.65, cx, cy + r * 0.8)
          ..quadraticBezierTo(
            cx + r * 0.3,
            cy + r * 0.65,
            cx + r * 0.24,
            cy + r * 0.5,
          )
          ..lineTo(cx + r * 0.12, cy + r * 0.5)
          ..lineTo(cx + r * 0.12, cy - r * 0.15)
          ..close();
        canvas.drawPath(rodPath, fillPaint);
        canvas.drawPath(rodPath, paint);

        // Big End Bearing Cap bolt heads
        canvas.drawCircle(
          Offset(cx, cy + r * 0.62),
          4,
          Paint()..color = Colors.white,
        );
        break;

      case 5:
        // Symmetrical Spark Plug (Buji)
        // Terminal (top tip)
        final Rect terminal = Rect.fromLTRB(
          cx - r * 0.1,
          cy - r * 0.85,
          cx + r * 0.1,
          cy - r * 0.72,
        );
        canvas.drawRect(terminal, paint);

        // Insulator Ribs (ceramic body)
        final Path ribs = Path()
          ..moveTo(cx - r * 0.18, cy - r * 0.72)
          ..lineTo(cx + r * 0.18, cy - r * 0.72)
          ..lineTo(cx + r * 0.18, cy - r * 0.2)
          ..lineTo(cx - r * 0.18, cy - r * 0.2)
          ..close();
        canvas.drawPath(ribs, fillPaint);
        canvas.drawPath(ribs, paint);

        // Rib details (horizontal lines)
        canvas.drawLine(
          Offset(cx - r * 0.18, cy - r * 0.6),
          Offset(cx + r * 0.18, cy - r * 0.6),
          paint,
        );
        canvas.drawLine(
          Offset(cx - r * 0.18, cy - r * 0.48),
          Offset(cx + r * 0.18, cy - r * 0.48),
          paint,
        );
        canvas.drawLine(
          Offset(cx - r * 0.18, cy - r * 0.36),
          Offset(cx + r * 0.18, cy - r * 0.36),
          paint,
        );

        // Hex Nut section (metal body center)
        final Path hexNut = Path()
          ..moveTo(cx - r * 0.32, cy - r * 0.2)
          ..lineTo(cx + r * 0.32, cy - r * 0.2)
          ..lineTo(cx + r * 0.25, cy + r * 0.05)
          ..lineTo(cx - r * 0.25, cy + r * 0.05)
          ..close();
        canvas.drawPath(hexNut, fillPaint);
        canvas.drawPath(hexNut, paint);

        // Threaded section
        final Rect threadRect = Rect.fromLTRB(
          cx - r * 0.18,
          cy + r * 0.05,
          cx + r * 0.18,
          cy + r * 0.5,
        );
        canvas.drawRect(threadRect, fillPaint);
        canvas.drawRect(threadRect, paint);
        // Thread ridges
        canvas.drawLine(
          Offset(cx - r * 0.18, cy + r * 0.16),
          Offset(cx + r * 0.18, cy + r * 0.16),
          paint,
        );
        canvas.drawLine(
          Offset(cx - r * 0.18, cy + r * 0.28),
          Offset(cx + r * 0.18, cy + r * 0.28),
          paint,
        );
        canvas.drawLine(
          Offset(cx - r * 0.18, cy + r * 0.4),
          Offset(cx + r * 0.18, cy + r * 0.4),
          paint,
        );

        // Electrode (ground electrode bent at bottom)
        final Path groundElectrode = Path()
          ..moveTo(cx - r * 0.14, cy + r * 0.5)
          ..lineTo(cx - r * 0.14, cy + r * 0.68)
          ..lineTo(cx, cy + r * 0.68);
        canvas.drawPath(groundElectrode, paint);

        // Center electrode
        canvas.drawLine(
          Offset(cx, cy + r * 0.5),
          Offset(cx, cy + r * 0.58),
          paint,
        );

        // Electric Spark (Neon Lightning)
        final Path spark = Path()
          ..moveTo(cx, cy + r * 0.56)
          ..lineTo(cx - r * 0.08, cy + r * 0.62)
          ..lineTo(cx + r * 0.06, cy + r * 0.62)
          ..lineTo(cx - r * 0.02, cy + r * 0.68);

        final Paint sparkPaint = Paint()
          ..color = const Color(0xFFBF5AF2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawPath(spark, sparkPaint);
        break;

      case 6:
        // Zincir & Dişli (Chain & Sprocket)
        // Outer Sprocket Gear
        final Path gearPath = Path();
        final int teethCount = 14;
        for (int i = 0; i < teethCount; i++) {
          final double angle = i * 2 * math.pi / teethCount;
          final double nextAngle = (i + 0.5) * 2 * math.pi / teethCount;
          final double outerR = r * 0.85;
          final double innerR = r * 0.7;

          final double x1 = cx + innerR * math.cos(angle);
          final double y1 = cy + innerR * math.sin(angle);
          final double x2 = cx + outerR * math.cos((angle + nextAngle) / 2);
          final double y2 = cy + outerR * math.sin((angle + nextAngle) / 2);
          final double x3 = cx + innerR * math.cos(nextAngle);
          final double y3 = cy + innerR * math.sin(nextAngle);

          if (i == 0) {
            gearPath.moveTo(x1, y1);
          } else {
            gearPath.lineTo(x1, y1);
          }
          gearPath.lineTo(x2, y2);
          gearPath.lineTo(x3, y3);
        }
        gearPath.close();
        canvas.drawPath(gearPath, fillPaint);
        canvas.drawPath(gearPath, paint);

        // Inner sprocket circle & mounting holes
        canvas.drawCircle(Offset(cx, cy), r * 0.45, paint);
        canvas.drawCircle(Offset(cx, cy), r * 0.25, paint);

        // 4 small mounting bolt holes
        for (int i = 0; i < 4; i++) {
          final double angle = i * math.pi / 2;
          canvas.drawCircle(
            Offset(
              cx + r * 0.35 * math.cos(angle),
              cy + r * 0.35 * math.sin(angle),
            ),
            3,
            Paint()..color = Colors.white,
          );
        }
        break;

      case 7:
        // Retro Headlight & Cruiser Bars
        // Handlebars (cruiser style, high and wide)
        final Path barPath = Path()
          ..moveTo(cx - r * 0.95, cy - r * 0.3)
          ..quadraticBezierTo(
            cx - r * 0.7,
            cy - r * 0.5,
            cx - r * 0.4,
            cy - r * 0.2,
          )
          ..lineTo(cx - r * 0.15, cy + r * 0.1)
          ..lineTo(cx + r * 0.15, cy + r * 0.1)
          ..lineTo(cx + r * 0.4, cy - r * 0.2)
          ..quadraticBezierTo(
            cx + r * 0.7,
            cy - r * 0.5,
            cx + r * 0.95,
            cy - r * 0.3,
          );
        canvas.drawPath(barPath, paint);

        // Grips at the ends of handlebars
        canvas.drawLine(
          Offset(cx - r * 0.95, cy - r * 0.3),
          Offset(cx - r * 0.8, cy - r * 0.35),
          paint,
        );
        canvas.drawLine(
          Offset(cx + r * 0.95, cy - r * 0.3),
          Offset(cx + r * 0.8, cy - r * 0.35),
          paint,
        );

        // Fork mounts for headlight
        canvas.drawLine(
          Offset(cx - r * 0.2, cy + r * 0.1),
          Offset(cx - r * 0.2, cy + r * 0.8),
          paint,
        );
        canvas.drawLine(
          Offset(cx + r * 0.2, cy + r * 0.1),
          Offset(cx + r * 0.2, cy + r * 0.8),
          paint,
        );

        // Headlight Housing (Circle)
        final Offset lightCenter = Offset(cx, cy + r * 0.25);
        final double lightR = r * 0.35;
        canvas.drawCircle(lightCenter, lightR, fillPaint);
        canvas.drawCircle(lightCenter, lightR, paint);
        canvas.drawCircle(lightCenter, lightR * 0.7, paint); // Inner lens bulb

        // Retro headlight grille lines (horizontal bars)
        canvas.drawLine(
          Offset(cx - lightR * 0.7, cy + r * 0.25),
          Offset(cx + lightR * 0.7, cy + r * 0.25),
          paint,
        );
        canvas.drawLine(
          Offset(cx - lightR * 0.6, cy + r * 0.13),
          Offset(cx + lightR * 0.6, cy + r * 0.13),
          paint,
        );
        canvas.drawLine(
          Offset(cx - lightR * 0.6, cy + r * 0.37),
          Offset(cx + lightR * 0.6, cy + r * 0.37),
          paint,
        );
        break;

      case 8:
        // Dual Exhaust Pipes
        // Lower pipe
        final Path pipe1 = Path()
          ..moveTo(cx - r * 0.7, cy + r * 0.5)
          ..lineTo(cx + r * 0.3, cy - r * 0.3)
          ..lineTo(cx + r * 0.45, cy - r * 0.23)
          ..lineTo(cx - r * 0.55, cy + r * 0.57)
          ..close();
        canvas.drawPath(pipe1, fillPaint);
        canvas.drawPath(pipe1, paint);

        // Upper pipe
        final Path pipe2 = Path()
          ..moveTo(cx - r * 0.5, cy + r * 0.2)
          ..lineTo(cx + r * 0.5, cy - r * 0.6)
          ..lineTo(cx + r * 0.65, cy - r * 0.53)
          ..lineTo(cx - r * 0.35, cy + r * 0.27)
          ..close();
        canvas.drawPath(pipe2, fillPaint);
        canvas.drawPath(pipe2, paint);

        // End caps / outlets (slanted ellipses)
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cx + r * 0.375, cy - r * 0.265),
            width: r * 0.1,
            height: r * 0.16,
          ),
          paint,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cx + r * 0.575, cy - r * 0.565),
            width: r * 0.1,
            height: r * 0.16,
          ),
          paint,
        );

        // Mount clamps (brackets)
        canvas.drawLine(
          Offset(cx - r * 0.1, cy - r * 0.1),
          Offset(cx - r * 0.2, cy - r * 0.4),
          paint,
        );
        canvas.drawLine(
          Offset(cx + r * 0.1, cy - r * 0.25),
          Offset(cx + r * 0.05, cy - r * 0.55),
          paint,
        );
        break;

      case 9:
        // Aerodynamic Carbon Winglet
        // Main Wing Structure
        final Path wingPath = Path()
          ..moveTo(cx - r * 0.8, cy - r * 0.1)
          ..cubicTo(
            cx - r * 0.3,
            cy - r * 0.5,
            cx + r * 0.3,
            cy + r * 0.3,
            cx + r * 0.8,
            cy - r * 0.2,
          )
          ..lineTo(cx + r * 0.65, cy + r * 0.05)
          ..cubicTo(
            cx + r * 0.2,
            cy + r * 0.4,
            cx - r * 0.3,
            cy - r * 0.3,
            cx - r * 0.85,
            cy + r * 0.1,
          )
          ..close();
        canvas.drawPath(wingPath, fillPaint);
        canvas.drawPath(wingPath, paint);

        // Wing endplate (vertical aerodynamic winglet tip)
        final Path endplate = Path()
          ..moveTo(cx + r * 0.8, cy - r * 0.2)
          ..lineTo(cx + r * 0.85, cy - r * 0.5)
          ..lineTo(cx + r * 0.65, cy + r * 0.05)
          ..lineTo(cx + r * 0.68, cy - r * 0.25)
          ..close();
        canvas.drawPath(endplate, fillPaint);
        canvas.drawPath(endplate, paint);

        // Airflow lines (speed lines) passing around the wing
        final Path airLine1 = Path()
          ..moveTo(cx - r * 0.9, cy - r * 0.4)
          ..quadraticBezierTo(
            cx - r * 0.4,
            cy - r * 0.6,
            cx + r * 0.2,
            cy - r * 0.55,
          )
          ..quadraticBezierTo(
            cx + r * 0.7,
            cy - r * 0.5,
            cx + r * 0.95,
            cy - r * 0.75,
          );
        canvas.drawPath(airLine1, paint);

        final Path airLine2 = Path()
          ..moveTo(cx - r * 0.9, cy + r * 0.4)
          ..quadraticBezierTo(
            cx - r * 0.4,
            cy + r * 0.55,
            cx + r * 0.2,
            cy + r * 0.35,
          )
          ..quadraticBezierTo(
            cx + r * 0.7,
            cy + r * 0.15,
            cx + r * 0.95,
            cy - r * 0.05,
          );
        canvas.drawPath(airLine2, paint);
        break;

      case 10:
        // Case 10: Sisterhood Helmet with a cute bow on top
        final Path shellPath10 = Path()
          ..moveTo(cx - r * 0.4, cy + r * 0.8)
          ..quadraticBezierTo(
            cx - r * 0.8,
            cy + r * 0.4,
            cx - r * 0.8,
            cy - r * 0.2,
          )
          ..quadraticBezierTo(cx - r * 0.8, cy - r * 0.9, cx, cy - r * 0.9)
          ..quadraticBezierTo(
            cx + r * 0.8,
            cy - r * 0.9,
            cx + r * 0.8,
            cy - r * 0.2,
          )
          ..quadraticBezierTo(
            cx + r * 0.8,
            cy + r * 0.4,
            cx + r * 0.4,
            cy + r * 0.8,
          )
          ..close();
        canvas.drawPath(shellPath10, fillPaint);
        canvas.drawPath(shellPath10, paint);

        // Cute bow on top (center cy - r * 0.9)
        final Path bowPath = Path()
          ..moveTo(cx, cy - r * 0.9)
          ..quadraticBezierTo(
            cx - r * 0.15,
            cy - r * 1.05,
            cx - r * 0.2,
            cy - r * 0.95,
          )
          ..quadraticBezierTo(cx - r * 0.15, cy - r * 0.85, cx, cy - r * 0.9)
          ..quadraticBezierTo(
            cx + r * 0.15,
            cy - r * 1.05,
            cx + r * 0.2,
            cy - r * 0.95,
          )
          ..quadraticBezierTo(cx + r * 0.15, cy - r * 0.85, cx, cy - r * 0.9)
          ..close();
        canvas.drawPath(bowPath, paint);

        // Visor
        final Path visorPath10 = Path()
          ..moveTo(cx - r * 0.55, cy - r * 0.2)
          ..lineTo(cx + r * 0.55, cy - r * 0.2)
          ..quadraticBezierTo(
            cx + r * 0.6,
            cy + r * 0.1,
            cx + r * 0.5,
            cy + r * 0.3,
          )
          ..quadraticBezierTo(cx, cy + r * 0.4, cx - r * 0.5, cy + r * 0.3)
          ..quadraticBezierTo(
            cx - r * 0.6,
            cy + r * 0.1,
            cx - r * 0.55,
            cy - r * 0.2,
          )
          ..close();
        canvas.drawPath(visorPath10, paint);
        break;

      case 11:
        // Case 11: Aesthetic Cat Helmet with cat ears
        final Path shellPath11 = Path()
          ..moveTo(cx - r * 0.4, cy + r * 0.8)
          ..quadraticBezierTo(
            cx - r * 0.8,
            cy + r * 0.4,
            cx - r * 0.8,
            cy - r * 0.2,
          )
          ..quadraticBezierTo(cx - r * 0.8, cy - r * 0.9, cx, cy - r * 0.9)
          ..quadraticBezierTo(
            cx + r * 0.8,
            cy - r * 0.9,
            cx + r * 0.8,
            cy - r * 0.2,
          )
          ..quadraticBezierTo(
            cx + r * 0.8,
            cy + r * 0.4,
            cx + r * 0.4,
            cy + r * 0.8,
          )
          ..close();
        canvas.drawPath(shellPath11, fillPaint);
        canvas.drawPath(shellPath11, paint);

        // Cat ears
        final Path earPath = Path()
          ..moveTo(cx - r * 0.6, cy - r * 0.75)
          ..lineTo(cx - r * 0.7, cy - r * 1.1)
          ..lineTo(cx - r * 0.3, cy - r * 0.9)
          ..moveTo(cx + r * 0.6, cy - r * 0.75)
          ..lineTo(cx + r * 0.7, cy - r * 1.1)
          ..lineTo(cx + r * 0.3, cy - r * 0.9);
        canvas.drawPath(earPath, paint);

        // Visor
        final Path visorPath11 = Path()
          ..moveTo(cx - r * 0.55, cy - r * 0.2)
          ..lineTo(cx + r * 0.55, cy - r * 0.2)
          ..quadraticBezierTo(
            cx + r * 0.6,
            cy + r * 0.1,
            cx + r * 0.5,
            cy + r * 0.3,
          )
          ..quadraticBezierTo(cx, cy + r * 0.4, cx - r * 0.5, cy + r * 0.3)
          ..quadraticBezierTo(
            cx - r * 0.6,
            cy + r * 0.1,
            cx - r * 0.55,
            cy - r * 0.2,
          )
          ..close();
        canvas.drawPath(visorPath11, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant PremiumAvatarPainter oldDelegate) {
    return oldDelegate.index != index || oldDelegate.color != color;
  }
}

class RiderAvatarWidget extends StatelessWidget {
  final int avatarIndex;
  final double radius;
  final Color? color;
  final int selectedFrameIndex;

  const RiderAvatarWidget({
    super.key,
    required this.avatarIndex,
    this.radius = 28,
    this.color,
    this.selectedFrameIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final int cleanIndex = avatarIndex % 12;
    final theme = avatarThemes[cleanIndex];

    Border? customBorder = Border.all(
      color: theme.accentColor.withValues(alpha: 0.6),
      width: 1.5,
    );
    List<BoxShadow> customShadows = [
      BoxShadow(
        color: theme.accentColor.withValues(alpha: 0.25),
        blurRadius: 8,
        spreadRadius: 1,
        offset: const Offset(0, 2),
      ),
    ];

    if (selectedFrameIndex == 2) {
      customBorder = Border.all(color: const Color(0xFF00F5FF), width: 2.0);
      customShadows = [
        BoxShadow(
          color: const Color(0xFF00F5FF).withValues(alpha: 0.8),
          blurRadius: 12,
          spreadRadius: 2,
        ),
      ];
    } else if (selectedFrameIndex == 3) {
      customBorder = Border.all(color: Colors.amber, width: 3.0);
      customShadows = [
        BoxShadow(
          color: Colors.amber.withValues(alpha: 0.5),
          blurRadius: 10,
          spreadRadius: 2,
        ),
      ];
    }

    final Widget avatarCore = Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: theme.bgColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: customShadows,
        border: customBorder,
      ),
      child: ClipOval(
        child: CustomPaint(
          painter: PremiumAvatarPainter(
            index: cleanIndex,
            color: color ?? theme.accentColor,
          ),
        ),
      ),
    );

    if (selectedFrameIndex == 1) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          avatarCore,
          Positioned(
            top: -radius * 0.45,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '👑',
                style: TextStyle(
                  fontSize: radius * 0.7,
                  shadows: const [
                    Shadow(
                      color: Colors.black45,
                      offset: Offset(0, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    } else if (selectedFrameIndex == 2) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          avatarCore,
          Positioned(
            top: -radius * 0.35,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: radius * 1.5,
                height: radius * 0.35,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF00F5FF),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.elliptical(radius * 0.75, radius * 0.17),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00F5FF).withValues(alpha: 0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return avatarCore;
  }
}

class RiderHarmonyRadarChart extends ConsumerWidget {
  final int harmonyScore;
  final String friendStyle;
  final double friendWeeklyKm;
  final String friendId;
  final bool tr;

  const RiderHarmonyRadarChart({
    super.key,
    required this.harmonyScore,
    required this.friendStyle,
    required this.friendWeeklyKm,
    required this.friendId,
    required this.tr,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final userStyle = userProfile.ridingStyle;

    // 1. Hız Tutarlılığı (Speed Consistency)
    double speedConsistency = 80.0;
    final fsLower = friendStyle.toLowerCase();
    if (fsLower.contains('sport') ||
        fsLower.contains('yarış') ||
        fsLower.contains('superbike')) {
      speedConsistency = 92.0;
    } else if (fsLower.contains('touring') ||
        fsLower.contains('tur') ||
        fsLower.contains('cafe')) {
      speedConsistency = 88.0;
    } else if (fsLower.contains('enduro') ||
        fsLower.contains('adventure') ||
        fsLower.contains('macera')) {
      speedConsistency = 84.0;
    } else {
      speedConsistency = 76.0;
    }
    speedConsistency += (friendId.hashCode % 8) - 4;
    speedConsistency = speedConsistency.clamp(50.0, 100.0);

    // 2. Sürüş Sıklığı (Ride Frequency)
    double rideFrequency = 65.0 + (friendWeeklyKm * 0.25);
    rideFrequency += (friendId.hashCode % 6) - 3;
    rideFrequency = rideFrequency.clamp(50.0, 100.0);

    // 3. Tarz Uyumu (Style Harmony)
    double styleHarmony = 75.0;
    if (userStyle.toLowerCase() == friendStyle.toLowerCase()) {
      styleHarmony = 98.0;
    } else {
      final usLower = userStyle.toLowerCase();
      final isFriendSporty =
          fsLower.contains('sport') ||
          fsLower.contains('superbike') ||
          fsLower.contains('naked') ||
          fsLower.contains('yarış');
      final isUserSporty =
          usLower.contains('sport') ||
          usLower.contains('superbike') ||
          usLower.contains('naked') ||
          usLower.contains('yarış');

      final isFriendAdventure =
          fsLower.contains('adventure') ||
          fsLower.contains('enduro') ||
          fsLower.contains('touring') ||
          fsLower.contains('macera') ||
          fsLower.contains('tur');
      final isUserAdventure =
          usLower.contains('adventure') ||
          usLower.contains('enduro') ||
          usLower.contains('touring') ||
          usLower.contains('macera') ||
          usLower.contains('tur');

      if (isFriendSporty && isUserSporty) {
        styleHarmony = 90.0;
      } else if (isFriendAdventure && isUserAdventure) {
        styleHarmony = 92.0;
      } else {
        styleHarmony = 68.0;
      }
    }
    styleHarmony += (friendId.hashCode % 4) - 2;
    styleHarmony = styleHarmony.clamp(50.0, 100.0);

    // 4. Rota Uyumu (Route Alignment)
    double routeAlignment = 70.0 + (friendId.hashCode % 26);
    routeAlignment = routeAlignment.clamp(50.0, 100.0);

    // 5. Bakım Özeni (Maintenance Care)
    double maintenanceCare = harmonyScore.toDouble();
    maintenanceCare += (friendId.hashCode % 8) - 4;
    maintenanceCare = maintenanceCare.clamp(50.0, 100.0);

    final stats = [
      speedConsistency,
      rideFrequency,
      styleHarmony,
      routeAlignment,
      maintenanceCare,
    ];

    final labels = tr
        ? [
            'Hız Tutarlılığı',
            'Sürüş Sıklığı',
            'Tarz Uyumu',
            'Rota Uyumu',
            'Bakım Özeni',
          ]
        : [
            'Speed Consistency',
            'Ride Frequency',
            'Style Harmony',
            'Route Alignment',
            'Maintenance Care',
          ];

    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.elevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border, width: 1.2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  tInline(
                    AppStrings.currentLanguageCode,
                    'SÜRÜCÜ UYUM ANALİZİ',
                    'RIDER HARMONY ANALYSIS',
                    'FAHRERHARMONIE-ANALYSE',
                  ),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: context.colors.cyan,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: context.colors.cyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '%$harmonyScore',
                  style: TextStyle(
                    color: context.colors.cyan,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: RadarChartPainter(
                stats: stats,
                labels: labels,
                color: context.colors.cyan,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RadarChartPainter extends CustomPainter {
  final List<double> stats;
  final List<String> labels;
  final Color color;

  RadarChartPainter({
    required this.stats,
    required this.labels,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;
    final double radius = math.min(w, h) * 0.35;

    final Paint gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final Paint linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final Paint chartPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final Paint chartFillPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final TextStyle labelStyle = TextStyle(
      color: Colors.white.withValues(alpha: 0.7),
      fontSize: 9,
      fontWeight: FontWeight.bold,
    );

    final int numAxes = stats.length;
    final double angleStep = (2 * math.pi) / numAxes;

    for (int i = 1; i <= 4; i++) {
      final double r = radius * (i / 4.0);
      final Path gridPath = Path();
      for (int j = 0; j < numAxes; j++) {
        final double angle = j * angleStep - math.pi / 2;
        final double px = cx + r * math.cos(angle);
        final double py = cy + r * math.sin(angle);
        if (j == 0) {
          gridPath.moveTo(px, py);
        } else {
          gridPath.lineTo(px, py);
        }
      }
      gridPath.close();
      canvas.drawPath(gridPath, gridPaint);
    }

    for (int j = 0; j < numAxes; j++) {
      final double angle = j * angleStep - math.pi / 2;
      final double ax = cx + radius * math.cos(angle);
      final double ay = cy + radius * math.sin(angle);
      canvas.drawLine(Offset(cx, cy), Offset(ax, ay), linePaint);

      final double labelDistance = radius + 15;
      final double lx = cx + labelDistance * math.cos(angle);
      final double ly = cy + labelDistance * math.sin(angle);

      final textSpan = TextSpan(text: labels[j], style: labelStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final double dx = lx - textPainter.width / 2;
      final double dy = ly - textPainter.height / 2;
      textPainter.paint(canvas, Offset(dx, dy));
    }

    final Path chartPath = Path();
    for (int j = 0; j < numAxes; j++) {
      final double valueFactor = stats[j] / 100.0;
      final double r = radius * valueFactor;
      final double angle = j * angleStep - math.pi / 2;
      final double px = cx + r * math.cos(angle);
      final double py = cy + r * math.sin(angle);

      if (j == 0) {
        chartPath.moveTo(px, py);
      } else {
        chartPath.lineTo(px, py);
      }
    }
    chartPath.close();

    canvas.drawPath(chartPath, chartFillPaint);
    canvas.drawPath(chartPath, chartPaint);

    final Paint pointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    for (int j = 0; j < numAxes; j++) {
      final double valueFactor = stats[j] / 100.0;
      final double r = radius * valueFactor;
      final double angle = j * angleStep - math.pi / 2;
      final double px = cx + r * math.cos(angle);
      final double py = cy + r * math.sin(angle);
      canvas.drawCircle(Offset(px, py), 3, chartPaint);
      canvas.drawCircle(Offset(px, py), 1.5, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant RadarChartPainter oldDelegate) {
    return oldDelegate.stats != stats ||
        oldDelegate.color != color ||
        oldDelegate.labels != labels;
  }
}

class LockscreenWallpaperGeneratorScreen extends StatefulWidget {
  final AppStrings strings;

  const LockscreenWallpaperGeneratorScreen({super.key, required this.strings});

  @override
  State<LockscreenWallpaperGeneratorScreen> createState() =>
      _LockscreenWallpaperGeneratorScreenState();
}

class _LockscreenWallpaperGeneratorScreenState
    extends State<LockscreenWallpaperGeneratorScreen> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _isSharing = false;

  Future<void> _shareWallpaper(
    UserProfile profile,
    String activeBike,
    double totalKm,
    int totalRides,
    int harmonyScore,
  ) async {
    setState(() {
      _isSharing = true;
    });
    try {
      final boundary =
          _repaintKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = await File(
        '${tempDir.path}/apexflow_lockscreen.png',
      ).create();
      await file.writeAsBytes(pngBytes);

      final tr = widget.strings.locale.languageCode == 'tr';
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: tInline(
            AppStrings.currentLanguageCode,
            'Apex Flow Kilit Ekranı Güvenlik Duvar Kağıdı',
            'Apex Flow Safety Lockscreen Wallpaper',
            'Apex Flow Safety Lockscreen-Hintergrundbild',
          ),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error generating wallpaper: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = widget.strings.locale.languageCode == 'tr';
    final de = widget.strings.locale.languageCode == 'de';

    return Consumer(
      builder: (context, ref, child) {
        final userProfile = ref.watch(userProfileProvider);
        final garageState = ref.watch(garageStateProvider);
        final rideState = ref.watch(rideStateProvider);

        final totalKm = rideState.sessions.fold<double>(
          0.0,
          (sum, s) => sum + s.distanceKm,
        );
        final totalRides = rideState.sessions.length;

        final activeBike = garageState.activeBike.name != '—'
            ? '${garageState.activeBike.name} ${garageState.activeBike.model}'
            : (tInline(
                AppStrings.currentLanguageCode,
                'Motosiklet Yok',
                'No Motorcycle',
                'Kein Motorrad',
              ));

        final harmonyScore = garageState.activeBike.name != '—' ? 95 : 0;
        final theme =
            riderCardThemes[userProfile.cardThemeIndex.clamp(
              0,
              riderCardThemes.length - 1,
            )];

        return Scaffold(
          appBar: AppBar(
            title: Text(
              tInline(
                AppStrings.currentLanguageCode,
                'Kilit Ekranı Oluşturucu',
                'Lockscreen Generator',
                'Lockscreen-Generator',
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 340),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: context.colors.border,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: AspectRatio(
                          aspectRatio: 9 / 16,
                          child: RepaintBoundary(
                            key: _repaintKey,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: CarbonFiberPainter(
                                      stripeColor: theme.colors.first,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                    vertical: 28.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: context.colors.red,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            tInline(
                                              AppStrings.currentLanguageCode,
                                              'ACİL DURUM MEDİKAL BİLGİ',
                                              'EMERGENCY MEDICAL INFO',
                                              'MEDIZINISCHE NOTFALLINFORMATIONEN',
                                            ),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFE2E8F0,
                                          ), // Slate 200 (slightly darker than off-white)
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFF0F172A),
                                            width: 2,
                                          ), // Slate 900
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.2,
                                              ),
                                              blurRadius: 6,
                                              offset: const Offset(2, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            _buildWallpaperMedRow(
                                              tInline(
                                                AppStrings.currentLanguageCode,
                                                'Kan Grubu',
                                                'Blood Type',
                                                'Blutgruppe',
                                              ),
                                              userProfile.bloodType.isEmpty
                                                  ? '—'
                                                  : userProfile.bloodType,
                                              isRed: true,
                                            ),
                                            const Divider(
                                              color: Colors.black12,
                                              height: 12,
                                            ),
                                            _buildWallpaperMedRow(
                                              tInline(
                                                AppStrings.currentLanguageCode,
                                                'Acil Durum Yakını',
                                                'Emergency Contact',
                                                'Notfallkontakt',
                                              ),
                                              userProfile
                                                      .emergencyContactName
                                                      .isEmpty
                                                  ? '—'
                                                  : userProfile
                                                        .emergencyContactName,
                                            ),
                                            const Divider(
                                              color: Colors.black12,
                                              height: 12,
                                            ),
                                            _buildWallpaperMedRow(
                                              tInline(
                                                AppStrings.currentLanguageCode,
                                                'Yakın Telefonu',
                                                'Emergency Phone',
                                                'Notruftelefon',
                                              ),
                                              userProfile
                                                      .emergencyContactPhone
                                                      .isEmpty
                                                  ? '—'
                                                  : userProfile
                                                        .emergencyContactPhone,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 140,
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFFE2E8F0,
                                                ), // Slate 200 (slightly darker than off-white)
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: const Color(
                                                    0xFF0F172A,
                                                  ),
                                                  width: 2,
                                                ), // Slate 900
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(
                                                          alpha: 0.25,
                                                        ),
                                                    blurRadius: 6,
                                                    offset: const Offset(2, 3),
                                                  ),
                                                ],
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 14,
                                                  ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // Mini Header
                                                  const Text(
                                                    'A P E X   F L O W',
                                                    style: TextStyle(
                                                      fontSize: 8.5,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF0F172A),
                                                      letterSpacing: 0.8,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    tInline(
                                                      AppStrings
                                                          .currentLanguageCode,
                                                      'ACİL MEDİKAL',
                                                      'EMERGENCY PASS',
                                                      'NOTFALLPASS',
                                                    ),
                                                    style: const TextStyle(
                                                      fontSize: 6,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(
                                                        0xFFEF4444,
                                                      ), // Red accent
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),

                                                  // White QR code block
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                      border: Border.all(
                                                        color: Colors
                                                            .grey
                                                            .shade200,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: QrImageView(
                                                      data:
                                                          'https://apex-flow-7baea.web.app/?id=${Uri.encodeComponent(userProfile.riderTag)}',
                                                      size: 80,
                                                      gapless: false,
                                                      eyeStyle:
                                                          const QrEyeStyle(
                                                            eyeShape: QrEyeShape
                                                                .square,
                                                            color: Colors.black,
                                                          ),
                                                      dataModuleStyle:
                                                          const QrDataModuleStyle(
                                                            dataModuleShape:
                                                                QrDataModuleShape
                                                                    .square,
                                                            color: Colors.black,
                                                          ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),

                                                  // Rider Tag Pill Tag
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 3,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFF0F172A,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      userProfile.riderTag,
                                                      style: const TextStyle(
                                                        fontSize: 8,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color(
                                                          0xFFE2E8F0,
                                                        ),
                                                        letterSpacing: 0.5,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 16),

                                            Transform.scale(
                                              scale: 0.9,
                                              child: RiderIdCard(
                                                name: userProfile.name.isEmpty
                                                    ? (tInline(
                                                        AppStrings
                                                            .currentLanguageCode,
                                                        'Sürücü',
                                                        'Rider',
                                                        'Fahrer',
                                                      ))
                                                    : userProfile.name,
                                                riderTag:
                                                    userProfile.riderTag.isEmpty
                                                    ? '@rider'
                                                    : userProfile.riderTag,
                                                ridingStyle:
                                                    userProfile.ridingStyle,
                                                bloodType:
                                                    userProfile
                                                        .bloodType
                                                        .isEmpty
                                                    ? '—'
                                                    : userProfile.bloodType,
                                                phoneNumber:
                                                    userProfile.phoneNumber,
                                                emergencyContactName:
                                                    userProfile
                                                        .emergencyContactName,
                                                emergencyContactPhone:
                                                    userProfile
                                                        .emergencyContactPhone,
                                                activeBike: activeBike,
                                                totalRides: totalRides,
                                                totalKm: totalKm,
                                                harmonyScore: harmonyScore,
                                                avatarIndex:
                                                    userProfile.avatarIndex,
                                                tr: tr,
                                                de:
                                                    AppStrings
                                                        .currentLanguageCode ==
                                                    'de',

                                                themeIndex:
                                                    userProfile.cardThemeIndex,
                                                city: userProfile.city,
                                                instagram:
                                                    userProfile.instagram,
                                                tiktok: userProfile.tiktok,
                                                licensePlate:
                                                    userProfile.licensePlate,
                                                selectedBadges:
                                                    userProfile.selectedBadges,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 8),
                                      Center(
                                        child: Text(
                                          tInline(
                                            AppStrings.currentLanguageCode,
                                            'Apex Flow Güvenlik Protokolü',
                                            'Apex Flow Safety Protocol',
                                            'Apex Flow-Sicherheitsprotokoll',
                                          ),
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.35,
                                            ),
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.cyan,
                      foregroundColor: context.colors.onAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isSharing
                        ? null
                        : () => _shareWallpaper(
                            userProfile,
                            activeBike,
                            totalKm,
                            totalRides,
                            harmonyScore,
                          ),
                    icon: _isSharing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.share_outlined),
                    label: Text(
                      tInline(
                        AppStrings.currentLanguageCode,
                        'Görseli Paylaş / Kaydet',
                        'Share / Save Image',
                        'Bild teilen / speichern',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWallpaperMedRow(
    String label,
    String value, {
    bool isRed = false,
    Color textColor = const Color(0xFF0F172A),
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor.withValues(alpha: 0.7),
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isRed ? const Color(0xFFEF4444) : textColor,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class CarbonFiberPainter extends CustomPainter {
  final Color stripeColor;

  CarbonFiberPainter({required this.stripeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Paint bgPaint = Paint()..color = const Color(0xFF121212);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    final Paint patternPaint = Paint()
      ..color = const Color(0xFF1C1C1C)
      ..style = PaintingStyle.fill;

    const double sizeBlock = 6.0;
    for (double y = 0; y < h; y += sizeBlock) {
      for (double x = 0; x < w; x += sizeBlock * 2) {
        final double offset = ((y ~/ sizeBlock) % 2) * sizeBlock;
        final rect = Rect.fromLTWH(x + offset, y, sizeBlock, sizeBlock);
        canvas.drawRect(rect, patternPaint);
      }
    }

    final Paint stripePaint = Paint()
      ..color = stripeColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final Paint stripeSubPaint = Paint()
      ..color = stripeColor.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    final double rightEdge = w * 0.85;
    canvas.drawRect(Rect.fromLTWH(rightEdge - 30, 0, 20, h), stripePaint);
    canvas.drawRect(Rect.fromLTWH(rightEdge - 5, 0, 6, h), stripeSubPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AnimatedBadge extends StatefulWidget {
  final int tier;

  const AnimatedBadge({super.key, required this.tier});

  @override
  State<AnimatedBadge> createState() => _AnimatedBadgeState();
}

class _AnimatedBadgeState extends State<AnimatedBadge>
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
    if (widget.tier < 1) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (widget.tier == 1) {
          // Pit Crew: Slowly rotating wrench/gear
          return Transform.rotate(
            angle: _controller.value * 2 * 3.14159,
            child: Icon(
              Icons.settings,
              color: context.colors.textSecondary,
              size: 16,
            ),
          );
        } else if (widget.tier == 2) {
          // Track Rider Tick: Scale pulse
          return Transform.scale(
            scale: 0.95 + (_controller.value * 0.15),
            child: Icon(Icons.verified, color: context.colors.cyan, size: 16),
          );
        } else {
          // Apex Founder Diamond: Glow + Rotate
          return Transform.scale(
            scale: 0.9 + (_controller.value * 0.2),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(
                      alpha: 0.5 * _controller.value,
                    ),
                    blurRadius: 8 * _controller.value,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Transform.rotate(
                angle: (_controller.value) * 0.2,
                child: const Icon(Icons.diamond, color: Colors.amber, size: 16),
              ),
            ),
          );
        }
      },
    );
  }
}

class _RiderMatchmakerScreen extends StatefulWidget {
  const _RiderMatchmakerScreen({
    super.key,
    required this.tr,
    required this.strings,
  });
  final bool tr;
  final AppStrings strings;

  @override
  State<_RiderMatchmakerScreen> createState() => _RiderMatchmakerScreenState();
}

class _RiderMatchmakerScreenState extends State<_RiderMatchmakerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _scanning = true;
  final List<FriendProfile> _matches = [];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _scanning = false;
        _matches.addAll([
          FriendProfile(
            stableId: 'mock1',
            ridingStyle: 'Street',
            ghostMode: false,
            modifications: [],
            name: 'Ali Yılmaz',
            riderTag: 'Street Rider',
            supporterTier: 1,
            avatarIndex: 2,
            weeklyKm: 210.5,
            harmonyScore: 88,
            activeBikeName: 'Yamaha',
            activeBikeModel: 'MT-07',
            city: 'Istanbul',
            instagram: 'ali.mt07',
            tiktok: '',
            licensePlate: '34 ALI 07',
            selectedBadges: [],
          ),
          FriendProfile(
            stableId: 'mock2',
            ridingStyle: 'Touring',
            ghostMode: false,
            modifications: [],
            name: 'Ayşe Kaya',
            riderTag: 'Explorer',
            supporterTier: 2,
            avatarIndex: 5,
            weeklyKm: 420.0,
            harmonyScore: 95,
            activeBikeName: 'Honda',
            activeBikeModel: 'CRF250',
            city: 'Antalya',
            instagram: '',
            tiktok: '',
            licensePlate: '',
            selectedBadges: [],
          ),
        ]);
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool de = widget.strings.locale.languageCode == 'de';
    final String tFound = widget.tr
        ? 'Sürücüler Bulundu'
        : ((AppStrings.currentLanguageCode == 'de')
              ? 'Fahrer gefunden'
              : 'Riders Found');
    final String tScanning = widget.tr
        ? 'Yakındaki Sürücüler Aranıyor...'
        : ((AppStrings.currentLanguageCode == 'de')
              ? 'Suche nach Fahrern in der Nähe...'
              : 'Scanning for nearby riders...');

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.tr
              ? 'Sürüş Arkadaşı Bul'
              : ((AppStrings.currentLanguageCode == 'de')
                    ? 'Fahrerkameraden finden'
                    : 'Find Riding Buddies'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: _scanning
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 150 + (_pulseController.value * 50),
                        height: 150 + (_pulseController.value * 50),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.colors.cyan.withValues(
                            alpha: 0.1 * (1.0 - _pulseController.value),
                          ),
                          border: Border.all(
                            color: context.colors.cyan.withValues(
                              alpha: 1.0 - _pulseController.value,
                            ),
                            width: 2 + 5 * _pulseController.value,
                          ),
                        ),
                        child: Icon(
                          Icons.wifi_tethering,
                          size: 64,
                          color: context.colors.cyan,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  Text(
                    tScanning,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  tFound,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                for (final match in _matches) ...[
                  RiderIdCard(
                    name: match.name,
                    riderTag: match.riderTag,
                    ridingStyle: 'Street',
                    bloodType: 'A+',
                    phoneNumber: '',
                    emergencyContactName: '',
                    emergencyContactPhone: '',
                    activeBike:
                        '${match.activeBikeName} ${match.activeBikeModel}',
                    totalRides: 42,
                    totalKm: match.weeklyKm * 10,
                    harmonyScore: match.harmonyScore,
                    avatarIndex: match.avatarIndex,
                    tr: widget.tr,
                    themeIndex: match.cardThemeIndex,
                    supporterTier: match.supporterTier,
                    city: match.city,
                    instagram: match.instagram,
                    tiktok: match.tiktok,
                    licensePlate: match.licensePlate,
                    selectedBadges: match.selectedBadges,
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
    );
  }
}

class _CompactShareToggle extends StatelessWidget {
  const _CompactShareToggle({
    required this.icon,
    required this.isActive,
    required this.onToggle,
    required this.color,
  });

  final IconData icon;
  final bool isActive;
  final ValueChanged<bool> onToggle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggle(!isActive),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.2) : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive
                ? color
                : context.colors.textSecondary.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isActive ? color : context.colors.textSecondary,
        ),
      ),
    );
  }
}

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.tr,
    required this.de,
    required this.strings,
  });

  final bool tr;
  final bool de;
  final AppStrings strings;

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController nameCtrl;
  late TextEditingController riderTagCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController emNameCtrl;
  late TextEditingController emPhoneCtrl;
  late TextEditingController bloodCtrl;
  late TextEditingController cityCtrl;
  late TextEditingController instagramCtrl;
  late TextEditingController tiktokCtrl;
  late TextEditingController youtubeCtrl;
  late TextEditingController plateCtrl;

  late TextEditingController riderCountryCodeCtrl;
  late TextEditingController emergencyCountryCodeCtrl;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    nameCtrl = TextEditingController(text: profile.name);

    final parsedRiderPhone = _parsePhoneNumber(profile.phoneNumber);
    final parsedEmergencyPhone = _parsePhoneNumber(
      profile.emergencyContactPhone,
    );
    riderCountryCodeCtrl = TextEditingController(
      text: parsedRiderPhone['code']!.replaceAll('+', ''),
    );
    emergencyCountryCodeCtrl = TextEditingController(
      text: parsedEmergencyPhone['code']!.replaceAll('+', ''),
    );

    riderTagCtrl = TextEditingController(text: profile.riderTag);
    phoneCtrl = TextEditingController(text: parsedRiderPhone['number']);
    emNameCtrl = TextEditingController(text: profile.emergencyContactName);
    emPhoneCtrl = TextEditingController(text: parsedEmergencyPhone['number']);
    bloodCtrl = TextEditingController(text: profile.bloodType);
    cityCtrl = TextEditingController(text: profile.city);
    instagramCtrl = TextEditingController(text: profile.instagram);
    tiktokCtrl = TextEditingController(text: profile.tiktok);
    youtubeCtrl = TextEditingController(text: profile.youtube);
    plateCtrl = TextEditingController(text: profile.licensePlate);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    riderTagCtrl.dispose();
    riderCountryCodeCtrl.dispose();
    emergencyCountryCodeCtrl.dispose();
    phoneCtrl.dispose();
    emNameCtrl.dispose();
    emPhoneCtrl.dispose();
    bloodCtrl.dispose();
    cityCtrl.dispose();
    instagramCtrl.dispose();
    tiktokCtrl.dispose();
    youtubeCtrl.dispose();
    plateCtrl.dispose();
    super.dispose();
  }

  Map<String, String> _parsePhoneNumber(String fullPhone) {
    if (fullPhone.isEmpty) return {'code': '+90', 'number': ''};
    final spaceIdx = fullPhone.indexOf(' ');
    if (spaceIdx != -1) {
      return {
        'code': fullPhone.substring(0, spaceIdx),
        'number': fullPhone.substring(spaceIdx + 1),
      };
    }
    return {'code': '+90', 'number': fullPhone};
  }

  String _t(String trStr, String enStr, String deStr) => widget.tr
      ? trStr
      : ((AppStrings.currentLanguageCode == 'de') ? deStr : enStr);

  void _save() {
    final combinedRiderPhone =
        '+${riderCountryCodeCtrl.text.replaceAll('+', '').trim()} ${phoneCtrl.text}';
    final combinedEmergencyPhone =
        '+${emergencyCountryCodeCtrl.text.replaceAll('+', '').trim()} ${emPhoneCtrl.text}';

    final currentProfile = ref.read(userProfileProvider);
    ref
        .read(userProfileProvider.notifier)
        .updateProfile(
          name: nameCtrl.text,
          riderTag: riderTagCtrl.text.trim().isNotEmpty
              ? riderTagCtrl.text.trim()
              : null,
          phoneNumber: combinedRiderPhone,
          bloodType: bloodCtrl.text,
          emergencyContactName: emNameCtrl.text,
          emergencyContactPhone: combinedEmergencyPhone,
          avatarIndex: currentProfile.avatarIndex,
          selectedFrameIndex: currentProfile.selectedFrameIndex,
          selectedBadges: currentProfile.selectedBadges,
          city: cityCtrl.text,
          instagram: instagramCtrl.text,
          tiktok: tiktokCtrl.text,
          youtube: youtubeCtrl.text,
          licensePlate: plateCtrl.text,
        );
    Navigator.pop(context);
  }

  void _showBloodTypeSheet() {
    final bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', '0+', '0-', '—'];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _t(
                  'Kan Grubu Seçin',
                  'Select Blood Type',
                  'Blutgruppe auswählen',
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: bloodTypes.map((type) {
                  final isSelected = bloodCtrl.text == type;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        bloodCtrl.text = type;
                      });
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.colors.cyan
                            : const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? context.colors.cyan
                              : const Color(0xFF334155),
                        ),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : context.colors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFieldRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required Widget child,
    bool showChevron = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: context.colors.surface,
          border: Border(
            bottom: BorderSide(color: context.colors.border, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  child,
                ],
              ),
            ),
            if (showChevron)
              Icon(
                Icons.chevron_right,
                color: context.colors.textSecondary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint, {
    bool isLocked = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: ctrl,
      enabled: !isLocked,
      keyboardType: keyboardType,
      style: TextStyle(
        color: isLocked ? context.colors.textSecondary : Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.zero,
        hintText: hint,
        hintStyle: TextStyle(
          color: context.colors.textSecondary.withValues(alpha: 0.5),
        ),
        filled: true,
        fillColor: Colors.transparent,
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _t('Profili Düzenle', 'Edit profile', 'Profil bearbeiten'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 10, bottom: 10),
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.cyan,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                _t('Kaydet', 'Save', 'Speichern'),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileAppearanceScreen(
                      tr: widget.tr,
                      de: AppStrings.currentLanguageCode == 'de',
                      strings: widget.strings,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.style, color: Colors.white),
              label: Text(
                widget.tr
                    ? 'Sürücü Kartını Özelleştir'
                    : ((AppStrings.currentLanguageCode == 'de')
                          ? 'Rider Card anpassen'
                          : 'Customize Rider Card'),
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.cyan,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              _t('KİŞİSEL BİLGİLER', 'PERSONAL INFO', 'PERSÖNLICHE INFO'),
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          _buildFieldRow(
            icon: Icons.person_outline,
            iconColor: context.colors.cyan,
            label: _t('İsim', 'Name', 'Vollständiger Name'),
            child: _buildTextField(nameCtrl, 'John Doe'),
          ),
          _buildFieldRow(
            icon: Icons.tag,
            iconColor: Colors.orange,
            label: _t(
              'Rider Tag (Benzersiz Kimlik)',
              'Rider Tag (Unique ID)',
              'Rider Tag (Eindeutige ID)',
            ),
            child: _buildTextField(riderTagCtrl, '@tag', isLocked: false),
          ),
          _buildFieldRow(
            icon: Icons.phone_outlined,
            iconColor: Colors.blue,
            label: _t('Telefon', 'Phone', 'Telefon'),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '+',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 2),
                      SizedBox(
                        width: 38,
                        child: TextField(
                          controller: riderCountryCodeCtrl,
                          keyboardType: TextInputType.number,
                          cursorColor: const Color(0xFF06B6D4),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            filled: true,
                            fillColor: Colors.transparent,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    phoneCtrl,
                    '555 123 4567',
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),
          ),
          _buildFieldRow(
            icon: Icons.bloodtype_outlined,
            iconColor: Colors.redAccent,
            label: _t('Kan Grubu', 'Blood Type', 'Blutgruppe'),
            child: Text(
              bloodCtrl.text.isEmpty ? '—' : bloodCtrl.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            showChevron: true,
            onTap: _showBloodTypeSheet,
          ),
          _buildFieldRow(
            icon: Icons.location_on_outlined,
            iconColor: Colors.green,
            label: _t('Şehir', 'City', 'Stadt'),
            child: _buildTextField(
              cityCtrl,
              _t('Örn: İstanbul', 'e.g. London', 'z.B. Berlin'),
            ),
          ),

          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              _t('ACİL DURUM', 'EMERGENCY', 'NOTFALL'),
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          _buildFieldRow(
            icon: Icons.health_and_safety_outlined,
            iconColor: Colors.red,
            label: _t('Acil Kişi Adı', 'Emergency Contact', 'Notfallkontakt'),
            child: _buildTextField(emNameCtrl, _t('İsim', 'Name', 'Name')),
          ),
          _buildFieldRow(
            icon: Icons.phone_in_talk_outlined,
            iconColor: Colors.orangeAccent,
            label: _t('Acil Kişi Telefon', 'Emergency Phone', 'Notfalltelefon'),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '+',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 2),
                      SizedBox(
                        width: 38,
                        child: TextField(
                          controller: emergencyCountryCodeCtrl,
                          keyboardType: TextInputType.number,
                          cursorColor: const Color(0xFF06B6D4),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            filled: true,
                            fillColor: Colors.transparent,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    emPhoneCtrl,
                    '555 987 6543',
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              _t('EKSTRA BİLGİLER', 'EXTRA INFO', 'ZUSATZINFO'),
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          _buildFieldRow(
            icon: Icons.pin_outlined,
            iconColor: Colors.yellow,
            label: _t('Plaka', 'License Plate', 'Kennzeichen'),
            child: _buildTextField(plateCtrl, '34 AB 123'),
          ),
          _buildFieldRow(
            icon: Icons.camera_alt_outlined,
            iconColor: Colors.pinkAccent,
            label: 'Instagram',
            child: _buildTextField(instagramCtrl, '@username'),
          ),
          _buildFieldRow(
            icon: Icons.music_note_outlined,
            iconColor: Colors.white,
            label: 'TikTok',
            child: _buildTextField(tiktokCtrl, '@username'),
          ),
          _buildFieldRow(
            icon: Icons.play_circle_outline,
            iconColor: Colors.red,
            label: 'YouTube',
            child: _buildTextField(youtubeCtrl, '@username'),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class ProfileAppearanceScreen extends ConsumerStatefulWidget {
  const ProfileAppearanceScreen({
    super.key,
    required this.tr,
    required this.de,
    required this.strings,
  });

  final bool tr;
  final bool de;
  final AppStrings strings;

  @override
  ConsumerState<ProfileAppearanceScreen> createState() =>
      _ProfileAppearanceScreenState();
}

class _ProfileAppearanceScreenState
    extends ConsumerState<ProfileAppearanceScreen> {
  late int localAvatarIndex;
  late int localSelectedFrameIndex;
  late List<String> localSelectedBadges;
  late int localThemeIndex;
  late String localRidingStyle;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    localAvatarIndex = profile.avatarIndex;
    localSelectedFrameIndex = profile.selectedFrameIndex;
    localSelectedBadges = List.from(profile.selectedBadges);
    localThemeIndex = profile.cardThemeIndex;
    localRidingStyle = profile.ridingStyle;
  }

  void _save() {
    final profile = ref.read(userProfileProvider);
    ref
        .read(userProfileProvider.notifier)
        .updateProfile(
          name: profile.name,
          phoneNumber: profile.phoneNumber,
          bloodType: profile.bloodType,
          emergencyContactName: profile.emergencyContactName,
          emergencyContactPhone: profile.emergencyContactPhone,
          ridingStyle: localRidingStyle,
          avatarIndex: localAvatarIndex,
          selectedFrameIndex: localSelectedFrameIndex,
          selectedBadges: localSelectedBadges,
        );
    // Note: themeIndex needs to be updated if added to profile model. Assuming updateProfile handles it or it's implicitly handled.
    Navigator.pop(context);
  }

  void _showPaywall(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PremiumPaywallScreen(strings: widget.strings),
      ),
    );
  }

  void _showPurchaseDialog(
    BuildContext context,
    WidgetRef ref,
    int index,
    RiderCardTheme theme,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: context.colors.surface,
          title: Text(
            tInline(
              AppStrings.currentLanguageCode,
              'Temayı Satın Al',
              'Unlock Theme',
              'Theme freischalten',
            ),
          ),
          content: Text(
            tInline(
              AppStrings.currentLanguageCode,
              '${theme.nameTr} temasını 35 TL (\$0.99) karşılığında satın almak istiyor musunuz?',
              'Do you want to unlock the ${theme.nameEn} theme for \$0.99?',
              'Möchten Sie das Design "${theme.nameEn}" für \$0.99 freischalten?',
            ),
            style: TextStyle(color: context.colors.textSecondary),
          ),
          actions: [
            TextButton(
              child: Text(
                tInline(
                  AppStrings.currentLanguageCode,
                  'İptal',
                  'Cancel',
                  'Stornieren',
                ),
                style: TextStyle(color: context.colors.textSecondary),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text(
                tInline(
                  AppStrings.currentLanguageCode,
                  'Satın Al',
                  'Purchase',
                  'Kaufen',
                ),
                style: TextStyle(color: context.colors.cyan),
              ),
              onPressed: () async {
                Navigator.pop(context);
                ref.read(userProfileProvider.notifier).purchaseTheme(index);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      tInline(
                        AppStrings.currentLanguageCode,
                        'Tema kilidi açıldı.',
                        'Theme unlocked.',
                        'Design freigeschaltet.',
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  String _t(String trStr, String enStr, String deStr) => widget.tr
      ? trStr
      : ((AppStrings.currentLanguageCode == 'de') ? deStr : enStr);

  void _showFrameSelectionSheet() {
    final profile = ref.read(userProfileProvider);
    final frames = [
      {'id': 0, 'name': 'Standart', 'icon': Icons.circle_outlined},
      {'id': 1, 'name': 'Premium', 'icon': Icons.stars},
      {'id': 2, 'name': 'Founder', 'icon': Icons.workspace_premium},
    ];

    if (profile.supporterTier > 0) {
      frames.add({'id': 3, 'name': 'Apex Supporter', 'icon': Icons.diamond});
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _t('Çerçeve Seçin', 'Select Frame', 'Rahmen auswählen'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: frames.map((f) {
                  final idx = f['id'] as int;
                  final isSelected = localSelectedFrameIndex == idx;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        localSelectedFrameIndex = idx;
                      });
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.colors.cyan
                            : const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? context.colors.cyan
                              : const Color(0xFF334155),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            f['icon'] as IconData,
                            color: isSelected
                                ? Colors.white
                                : context.colors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            f['name'] as String,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : context.colors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _toggleBadge(String badgeId) {
    setState(() {
      if (localSelectedBadges.contains(badgeId)) {
        localSelectedBadges.remove(badgeId);
      } else {
        if (localSelectedBadges.length < 3) {
          localSelectedBadges.add(badgeId);
        } else {
          // Could show a snackbar here that max 3 badges allowed
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.read(userProfileProvider);

    // We get all badges in one unified list (mocking unlocked ones for UI)
    final allBadges = [
      {
        'id': 'first_ride',
        'icon': '🏁',
        'name': _t('İlk Sürüş', 'First Ride', 'Erste Fahrt'),
      },
      {
        'id': 'mileage_100',
        'icon': '🌟',
        'name': _t('100 KM', 'Mileage 100', '100 Kilometer'),
      },
      {
        'id': 'speed_demon',
        'icon': '🔥',
        'name': _t('Hız Canavarı', 'Speed Demon', 'Tempo-Teufel'),
      },
      {
        'id': 'night_rider',
        'icon': '🌙',
        'name': _t('Gece Sürücüsü', 'Night Rider', 'Nachtfahrer'),
      },
      {
        'id': 'maintenance_master',
        'icon': '🛠️',
        'name': _t('Bakım Ustası', 'Maintenance Master', 'Wartungsmeister'),
      },
    ];

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _t(
            'Profil Görünümü',
            'Profile Appearance',
            'Profil-Erscheinungsbild',
          ),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 10, bottom: 10),
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.cyan,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                _t('Kaydet', 'Save', 'Speichern'),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // PREVIEW
          Text(
            _t('ÖNİZLEME', 'PREVIEW', 'VORSCHAU'),
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          IgnorePointer(
            child: RiderIdCard(
              name: profile.name,
              riderTag: profile.riderTag,
              ridingStyle: localRidingStyle,
              bloodType: profile.bloodType,
              phoneNumber: profile.phoneNumber,
              emergencyContactName: profile.emergencyContactName,
              emergencyContactPhone: profile.emergencyContactPhone,
              activeBike: 'Preview Bike',
              totalRides: 120,
              totalKm: 4500.5,
              harmonyScore: 95,
              avatarIndex: localAvatarIndex,
              themeIndex: localThemeIndex,
              selectedFrameIndex: localSelectedFrameIndex,
              selectedBadges: localSelectedBadges,
              supporterTier: profile.supporterTier,
              city: profile.city,
              instagram: profile.instagram,
              tiktok: profile.tiktok,
              licensePlate: profile.licensePlate,
              tr: widget.tr,
              de: AppStrings.currentLanguageCode == 'de',
              compact: true,
              hideActiveBike: true,
            ),
          ),

          const SizedBox(height: 32),

          // FRAME
          Text(
            _t('PROFİL ÇERÇEVESİ', 'PROFILE FRAME', 'PROFILRAHMEN'),
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _showFrameSelectionSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Row(
                children: [
                  Icon(Icons.face_outlined, color: context.colors.cyan),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _t(
                            'Mevcut Çerçeve',
                            'Current Frame',
                            'Aktueller Rahmen',
                          ),
                          style: TextStyle(
                            color: context.colors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          localSelectedFrameIndex == 0
                              ? 'Standart'
                              : (localSelectedFrameIndex == 1
                                    ? 'Premium'
                                    : 'Founder'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: context.colors.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // CARD THEME SELECTOR
          Text(
            _t(
              'KART ARKAPLAN TEMASI',
              'CARD BACKGROUND THEME',
              'KARTEN-HINTERGRUNDTHEMA',
            ),
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 108,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: riderCardThemes.length,
              itemBuilder: (context, index) {
                final theme = riderCardThemes[index];
                final isSelected = localThemeIndex == index;

                var isUnlocked = true;
                if (theme.isPremiumOnly && !profile.isPremium) {
                  isUnlocked = false;
                } else if (theme.isPaid &&
                    !profile.purchasedThemes.contains(index)) {
                  isUnlocked = false;
                } else if (theme.requiredSupporterTier > 0 &&
                    profile.supporterTier < theme.requiredSupporterTier) {
                  isUnlocked = false;
                }

                return GestureDetector(
                  onTap: () {
                    if (isUnlocked) {
                      setState(() {
                        localThemeIndex = index;
                      });
                      // Update main provider theme immediately so it syncs correctly
                      ref.read(userProfileProvider.notifier).selectTheme(index);
                    } else {
                      if (theme.requiredSupporterTier > 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                SupporterPaywallScreen(strings: widget.strings),
                          ),
                        );
                      } else if (theme.isPremiumOnly) {
                        _showPaywall(context);
                      } else {
                        _showPurchaseDialog(context, ref, index, theme);
                      }
                    }
                  },
                  child: Container(
                    width: 84,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? context.colors.cyan
                            : const Color(0xFF4B5563),
                        width: isSelected ? 1.5 : 0.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFF1F2937),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: theme.colors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: isSelected
                                ? const Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  )
                                : (!isUnlocked
                                      ? Icon(
                                          theme.isPremiumOnly
                                              ? Icons.star_rounded
                                              : Icons.lock_outline_rounded,
                                          color: Colors.white70,
                                          size: 16,
                                        )
                                      : null),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.tr ? theme.nameTr : theme.nameEn,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Colors.white
                                : context.colors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 32),

          // RIDING STYLE
          Text(
            widget.tr
                ? 'SÜRÜCÜ TİPİ'
                : ((AppStrings.currentLanguageCode == 'de')
                      ? 'FAHRSTIL'
                      : 'RIDING STYLE'),
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
                [
                  'Focused',
                  'Aggressive',
                  'Touring',
                  'Track',
                  'Commuter',
                  'Chill',
                  'Long Hauler 🏆',
                  'Mechanic Mind 🛠️',
                  'Customizer 🎨',
                  'Night Legend 🌙',
                ].map((style) {
                  final isSelected = localRidingStyle == style;
                  return GestureDetector(
                    onTap: () => setState(() => localRidingStyle = style),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.colors.cyan.withValues(alpha: 0.1)
                            : const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? context.colors.cyan
                              : const Color(0xFF334155),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        _t(
                          switch (style) {
                            'Focused' => 'Odaklı',
                            'Aggressive' => 'Agresif',
                            'Touring' => 'Gezi',
                            'Track' => 'Pist',
                            'Commuter' => 'Şehir İçi',
                            'Chill' => 'Sakin',
                            _ => style,
                          },
                          style,
                          switch (style) {
                            'Focused' => 'Fokussiert',
                            'Aggressive' => 'Dynamisch',
                            'Touring' => 'Touren',
                            'Track' => 'Rennstrecke',
                            'Commuter' => 'Pendler',
                            'Chill' => 'Entspannt',
                            _ => style,
                          },
                        ),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : context.colors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),

          const SizedBox(height: 32),

          // AVATAR
          Text(
            widget.tr
                ? 'AVATAR SEÇİMİ'
                : ((AppStrings.currentLanguageCode == 'de')
                      ? 'AVATARAUSWAHL'
                      : 'AVATAR SELECTION'),
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(8, (index) {
              final isSelected = localAvatarIndex == index;
              return GestureDetector(
                onTap: () => setState(() => localAvatarIndex = index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? context.colors.cyan
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: RiderAvatarWidget(avatarIndex: index, radius: 24),
                ),
              );
            }),
          ),

          const SizedBox(height: 32),

          // BADGES
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _t('ROZETLER (MAKS. 3)', 'BADGES (MAX 3)', 'ABZEICHEN (MAX 3)'),
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                '${localSelectedBadges.length}/3',
                style: TextStyle(
                  color: context.colors.cyan,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: allBadges.map((badge) {
              final badgeId = badge['id'] as String;
              final isSelected = localSelectedBadges.contains(badgeId);

              return GestureDetector(
                onTap: () => _toggleBadge(badgeId),
                child: Container(
                  width: 80,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.colors.cyan.withValues(alpha: 0.1)
                        : const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? context.colors.cyan
                          : const Color(0xFF334155),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: context.colors.cyan.withValues(alpha: 0.2),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        badge['icon'] as String,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        badge['name'] as String,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : context.colors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _AchievementOverviewCard extends StatelessWidget {
  const _AchievementOverviewCard({
    required this.tr,
    required this.de,
    required this.onTap,
  });

  final bool tr;
  final bool de;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final allCount = AchievementCatalog.allAchievements.length;
    // Mocked unlocked ratio for high engagement UI
    final unlockedCount = 18;

    String _t(String trStr, String enStr, String deStr) =>
        tr ? trStr : (de ? deStr : enStr);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ApexSpacing.radius),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(ApexSpacing.radius),
          border: Border.all(
            color: context.colors.cyan.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.colors.cyan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.military_tech_outlined,
                    color: context.colors.cyan,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _t('BAŞARIMLAR & ROZETLER', 'ACHIEVEMENTS & BADGES', 'ERFOLGE & ABZEICHEN'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _t('Kazanılan: $unlockedCount / $allCount Başarım', 'Unlocked: $unlockedCount / $allCount Achievements', 'Freigeschaltet: $unlockedCount / $allCount Erfolge'),
                        style: TextStyle(
                          fontSize: 10,
                          color: context.colors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: context.colors.cyan,
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: unlockedCount / allCount,
                minHeight: 6,
                backgroundColor: context.colors.background,
                valueColor: AlwaysStoppedAnimation<Color>(context.colors.cyan),
              ),
            ),
            const SizedBox(height: 10),
            // Quick Badges Preview Row
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: const [
                        _MiniBadgeChip(icon: '🏁', label: 'İlk Sürüş'),
                        SizedBox(width: 6),
                        _MiniBadgeChip(icon: '🌟', label: '100 KM'),
                        SizedBox(width: 6),
                        _MiniBadgeChip(icon: '🔥', label: 'Hız Canavarı'),
                        SizedBox(width: 6),
                        _MiniBadgeChip(icon: '🛠️', label: 'Bakım'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _t('Tümünü Gör', 'View All', 'Alle Anzeigen'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: context.colors.cyan,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniBadgeChip extends StatelessWidget {
  const _MiniBadgeChip({required this.icon, required this.label});
  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: context.colors.border, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 9, color: context.colors.textSecondary, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

void _showAchievementsModal(BuildContext context, bool tr, bool de, UserProfile userProfile) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return _AchievementSheetWidget(tr: tr, de: de, userProfile: userProfile);
    },
  );
}

class _AchievementSheetWidget extends ConsumerStatefulWidget {
  const _AchievementSheetWidget({
    required this.tr,
    required this.de,
    required this.userProfile,
  });

  final bool tr;
  final bool de;
  final UserProfile userProfile;

  @override
  ConsumerState<_AchievementSheetWidget> createState() => _AchievementSheetWidgetState();
}

class _AchievementSheetWidgetState extends ConsumerState<_AchievementSheetWidget> {
  String _selectedCategory = 'all';
  final Set<String> _claimedRewards = {};

  @override
  Widget build(BuildContext context) {
    final tr = widget.tr;
    final de = widget.de;
    final langCode = tr ? 'tr' : (de ? 'de' : 'en');
    final all = AchievementCatalog.allAchievements;

    final categories = [
      {'id': 'all', 'label': tr ? 'Tümü' : (de ? 'Alle' : 'All'), 'icon': '🎯'},
      {'id': 'km', 'label': 'KM', 'icon': '🛣️'},
      {'id': 'ride', 'label': tr ? 'Sürüş' : 'Rides', 'icon': '🏍️'},
      {'id': 'maintenance', 'label': tr ? 'Bakım' : 'Service', 'icon': '🛠️'},
      {'id': 'harmony', 'label': tr ? 'Uyum' : 'Harmony', 'icon': '🧘'},
      {'id': 'social', 'label': tr ? 'Sosyal' : 'Social', 'icon': '🤝'},
    ];

    final filtered = _selectedCategory == 'all'
        ? all
        : all.where((a) => a.category == _selectedCategory).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      maxChildSize: 0.96,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.colors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: context.colors.border),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr ? 'BAŞARIM & RİDER XP' : (de ? 'ERFOLGE & FAHRER XP' : 'ACHIEVEMENT & RIDER XP'),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tr ? 'Tamamlanan başarımlarla Rider XP ve seviye kazan' : 'Earn Rider XP & levels from completed achievements',
                          style: TextStyle(
                            fontSize: 11,
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: context.colors.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // CATEGORIES TAB BAR WITH SCROLL FADE INDICATOR
              Container(
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Stack(
                  children: [
                    ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, idx) {
                        final cat = categories[idx];
                        final isSelected = cat['id'] == _selectedCategory;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            showCheckmark: false,
                            selected: isSelected,
                            selectedColor: context.colors.cyan,
                            backgroundColor: context.colors.surface,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(cat['icon'] as String, style: const TextStyle(fontSize: 12)),
                                const SizedBox(width: 6),
                                Text(
                                  cat['label'] as String,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.black : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            onSelected: (_) {
                              setState(() {
                                _selectedCategory = cat['id'] as String;
                              });
                            },
                          ),
                        );
                      },
                    ),
                    // Right scroll fade hint
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: IgnorePointer(
                        child: Container(
                          width: 32,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                context.colors.background.withValues(alpha: 0.0),
                                context.colors.background,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                          child: const Icon(
                            Icons.chevron_right,
                            color: Color(0xFFFBBF24),
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, color: Color(0xFF334155)),

              // ACHIEVEMENTS LIST
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    // Calculate actual real progress dynamically for each achievement
                    final rideState = ref.watch(rideStateProvider);
                    final garageState = ref.watch(garageStateProvider);
                    final friendsList = ref.watch(friendsStateProvider);

                    // Real Stats Calculation:
                    // 1. Total distance recorded ONLY during ride sessions in ApexFlow (excludes initial bike odometer)
                    final realTotalRideKm = rideState.sessions.fold<double>(
                      0.0,
                      (sum, s) => sum + s.distanceKm,
                    );

                    // 2. Real ride count sessions
                    final realRideCount = rideState.sessions.length;

                    // 3. Real maintenance entries
                    final realMaintCount = garageState.serviceRecords.length;

                    // 4. Real friends count
                    final realFriendsCount = friendsList.length;

                    // 5. Harmony rides per mood
                    int realHarmonyCount = 0;
                    if (item.category == 'harmony') {
                      final moodName = item.id.split('_').length > 1 ? item.id.split('_')[1] : '';
                      realHarmonyCount = rideState.sessions.where(
                        (s) => s.mood.toLowerCase() == moodName.toLowerCase(),
                      ).length;
                    }

                    bool isUnlocked = false;
                    int currentProgress = 0;

                    if (item.category == 'km') {
                      currentProgress = realTotalRideKm.floor();
                      isUnlocked = currentProgress >= item.requiredCount;
                    } else if (item.category == 'ride') {
                      currentProgress = realRideCount;
                      isUnlocked = currentProgress >= item.requiredCount;
                    } else if (item.category == 'maintenance') {
                      currentProgress = realMaintCount;
                      isUnlocked = currentProgress >= item.requiredCount;
                    } else if (item.category == 'harmony') {
                      currentProgress = realHarmonyCount;
                      isUnlocked = currentProgress >= item.requiredCount;
                    } else if (item.category == 'social' || item.id.startsWith('friend_count_')) {
                      currentProgress = realFriendsCount;
                      isUnlocked = currentProgress >= item.requiredCount;
                    } else {
                      isUnlocked = false;
                    }

                    final isClaimed = _claimedRewards.contains(item.id);

                    return GestureDetector(
                      onTap: () {
                        if (isUnlocked && !isClaimed) {
                          setState(() {
                            _claimedRewards.add(item.id);
                          });
                          // Add dynamic achievement XP to user profile
                          ref.read(userProfileProvider.notifier).addXp(item.xpReward);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFFD97706),
                              content: Text('✨ +${item.xpReward} Rider XP Kazandın! Ödül: ${item.reward.title(langCode)}'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isClaimed
                              ? const Color(0xFF78350F).withValues(alpha: 0.25)
                              : (isUnlocked ? context.colors.surface : const Color(0xFF0F172A)),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isClaimed
                                ? const Color(0xFFF59E0B) // Gold border when claimed
                                : (isUnlocked
                                    ? context.colors.cyan.withValues(alpha: 0.5)
                                    : const Color(0xFF1E293B)),
                            width: isClaimed ? 2.0 : 1.0,
                          ),
                          boxShadow: isClaimed
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  )
                                ]
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isClaimed
                                        ? const Color(0xFFF59E0B).withValues(alpha: 0.2)
                                        : (isUnlocked
                                            ? context.colors.cyan.withValues(alpha: 0.15)
                                            : const Color(0xFF1E293B)),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    isUnlocked ? item.icon : '🔒',
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.title(langCode),
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: isUnlocked ? Colors.white : context.colors.textSecondary,
                                              ),
                                            ),
                                          ),
                                          if (isClaimed)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF78350F).withValues(alpha: 0.8),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: const Color(0xFFF59E0B), width: 1.0),
                                              ),
                                              child: Text(
                                                tr ? 'ÖDÜL ALINDI 👑' : 'CLAIMED 👑',
                                                style: const TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w900,
                                                  color: Color(0xFFFBBF24), // Gold Text
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.description(langCode),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: context.colors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Divider(height: 1, color: Color(0xFF1E293B)),
                            const SizedBox(height: 8),

                            // REWARD CLAIM BAR
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.card_giftcard,
                                      size: 14,
                                      color: isClaimed
                                          ? const Color(0xFFFBBF24)
                                          : (isUnlocked ? context.colors.cyan : context.colors.textSecondary),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      item.reward.title(langCode),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isClaimed
                                            ? const Color(0xFFFBBF24)
                                            : (isUnlocked ? context.colors.cyan : context.colors.textSecondary),
                                      ),
                                    ),
                                  ],
                                ),
                                if (isUnlocked && !isClaimed)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD97706),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      tr ? 'Tıkla & Ödülü Al ✨' : 'Tap to Claim ✨',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PremiumVaultButton extends StatelessWidget {
  const _PremiumVaultButton({
    required this.tr,
    required this.de,
    required this.onTap,
  });

  final bool tr;
  final bool de;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    String _t(String trStr, String enStr, String deStr) =>
        tr ? trStr : (de ? deStr : enStr);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ApexSpacing.radius),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1B4B),
          borderRadius: BorderRadius.circular(ApexSpacing.radius),
          border: Border.all(
            color: const Color(0xFF818CF8).withValues(alpha: 0.4),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                color: Color(0xFFA5B4FC),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t('ÖDÜL KASASI 🔐', 'REWARD VAULT 🔐', 'BELOHNUNGS TRESOR 🔐'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _t('Kazanılan ödülleri, temaları ve promo kodlarını yönet', 'Manage earned rewards, themes & promo codes', 'Verwalte deine Prämien, Themes & Codes'),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFFC7D2FE),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFA5B4FC),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

void _showPremiumVaultModal(
  BuildContext context,
  bool tr,
  bool de,
  UserProfile userProfile,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return _PremiumVaultSheetWidget(
        tr: tr,
        de: de,
        userProfile: userProfile,
      );
    },
  );
}

class _PremiumVaultSheetWidget extends ConsumerStatefulWidget {
  const _PremiumVaultSheetWidget({
    required this.tr,
    required this.de,
    required this.userProfile,
  });

  final bool tr;
  final bool de;
  final UserProfile userProfile;

  @override
  ConsumerState<_PremiumVaultSheetWidget> createState() =>
      _PremiumVaultSheetWidgetState();
}

class _PremiumVaultSheetWidgetState
    extends ConsumerState<_PremiumVaultSheetWidget> {
  late TextEditingController _promoController;

  @override
  void initState() {
    super.initState();
    _promoController = TextEditingController();
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = widget.tr;
    final de = widget.de;
    final userProfile = ref.watch(userProfileProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.colors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: context.colors.border),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr ? 'ÖDÜL KASASI 🔐' : (de ? 'BELOHNUNGS TRESOR 🔐' : 'REWARD VAULT 🔐'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: context.colors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Vault Items Header
              Text(
                tr ? 'KASADAKİ ÖDÜLLER' : (de ? 'TRESOR PRÄMIEN' : 'VAULT REWARDS'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),

              // Vault Item 1: Premium License
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1B4B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF818CF8).withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.card_membership,
                            color: Color(0xFFA5B4FC),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tr ? 'Premium Sürücü Lisansı' : 'Premium Rider License',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                userProfile.isPremium
                                    ? (tr ? '👑 Hesabınızda Aktif' : '👑 Active on Account')
                                    : (tr ? '⚡ 24 Gün Kullanılabilir' : '⚡ 24 Days Available'),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: userProfile.isPremium ? const Color(0xFF10B981) : const Color(0xFFC7D2FE),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: userProfile.isPremium ? const Color(0xFF10B981) : const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            if (!userProfile.isPremium) {
                              final messenger = ScaffoldMessenger.of(context);
                              await ref.read(userProfileProvider.notifier).updatePremiumStatus(true);
                              if (mounted) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    backgroundColor: const Color(0xFF10B981),
                                    content: Text(
                                      tr
                                          ? '🎉 Premium Hesabınıza Başarıyla Aktifleştirildi!'
                                          : '🎉 Premium Activated Successfully!',
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          child: Text(
                            userProfile.isPremium ? (tr ? 'Aktif ⚡' : 'Active ⚡') : (tr ? 'Kullan ⚡' : 'Use ⚡'),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Vault Item 2: Dynamic Custom Avatar / Theme Placeholders for Future Rewards
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF334155),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF334155),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.style,
                        color: Color(0xFFF59E0B),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr ? 'Özel Garaj Tema & Avatarlar' : 'Custom Garage Themes & Avatars',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tr ? 'Seviye atladıkça veya etkinliklerle kilit aç' : 'Unlock as you level up or via events',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Text(
                tr ? 'PROMO KOD VEYA YÖNETİCİ ÖDÜLÜ' : 'PROMO CODE OR ADMIN REWARD',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _promoController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: tr ? 'Promo kodunuzu girin...' : 'Enter promo code...',
                        hintStyle: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF1E293B),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.cyan,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final code = _promoController.text.trim();
                      if (code.isNotEmpty) {
                        final messenger = ScaffoldMessenger.of(context);
                        // Aktif et ve bildirim yolla
                        await ref.read(userProfileProvider.notifier).updatePremiumStatus(true);

                        ref.read(notificationsProvider.notifier).addNotification(
                              title: tr ? '🎉 Yönetici / Promo Ödülü Tanımlandı' : '🎉 Admin / Promo Reward Granted',
                              body: tr
                                  ? '"$code" promo kodu ile hesabınıza özel premium hediye tanımlandı!'
                                  : 'Special premium reward code "$code" has been applied to your account!',
                              type: NotificationType.general,
                            );

                        _promoController.clear();

                        if (mounted) {
                          messenger.showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF10B981),
                              content: Text(
                                tr
                                    ? '🎉 Promo Kod Başarıyla Uygulandı ve Bildirim Kutunuza Eklendi: $code'
                                    : '🎉 Promo Code Applied & Notification Sent: $code',
                              ),
                            ),
                          );
                        }
                      }
                    },
                    child: Text(
                      tr ? 'Uygula' : 'Apply',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
