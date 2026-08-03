// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_session_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRideSessionEntityCollection on Isar {
  IsarCollection<RideSessionEntity> get rideSessionEntitys => this.collection();
}

const RideSessionEntitySchema = CollectionSchema(
  name: r'RideSessionEntity',
  id: -484048575117375086,
  properties: {
    r'averageSpeedKmh': PropertySchema(
      id: 0,
      name: r'averageSpeedKmh',
      type: IsarType.double,
    ),
    r'bikeStableId': PropertySchema(
      id: 1,
      name: r'bikeStableId',
      type: IsarType.string,
    ),
    r'distanceKm': PropertySchema(
      id: 2,
      name: r'distanceKm',
      type: IsarType.double,
    ),
    r'durationMinutes': PropertySchema(
      id: 3,
      name: r'durationMinutes',
      type: IsarType.long,
    ),
    r'hardAccelerations': PropertySchema(
      id: 4,
      name: r'hardAccelerations',
      type: IsarType.long,
    ),
    r'hardBrakes': PropertySchema(
      id: 5,
      name: r'hardBrakes',
      type: IsarType.long,
    ),
    r'harmonyScore': PropertySchema(
      id: 6,
      name: r'harmonyScore',
      type: IsarType.long,
    ),
    r'loggedAtIso': PropertySchema(
      id: 7,
      name: r'loggedAtIso',
      type: IsarType.string,
    ),
    r'maxLeanAngle': PropertySchema(
      id: 8,
      name: r'maxLeanAngle',
      type: IsarType.double,
    ),
    r'maxSpeedKmh': PropertySchema(
      id: 9,
      name: r'maxSpeedKmh',
      type: IsarType.double,
    ),
    r'mechanicalObservation': PropertySchema(
      id: 10,
      name: r'mechanicalObservation',
      type: IsarType.string,
    ),
    r'mood': PropertySchema(
      id: 11,
      name: r'mood',
      type: IsarType.string,
    ),
    r'userId': PropertySchema(
      id: 12,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _rideSessionEntityEstimateSize,
  serialize: _rideSessionEntitySerialize,
  deserialize: _rideSessionEntityDeserialize,
  deserializeProp: _rideSessionEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'bikeStableId': IndexSchema(
      id: -4670877578962729661,
      name: r'bikeStableId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'bikeStableId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'userId': IndexSchema(
      id: -2005826577402374815,
      name: r'userId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'userId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _rideSessionEntityGetId,
  getLinks: _rideSessionEntityGetLinks,
  attach: _rideSessionEntityAttach,
  version: '3.1.0+1',
);

int _rideSessionEntityEstimateSize(
  RideSessionEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.bikeStableId.length * 3;
  bytesCount += 3 + object.loggedAtIso.length * 3;
  bytesCount += 3 + object.mechanicalObservation.length * 3;
  bytesCount += 3 + object.mood.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _rideSessionEntitySerialize(
  RideSessionEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.averageSpeedKmh);
  writer.writeString(offsets[1], object.bikeStableId);
  writer.writeDouble(offsets[2], object.distanceKm);
  writer.writeLong(offsets[3], object.durationMinutes);
  writer.writeLong(offsets[4], object.hardAccelerations);
  writer.writeLong(offsets[5], object.hardBrakes);
  writer.writeLong(offsets[6], object.harmonyScore);
  writer.writeString(offsets[7], object.loggedAtIso);
  writer.writeDouble(offsets[8], object.maxLeanAngle);
  writer.writeDouble(offsets[9], object.maxSpeedKmh);
  writer.writeString(offsets[10], object.mechanicalObservation);
  writer.writeString(offsets[11], object.mood);
  writer.writeString(offsets[12], object.userId);
}

RideSessionEntity _rideSessionEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RideSessionEntity();
  object.averageSpeedKmh = reader.readDouble(offsets[0]);
  object.bikeStableId = reader.readString(offsets[1]);
  object.distanceKm = reader.readDouble(offsets[2]);
  object.durationMinutes = reader.readLong(offsets[3]);
  object.hardAccelerations = reader.readLong(offsets[4]);
  object.hardBrakes = reader.readLong(offsets[5]);
  object.harmonyScore = reader.readLong(offsets[6]);
  object.id = id;
  object.loggedAtIso = reader.readString(offsets[7]);
  object.maxLeanAngle = reader.readDouble(offsets[8]);
  object.maxSpeedKmh = reader.readDouble(offsets[9]);
  object.mechanicalObservation = reader.readString(offsets[10]);
  object.mood = reader.readString(offsets[11]);
  object.userId = reader.readString(offsets[12]);
  return object;
}

P _rideSessionEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDouble(offset)) as P;
    case 9:
      return (reader.readDouble(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _rideSessionEntityGetId(RideSessionEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _rideSessionEntityGetLinks(
    RideSessionEntity object) {
  return [];
}

void _rideSessionEntityAttach(
    IsarCollection<dynamic> col, Id id, RideSessionEntity object) {
  object.id = id;
}

extension RideSessionEntityQueryWhereSort
    on QueryBuilder<RideSessionEntity, RideSessionEntity, QWhere> {
  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension RideSessionEntityQueryWhere
    on QueryBuilder<RideSessionEntity, RideSessionEntity, QWhereClause> {
  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterWhereClause>
      idBetween(
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

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterWhereClause>
      bikeStableIdEqualTo(String bikeStableId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bikeStableId',
        value: [bikeStableId],
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterWhereClause>
      bikeStableIdNotEqualTo(String bikeStableId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bikeStableId',
              lower: [],
              upper: [bikeStableId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bikeStableId',
              lower: [bikeStableId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bikeStableId',
              lower: [bikeStableId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bikeStableId',
              lower: [],
              upper: [bikeStableId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterWhereClause>
      userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterWhereClause>
      userIdNotEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension RideSessionEntityQueryFilter
    on QueryBuilder<RideSessionEntity, RideSessionEntity, QFilterCondition> {
  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      averageSpeedKmhEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'averageSpeedKmh',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      averageSpeedKmhGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'averageSpeedKmh',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      averageSpeedKmhLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'averageSpeedKmh',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      averageSpeedKmhBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'averageSpeedKmh',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      bikeStableIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bikeStableId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      bikeStableIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bikeStableId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      bikeStableIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bikeStableId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      bikeStableIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bikeStableId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      bikeStableIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bikeStableId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      bikeStableIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bikeStableId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      bikeStableIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bikeStableId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      bikeStableIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bikeStableId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      bikeStableIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bikeStableId',
        value: '',
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      bikeStableIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bikeStableId',
        value: '',
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      distanceKmEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'distanceKm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      distanceKmGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'distanceKm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      distanceKmLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'distanceKm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      distanceKmBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'distanceKm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      durationMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'durationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      durationMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'durationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      durationMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'durationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      durationMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'durationMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      hardAccelerationsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hardAccelerations',
        value: value,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      hardAccelerationsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hardAccelerations',
        value: value,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      hardAccelerationsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hardAccelerations',
        value: value,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      hardAccelerationsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hardAccelerations',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      hardBrakesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hardBrakes',
        value: value,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      hardBrakesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hardBrakes',
        value: value,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      hardBrakesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hardBrakes',
        value: value,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      hardBrakesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hardBrakes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      harmonyScoreEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'harmonyScore',
        value: value,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
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

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
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

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
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

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      loggedAtIsoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'loggedAtIso',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      loggedAtIsoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'loggedAtIso',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      loggedAtIsoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'loggedAtIso',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      loggedAtIsoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'loggedAtIso',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      loggedAtIsoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'loggedAtIso',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      loggedAtIsoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'loggedAtIso',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      loggedAtIsoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'loggedAtIso',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      loggedAtIsoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'loggedAtIso',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      loggedAtIsoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'loggedAtIso',
        value: '',
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      loggedAtIsoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'loggedAtIso',
        value: '',
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      maxLeanAngleEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxLeanAngle',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      maxLeanAngleGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxLeanAngle',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      maxLeanAngleLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxLeanAngle',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      maxLeanAngleBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxLeanAngle',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      maxSpeedKmhEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxSpeedKmh',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      maxSpeedKmhGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxSpeedKmh',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      maxSpeedKmhLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxSpeedKmh',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      maxSpeedKmhBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxSpeedKmh',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      mechanicalObservationEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mechanicalObservation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      mechanicalObservationGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mechanicalObservation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      mechanicalObservationLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mechanicalObservation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      mechanicalObservationBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mechanicalObservation',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      mechanicalObservationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mechanicalObservation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      mechanicalObservationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mechanicalObservation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      mechanicalObservationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mechanicalObservation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      mechanicalObservationMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mechanicalObservation',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      mechanicalObservationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mechanicalObservation',
        value: '',
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      mechanicalObservationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mechanicalObservation',
        value: '',
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      moodEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mood',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      moodGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mood',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      moodLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mood',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      moodBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mood',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      moodStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mood',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      moodEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mood',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      moodContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mood',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      moodMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mood',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      moodIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mood',
        value: '',
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      moodIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mood',
        value: '',
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      userIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      userIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      userIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      userIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      userIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      userIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension RideSessionEntityQueryObject
    on QueryBuilder<RideSessionEntity, RideSessionEntity, QFilterCondition> {}

extension RideSessionEntityQueryLinks
    on QueryBuilder<RideSessionEntity, RideSessionEntity, QFilterCondition> {}

extension RideSessionEntityQuerySortBy
    on QueryBuilder<RideSessionEntity, RideSessionEntity, QSortBy> {
  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      sortByAverageSpeedKmh() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageSpeedKmh', Sort.asc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      sortByAverageSpeedKmhDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageSpeedKmh', Sort.desc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      sortByBikeStableId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bikeStableId', Sort.asc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      sortByBikeStableIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bikeStableId', Sort.desc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      sortByDistanceKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distanceKm', Sort.asc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      sortByDistanceKmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distanceKm', Sort.desc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      sortByDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMinutes', Sort.asc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      sortByDurationMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMinutes', Sort.desc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      sortByHardAccelerations() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hardAccelerations', Sort.asc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      sortByHardAccelerationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hardAccelerations', Sort.desc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      sortByHardBrakes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hardBrakes', Sort.asc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      sortByHardBrakesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hardBrakes', Sort.desc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      sortByHarmonyScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'harmonyScore', Sort.asc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      sortByHarmonyScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'harmonyScore', Sort.desc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      sortByLoggedAtIso() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loggedAtIso', Sort.asc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      sortByLoggedAtIsoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loggedAtIso', Sort.desc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      sortByMaxLeanAngle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxLeanAngle', Sort.asc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      sortByMaxLeanAngleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxLeanAngle', Sort.desc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      sortByMaxSpeedKmh() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxSpeedKmh', Sort.asc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      sortByMaxSpeedKmhDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxSpeedKmh', Sort.desc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      sortByMechanicalObservation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mechanicalObservation', Sort.asc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      sortByMechanicalObservationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mechanicalObservation', Sort.desc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      sortByMood() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mood', Sort.asc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      sortByMoodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mood', Sort.desc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension RideSessionEntityQuerySortThenBy
    on QueryBuilder<RideSessionEntity, RideSessionEntity, QSortThenBy> {
  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      thenByAverageSpeedKmh() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageSpeedKmh', Sort.asc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      thenByAverageSpeedKmhDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageSpeedKmh', Sort.desc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      thenByBikeStableId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bikeStableId', Sort.asc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      thenByBikeStableIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bikeStableId', Sort.desc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      thenByDistanceKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distanceKm', Sort.asc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      thenByDistanceKmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distanceKm', Sort.desc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      thenByDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMinutes', Sort.asc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      thenByDurationMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMinutes', Sort.desc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      thenByHardAccelerations() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hardAccelerations', Sort.asc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      thenByHardAccelerationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hardAccelerations', Sort.desc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      thenByHardBrakes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hardBrakes', Sort.asc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      thenByHardBrakesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hardBrakes', Sort.desc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      thenByHarmonyScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'harmonyScore', Sort.asc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      thenByHarmonyScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'harmonyScore', Sort.desc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      thenByLoggedAtIso() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loggedAtIso', Sort.asc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      thenByLoggedAtIsoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loggedAtIso', Sort.desc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      thenByMaxLeanAngle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxLeanAngle', Sort.asc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      thenByMaxLeanAngleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxLeanAngle', Sort.desc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      thenByMaxSpeedKmh() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxSpeedKmh', Sort.asc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      thenByMaxSpeedKmhDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxSpeedKmh', Sort.desc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      thenByMechanicalObservation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mechanicalObservation', Sort.asc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      thenByMechanicalObservationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mechanicalObservation', Sort.desc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      thenByMood() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mood', Sort.asc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      thenByMoodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mood', Sort.desc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension RideSessionEntityQueryWhereDistinct
    on QueryBuilder<RideSessionEntity, RideSessionEntity, QDistinct> {
  QueryBuilder<RideSessionEntity, RideSessionEntity, QDistinct>
      distinctByAverageSpeedKmh() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'averageSpeedKmh');
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QDistinct>
      distinctByBikeStableId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bikeStableId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QDistinct>
      distinctByDistanceKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'distanceKm');
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QDistinct>
      distinctByDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationMinutes');
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QDistinct>
      distinctByHardAccelerations() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hardAccelerations');
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QDistinct>
      distinctByHardBrakes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hardBrakes');
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QDistinct>
      distinctByHarmonyScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'harmonyScore');
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QDistinct>
      distinctByLoggedAtIso({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'loggedAtIso', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QDistinct>
      distinctByMaxLeanAngle() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxLeanAngle');
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QDistinct>
      distinctByMaxSpeedKmh() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxSpeedKmh');
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QDistinct>
      distinctByMechanicalObservation({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mechanicalObservation',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QDistinct> distinctByMood(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mood', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RideSessionEntity, RideSessionEntity, QDistinct>
      distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension RideSessionEntityQueryProperty
    on QueryBuilder<RideSessionEntity, RideSessionEntity, QQueryProperty> {
  QueryBuilder<RideSessionEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RideSessionEntity, double, QQueryOperations>
      averageSpeedKmhProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'averageSpeedKmh');
    });
  }

  QueryBuilder<RideSessionEntity, String, QQueryOperations>
      bikeStableIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bikeStableId');
    });
  }

  QueryBuilder<RideSessionEntity, double, QQueryOperations>
      distanceKmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'distanceKm');
    });
  }

  QueryBuilder<RideSessionEntity, int, QQueryOperations>
      durationMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationMinutes');
    });
  }

  QueryBuilder<RideSessionEntity, int, QQueryOperations>
      hardAccelerationsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hardAccelerations');
    });
  }

  QueryBuilder<RideSessionEntity, int, QQueryOperations> hardBrakesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hardBrakes');
    });
  }

  QueryBuilder<RideSessionEntity, int, QQueryOperations>
      harmonyScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'harmonyScore');
    });
  }

  QueryBuilder<RideSessionEntity, String, QQueryOperations>
      loggedAtIsoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'loggedAtIso');
    });
  }

  QueryBuilder<RideSessionEntity, double, QQueryOperations>
      maxLeanAngleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxLeanAngle');
    });
  }

  QueryBuilder<RideSessionEntity, double, QQueryOperations>
      maxSpeedKmhProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxSpeedKmh');
    });
  }

  QueryBuilder<RideSessionEntity, String, QQueryOperations>
      mechanicalObservationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mechanicalObservation');
    });
  }

  QueryBuilder<RideSessionEntity, String, QQueryOperations> moodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mood');
    });
  }

  QueryBuilder<RideSessionEntity, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
