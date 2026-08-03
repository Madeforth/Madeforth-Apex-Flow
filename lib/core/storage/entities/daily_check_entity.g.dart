// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_check_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDailyCheckEntityCollection on Isar {
  IsarCollection<DailyCheckEntity> get dailyCheckEntitys => this.collection();
}

const DailyCheckEntitySchema = CollectionSchema(
  name: r'DailyCheckEntity',
  id: 8571863877948484570,
  properties: {
    r'batteryOk': PropertySchema(
      id: 0,
      name: r'batteryOk',
      type: IsarType.bool,
    ),
    r'brakesOk': PropertySchema(
      id: 1,
      name: r'brakesOk',
      type: IsarType.bool,
    ),
    r'chainOk': PropertySchema(
      id: 2,
      name: r'chainOk',
      type: IsarType.bool,
    ),
    r'isoDate': PropertySchema(
      id: 3,
      name: r'isoDate',
      type: IsarType.string,
    ),
    r'lightsOk': PropertySchema(
      id: 4,
      name: r'lightsOk',
      type: IsarType.bool,
    ),
    r'loggedAtIso': PropertySchema(
      id: 5,
      name: r'loggedAtIso',
      type: IsarType.string,
    ),
    r'note': PropertySchema(
      id: 6,
      name: r'note',
      type: IsarType.string,
    ),
    r'oilOk': PropertySchema(
      id: 7,
      name: r'oilOk',
      type: IsarType.bool,
    ),
    r'tiresOk': PropertySchema(
      id: 8,
      name: r'tiresOk',
      type: IsarType.bool,
    )
  },
  estimateSize: _dailyCheckEntityEstimateSize,
  serialize: _dailyCheckEntitySerialize,
  deserialize: _dailyCheckEntityDeserialize,
  deserializeProp: _dailyCheckEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'isoDate': IndexSchema(
      id: -5087741933233584201,
      name: r'isoDate',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isoDate',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _dailyCheckEntityGetId,
  getLinks: _dailyCheckEntityGetLinks,
  attach: _dailyCheckEntityAttach,
  version: '3.1.0+1',
);

int _dailyCheckEntityEstimateSize(
  DailyCheckEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.isoDate.length * 3;
  {
    final value = object.loggedAtIso;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.note.length * 3;
  return bytesCount;
}

void _dailyCheckEntitySerialize(
  DailyCheckEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.batteryOk);
  writer.writeBool(offsets[1], object.brakesOk);
  writer.writeBool(offsets[2], object.chainOk);
  writer.writeString(offsets[3], object.isoDate);
  writer.writeBool(offsets[4], object.lightsOk);
  writer.writeString(offsets[5], object.loggedAtIso);
  writer.writeString(offsets[6], object.note);
  writer.writeBool(offsets[7], object.oilOk);
  writer.writeBool(offsets[8], object.tiresOk);
}

DailyCheckEntity _dailyCheckEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DailyCheckEntity();
  object.batteryOk = reader.readBool(offsets[0]);
  object.brakesOk = reader.readBool(offsets[1]);
  object.chainOk = reader.readBool(offsets[2]);
  object.id = id;
  object.isoDate = reader.readString(offsets[3]);
  object.lightsOk = reader.readBool(offsets[4]);
  object.loggedAtIso = reader.readStringOrNull(offsets[5]);
  object.note = reader.readString(offsets[6]);
  object.oilOk = reader.readBool(offsets[7]);
  object.tiresOk = reader.readBool(offsets[8]);
  return object;
}

