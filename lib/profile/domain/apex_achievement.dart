import 'package:flutter/material.dart';

enum AchievementRewardType { badge, ridingStyle, premiumVault, none }

class AchievementReward {
  final AchievementRewardType type;
  final String? rewardId; // Badge id, Riding style name or Premium days
  final String titleTr;
  final String titleEn;
  final String titleDe;
  final int premiumDays;

  const AchievementReward({
    required this.type,
    this.rewardId,
    required this.titleTr,
    required this.titleEn,
    required this.titleDe,
    this.premiumDays = 0,
  });

  String title(String langCode) {
    if (langCode == 'tr') return titleTr;
    if (langCode == 'de') return titleDe;
    return titleEn;
  }
}

class ApexAchievement {
  final String id;
  final String titleTr;
  final String titleEn;
  final String titleDe;
  final String descriptionTr;
  final String descriptionEn;
  final String descriptionDe;
  final IconData icon;
  final String
  category; // 'all', 'km', 'ride', 'maintenance', 'harmony', 'social'
  final int requiredCount;
  final AchievementReward reward;
  final int xpReward;
  final bool isSecret;

  const ApexAchievement({
    required this.id,
    required this.titleTr,
    required this.titleEn,
    required this.titleDe,
    required this.descriptionTr,
    required this.descriptionEn,
    required this.descriptionDe,
    required this.icon,
    required this.category,
    required this.requiredCount,
    required this.reward,
    this.xpReward = 50,
    this.isSecret = false,
  });

  String title(String langCode) {
    if (langCode == 'tr') return titleTr;
    if (langCode == 'de') return titleDe;
    return titleEn;
  }

  String description(String langCode) {
    if (langCode == 'tr') return descriptionTr;
    if (langCode == 'de') return descriptionDe;
    return descriptionEn;
  }
}

class AchievementCatalog {
  static List<ApexAchievement> _cached = [];

  static List<ApexAchievement> get allAchievements {
    if (_cached.isNotEmpty) return _cached;
    _cached = _generate200Achievements();
    return _cached;
  }

