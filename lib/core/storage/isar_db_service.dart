import 'dart:io';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:apexflow/core/storage/db_service.dart';
import 'package:apexflow/core/storage/entities/motorcycle_entity.dart';
import 'package:apexflow/core/storage/entities/service_record_entity.dart';
import 'package:apexflow/core/storage/entities/ride_session_entity.dart';
import 'package:apexflow/core/storage/entities/daily_check_entity.dart';
import 'package:apexflow/core/storage/entities/document_entity.dart';
import 'package:apexflow/core/storage/entities/tax_record_entity.dart';
import 'package:apexflow/core/storage/entities/friend_entity.dart';
import 'package:apexflow/garage/domain/motorcycle_profile.dart';
import 'package:apexflow/garage/domain/service_record.dart';
import 'package:apexflow/rides/domain/ride_session.dart';
import 'package:apexflow/rituals/application/rituals_state.dart';
import 'package:apexflow/documents/domain/motorcycle_document.dart';
import 'package:apexflow/documents/domain/tax_record.dart';
import 'package:apexflow/profile/domain/friend_profile.dart';

class IsarDbService implements DbService {
  Isar? _isar;
  bool _initialized = false;

  bool _isFallback = false;

  @override
  Future<void> init() async {
    if (_initialized) return;
    String path = '';
    if (!kIsWeb) {
      final dir = await getApplicationDocumentsDirectory();
      path = dir.path;
    }

    final schemas = [
      MotorcycleEntitySchema,
      ServiceRecordEntitySchema,
      RideSessionEntitySchema,
      DailyCheckEntitySchema,
      DocumentEntitySchema,
      TaxRecordEntitySchema,
      FriendEntitySchema,
    ];

    try {
      _isar = Isar.getInstance() ?? await Isar.open(schemas, directory: path);
    } catch (e) {
      debugPrint('[IsarDbService] Isar open error: $e');
      try {
        Isar.getInstance()?.close();
      } catch (_) {}

      // AF-QA-006: Backup DB before any recovery attempt instead of deleting user files!
      if (path.isNotEmpty) {
        try {
          final isarFile = File('$path/default.isar');
          if (await isarFile.exists()) {
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            await isarFile.copy('$path/default.isar.bak.$timestamp');
            debugPrint(
              '[IsarDbService] Safety backup created: default.isar.bak.$timestamp',
            );
          }
        } catch (backupError) {
          debugPrint('[IsarDbService] Backup creation error: $backupError');
        }
      }

      try {
        _isar = await Isar.open(schemas, directory: path);
      } catch (e2) {
        debugPrint(
          '[IsarDbService] Isar open retry failed, using read-only fallback: $e2',
        );
        _isFallback = true;
      }
    }
    _initialized = true;
  }

  Isar get _db => _isar!;

  @override
  Future<List<MotorcycleProfile>> getMotorcycles({String? userId}) async {
    if (userId == null || userId.isEmpty) {
      return []; // Strict privacy: never expose local records without an owner id
    }
    final list = await _db
        .collection<MotorcycleEntity>()
        .filter()
        .userIdEqualTo(userId)
        .findAll();
    return list.map((e) => e.toDomain()).toList();
  }

  @override
  Future<void> saveMotorcycle(MotorcycleProfile bike, {String? userId}) async {
    final ownerId = userId ?? '';
    await _db.writeTxn(() async {
      final existing = await _db
          .collection<MotorcycleEntity>()
          .filter()
          .stableIdEqualTo(bike.id)
          .and()
          .userIdEqualTo(ownerId)
          .findFirst();
      final entity = MotorcycleEntity.fromDomain(bike, userId: ownerId);
      if (existing != null) {
        entity.id = existing.id;
      }
      await _db.collection<MotorcycleEntity>().put(entity);
    });
  }

  @override
  Future<void> deleteMotorcycle(String bikeStableId) async {
    await _db.writeTxn(() async {
      final existing = await _db
          .collection<MotorcycleEntity>()
          .filter()
          .stableIdEqualTo(bikeStableId)
          .findFirst();
      if (existing != null) {
        await _db.collection<MotorcycleEntity>().delete(existing.id);
      }
      final services = await _db
          .collection<ServiceRecordEntity>()
          .filter()
          .bikeStableIdEqualTo(bikeStableId)
          .findAll();
      for (final s in services) {
        await _db.collection<ServiceRecordEntity>().delete(s.id);
      }
    });
  }

