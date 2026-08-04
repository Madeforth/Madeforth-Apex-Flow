// Verifies the per-entity userId wiring added for local multi-account
// isolation (see memory-bank/progress.md item #6). This does not exercise
// real Isar storage/queries — the isar.dll native library is not available
// in this test environment (see activeContext.md) — but it does verify the
// exact thing most likely to be wrong in a six-entity mechanical edit like
// this one: that fromDomain() actually assigns the userId field, and that
// omitting it still defaults safely to ''.
import 'package:apexflow/core/storage/entities/daily_check_entity.dart';
import 'package:apexflow/core/storage/entities/document_entity.dart';
import 'package:apexflow/core/storage/entities/friend_entity.dart';
import 'package:apexflow/core/storage/entities/motorcycle_entity.dart';
import 'package:apexflow/core/storage/entities/service_record_entity.dart';
import 'package:apexflow/core/storage/entities/tax_record_entity.dart';
import 'package:apexflow/documents/domain/motorcycle_document.dart';
import 'package:apexflow/documents/domain/tax_record.dart';
import 'package:apexflow/garage/domain/motorcycle_profile.dart';
import 'package:apexflow/garage/domain/service_record.dart';
import 'package:apexflow/profile/domain/friend_profile.dart';
import 'package:apexflow/rituals/application/rituals_state.dart';
import 'package:flutter_test/flutter_test.dart';

const _bike = MotorcycleProfile(
  id: 'bike-1',
  name: 'Night Vector',
  model: 'MT-07',
  odometerKm: 100,
  lastServiceKm: 0,
  chainWearPercent: 0,
  tireWearPercent: 0,
  brakeWearPercent: 0,
  oilHealthPercent: 0,
  batteryHealthPercent: 0,
  serviceIntervalKm: 6000,
);

const _service = ServiceRecord(
  id: 'svc-1',
  type: 'diy',
  label: 'Oil change',
  odometerKm: 100,
  status: 'Completed',
  note: 'note',
);

const _check = DailyCheckEntry(
  isoDate: '2026-08-04',
  tiresOk: true,
  chainOk: true,
  oilOk: true,
  brakesOk: true,
  lightsOk: true,
  batteryOk: true,
  note: '',
);

const _doc = MotorcycleDocument(
  id: 'doc-1',
  bikeStableId: 'bike-1',
  title: 'Insurance',
  description: 'desc',
);

const _tax = TaxRecord(
  id: 'tax-1',
  bikeStableId: 'bike-1',
  type: 'insurance',
  dueDateIso: '2026-12-31T00:00:00.000Z',
  amount: 100.0,
  currency: 'TRY',
  isPaid: false,
);

const _friend = FriendProfile(
  stableId: 'friend-1',
  name: 'Ahmet',
  riderTag: '@ahmet',
  ridingStyle: 'Tourer',
  avatarIndex: 0,
  activeBikeName: 'Goldwing',
  activeBikeModel: '2022',
  weeklyKm: 100,
  harmonyScore: 90,
  ghostMode: false,
  modifications: [],
);

void main() {
  group('Owner-scoped entity fromDomain wiring', () {
    test('MotorcycleEntity carries the given userId', () {
      final entity = MotorcycleEntity.fromDomain(_bike, userId: 'user-a');
      expect(entity.userId, 'user-a');
      expect(entity.stableId, 'bike-1');
    });

    test('MotorcycleEntity defaults userId to empty when omitted', () {
      final entity = MotorcycleEntity.fromDomain(_bike);
      expect(entity.userId, '');
    });

    test('ServiceRecordEntity carries the given userId', () {
      final entity = ServiceRecordEntity.fromDomain(
        _service,
        'bike-1',
        userId: 'user-a',
      );
      expect(entity.userId, 'user-a');
    });

    test('DailyCheckEntity carries the given userId', () {
      final entity = DailyCheckEntity.fromDomain(_check, userId: 'user-a');
      expect(entity.userId, 'user-a');
      expect(entity.isoDate, '2026-08-04');
    });

    test('DocumentEntity carries the given userId', () {
      final entity = DocumentEntity.fromDomain(_doc, userId: 'user-a');
      expect(entity.userId, 'user-a');
    });

    test('TaxRecordEntity carries the given userId', () {
      final entity = TaxRecordEntity.fromDomain(_tax, userId: 'user-a');
      expect(entity.userId, 'user-a');
    });

    test('FriendEntity carries the given userId', () {
      final entity = FriendEntity.fromDomain(_friend, userId: 'user-a');
      expect(entity.userId, 'user-a');
    });

    test('two different owners produce entities with different userId', () {
      final a = MotorcycleEntity.fromDomain(_bike, userId: 'user-a');
      final b = MotorcycleEntity.fromDomain(_bike, userId: 'user-b');
      expect(a.userId, isNot(equals(b.userId)));
    });
  });
}