  static List<ApexAchievement> _generate200Achievements() {
    final list = <ApexAchievement>[];

    // 1. KM CATEGORY (40 Achievements)
    final kmMilestones = [
      10,
      25,
      50,
      100,
      200,
      300,
      500,
      750,
      1000,
      1500,
      2000,
      2500,
      3000,
      4000,
      5000,
      6000,
      7000,
      8000,
      9000,
      10000,
      12000,
      15000,
      20000,
      25000,
      30000,
      40000,
      50000,
      60000,
      70000,
      80000,
      90000,
      100000,
      120000,
      150000,
      200000,
      250000,
      300000,
      400000,
      500000,
      1000000,
    ];
    for (int i = 0; i < kmMilestones.length; i++) {
      final km = kmMilestones[i];
      AchievementReward reward;
      if (km == 100) {
        reward = const AchievementReward(
          type: AchievementRewardType.badge,
          rewardId: 'mileage_100',
          titleTr: '🌟 100 KM Rozeti',
          titleEn: '🌟 100 KM Badge',
          titleDe: '🌟 100 KM Abzeichen',
        );
      } else if (km == 1000) {
        reward = const AchievementReward(
          type: AchievementRewardType.ridingStyle,
          rewardId: 'Long Hauler',
          titleTr: '🛣️ "Long Hauler" Sürüş Tipi',
          titleEn: '🛣️ "Long Hauler" Riding Style',
          titleDe: '🛣️ "Long Hauler" Fahrstil',
        );
      } else if (i == 15) {
        reward = const AchievementReward(
          type: AchievementRewardType.badge,
          rewardId: 'asphalt_master',
          titleTr: '⚡ Asfalt Ustası Rozeti',
          titleEn: '⚡ Asphalt Master Badge',
          titleDe: '⚡ Asphalt Meister Abzeichen',
        );
      } else {
        reward = AchievementReward(
          type: AchievementRewardType.none,
          titleTr: '⚡ Sürücü Lv XP',
          titleEn: '⚡ Rider Lv XP',
          titleDe: '⚡ Fahrer Stufe XP',
        );
      }

      int xp = 50 + (i * 25);
      if (km >= 100000)
        xp = 1500;
      else if (km >= 10000)
        xp = 800;
      else if (km >= 1000)
        xp = 300;

      list.add(
        ApexAchievement(
          id: 'km_$km',
          titleTr: '$km KM Sürücüsü',
          titleEn: '$km KM Rider',
          titleDe: '$km KM Fahrer',
          descriptionTr: 'Toplamda $km kilometre mesafe kat et.',
          descriptionEn: 'Cover a total distance of $km kilometers.',
          descriptionDe: 'Laufe insgesamt $km Kilometer.',
          icon: km >= 100000
              ? Icons.workspace_premium
              : (km >= 10000
                    ? Icons.emoji_events
                    : (km >= 1000 ? Icons.bolt : Icons.route)),
          category: 'km',
          requiredCount: km,
          reward: reward,
          xpReward: xp,
        ),
      );
    }

    // 2. RIDE COUNT CATEGORY (40 Achievements)
    final rideMilestones = [
      1,
      3,
      5,
      10,
      15,
      20,
      25,
      30,
      40,
      50,
      60,
      70,
      80,
      90,
      100,
      120,
      140,
      160,
      180,
      200,
      250,
      300,
      350,
      400,
      450,
      500,
      600,
      700,
      800,
      900,
      1000,
      1200,
      1500,
      2000,
      2500,
      3000,
      4000,
      5000,
      7500,
      10000,
    ];
    for (int i = 0; i < rideMilestones.length; i++) {
      final count = rideMilestones[i];
      AchievementReward reward;
      if (count == 1) {
        reward = const AchievementReward(
          type: AchievementRewardType.badge,
          rewardId: 'first_ride',
          titleTr: '🏁 İlk Sürüş Rozeti',
          titleEn: '🏁 First Ride Badge',
          titleDe: '🏁 Erste Fahrt Abzeichen',
        );
      } else if (count == 50) {
        reward = const AchievementReward(
          type: AchievementRewardType.premiumVault,
          premiumDays: 3,
          titleTr: '💎 3 Günlük Premium Kasası',
          titleEn: '💎 3-Day Premium Vault',
          titleDe: '💎 3-Tage Premium Tresor',
        );
      } else if (count == 100) {
        reward = const AchievementReward(
          type: AchievementRewardType.premiumVault,
          premiumDays: 7,
          titleTr: '👑 7 Günlük Premium Kasası',
          titleEn: '👑 7-Day Premium Vault',
          titleDe: '👑 7-Tage Premium Tresor',
        );
      } else if (count == 200) {
        reward = const AchievementReward(
          type: AchievementRewardType.premiumVault,
          premiumDays: 14,
          titleTr: '🔥 14 Günlük Premium Kasası',
          titleEn: '🔥 14-Day Premium Vault',
          titleDe: '🔥 14-Tage Premium Tresor',
        );
      } else {
        reward = AchievementReward(
          type: AchievementRewardType.none,
          titleTr: '⚡ Sürücü Lv XP',
          titleEn: '⚡ Rider Lv XP',
          titleDe: '⚡ Fahrer Stufe XP',
        );
      }

      int xp = 40 + (i * 20);
      if (count >= 1000)
        xp = 1200;
      else if (count >= 100)
        xp = 500;

      list.add(
        ApexAchievement(
          id: 'ride_count_$count',
          titleTr: '$count. Sürüş Kaydı',
          titleEn: '$count Rides Logged',
          titleDe: '$count Fahrten Erfasst',
          descriptionTr: 'Toplam $count adet sürüş oturumu tamamla.',
          descriptionEn: 'Complete a total of $count ride sessions.',
          descriptionDe: 'Absolviere insgesamt $count Fahrten.',
          icon: count >= 1000
              ? Icons.military_tech
              : (count >= 100 ? Icons.flag : Icons.motorcycle),
          category: 'ride',
          requiredCount: count,
          reward: reward,
          xpReward: xp,
        ),
      );
    }

    // 3. MAINTENANCE & SERVICE CATEGORY (40 Achievements)
    final serviceMilestones = [
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
      10,
      12,
      14,
      16,
      18,
      20,
      25,
      30,
      35,
      40,
      45,
      50,
      55,
      60,
      65,
      70,
      75,
      80,
      85,
      90,
      95,
      100,
      110,
      120,
      130,
      140,
      150,
      175,
      200,
      250,
      300,
    ];
    for (int i = 0; i < serviceMilestones.length; i++) {
      final count = serviceMilestones[i];
      AchievementReward reward;
      if (count == 5) {
        reward = const AchievementReward(
          type: AchievementRewardType.badge,
          rewardId: 'maintenance_master',
          titleTr: '🛠️ Bakım Ustası Rozeti',
          titleEn: '🛠️ Maintenance Master Badge',
          titleDe: '🛠️ Wartungsmeister Abzeichen',
        );
      } else if (count == 10) {
        reward = const AchievementReward(
          type: AchievementRewardType.ridingStyle,
          rewardId: 'Mechanic Mind',
          titleTr: '🔧 "Mechanic Mind" Sürüş Tipi',
          titleEn: '🔧 "Mechanic Mind" Riding Style',
          titleDe: '🔧 "Mechanic Mind" Fahrstil',
        );
      } else {
        reward = AchievementReward(
          type: AchievementRewardType.none,
          titleTr: '⚡ Sürücü Lv XP',
          titleEn: '⚡ Rider Lv XP',
          titleDe: '⚡ Fahrer Stufe XP',
        );
      }

      list.add(
        ApexAchievement(
          id: 'maint_$count',
          titleTr: 'Bakım Ustası Level ${i + 1}',
          titleEn: 'Maintenance Master Lvl ${i + 1}',
          titleDe: 'Wartungsmeister Stufe ${i + 1}',
          descriptionTr:
              'Motosikletin için $count kez servis veya günlük kontrol kaydı oluştur.',
          descriptionEn:
              'Log $count maintenance or daily check entries for your bike.',
          descriptionDe: 'Trage $count Wartungen oder Tages-Checks ein.',
          icon: count >= 50
              ? Icons.diamond
              : (count >= 10 ? Icons.handyman : Icons.build),
          category: 'maintenance',
          requiredCount: count,
          reward: reward,
          xpReward: 50 + (i * 20),
        ),
      );
    }

    // 4. HARMONY & MOOD CATEGORY (40 Achievements)
    final moodTypes = <Map<String, Object>>[
      {'nameTr': 'Odaklı', 'nameEn': 'Focused', 'icon': Icons.track_changes},
      {'nameTr': 'Sakin', 'nameEn': 'Calm', 'icon': Icons.self_improvement},
      {
        'nameTr': 'Spor',
        'nameEn': 'Sporty',
        'icon': Icons.local_fire_department,
      },
      {'nameTr': 'Gece', 'nameEn': 'Night', 'icon': Icons.nightlight_round},
    ];
    for (var mood in moodTypes) {
      for (int level = 1; level <= 10; level++) {
        final req = level * 5;
        AchievementReward reward;
        if (level == 5 && mood['nameEn'] == 'Night') {
          reward = const AchievementReward(
            type: AchievementRewardType.badge,
            rewardId: 'night_rider',
            titleTr: '🌙 Gece Sürücüsü Rozeti',
            titleEn: '🌙 Night Rider Badge',
            titleDe: '🌙 Nachtfahrer Abzeichen',
          );
        } else if (level == 5 && mood['nameEn'] == 'Sporty') {
          reward = const AchievementReward(
            type: AchievementRewardType.badge,
            rewardId: 'speed_demon',
            titleTr: '🔥 Hız Canavarı Rozeti',
            titleEn: '🔥 Speed Demon Badge',
            titleDe: '🔥 Tempo-Teufel Abzeichen',
          );
        } else if (level == 10) {
          reward = AchievementReward(
            type: AchievementRewardType.ridingStyle,
            rewardId: '${mood['nameEn']} Legend',
            titleTr: '"${mood['nameEn']} Legend" Sürüş Tipi',
            titleEn: '"${mood['nameEn']} Legend" Riding Style',
            titleDe: '"${mood['nameEn']} Legend" Fahrstil',
          );
        } else {
          reward = AchievementReward(
            type: AchievementRewardType.none,
            titleTr: '⚡ Sürücü Lv XP',
            titleEn: '⚡ Rider Lv XP',
            titleDe: '⚡ Fahrer Stufe XP',
          );
        }

        list.add(
          ApexAchievement(
            id: 'harmony_${mood['nameEn']}_$level',
            titleTr: '${mood['nameTr']} Sürüş Ruhu #$level',
            titleEn: '${mood['nameEn']} Ride Spirit #$level',
            titleDe: '${mood['nameEn']} Fahrgeist #$level',
            descriptionTr: '${mood['nameTr']} modunda $req sürüş gerçekleştir.',
            descriptionEn: 'Complete $req rides in ${mood['nameEn']} mood.',
            descriptionDe: 'Fahre $req Mal im Modus ${mood['nameEn']}.',
            icon: mood['icon']! as IconData,
            category: 'harmony',
            requiredCount: req,
            reward: reward,
            xpReward: level * 35,
          ),
        );
      }
    }

    // 5. SOCIAL & COMMUNITY & SPECIAL (40 Achievements)
    final socialTitles = [
      'İlk Yol Arkadaşı (1 Arkadaş)',
      '3 Sürücü Dostu (3 Arkadaş)',
      '5 Motorcu Çetesi (5 Arkadaş)',
      '10 Asfalt Kardeşliği (10 Arkadaş)',
      '25 Sürüş Kulübü (25 Arkadaş)',
      '50 Topluluk Lideri (50 Arkadaş)',
      '100 Yol Efsanesi (100 Arkadaş)',
      'Profil Özelleştirici',
      'Kilit Ekranı Ustası',
      'Rider Tag Oluşturucu',
      'Gece Yıldızı',
      'Erken Kuş',
      'Hafta Sonu Gezgini',
      'Yağmurlu Sürüş Ustası',
      'Uzun Yol Kampçısı',
      'Garaj Koleksiyoneri',
      'Akü Dostu',
      'Zincir Titizliği',
      'Lastik Uzmanı',
      'Yakıt Ekonomisti',
      'Pist Tutkunu',
      'Viraj Avcısı',
      'Dağ Sürücüsü',
      'Sahil Gezgini',
      'Apex Efsanesi',
      'Şehir Kaşifi',
      'Harita Fatihi',
      'Sosyal Sürücü',
      'QR İletişim',
      'Sticker Üreticisi',
      'Grup Lideri',
      'Rozet Avcısı',
      'Harmoni Ustası',
      'Mekanik Gözlemci',
      'Servis Defteri Dostu',
      'Sıfır Hata',
      'Güvenlik Odaklı',
      'Apex Üyesi',
      'Apex Destekçisi',
      'Kıdemli Sürücü',
    ];
    final friendCounts = [1, 3, 5, 10, 25, 50, 100];
    for (int i = 0; i < socialTitles.length; i++) {
      AchievementReward reward;
      int reqCount = 1;
      int xp = 60 + (i * 25);
      if (i < friendCounts.length) {
        reqCount = friendCounts[i];
        xp = reqCount * 30;
        reward = AchievementReward(
          type: AchievementRewardType.badge,
          rewardId: 'friend_count_$reqCount',
          titleTr: '🤝 $reqCount Arkadaş Ekleyen Rozeti',
          titleEn: '🤝 Add $reqCount Friends Badge',
          titleDe: '🤝 $reqCount Freunde Hinzugefügt Abzeichen',
        );
      } else if (i == 7) {
        reward = const AchievementReward(
          type: AchievementRewardType.ridingStyle,
          rewardId: 'Customizer',
          titleTr: '🎨 "Customizer" Sürüş Tipi',
          titleEn: '🎨 "Customizer" Riding Style',
          titleDe: '🎨 "Customizer" Fahrstil',
        );
      } else {
        reward = AchievementReward(
          type: AchievementRewardType.none,
          titleTr: '⚡ Sürücü Lv XP',
          titleEn: '⚡ Rider Lv XP',
          titleDe: '⚡ Fahrer Stufe XP',
        );
      }

      list.add(
        ApexAchievement(
          id: i < friendCounts.length
              ? 'friend_count_$reqCount'
              : 'special_${i + 1}',
          titleTr: socialTitles[i],
          titleEn: '${socialTitles[i]} Badge',
          titleDe: '${socialTitles[i]} Abzeichen',
          descriptionTr: i < friendCounts.length
              ? 'Apex Flow topluluğuna $reqCount motorcu arkadaş ekle.'
              : '${socialTitles[i]} başarım kilitlerini açarak topluluk gücünü kanıtla.',
          descriptionEn: i < friendCounts.length
              ? 'Add $reqCount rider friends to your Apex Flow circle.'
              : 'Unlock ${socialTitles[i]} achievement.',
          descriptionDe: i < friendCounts.length
              ? 'Füge $reqCount Motorrad-Freunde hinzu.'
              : 'Schalte das Abzeichen ${socialTitles[i]} frei.',
          icon: i < friendCounts.length
              ? Icons.handshake
              : (i % 5 == 0
                    ? Icons.auto_awesome
                    : (i % 3 == 0 ? Icons.military_tech : Icons.label)),
          category: 'social',
          requiredCount: reqCount,
          reward: reward,
          xpReward: xp,
        ),
      );
    }

    return list;
  }
}
