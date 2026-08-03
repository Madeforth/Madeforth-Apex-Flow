// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'motorcycle_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMotorcycleEntityCollection on Isar {
  IsarCollection<MotorcycleEntity> get motorcycleEntitys => this.collection();
}

const MotorcycleEntitySchema = CollectionSchema(
  name: r'MotorcycleEntity',
  id: -5996971742116094118,
  properties: {
    r'archived': PropertySchema(
      id: 0,
      name: r'archived',
      type: IsarType.bool,
    ),
    r'batteryHealthPercent': PropertySchema(
      id: 1,
      name: r'batteryHealthPercent',
      type: IsarType.long,
    ),
    r'brakeWearPercent': PropertySchema(
      id: 2,
      name: r'brakeWearPercent',
      type: IsarType.long,
    ),
    r'chainWearPercent': PropertySchema(
      id: 3,
      name: r'chainWearPercent',
      type: IsarType.long,
    ),
    r'lastServiceKm': PropertySchema(
      id: 4,
      name: r'lastServiceKm',
      type: IsarType.long,
    ),
    r'model': PropertySchema(
      id: 5,
      name: r'model',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 6,
      name: r'name',
      type: IsarType.string,
    ),
    r'odometerKm': PropertySchema(
      id: 7,
      name: r'odometerKm',
      type: IsarType.long,
    ),
    r'oilHealthPercent': PropertySchema(
      id: 8,
      name: r'oilHealthPercent',
      type: IsarType.long,
    ),
    r'serviceIntervalKm': PropertySchema(
      id: 9,
      name: r'serviceIntervalKm',
      type: IsarType.long,
    ),
    r'stableId': PropertySchema(
      id: 10,
      name: r'stableId',
      type: IsarType.string,
    ),
    r'tireWearPercent': PropertySchema(
      id: 11,
      name: r'tireWearPercent',
      type: IsarType.long,
    )
  },
  estimateSize: _motorcycleEntityEstimateSize,
  serialize: _motorcycleEntitySerialize,
  deserialize: _motorcycleEntityDeserialize,
  deserializeProp: _motorcycleEntityDeserializeProp,
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
  getId: _motorcycleEntityGetId,
  getLinks: _motorcycleEntityGetLinks,
  attach: _motorcycleEntityAttach,
  version: '3.1.0+1',
);

int _motorcycleEntityEstimateSize(
  MotorcycleEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.model.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.stableId.length * 3;
  return bytesCount;
}

void _motorcycleEntitySerialize(
  MotorcycleEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.archived);
  writer.writeLong(offsets[1], object.batteryHealthPercent);
  writer.writeLong(offsets[2], object.brakeWearPercent);
  writer.writeLong(offsets[3], object.chainWearPercent);
  writer.writeLong(offsets[4], object.lastServiceKm);
  writer.writeString(offsets[5], object.model);
  writer.writeString(offsets[6], object.name);
  writer.writeLong(offsets[7], object.odometerKm);
  writer.writeLong(offsets[8], object.oilHealthPercent);
  writer.writeLong(offsets[9], object.serviceIntervalKm);
  writer.writeString(offsets[10], object.stableId);
  writer.writeLong(offsets[11], object.tireWearPercent);
}

MotorcycleEntity _motorcycleEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MotorcycleEntity();
  object.archived = reader.readBool(offsets[0]);
  object.batteryHealthPercent = reader.readLong(offsets[1]);
  object.brakeWearPercent = reader.readLong(offsets[2]);
  object.chainWearPercent = reader.readLong(offsets[3]);
  object.id = id;
  object.lastServiceKm = reader.readLong(offsets[4]);
  object.model = reader.readString(offsets[5]);
  object.name = reader.readString(offsets[6]);
  object.odometerKm = reader.readLong(offsets[7]);
  object.oilHealthPercent = reader.readLong(offsets[8]);
  object.serviceIntervalKm = reader.readLong(offsets[9]);
  object.stableId = reader.readString(offsets[10]);
  object.tireWearPercent = reader.readLong(offsets[11]);
  return object;
}

