// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFriendEntityCollection on Isar {
  IsarCollection<FriendEntity> get friendEntitys => this.collection();
}

const FriendEntitySchema = CollectionSchema(
  name: r'FriendEntity',
  id: 2966319665544051303,
  properties: {
    r'activeBikeModel': PropertySchema(
      id: 0,
      name: r'activeBikeModel',
      type: IsarType.string,
    ),
    r'activeBikeName': PropertySchema(
      id: 1,
      name: r'activeBikeName',
      type: IsarType.string,
    ),
    r'avatarIndex': PropertySchema(
      id: 2,
      name: r'avatarIndex',
      type: IsarType.long,
    ),
    r'bloodType': PropertySchema(
      id: 3,
      name: r'bloodType',
      type: IsarType.string,
    ),
    r'cardThemeIndex': PropertySchema(
      id: 4,
      name: r'cardThemeIndex',
      type: IsarType.long,
    ),
    r'emergencyPhone': PropertySchema(
      id: 5,
      name: r'emergencyPhone',
      type: IsarType.string,
    ),
    r'ghostMode': PropertySchema(
      id: 6,
      name: r'ghostMode',
      type: IsarType.bool,
    ),
    r'harmonyScore': PropertySchema(
      id: 7,
      name: r'harmonyScore',
      type: IsarType.long,
    ),
    r'modifications': PropertySchema(
      id: 8,
      name: r'modifications',
      type: IsarType.stringList,
    ),
    r'name': PropertySchema(
      id: 9,
      name: r'name',
      type: IsarType.string,
    ),
    r'phone': PropertySchema(
      id: 10,
      name: r'phone',
      type: IsarType.string,
    ),
    r'riderTag': PropertySchema(
      id: 11,
      name: r'riderTag',
      type: IsarType.string,
    ),
    r'ridingStyle': PropertySchema(
      id: 12,
      name: r'ridingStyle',
      type: IsarType.string,
    ),
    r'stableId': PropertySchema(
      id: 13,
      name: r'stableId',
      type: IsarType.string,
    ),
    r'weeklyKm': PropertySchema(
      id: 14,
      name: r'weeklyKm',
      type: IsarType.double,
    )
  },
  estimateSize: _friendEntityEstimateSize,
  serialize: _friendEntitySerialize,
  deserialize: _friendEntityDeserialize,
  deserializeProp: _friendEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'stableId': IndexSchema(
      id: 8172736602419351792,
      name: r'stableId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'stableId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _friendEntityGetId,
  getLinks: _friendEntityGetLinks,
  attach: _friendEntityAttach,
  version: '3.1.0+1',
);

int _friendEntityEstimateSize(
  FriendEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.activeBikeModel.length * 3;
  bytesCount += 3 + object.activeBikeName.length * 3;
  {
    final value = object.bloodType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.emergencyPhone;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.modifications.length * 3;
  {
    for (var i = 0; i < object.modifications.length; i++) {
      final value = object.modifications[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.phone;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.riderTag.length * 3;
  bytesCount += 3 + object.ridingStyle.length * 3;
  bytesCount += 3 + object.stableId.length * 3;
  return bytesCount;
}

void _friendEntitySerialize(
  FriendEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.activeBikeModel);
  writer.writeString(offsets[1], object.activeBikeName);
  writer.writeLong(offsets[2], object.avatarIndex);
  writer.writeString(offsets[3], object.bloodType);
  writer.writeLong(offsets[4], object.cardThemeIndex);
  writer.writeString(offsets[5], object.emergencyPhone);
  writer.writeBool(offsets[6], object.ghostMode);
  writer.writeLong(offsets[7], object.harmonyScore);
  writer.writeStringList(offsets[8], object.modifications);
  writer.writeString(offsets[9], object.name);
  writer.writeString(offsets[10], object.phone);
  writer.writeString(offsets[11], object.riderTag);
  writer.writeString(offsets[12], object.ridingStyle);
  writer.writeString(offsets[13], object.stableId);
  writer.writeDouble(offsets[14], object.weeklyKm);
}

FriendEntity _friendEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FriendEntity();
  object.activeBikeModel = reader.readString(offsets[0]);
  object.activeBikeName = reader.readString(offsets[1]);
  object.avatarIndex = reader.readLong(offsets[2]);
  object.bloodType = reader.readStringOrNull(offsets[3]);
  object.cardThemeIndex = reader.readLongOrNull(offsets[4]);
  object.emergencyPhone = reader.readStringOrNull(offsets[5]);
  object.ghostMode = reader.readBool(offsets[6]);
  object.harmonyScore = reader.readLong(offsets[7]);
  object.id = id;
  object.modifications = reader.readStringList(offsets[8]) ?? [];
  object.name = reader.readString(offsets[9]);
  object.phone = reader.readStringOrNull(offsets[10]);
  object.riderTag = reader.readString(offsets[11]);
  object.ridingStyle = reader.readString(offsets[12]);
  object.stableId = reader.readString(offsets[13]);
  object.weeklyKm = reader.readDouble(offsets[14]);
  return object;
}

P _friendEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readStringList(offset) ?? []) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _friendEntityGetId(FriendEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _friendEntityGetLinks(FriendEntity object) {
  return [];
}

void _friendEntityAttach(
    IsarCollection<dynamic> col, Id id, FriendEntity object) {
  object.id = id;
}

extension FriendEntityByIndex on IsarCollection<FriendEntity> {
  Future<FriendEntity?> getByStableId(String stableId) {
    return getByIndex(r'stableId', [stableId]);
  }

  FriendEntity? getByStableIdSync(String stableId) {
    return getByIndexSync(r'stableId', [stableId]);
  }

  Future<bool> deleteByStableId(String stableId) {
    return deleteByIndex(r'stableId', [stableId]);
  }

  bool deleteByStableIdSync(String stableId) {
    return deleteByIndexSync(r'stableId', [stableId]);
  }

  Future<List<FriendEntity?>> getAllByStableId(List<String> stableIdValues) {
    final values = stableIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'stableId', values);
  }

  List<FriendEntity?> getAllByStableIdSync(List<String> stableIdValues) {
    final values = stableIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'stableId', values);
  }

  Future<int> deleteAllByStableId(List<String> stableIdValues) {
    final values = stableIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'stableId', values);
  }

  int deleteAllByStableIdSync(List<String> stableIdValues) {
    final values = stableIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'stableId', values);
  }

  Future<Id> putByStableId(FriendEntity object) {
    return putByIndex(r'stableId', object);
  }

  Id putByStableIdSync(FriendEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'stableId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByStableId(List<FriendEntity> objects) {
    return putAllByIndex(r'stableId', objects);
  }

  List<Id> putAllByStableIdSync(List<FriendEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'stableId', objects, saveLinks: saveLinks);
  }
}

