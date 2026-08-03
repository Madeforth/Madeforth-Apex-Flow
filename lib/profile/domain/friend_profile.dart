class FriendProfile {
  const FriendProfile({
    required this.stableId,
    required this.name,
    required this.riderTag,
    required this.ridingStyle,
    required this.avatarIndex,
    required this.activeBikeName,
    required this.activeBikeModel,
    required this.weeklyKm,
    required this.harmonyScore,
    required this.ghostMode,
    required this.modifications,
    this.phone,
    this.emergencyPhone,
    this.bloodType = '—',
    this.cardThemeIndex = 0,
    this.city = '',
    this.instagram = '',
    this.tiktok = '',
    this.youtube = '',
    this.licensePlate = '',
    this.selectedBadges = const [],
    this.supporterTier = 0,
  });

  final String stableId;
  final String name;
  final String riderTag;
  final String ridingStyle;
  final int avatarIndex;
  final String activeBikeName;
  final String activeBikeModel;
  final double weeklyKm;
  final int harmonyScore;
  final bool ghostMode;
  final List<String> modifications;
  final String? phone;
  final String? emergencyPhone;
  final String bloodType;
  final int cardThemeIndex;
  final String city;
  final String instagram;
  final String tiktok;
  final String youtube;
  final String licensePlate;
  final List<String> selectedBadges;
  final int supporterTier;

  FriendProfile copyWith({
    String? stableId,
    String? name,
    String? riderTag,
    String? ridingStyle,
    int? avatarIndex,
    String? activeBikeName,
    String? activeBikeModel,
    double? weeklyKm,
    int? harmonyScore,
    bool? ghostMode,
    List<String>? modifications,
    String? phone,
    String? emergencyPhone,
    String? bloodType,
    int? cardThemeIndex,
    String? city,
    String? instagram,
    String? tiktok,
    String? youtube,
    String? licensePlate,
    List<String>? selectedBadges,
    int? supporterTier,
  }) {
    return FriendProfile(
      stableId: stableId ?? this.stableId,
      name: name ?? this.name,
      riderTag: riderTag ?? this.riderTag,
      ridingStyle: ridingStyle ?? this.ridingStyle,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      activeBikeName: activeBikeName ?? this.activeBikeName,
      activeBikeModel: activeBikeModel ?? this.activeBikeModel,
      weeklyKm: weeklyKm ?? this.weeklyKm,
      harmonyScore: harmonyScore ?? this.harmonyScore,
      ghostMode: ghostMode ?? this.ghostMode,
      modifications: modifications ?? this.modifications,
      phone: phone ?? this.phone,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      bloodType: bloodType ?? this.bloodType,
      cardThemeIndex: cardThemeIndex ?? this.cardThemeIndex,
      city: city ?? this.city,
      instagram: instagram ?? this.instagram,
      tiktok: tiktok ?? this.tiktok,
      youtube: youtube ?? this.youtube,
      licensePlate: licensePlate ?? this.licensePlate,
      selectedBadges: selectedBadges ?? this.selectedBadges,
      supporterTier: supporterTier ?? this.supporterTier,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stableId': stableId,
      'name': name,
      'riderTag': riderTag,
      'ridingStyle': ridingStyle,
      'avatarIndex': avatarIndex,
      'activeBikeName': activeBikeName,
      'activeBikeModel': activeBikeModel,
      'weeklyKm': weeklyKm,
      'harmonyScore': harmonyScore,
      'ghostMode': ghostMode,
      'modifications': modifications,
      'phone': phone,
      'emergencyPhone': emergencyPhone,
      'bloodType': bloodType,
      'cardThemeIndex': cardThemeIndex,
      'city': city,
      'instagram': instagram,
      'tiktok': tiktok,
      'youtube': youtube,
      'licensePlate': licensePlate,
      'selectedBadges': selectedBadges,
      'supporterTier': supporterTier,
    };
  }

  factory FriendProfile.fromJson(Map<String, dynamic> json) {
    return FriendProfile(
      stableId: json['stableId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      riderTag: json['riderTag'] as String? ?? '',
      ridingStyle: json['ridingStyle'] as String? ?? 'Focused',
      avatarIndex: json['avatarIndex'] as int? ?? 0,
      activeBikeName: json['activeBikeName'] as String? ?? '',
      activeBikeModel: json['activeBikeModel'] as String? ?? '',
      weeklyKm: (json['weeklyKm'] as num?)?.toDouble() ?? 0.0,
      harmonyScore: json['harmonyScore'] as int? ?? 100,
      ghostMode: json['ghostMode'] as bool? ?? false,
      modifications:
          (json['modifications'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      phone: json['phone'] as String?,
      emergencyPhone: json['emergencyPhone'] as String?,
      bloodType: json['bloodType'] as String? ?? '—',
      cardThemeIndex: json['cardThemeIndex'] as int? ?? 0,
      city: json['city'] as String? ?? '',
      instagram: json['instagram'] as String? ?? '',
      tiktok: json['tiktok'] as String? ?? '',
      youtube: json['youtube'] as String? ?? '',
      licensePlate: json['licensePlate'] as String? ?? '',
      selectedBadges:
          (json['selectedBadges'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      supporterTier: json['supporterTier'] as int? ?? 0,
    );
  }
}
