import 'dart:io';
import 'package:apexflow/garage/application/garage_passport_pdf_service.dart';
import 'package:apexflow/garage/application/garage_state.dart';
import 'package:apexflow/garage/domain/garage_passport.dart';
import 'package:apexflow/garage/domain/motorcycle_profile.dart';
import 'package:apexflow/garage/domain/service_record.dart';
import 'package:apexflow/rides/application/ride_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:apexflow/core/i18n/app_strings.dart';

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async {
    return Directory.systemTemp.path;
  }
}

void main() {
  PathProviderPlatform.instance = MockPathProviderPlatform();
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GaragePassport Domain Model Tests', () {
    const testBike = MotorcycleProfile(
      id: 'bike-vector',
      name: 'Night Vector',
      model: 'Yamaha MT-07',
      odometerKm: 18420,
      lastServiceKm: 18000,
      chainWearPercent: 25,
      tireWearPercent: 30,
      brakeWearPercent: 15,
      oilHealthPercent: 88,
      batteryHealthPercent: 95,
      serviceIntervalKm: 6000,
    );

    final testRecords = [
      ServiceRecord(
        id: 'mock_id',
        type: 'diy',
        label: 'Oil & Filter Change',
        odometerKm: 18000,
        status: 'Completed',
        note: 'Castrol 10W-40, OEM Filter',
        loggedAtIso: '2026-06-10T12:00:00Z',
      ),
    ];

    test('toShareableText generates correct formatted text in Turkish', () {
      final passport = GaragePassport(
        bike: testBike,
        serviceRecords: testRecords,
        totalRides: 12,
        totalDistanceKm: 450.5,
        averageRideDistanceKm: 37.5,
        harmonyScore: 92,
        harmonyLevel: 'Mükemmel',
        harmonyInsight: 'Makine durumunuz çok dengeli.',
        generatedAtIso: '2026-06-11T04:00:00Z',
      );

      AppStrings.currentLanguageCode = 'tr';
      final text = passport.toShareableText(tr: true);

      expect(text, contains('GARAJ PASAPORTU'));
      expect(text, contains('Night Vector — Yamaha MT-07'));
      expect(text, contains('Kilometre: 18420 km'));
      expect(text, contains('Skor: 92 / 100 (Mükemmel)'));
      expect(text, contains('Zincir: 25% aşınma'));
      expect(text, contains('Akü: 95% sağlık'));
      expect(text, contains('Toplam sürüş: 12'));
      expect(text, contains('Toplam mesafe: 450.5 km'));
      expect(text, contains('Ort. mesafe: 37.5 km'));
      expect(text, contains('Oil & Filter Change — 18000 km (10.06.2026)'));
    });

    test('toShareableText generates correct formatted text in English', () {
      final passport = GaragePassport(
        bike: testBike,
        serviceRecords: testRecords,
        totalRides: 5,
        totalDistanceKm: 100.0,
        averageRideDistanceKm: 20.0,
        harmonyScore: 75,
        harmonyLevel: 'Stable',
        harmonyInsight: 'Keep doing regular checks.',
        generatedAtIso: '2026-06-11T04:00:00Z',
      );

      AppStrings.currentLanguageCode = 'en';
      final text = passport.toShareableText(tr: false);

      expect(text, contains('GARAGE PASSPORT'));
      expect(text, contains('Odometer: 18420 km'));
      expect(text, contains('Score: 75 / 100 (Stable)'));
      expect(text, contains('Chain: 25% wear'));
      expect(text, contains('Battery: 95% health'));
      expect(text, contains('Total rides: 5'));
      expect(text, contains('Total distance: 100.0 km'));
      expect(text, contains('Avg. distance: 20.0 km'));
      expect(text, contains('Oil & Filter Change — 18000 km (06/10/2026)'));
    });

    test('toShareableText handles empty lists and fallback states', () {
      final passport = GaragePassport(
        bike: testBike,
        serviceRecords: const [],
        totalRides: 0,
        totalDistanceKm: 0.0,
        averageRideDistanceKm: 0.0,
        harmonyScore: 100,
        harmonyLevel: 'Optimal',
        harmonyInsight: 'All clear.',
        generatedAtIso: '1970-01-01T00:00:00Z', // Unknown/Fallback date
      );

      AppStrings.currentLanguageCode = 'en';
      final textEn = passport.toShareableText(tr: false);
      expect(textEn, contains('Unknown'));
      expect(textEn, isNot(contains('Recent Service Records')));
      expect(textEn, isNot(contains('Avg. distance')));

      AppStrings.currentLanguageCode = 'tr';
      final textTr = passport.toShareableText(tr: true);
      expect(textTr, contains('Bilinmiyor'));
      expect(textTr, isNot(contains('Son Servis Kayıtları')));
    });
  });

  group('GarageController buildPassport() Integration Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test(
      'buildPassport aggregates correctly from state and other providers',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final garageController = container.read(garageStateProvider.notifier);
        final rideController = container.read(rideStateProvider.notifier);

        // Hydrate state
        await Future<void>.delayed(Duration.zero);

        // Add a custom bike
        garageController.addMotorcycle(
          name: 'Thunderbolt',
          model: 'Suzuki SV650',
          odometerKm: 5000,
        );

        // Add some rides
        rideController.startRide(mood: 'Focused');
        rideController.endRide(
          distanceKm: 12.5,
          durationMinutes: 5,
          averageSpeedKmh: 45.0,
          mood: 'Focused',
          mechanicalObservation: 'Stable',
        );

        rideController.startRide(mood: 'Sporty');
        rideController.endRide(
          distanceKm: 27.5,
          durationMinutes: 10,
          averageSpeedKmh: 55.0,
          mood: 'Sporty',
          mechanicalObservation: 'Great response',
        );

        // Add a service record
        garageController.addServiceRecord(
          type: 'diy',
          label: 'First Inspection',
          odometerKm: 1000,
          note: 'All valves checked',
        );

        final passport = garageController.buildPassport();

        expect(passport.bike.name, 'Thunderbolt');
        expect(passport.totalRides, 2);
        expect(passport.totalDistanceKm, closeTo(40.0, 0.01));
        expect(passport.averageRideDistanceKm, closeTo(20.0, 0.01));
        expect(passport.serviceRecords.length, 1);
        expect(passport.serviceRecords.first.label, 'First Inspection');
        expect(passport.harmonyScore, inInclusiveRange(0, 100));
        expect(passport.harmonyLevel, isNotEmpty);
        expect(passport.harmonyInsight, isNotEmpty);
      },
    );
  });

  group('GaragePassportPdfService Tests', () {
    test('generatePdf generates a valid PDF file in temp directory', () async {
      const testBike = MotorcycleProfile(
        id: 'bike-vector',
        name: 'Night Vector',
        model: 'Yamaha MT-07',
        odometerKm: 18420,
        lastServiceKm: 18000,
        chainWearPercent: 25,
        tireWearPercent: 30,
        brakeWearPercent: 15,
        oilHealthPercent: 88,
        batteryHealthPercent: 95,
        serviceIntervalKm: 6000,
      );

      final testRecords = [
        ServiceRecord(
          id: 'mock_id',
          type: 'diy',
          label: 'Oil & Filter Change',
          odometerKm: 18000,
          status: 'Completed',
          note: 'Castrol 10W-40, OEM Filter',
          loggedAtIso: '2026-06-10T12:00:00Z',
        ),
      ];

      final passport = GaragePassport(
        bike: testBike,
        serviceRecords: testRecords,
        totalRides: 5,
        totalDistanceKm: 100.0,
        averageRideDistanceKm: 20.0,
        harmonyScore: 75,
        harmonyLevel: 'Stable',
        harmonyInsight: 'Keep doing regular checks.',
        generatedAtIso: '2026-06-11T04:00:00Z',
      );

      final path = await GaragePassportPdfService.generatePdf(passport, false);
      expect(path, isNotEmpty);
      final file = File(path);
      expect(await file.exists(), isTrue);
      expect(await file.length(), isPositive);
    });
  });
}