P _dailyCheckEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _dailyCheckEntityGetId(DailyCheckEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _dailyCheckEntityGetLinks(DailyCheckEntity object) {
  return [];
}

void _dailyCheckEntityAttach(
    IsarCollection<dynamic> col, Id id, DailyCheckEntity object) {
  object.id = id;
}

extension DailyCheckEntityByIndex on IsarCollection<DailyCheckEntity> {
  Future<DailyCheckEntity?> getByIsoDate(String isoDate) {
    return getByIndex(r'isoDate', [isoDate]);
  }

  DailyCheckEntity? getByIsoDateSync(String isoDate) {
    return getByIndexSync(r'isoDate', [isoDate]);
  }

  Future<bool> deleteByIsoDate(String isoDate) {
    return deleteByIndex(r'isoDate', [isoDate]);
  }

  bool deleteByIsoDateSync(String isoDate) {
    return deleteByIndexSync(r'isoDate', [isoDate]);
  }

  Future<List<DailyCheckEntity?>> getAllByIsoDate(List<String> isoDateValues) {
    final values = isoDateValues.map((e) => [e]).toList();
    return getAllByIndex(r'isoDate', values);
  }

  List<DailyCheckEntity?> getAllByIsoDateSync(List<String> isoDateValues) {
    final values = isoDateValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'isoDate', values);
  }

  Future<int> deleteAllByIsoDate(List<String> isoDateValues) {
    final values = isoDateValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'isoDate', values);
  }

  int deleteAllByIsoDateSync(List<String> isoDateValues) {
    final values = isoDateValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'isoDate', values);
  }

  Future<Id> putByIsoDate(DailyCheckEntity object) {
    return putByIndex(r'isoDate', object);
  }

  Id putByIsoDateSync(DailyCheckEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'isoDate', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByIsoDate(List<DailyCheckEntity> objects) {
    return putAllByIndex(r'isoDate', objects);
  }

  List<Id> putAllByIsoDateSync(List<DailyCheckEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'isoDate', objects, saveLinks: saveLinks);
  }
}

extension DailyCheckEntityQueryWhereSort
    on QueryBuilder<DailyCheckEntity, DailyCheckEntity, QWhere> {
  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DailyCheckEntityQueryWhere
    on QueryBuilder<DailyCheckEntity, DailyCheckEntity, QWhereClause> {
  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterWhereClause>
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

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterWhereClause> idBetween(
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

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterWhereClause>
      isoDateEqualTo(String isoDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isoDate',
        value: [isoDate],
      ));
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterWhereClause>
      isoDateNotEqualTo(String isoDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isoDate',
              lower: [],
              upper: [isoDate],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isoDate',
              lower: [isoDate],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isoDate',
              lower: [isoDate],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isoDate',
              lower: [],
              upper: [isoDate],
              includeUpper: false,
            ));
      }
    });
  }
}

extension DailyCheckEntityQueryFilter
    on QueryBuilder<DailyCheckEntity, DailyCheckEntity, QFilterCondition> {
  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
      batteryOkEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'batteryOk',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
      brakesOkEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'brakesOk',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
      chainOkEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chainOk',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
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

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
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

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
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

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
      isoDateEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isoDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
      isoDateGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isoDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
      isoDateLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isoDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
      isoDateBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isoDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
      isoDateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'isoDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
      isoDateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'isoDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
      isoDateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'isoDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
      isoDateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'isoDate',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
      isoDateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isoDate',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
      isoDateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'isoDate',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
      lightsOkEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lightsOk',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
      loggedAtIsoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'loggedAtIso',
      ));
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
      loggedAtIsoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'loggedAtIso',
      ));
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
      loggedAtIsoEqualTo(
    String? value, {
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

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
      loggedAtIsoGreaterThan(
    String? value, {
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

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
      loggedAtIsoLessThan(
    String? value, {
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

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
      loggedAtIsoBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
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

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
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

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
      loggedAtIsoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'loggedAtIso',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
      loggedAtIsoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'loggedAtIso',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
      loggedAtIsoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'loggedAtIso',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
      loggedAtIsoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'loggedAtIso',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
      noteEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
      noteGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
      noteLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
      noteBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'note',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
      noteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
      noteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
      noteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
      noteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'note',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
      noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
      noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
      oilOkEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'oilOk',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterFilterCondition>
      tiresOkEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tiresOk',
        value: value,
      ));
    });
  }
}

extension DailyCheckEntityQueryObject
    on QueryBuilder<DailyCheckEntity, DailyCheckEntity, QFilterCondition> {}

extension DailyCheckEntityQueryLinks
    on QueryBuilder<DailyCheckEntity, DailyCheckEntity, QFilterCondition> {}