P _motorcycleEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _motorcycleEntityGetId(MotorcycleEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _motorcycleEntityGetLinks(MotorcycleEntity object) {
  return [];
}

void _motorcycleEntityAttach(
    IsarCollection<dynamic> col, Id id, MotorcycleEntity object) {
  object.id = id;
}

extension MotorcycleEntityByIndex on IsarCollection<MotorcycleEntity> {
  Future<MotorcycleEntity?> getByStableId(String stableId) {
    return getByIndex(r'stableId', [stableId]);
  }

  MotorcycleEntity? getByStableIdSync(String stableId) {
    return getByIndexSync(r'stableId', [stableId]);
  }

  Future<bool> deleteByStableId(String stableId) {
    return deleteByIndex(r'stableId', [stableId]);
  }

  bool deleteByStableIdSync(String stableId) {
    return deleteByIndexSync(r'stableId', [stableId]);
  }

  Future<List<MotorcycleEntity?>> getAllByStableId(
      List<String> stableIdValues) {
    final values = stableIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'stableId', values);
  }

  List<MotorcycleEntity?> getAllByStableIdSync(List<String> stableIdValues) {
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

  Future<Id> putByStableId(MotorcycleEntity object) {
    return putByIndex(r'stableId', object);
  }

  Id putByStableIdSync(MotorcycleEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'stableId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByStableId(List<MotorcycleEntity> objects) {
    return putAllByIndex(r'stableId', objects);
  }

  List<Id> putAllByStableIdSync(List<MotorcycleEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'stableId', objects, saveLinks: saveLinks);
  }
}

extension MotorcycleEntityQueryWhereSort
    on QueryBuilder<MotorcycleEntity, MotorcycleEntity, QWhere> {
  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MotorcycleEntityQueryWhere
    on QueryBuilder<MotorcycleEntity, MotorcycleEntity, QWhereClause> {
  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterWhereClause>
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

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterWhereClause> idBetween(
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

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterWhereClause>
      stableIdEqualTo(String stableId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'stableId',
        value: [stableId],
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterWhereClause>
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

extension MotorcycleEntityQueryFilter
    on QueryBuilder<MotorcycleEntity, MotorcycleEntity, QFilterCondition> {
  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      archivedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'archived',
        value: value,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      batteryHealthPercentEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'batteryHealthPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      batteryHealthPercentGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'batteryHealthPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      batteryHealthPercentLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'batteryHealthPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      batteryHealthPercentBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'batteryHealthPercent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      brakeWearPercentEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'brakeWearPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      brakeWearPercentGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'brakeWearPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      brakeWearPercentLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'brakeWearPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      brakeWearPercentBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'brakeWearPercent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      chainWearPercentEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chainWearPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      chainWearPercentGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chainWearPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      chainWearPercentLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chainWearPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      chainWearPercentBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chainWearPercent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
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

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
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

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
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

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      lastServiceKmEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastServiceKm',
        value: value,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      lastServiceKmGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastServiceKm',
        value: value,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      lastServiceKmLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastServiceKm',
        value: value,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      lastServiceKmBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastServiceKm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      modelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      modelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      modelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      modelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'model',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      modelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      modelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      modelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      modelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'model',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      modelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'model',
        value: '',
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      modelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'model',
        value: '',
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      nameEqualTo(
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

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
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

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      nameLessThan(
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

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      nameBetween(
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

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
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

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      nameEndsWith(
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

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      odometerKmEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'odometerKm',
        value: value,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      odometerKmGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'odometerKm',
        value: value,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      odometerKmLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'odometerKm',
        value: value,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      odometerKmBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'odometerKm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      oilHealthPercentEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'oilHealthPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      oilHealthPercentGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'oilHealthPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      oilHealthPercentLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'oilHealthPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      oilHealthPercentBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'oilHealthPercent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      serviceIntervalKmEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serviceIntervalKm',
        value: value,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      serviceIntervalKmGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'serviceIntervalKm',
        value: value,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      serviceIntervalKmLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'serviceIntervalKm',
        value: value,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      serviceIntervalKmBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'serviceIntervalKm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
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

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
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

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
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

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
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

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
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

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
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

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      stableIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'stableId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      stableIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'stableId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      stableIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stableId',
        value: '',
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      stableIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'stableId',
        value: '',
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      tireWearPercentEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tireWearPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      tireWearPercentGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tireWearPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      tireWearPercentLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tireWearPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterFilterCondition>
      tireWearPercentBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tireWearPercent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MotorcycleEntityQueryObject
    on QueryBuilder<MotorcycleEntity, MotorcycleEntity, QFilterCondition> {}

extension MotorcycleEntityQueryLinks
    on QueryBuilder<MotorcycleEntity, MotorcycleEntity, QFilterCondition> {}

extension MotorcycleEntityQuerySortBy
    on QueryBuilder<MotorcycleEntity, MotorcycleEntity, QSortBy> {
  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      sortByArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'archived', Sort.asc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      sortByArchivedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'archived', Sort.desc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      sortByBatteryHealthPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batteryHealthPercent', Sort.asc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      sortByBatteryHealthPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batteryHealthPercent', Sort.desc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      sortByBrakeWearPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brakeWearPercent', Sort.asc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      sortByBrakeWearPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brakeWearPercent', Sort.desc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      sortByChainWearPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chainWearPercent', Sort.asc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      sortByChainWearPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chainWearPercent', Sort.desc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      sortByLastServiceKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastServiceKm', Sort.asc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      sortByLastServiceKmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastServiceKm', Sort.desc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy> sortByModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.asc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      sortByModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.desc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      sortByOdometerKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'odometerKm', Sort.asc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      sortByOdometerKmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'odometerKm', Sort.desc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      sortByOilHealthPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oilHealthPercent', Sort.asc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      sortByOilHealthPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oilHealthPercent', Sort.desc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      sortByServiceIntervalKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceIntervalKm', Sort.asc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      sortByServiceIntervalKmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceIntervalKm', Sort.desc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      sortByStableId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stableId', Sort.asc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      sortByStableIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stableId', Sort.desc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      sortByTireWearPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tireWearPercent', Sort.asc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      sortByTireWearPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tireWearPercent', Sort.desc);
    });
  }
}

extension MotorcycleEntityQuerySortThenBy
    on QueryBuilder<MotorcycleEntity, MotorcycleEntity, QSortThenBy> {
  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      thenByArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'archived', Sort.asc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      thenByArchivedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'archived', Sort.desc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      thenByBatteryHealthPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batteryHealthPercent', Sort.asc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      thenByBatteryHealthPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batteryHealthPercent', Sort.desc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      thenByBrakeWearPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brakeWearPercent', Sort.asc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      thenByBrakeWearPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brakeWearPercent', Sort.desc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      thenByChainWearPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chainWearPercent', Sort.asc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      thenByChainWearPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chainWearPercent', Sort.desc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      thenByLastServiceKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastServiceKm', Sort.asc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      thenByLastServiceKmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastServiceKm', Sort.desc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy> thenByModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.asc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      thenByModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.desc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      thenByOdometerKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'odometerKm', Sort.asc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      thenByOdometerKmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'odometerKm', Sort.desc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      thenByOilHealthPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oilHealthPercent', Sort.asc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      thenByOilHealthPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oilHealthPercent', Sort.desc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      thenByServiceIntervalKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceIntervalKm', Sort.asc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      thenByServiceIntervalKmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceIntervalKm', Sort.desc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      thenByStableId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stableId', Sort.asc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      thenByStableIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stableId', Sort.desc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      thenByTireWearPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tireWearPercent', Sort.asc);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QAfterSortBy>
      thenByTireWearPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tireWearPercent', Sort.desc);
    });
  }
}

extension MotorcycleEntityQueryWhereDistinct
    on QueryBuilder<MotorcycleEntity, MotorcycleEntity, QDistinct> {
  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QDistinct>
      distinctByArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'archived');
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QDistinct>
      distinctByBatteryHealthPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'batteryHealthPercent');
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QDistinct>
      distinctByBrakeWearPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'brakeWearPercent');
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QDistinct>
      distinctByChainWearPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chainWearPercent');
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QDistinct>
      distinctByLastServiceKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastServiceKm');
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QDistinct> distinctByModel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'model', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QDistinct>
      distinctByOdometerKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'odometerKm');
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QDistinct>
      distinctByOilHealthPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'oilHealthPercent');
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QDistinct>
      distinctByServiceIntervalKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serviceIntervalKm');
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QDistinct>
      distinctByStableId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stableId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MotorcycleEntity, MotorcycleEntity, QDistinct>
      distinctByTireWearPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tireWearPercent');
    });
  }
}

