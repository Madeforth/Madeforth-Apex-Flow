import 'package:apexflow/fuel/application/fuel_state.dart';
import 'package:flutter_test/flutter_test.dart';

FuelEntry _entry({
  required String dateIso,
  required double litres,
  required double totalTry,
  int? odometerKm,
  String brand = 'Shell',
}) {
  return FuelEntry(
    dateIso: dateIso,
    litres: litres,
    totalTry: totalTry,
    odometerKm: odometerKm,
    note: '',
    brand: brand,
  );
}

FuelState _stateWith(List<FuelEntry> entries) {
  return FuelState(
    isHydrating: false,
    entries: entries,
    activeRange: FuelRange.custom,
    customStartIso: '1970-01-01',
    customEndIso: DateTime.now().toIso8601String(),
  );
}

void main() {
  group('FuelState.consumptionTrend', () {
    test('computes L/100km from consecutive odometer-tagged fill-ups', () {
      final state = _stateWith([
        _entry(
          dateIso: '2026-01-01T10:00:00.000',
          litres: 10,
          totalTry: 500,
          odometerKm: 1000,
        ),
        _entry(
          dateIso: '2026-01-08T10:00:00.000',
          litres: 20,
          totalTry: 1000,
          odometerKm: 1400, // 400km covered, 20L used -> 5.0 L/100km
        ),
      ]);

      final trend = state.consumptionTrend;
      expect(trend, hasLength(1));
      expect(trend.single.distanceKm, 400);
      expect(trend.single.litresPer100Km, closeTo(5.0, 0.0001));
    });

    test('ignores entries without an odometer reading', () {
      final state = _stateWith([
        _entry(
          dateIso: '2026-01-01T10:00:00.000',
          litres: 10,
          totalTry: 500,
          odometerKm: 1000,
        ),
        _entry(dateIso: '2026-01-04T10:00:00.000', litres: 5, totalTry: 250),
        _entry(
          dateIso: '2026-01-08T10:00:00.000',
          litres: 20,
          totalTry: 1000,
          odometerKm: 1400,
        ),
      ]);

      // The middle entry (no odometer) is skipped; the point is still
      // derived from the two odometer-tagged entries.
      expect(state.consumptionTrend, hasLength(1));
    });

    test('guards against a non-increasing odometer (reset/typo)', () {
      final state = _stateWith([
        _entry(
          dateIso: '2026-01-01T10:00:00.000',
          litres: 10,
          totalTry: 500,
          odometerKm: 1000,
        ),
        _entry(
          dateIso: '2026-01-08T10:00:00.000',
          litres: 20,
          totalTry: 1000,
          odometerKm: 900, // went backwards
        ),
      ]);

      expect(state.consumptionTrend, isEmpty);
    });
  });

  group('FuelState.latestConsumptionAnomaly', () {
    test('flags a fill-up more than 20% above the rolling average', () {
      final state = _stateWith([
        _entry(
          dateIso: '2026-01-01T10:00:00.000',
          litres: 10,
          totalTry: 500,
          odometerKm: 1000,
        ),
        _entry(
          dateIso: '2026-01-08T10:00:00.000',
          litres: 20,
          totalTry: 1000,
          odometerKm: 1400, // 5.0 L/100km
        ),
        _entry(
          dateIso: '2026-01-15T10:00:00.000',
          litres: 20,
          totalTry: 1000,
          odometerKm: 1700, // 300km, 20L -> 6.67 L/100km — first point avg
        ),
        _entry(
          dateIso: '2026-01-22T10:00:00.000',
          litres: 30,
          totalTry: 1500,
          odometerKm: 1900, // 200km, 30L -> 15.0 L/100km — clear anomaly
        ),
      ]);

      final anomaly = state.latestConsumptionAnomaly;
      expect(anomaly, isNotNull);
      expect(anomaly!.percentAboveAverage, greaterThan(20));
    });

    test('returns null when consumption is within normal range', () {
      final state = _stateWith([
        _entry(
          dateIso: '2026-01-01T10:00:00.000',
          litres: 10,
          totalTry: 500,
          odometerKm: 1000,
        ),
        _entry(
          dateIso: '2026-01-08T10:00:00.000',
          litres: 20,
          totalTry: 1000,
          odometerKm: 1400,
        ),
        _entry(
          dateIso: '2026-01-15T10:00:00.000',
          litres: 21,
          totalTry: 1050,
          odometerKm: 1800, // near-identical consumption
        ),
      ]);

      expect(state.latestConsumptionAnomaly, isNull);
    });
  });

  group('FuelState.brandComparison', () {
    test('groups entries by brand with average price and consumption', () {
      final state = _stateWith([
        _entry(
          dateIso: '2026-01-01T10:00:00.000',
          litres: 10,
          totalTry: 500,
          odometerKm: 1000,
          brand: 'Shell',
        ),
        _entry(
          dateIso: '2026-01-08T10:00:00.000',
          litres: 20,
          totalTry: 1000,
          odometerKm: 1400,
          brand: 'Shell',
        ),
        _entry(
          dateIso: '2026-01-15T10:00:00.000',
          litres: 15,
          totalTry: 900,
          odometerKm: 1700,
          brand: 'Opet',
        ),
      ]);

      final stats = state.brandComparison;
      final shell = stats.firstWhere((s) => s.brand == 'Shell');
      expect(shell.entryCount, 2);
      expect(shell.avgLitresPer100Km, closeTo(5.0, 0.0001));

      final opet = stats.firstWhere((s) => s.brand == 'Opet');
      expect(opet.entryCount, 1);
      // Only one Shell->Opet interval exists and it belongs to the Opet
      // (closing) fill-up.
      expect(opet.avgLitresPer100Km, isNotNull);
    });
  });
}