extension FriendEntityQueryWhereSort
    on QueryBuilder<FriendEntity, FriendEntity, QWhere> {
  QueryBuilder<FriendEntity, FriendEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FriendEntityQueryWhere
    on QueryBuilder<FriendEntity, FriendEntity, QWhereClause> {
  QueryBuilder<FriendEntity, FriendEntity, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterWhereClause> stableIdEqualTo(
      String stableId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'stableId',
        value: [stableId],
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterWhereClause>
      stableIdNotEqualTo(String stableId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'stableId',
              lower: [],
              upper: [stableId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'stableId',
              lower: [stableId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'stableId',
              lower: [stableId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'stableId',
              lower: [],
              upper: [stableId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension FriendEntityQueryFilter
    on QueryBuilder<FriendEntity, FriendEntity, QFilterCondition> {
  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      activeBikeModelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeBikeModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      activeBikeModelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activeBikeModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      activeBikeModelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activeBikeModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      activeBikeModelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activeBikeModel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      activeBikeModelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'activeBikeModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      activeBikeModelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'activeBikeModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      activeBikeModelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'activeBikeModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      activeBikeModelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'activeBikeModel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      activeBikeModelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeBikeModel',
        value: '',
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      activeBikeModelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'activeBikeModel',
        value: '',
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      activeBikeNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeBikeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      activeBikeNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activeBikeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      activeBikeNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activeBikeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      activeBikeNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activeBikeName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      activeBikeNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'activeBikeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      activeBikeNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'activeBikeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      activeBikeNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'activeBikeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      activeBikeNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'activeBikeName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      activeBikeNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeBikeName',
        value: '',
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      activeBikeNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'activeBikeName',
        value: '',
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      avatarIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avatarIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      avatarIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'avatarIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      avatarIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'avatarIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      avatarIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'avatarIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      bloodTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'bloodType',
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      bloodTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'bloodType',
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      bloodTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bloodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      bloodTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bloodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      bloodTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bloodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      bloodTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bloodType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      bloodTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bloodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      bloodTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bloodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      bloodTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bloodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      bloodTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bloodType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      bloodTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bloodType',
        value: '',
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      bloodTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bloodType',
        value: '',
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      cardThemeIndexIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cardThemeIndex',
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      cardThemeIndexIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cardThemeIndex',
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      cardThemeIndexEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cardThemeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      cardThemeIndexGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cardThemeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      cardThemeIndexLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cardThemeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      cardThemeIndexBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cardThemeIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      emergencyPhoneIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'emergencyPhone',
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      emergencyPhoneIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'emergencyPhone',
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      emergencyPhoneEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'emergencyPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      emergencyPhoneGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'emergencyPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      emergencyPhoneLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'emergencyPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      emergencyPhoneBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'emergencyPhone',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      emergencyPhoneStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'emergencyPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      emergencyPhoneEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'emergencyPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      emergencyPhoneContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'emergencyPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      emergencyPhoneMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'emergencyPhone',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      emergencyPhoneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'emergencyPhone',
        value: '',
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      emergencyPhoneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'emergencyPhone',
        value: '',
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      ghostModeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ghostMode',
        value: value,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      harmonyScoreEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'harmonyScore',
        value: value,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      harmonyScoreGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'harmonyScore',
        value: value,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      harmonyScoreLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'harmonyScore',
        value: value,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      harmonyScoreBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'harmonyScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      modificationsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'modifications',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      modificationsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'modifications',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      modificationsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'modifications',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      modificationsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'modifications',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      modificationsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'modifications',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      modificationsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'modifications',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      modificationsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'modifications',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      modificationsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'modifications',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      modificationsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'modifications',
        value: '',
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      modificationsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'modifications',
        value: '',
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      modificationsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'modifications',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      modificationsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'modifications',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      modificationsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'modifications',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      modificationsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'modifications',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      modificationsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'modifications',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      modificationsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'modifications',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      phoneIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'phone',
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      phoneIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'phone',
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition> phoneEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      phoneGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition> phoneLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition> phoneBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'phone',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      phoneStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition> phoneEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition> phoneContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition> phoneMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'phone',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      phoneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'phone',
        value: '',
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      phoneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'phone',
        value: '',
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      riderTagEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'riderTag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      riderTagGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'riderTag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      riderTagLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'riderTag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      riderTagBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'riderTag',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      riderTagStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'riderTag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      riderTagEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'riderTag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      riderTagContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'riderTag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      riderTagMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'riderTag',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      riderTagIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'riderTag',
        value: '',
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      riderTagIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'riderTag',
        value: '',
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      ridingStyleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ridingStyle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      ridingStyleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ridingStyle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      ridingStyleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ridingStyle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      ridingStyleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ridingStyle',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      ridingStyleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ridingStyle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      ridingStyleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ridingStyle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      ridingStyleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ridingStyle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      ridingStyleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ridingStyle',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      ridingStyleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ridingStyle',
        value: '',
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      ridingStyleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ridingStyle',
        value: '',
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      stableIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stableId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      stableIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stableId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      stableIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stableId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      stableIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stableId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      stableIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'stableId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      stableIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'stableId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      stableIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'stableId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      stableIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'stableId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      stableIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stableId',
        value: '',
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      stableIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'stableId',
        value: '',
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      weeklyKmEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weeklyKm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      weeklyKmGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weeklyKm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      weeklyKmLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weeklyKm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterFilterCondition>
      weeklyKmBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weeklyKm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension FriendEntityQueryObject
    on QueryBuilder<FriendEntity, FriendEntity, QFilterCondition> {}

extension FriendEntityQueryLinks
    on QueryBuilder<FriendEntity, FriendEntity, QFilterCondition> {}

extension FriendEntityQuerySortBy
    on QueryBuilder<FriendEntity, FriendEntity, QSortBy> {
  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy>
      sortByActiveBikeModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeBikeModel', Sort.asc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy>
      sortByActiveBikeModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeBikeModel', Sort.desc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy>
      sortByActiveBikeName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeBikeName', Sort.asc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy>
      sortByActiveBikeNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeBikeName', Sort.desc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy> sortByAvatarIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatarIndex', Sort.asc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy>
      sortByAvatarIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatarIndex', Sort.desc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy> sortByBloodType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bloodType', Sort.asc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy> sortByBloodTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bloodType', Sort.desc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy>
      sortByCardThemeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardThemeIndex', Sort.asc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy>
      sortByCardThemeIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardThemeIndex', Sort.desc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy>
      sortByEmergencyPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emergencyPhone', Sort.asc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy>
      sortByEmergencyPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emergencyPhone', Sort.desc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy> sortByGhostMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ghostMode', Sort.asc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy> sortByGhostModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ghostMode', Sort.desc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy> sortByHarmonyScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'harmonyScore', Sort.asc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy>
      sortByHarmonyScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'harmonyScore', Sort.desc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy> sortByPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.asc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy> sortByPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.desc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy> sortByRiderTag() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'riderTag', Sort.asc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy> sortByRiderTagDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'riderTag', Sort.desc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy> sortByRidingStyle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ridingStyle', Sort.asc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy>
      sortByRidingStyleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ridingStyle', Sort.desc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy> sortByStableId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stableId', Sort.asc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy> sortByStableIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stableId', Sort.desc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy> sortByWeeklyKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyKm', Sort.asc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy> sortByWeeklyKmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyKm', Sort.desc);
    });
  }
}

extension FriendEntityQuerySortThenBy
    on QueryBuilder<FriendEntity, FriendEntity, QSortThenBy> {
  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy>
      thenByActiveBikeModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeBikeModel', Sort.asc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy>
      thenByActiveBikeModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeBikeModel', Sort.desc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy>
      thenByActiveBikeName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeBikeName', Sort.asc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy>
      thenByActiveBikeNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeBikeName', Sort.desc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy> thenByAvatarIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatarIndex', Sort.asc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy>
      thenByAvatarIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatarIndex', Sort.desc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy> thenByBloodType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bloodType', Sort.asc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy> thenByBloodTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bloodType', Sort.desc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy>
      thenByCardThemeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardThemeIndex', Sort.asc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy>
      thenByCardThemeIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardThemeIndex', Sort.desc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy>
      thenByEmergencyPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emergencyPhone', Sort.asc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy>
      thenByEmergencyPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emergencyPhone', Sort.desc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy> thenByGhostMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ghostMode', Sort.asc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy> thenByGhostModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ghostMode', Sort.desc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy> thenByHarmonyScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'harmonyScore', Sort.asc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy>
      thenByHarmonyScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'harmonyScore', Sort.desc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy> thenByPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.asc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy> thenByPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.desc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy> thenByRiderTag() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'riderTag', Sort.asc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy> thenByRiderTagDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'riderTag', Sort.desc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy> thenByRidingStyle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ridingStyle', Sort.asc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy>
      thenByRidingStyleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ridingStyle', Sort.desc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy> thenByStableId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stableId', Sort.asc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy> thenByStableIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stableId', Sort.desc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy> thenByWeeklyKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyKm', Sort.asc);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QAfterSortBy> thenByWeeklyKmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyKm', Sort.desc);
    });
  }
}

extension FriendEntityQueryWhereDistinct
    on QueryBuilder<FriendEntity, FriendEntity, QDistinct> {
  QueryBuilder<FriendEntity, FriendEntity, QDistinct> distinctByActiveBikeModel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activeBikeModel',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QDistinct> distinctByActiveBikeName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activeBikeName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QDistinct> distinctByAvatarIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'avatarIndex');
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QDistinct> distinctByBloodType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bloodType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QDistinct>
      distinctByCardThemeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cardThemeIndex');
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QDistinct> distinctByEmergencyPhone(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'emergencyPhone',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QDistinct> distinctByGhostMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ghostMode');
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QDistinct> distinctByHarmonyScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'harmonyScore');
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QDistinct>
      distinctByModifications() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'modifications');
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QDistinct> distinctByPhone(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'phone', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QDistinct> distinctByRiderTag(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'riderTag', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QDistinct> distinctByRidingStyle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ridingStyle', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QDistinct> distinctByStableId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stableId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FriendEntity, FriendEntity, QDistinct> distinctByWeeklyKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weeklyKm');
    });
  }
}