extension DailyCheckEntityQuerySortBy
    on QueryBuilder<DailyCheckEntity, DailyCheckEntity, QSortBy> {
  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterSortBy>
      sortByBatteryOk() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batteryOk', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterSortBy>
      sortByBatteryOkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batteryOk', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterSortBy>
      sortByBrakesOk() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brakesOk', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterSortBy>
      sortByBrakesOkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brakesOk', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterSortBy>
      sortByChainOk() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chainOk', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterSortBy>
      sortByChainOkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chainOk', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterSortBy>
      sortByIsoDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isoDate', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterSortBy>
      sortByIsoDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isoDate', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterSortBy>
      sortByLightsOk() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lightsOk', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterSortBy>
      sortByLightsOkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lightsOk', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterSortBy>
      sortByLoggedAtIso() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loggedAtIso', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterSortBy>
      sortByLoggedAtIsoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loggedAtIso', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterSortBy> sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterSortBy>
      sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterSortBy> sortByOilOk() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oilOk', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterSortBy>
      sortByOilOkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oilOk', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterSortBy>
      sortByTiresOk() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tiresOk', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterSortBy>
      sortByTiresOkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tiresOk', Sort.desc);
    });
  }
}

extension DailyCheckEntityQuerySortThenBy
    on QueryBuilder<DailyCheckEntity, DailyCheckEntity, QSortThenBy> {
  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterSortBy>
      thenByBatteryOk() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batteryOk', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterSortBy>
      thenByBatteryOkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batteryOk', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterSortBy>
      thenByBrakesOk() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brakesOk', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterSortBy>
      thenByBrakesOkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brakesOk', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterSortBy>
      thenByChainOk() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chainOk', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterSortBy>
      thenByChainOkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chainOk', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterSortBy>
      thenByIsoDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isoDate', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterSortBy>
      thenByIsoDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isoDate', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterSortBy>
      thenByLightsOk() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lightsOk', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterSortBy>
      thenByLightsOkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lightsOk', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterSortBy>
      thenByLoggedAtIso() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loggedAtIso', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterSortBy>
      thenByLoggedAtIsoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loggedAtIso', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterSortBy> thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterSortBy>
      thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterSortBy> thenByOilOk() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oilOk', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterSortBy>
      thenByOilOkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oilOk', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterSortBy>
      thenByTiresOk() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tiresOk', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QAfterSortBy>
      thenByTiresOkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tiresOk', Sort.desc);
    });
  }
}

extension DailyCheckEntityQueryWhereDistinct
    on QueryBuilder<DailyCheckEntity, DailyCheckEntity, QDistinct> {
  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QDistinct>
      distinctByBatteryOk() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'batteryOk');
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QDistinct>
      distinctByBrakesOk() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'brakesOk');
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QDistinct>
      distinctByChainOk() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chainOk');
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QDistinct> distinctByIsoDate(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isoDate', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QDistinct>
      distinctByLightsOk() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lightsOk');
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QDistinct>
      distinctByLoggedAtIso({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'loggedAtIso', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QDistinct> distinctByNote(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QDistinct>
      distinctByOilOk() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'oilOk');
    });
  }

  QueryBuilder<DailyCheckEntity, DailyCheckEntity, QDistinct>
      distinctByTiresOk() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tiresOk');
    });
  }
}

extension DailyCheckEntityQueryProperty
    on QueryBuilder<DailyCheckEntity, DailyCheckEntity, QQueryProperty> {
  QueryBuilder<DailyCheckEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DailyCheckEntity, bool, QQueryOperations> batteryOkProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'batteryOk');
    });
  }

  QueryBuilder<DailyCheckEntity, bool, QQueryOperations> brakesOkProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'brakesOk');
    });
  }

  QueryBuilder<DailyCheckEntity, bool, QQueryOperations> chainOkProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chainOk');
    });
  }

  QueryBuilder<DailyCheckEntity, String, QQueryOperations> isoDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isoDate');
    });
  }

  QueryBuilder<DailyCheckEntity, bool, QQueryOperations> lightsOkProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lightsOk');
    });
  }

  QueryBuilder<DailyCheckEntity, String?, QQueryOperations>
      loggedAtIsoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'loggedAtIso');
    });
  }

  QueryBuilder<DailyCheckEntity, String, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<DailyCheckEntity, bool, QQueryOperations> oilOkProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'oilOk');
    });
  }

  QueryBuilder<DailyCheckEntity, bool, QQueryOperations> tiresOkProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tiresOk');
    });
  }
}