extension MotorcycleEntityQueryProperty
    on QueryBuilder<MotorcycleEntity, MotorcycleEntity, QQueryProperty> {
  QueryBuilder<MotorcycleEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MotorcycleEntity, bool, QQueryOperations> archivedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'archived');
    });
  }

  QueryBuilder<MotorcycleEntity, int, QQueryOperations>
      batteryHealthPercentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'batteryHealthPercent');
    });
  }

  QueryBuilder<MotorcycleEntity, int, QQueryOperations>
      brakeWearPercentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'brakeWearPercent');
    });
  }

  QueryBuilder<MotorcycleEntity, int, QQueryOperations>
      chainWearPercentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chainWearPercent');
    });
  }

  QueryBuilder<MotorcycleEntity, int, QQueryOperations>
      lastServiceKmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastServiceKm');
    });
  }

  QueryBuilder<MotorcycleEntity, String, QQueryOperations> modelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'model');
    });
  }

  QueryBuilder<MotorcycleEntity, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<MotorcycleEntity, int, QQueryOperations> odometerKmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'odometerKm');
    });
  }

  QueryBuilder<MotorcycleEntity, int, QQueryOperations>
      oilHealthPercentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'oilHealthPercent');
    });
  }

  QueryBuilder<MotorcycleEntity, int, QQueryOperations>
      serviceIntervalKmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serviceIntervalKm');
    });
  }

  QueryBuilder<MotorcycleEntity, String, QQueryOperations> stableIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stableId');
    });
  }

  QueryBuilder<MotorcycleEntity, int, QQueryOperations>
      tireWearPercentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tireWearPercent');
    });
  }
}