extension FriendEntityQueryProperty
    on QueryBuilder<FriendEntity, FriendEntity, QQueryProperty> {
  QueryBuilder<FriendEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FriendEntity, String, QQueryOperations>
      activeBikeModelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activeBikeModel');
    });
  }

  QueryBuilder<FriendEntity, String, QQueryOperations>
      activeBikeNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activeBikeName');
    });
  }

  QueryBuilder<FriendEntity, int, QQueryOperations> avatarIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'avatarIndex');
    });
  }

  QueryBuilder<FriendEntity, String?, QQueryOperations> bloodTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bloodType');
    });
  }

  QueryBuilder<FriendEntity, int?, QQueryOperations> cardThemeIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cardThemeIndex');
    });
  }

  QueryBuilder<FriendEntity, String?, QQueryOperations>
      emergencyPhoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'emergencyPhone');
    });
  }

  QueryBuilder<FriendEntity, bool, QQueryOperations> ghostModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ghostMode');
    });
  }

  QueryBuilder<FriendEntity, int, QQueryOperations> harmonyScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'harmonyScore');
    });
  }

  QueryBuilder<FriendEntity, List<String>, QQueryOperations>
      modificationsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'modifications');
    });
  }

  QueryBuilder<FriendEntity, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<FriendEntity, String?, QQueryOperations> phoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'phone');
    });
  }

  QueryBuilder<FriendEntity, String, QQueryOperations> riderTagProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'riderTag');
    });
  }

  QueryBuilder<FriendEntity, String, QQueryOperations> ridingStyleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ridingStyle');
    });
  }

  QueryBuilder<FriendEntity, String, QQueryOperations> stableIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stableId');
    });
  }

  QueryBuilder<FriendEntity, double, QQueryOperations> weeklyKmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weeklyKm');
    });
  }
}