  @override
  Future<List<ServiceRecord>> getServiceRecords({String? userId}) async {
    if (userId == null || userId.isEmpty) {
      return [];
    }
    final list = await _db
        .collection<ServiceRecordEntity>()
        .filter()
        .userIdEqualTo(userId)
        .findAll();
    return list.map((e) => e.toDomain()).toList();
  }

  @override
  Future<void> saveServiceRecord(
    ServiceRecord record,
    String bikeStableId, {
    String? userId,
  }) async {
    final ownerId = userId ?? '';
    await _db.writeTxn(() async {
      final existing = await _db
          .collection<ServiceRecordEntity>()
          .filter()
          .stableIdEqualTo(record.id)
          .and()
          .userIdEqualTo(ownerId)
          .findFirst();
      final entity = ServiceRecordEntity.fromDomain(
        record,
        bikeStableId,
        userId: ownerId,
      );
      if (existing != null) {
        entity.id = existing.id;
      }
      await _db.collection<ServiceRecordEntity>().put(entity);
    });
  }

  @override
  Future<void> deleteServiceRecord(String recordId, String bikeStableId) async {
    await _db.writeTxn(() async {
      final existing = await _db
          .collection<ServiceRecordEntity>()
          .filter()
          .stableIdEqualTo(recordId)
          .findFirst();
      if (existing != null) {
        await _db.collection<ServiceRecordEntity>().delete(existing.id);
      }
    });
  }

  @override
  Future<List<RideSession>> getRideSessions({String? userId}) async {
    if (userId == null || userId.isEmpty) {
      return []; // Strict privacy: never expose rides if user is unauthenticated
    }
    final list = await _db
        .collection<RideSessionEntity>()
        .filter()
        .userIdEqualTo(userId)
        .findAll();
    return list.map((e) => e.toDomain()).toList();
  }

  @override
  Future<void> saveRideSession(
    RideSession session,
    String bikeStableId, {
    String? userId,
  }) async {
    await _db.writeTxn(() async {
      final entity = RideSessionEntity.fromDomain(
        session,
        bikeStableId,
        userId: userId ?? '',
      );
      await _db.collection<RideSessionEntity>().put(entity);
    });
  }

  @override
  Future<List<DailyCheckEntry>> getDailyChecks({String? userId}) async {
    if (userId == null || userId.isEmpty) {
      return [];
    }
    final list = await _db
        .collection<DailyCheckEntity>()
        .filter()
        .userIdEqualTo(userId)
        .findAll();
    return list.map((e) => e.toDomain()).toList();
  }

  @override
  Future<void> saveDailyCheck(DailyCheckEntry entry, {String? userId}) async {
    final ownerId = userId ?? '';
    await _db.writeTxn(() async {
      final existing = await _db
          .collection<DailyCheckEntity>()
          .filter()
          .isoDateEqualTo(entry.isoDate)
          .and()
          .userIdEqualTo(ownerId)
          .findFirst();
      final entity = DailyCheckEntity.fromDomain(entry, userId: ownerId);
      if (existing != null) {
        entity.id = existing.id;
      }
      await _db.collection<DailyCheckEntity>().put(entity);
    });
  }

  @override
  Future<List<MotorcycleDocument>> getDocuments({String? userId}) async {
    if (userId == null || userId.isEmpty) {
      return [];
    }
    final list = await _db
        .collection<DocumentEntity>()
        .filter()
        .userIdEqualTo(userId)
        .findAll();
    return list.map((e) => e.toDomain()).toList();
  }

  @override
  Future<void> saveDocument(MotorcycleDocument doc, {String? userId}) async {
    final ownerId = userId ?? '';
    await _db.writeTxn(() async {
      final existing = await _db
          .collection<DocumentEntity>()
          .filter()
          .stableIdEqualTo(doc.id)
          .and()
          .userIdEqualTo(ownerId)
          .findFirst();
      final entity = DocumentEntity.fromDomain(doc, userId: ownerId);
      if (existing != null) {
        entity.id = existing.id;
      }
      await _db.collection<DocumentEntity>().put(entity);
    });
  }

  @override
  Future<void> deleteDocument(String stableId) async {
    await _db.writeTxn(() async {
      final existing = await _db
          .collection<DocumentEntity>()
          .filter()
          .stableIdEqualTo(stableId)
          .findFirst();
      if (existing != null) {
        await _db.collection<DocumentEntity>().delete(existing.id);
      }
    });
  }

