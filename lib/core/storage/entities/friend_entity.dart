import 'package:isar/isar.dart';
import 'package:apexflow/profile/domain/friend_profile.dart';

part 'friend_entity.g.dart';

@collection
class FriendEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String stableId;

  @Index()
  String userId = '';

  late String name;
  late String riderTag;
  late String ridingStyle;
  late int avatarIndex;
  late String activeBikeName;
  late String activeBikeModel;
  late double weeklyKm;
  late int harmonyScore;
  late bool ghostMode;
  late List<String> modifications;
  String? phone;
  String? emergencyPhone;
  String? bloodType;
  int? cardThemeIndex;

  FriendProfile toDomain() {
    return FriendProfile(
      stableId: stableId,
      name: name,
      riderTag: riderTag,
      ridingStyle: ridingStyle,
      avatarIndex: avatarIndex,
      activeBikeName: activeBikeName,
      activeBikeModel: activeBikeModel,
      weeklyKm: weeklyKm,
      harmonyScore: harmonyScore,
      ghostMode: ghostMode,
      modifications: modifications,
      phone: phone,
      emergencyPhone: emergencyPhone,
      bloodType: bloodType ?? '—',
      cardThemeIndex: cardThemeIndex ?? 0,
    );
  }

  static FriendEntity fromDomain(FriendProfile domain, {String userId = ''}) {
    return FriendEntity()
      ..stableId = domain.stableId
      ..userId = userId
      ..name = domain.name
      ..riderTag = domain.riderTag
      ..ridingStyle = domain.ridingStyle
      ..avatarIndex = domain.avatarIndex
      ..activeBikeName = domain.activeBikeName
      ..activeBikeModel = domain.activeBikeModel
      ..weeklyKm = domain.weeklyKm
      ..harmonyScore = domain.harmonyScore
      ..ghostMode = domain.ghostMode
      ..modifications = domain.modifications
      ..phone = domain.phone
      ..emergencyPhone = domain.emergencyPhone
      ..bloodType = domain.bloodType
      ..cardThemeIndex = domain.cardThemeIndex;
  }
}
