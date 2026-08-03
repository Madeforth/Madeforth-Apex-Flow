import 'package:flutter/material.dart';

/// Level milestone reward definitions
class LevelReward {
  final int level;
  final int premiumDays;
  final String titleTr;
  final String titleEn;
  final String titleDe;

  const LevelReward({
    required this.level,
    required this.premiumDays,
    required this.titleTr,
    required this.titleEn,
    required this.titleDe,
  });

  String title(String langCode) {
    if (langCode == 'tr') return titleTr;
    if (langCode == 'de') return titleDe;
    return titleEn;
  }
}

/// Motosiklet Kültürüne Uygun Level & XP Sistemi (Level 1 - 100)
class RiderXpSystem {
  /// Sabit Level Ödül Haritası
  static const List<LevelReward> milestoneRewards = [
    LevelReward(
      level: 10,
      premiumDays: 1,
      titleTr: '🎁 1 Günlük Premium Hediye',
      titleEn: '🎁 1-Day Premium Gift',
      titleDe: '🎁 1 Tag Premium Geschenk',
    ),
    LevelReward(
      level: 50,
      premiumDays: 2,
      titleTr: '💎 2 Günlük Premium Hediye',
      titleEn: '💎 2-Day Premium Gift',
      titleDe: '💎 2 Tage Premium Geschenk',
    ),
    LevelReward(
      level: 80,
      premiumDays: 3,
      titleTr: '🔥 3 Günlük Premium Hediye',
      titleEn: '🔥 3-Day Premium Gift',
      titleDe: '🔥 3 Tage Premium Geschenk',
    ),
    LevelReward(
      level: 100,
      premiumDays: 5,
      titleTr: '👑 5 Günlük Efsanevi Premium Hediye',
      titleEn: '👑 5-Day Legendary Premium Gift',
      titleDe: '👑 5 Tage Legendäres Premium Geschenk',
    ),
  ];

  /// levelForXp: XP miktarına göre seviyeyi (1 - 100) hesaplar.
  /// Dengeli Monetizasyon Eğrisi:
  /// Seviye atlamak için gereken XP: Base 100 XP + (Level * 40)
  /// Toplam XP (Level L için): L=1 iken 0 XP, L=100 Max Level.
  static int _reqForLevel(int lvl) => 100 + (lvl * 40);

  static int getLevelForXp(int totalXp) {
    if (totalXp <= 0) return 1;
    int level = 1;
    int accumulatedXp = 0;

    while (level < 100) {
      final req = _reqForLevel(level);
      if (totalXp < accumulatedXp + req) {
        break;
      }
      accumulatedXp += req;
      level++;
    }
    return level;
  }

  static ({int xpInCurrentLevel, int xpRequiredForNextLevel, double progress}) getLevelProgress(int totalXp) {
    final currentLevel = getLevelForXp(totalXp);
    if (currentLevel >= 100) {
      return (xpInCurrentLevel: 1000, xpRequiredForNextLevel: 1000, progress: 1.0);
    }

    int accumulatedXp = 0;
    for (int lvl = 1; lvl < currentLevel; lvl++) {
      accumulatedXp += _reqForLevel(lvl);
    }
    final currentRequirement = _reqForLevel(currentLevel);

    final xpInCurrentLevel = (totalXp - accumulatedXp).clamp(0, currentRequirement);
    final progress = (xpInCurrentLevel / currentRequirement).clamp(0.0, 1.0);

    return (
      xpInCurrentLevel: xpInCurrentLevel,
      xpRequiredForNextLevel: currentRequirement,
      progress: progress,
    );
  }

  /// Motosiklet Kültürüne Uygun Seviye Unvanı (Rider Rank Title)
  static String getRankTitle(int level, String langCode) {
    final isTr = langCode == 'tr';
    final isDe = langCode == 'de';

    if (level < 5) {
      return isTr ? 'Çaylak Sürücü 🛵' : (isDe ? 'Fahranfänger 🛵' : 'Novice Rider 🛵');
    } else if (level < 10) {
      return isTr ? 'Asfalt Kaşifi 🛣️' : (isDe ? 'Asphalt-Entdecker 🛣️' : 'Asphalt Scout 🛣️');
    } else if (level < 20) {
      return isTr ? 'Viraj Avcısı 🏍️' : (isDe ? 'Kurvenjäger 🏍️' : 'Corner Hunter 🏍️');
    } else if (level < 35) {
      return isTr ? 'Uzun Yol Kurdu 🏁' : (isDe ? 'Langstrecken-Wolf 🏁' : 'Long Haul Wolf 🏁');
    } else if (level < 50) {
      return isTr ? 'Otoban Şövalyesi ⚡' : (isDe ? 'Autobahn-Ritter ⚡' : 'Highway Knight ⚡');
    } else if (level < 70) {
      return isTr ? 'Apex Ustası 🏆' : (isDe ? 'Apex-Meister 🏆' : 'Apex Master 🏆');
    } else if (level < 85) {
      return isTr ? 'Pist Efsanesi 🔥' : (isDe ? 'Rennstrecken-Legende 🔥' : 'Track Legend 🔥');
    } else if (level < 100) {
      return isTr ? 'Zirve Kaptanı 💎' : (isDe ? 'Gipfel-Kapitän 💎' : 'Summit Captain 💎');
    } else {
      return isTr ? 'ÖLÜMSÜZ RİDER 👑' : (isDe ? 'UNSTERBLICHER FAHRER 👑' : 'IMMORTAL RIDER 👑');
    }
  }

  /// Belirli bir level için kazanılacak ödül varsa getirir.
  static LevelReward? getRewardForLevel(int level) {
    try {
      return milestoneRewards.firstWhere((r) => r.level == level);
    } catch (_) {
      return null;
    }
  }
}