  @override
  Future<List<TaxRecord>> getTaxRecords({String? userId}) async {
    if (userId == null || userId.isEmpty) {
      return [];
    }
    final list = await _db
        .collection<TaxRecordEntity>()
        .filter()
        .userIdEqualTo(userId)
        .findAll();
    return list.map((e) => e.toDomain()).toList();
  }

  @override
  Future<void> saveTaxRecord(TaxRecord record, {String? userId}) async {
    final ownerId = userId ?? '';
    await _db.writeTxn(() async {
      final existing = await _db
          .collection<TaxRecordEntity>()
          .filter()
          .stableIdEqualTo(record.id)
          .and()
          .userIdEqualTo(ownerId)
          .findFirst();
      final entity = TaxRecordEntity.fromDomain(record, userId: ownerId);
      if (existing != null) {
        entity.id = existing.id;
      }
      await _db.collection<TaxRecordEntity>().put(entity);
    });
  }

  @override
  Future<void> deleteTaxRecord(String stableId) async {
    await _db.writeTxn(() async {
      final existing = await _db
          .collection<TaxRecordEntity>()
          .filter()
          .stableIdEqualTo(stableId)
          .findFirst();
      if (existing != null) {
        await _db.collection<TaxRecordEntity>().delete(existing.id);
      }
    });
  }

  @override
  Future<List<FriendProfile>> getFriends({String? userId}) async {
    if (userId == null || userId.isEmpty) {
      return [];
    }
    final list = await _db
        .collection<FriendEntity>()
        .filter()
        .userIdEqualTo(userId)
        .findAll();
    return list.map((e) => e.toDomain()).toList();
  }

  @override
  Future<void> saveFriend(FriendProfile friend, {String? userId}) async {
    final ownerId = userId ?? '';
    await _db.writeTxn(() async {
      final existing = await _db
          .collection<FriendEntity>()
          .filter()
          .stableIdEqualTo(friend.stableId)
          .and()
          .userIdEqualTo(ownerId)
          .findFirst();
      final entity = FriendEntity.fromDomain(friend, userId: ownerId);
      if (existing != null) {
        entity.id = existing.id;
      }
      await _db.collection<FriendEntity>().put(entity);
    });
  }

  @override
  Future<void> deleteFriend(String stableId) async {
    await _db.writeTxn(() async {
      final existing = await _db
          .collection<FriendEntity>()
          .filter()
          .stableIdEqualTo(stableId)
          .findFirst();
      if (existing != null) {
        await _db.collection<FriendEntity>().delete(existing.id);
      }
    });
  }

  @override
  Future<void> backfillOwnerId(String ownerId) async {
    if (ownerId.isEmpty) return;
    await _db.writeTxn(() async {
      final bikes = await _db
          .collection<MotorcycleEntity>()
          .filter()
          .userIdEqualTo('')
          .findAll();
      for (final e in bikes) {
        e.userId = ownerId;
        await _db.collection<MotorcycleEntity>().put(e);
      }

      final services = await _db
          .collection<ServiceRecordEntity>()
          .filter()
          .userIdEqualTo('')
          .findAll();
      for (final e in services) {
        e.userId = ownerId;
        await _db.collection<ServiceRecordEntity>().put(e);
      }

      final checks = await _db
          .collection<DailyCheckEntity>()
          .filter()
          .userIdEqualTo('')
          .findAll();
      for (final e in checks) {
        e.userId = ownerId;
        await _db.collection<DailyCheckEntity>().put(e);
      }

      final docs = await _db
          .collection<DocumentEntity>()
          .filter()
          .userIdEqualTo('')
          .findAll();
      for (final e in docs) {
        e.userId = ownerId;
        await _db.collection<DocumentEntity>().put(e);
      }

      final taxes = await _db
          .collection<TaxRecordEntity>()
          .filter()
          .userIdEqualTo('')
          .findAll();
      for (final e in taxes) {
        e.userId = ownerId;
        await _db.collection<TaxRecordEntity>().put(e);
      }

      final friends = await _db
          .collection<FriendEntity>()
          .filter()
          .userIdEqualTo('')
          .findAll();
      for (final e in friends) {
        e.userId = ownerId;
        await _db.collection<FriendEntity>().put(e);
      }
    });
  }

  @override
  Future<void> clearAll() async {
    await _db.writeTxn(() async {
      await _isar?.clear();
    });
  }
}
