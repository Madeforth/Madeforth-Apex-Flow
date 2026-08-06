import 'dart:async';
import 'dart:convert';

import 'package:apexflow/core/storage/apex_kv_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

enum FuelRange { day, week, month, year, custom }

class FuelEntry {
  const FuelEntry({
    required this.dateIso,
    required this.litres,
    required this.totalTry,
    this.odometerKm,
    required this.note,
    required this.brand,
    this.imagePath,
  });

  final String dateIso;
  final double litres;
  final double totalTry;
  final int? odometerKm;
  final String note;
  final String brand;
  final String? imagePath;

  DateTime get date => DateTime.parse(dateIso);
  double get pricePerLitre => litres <= 0 ? 0 : totalTry / litres;

  Map<String, dynamic> toJson() => {
    'dateIso': dateIso,
    'litres': litres,
    'totalTry': totalTry,
    'odometerKm': odometerKm,
    'note': note,
    'brand': brand,
    'imagePath': imagePath,
  };

  factory FuelEntry.fromJson(Map<String, dynamic> json) {
    return FuelEntry(
      dateIso: json['dateIso'] as String? ?? DateTime.now().toIso8601String(),
      litres: (json['litres'] as num?)?.toDouble() ?? 0,
      totalTry: (json['totalTry'] as num?)?.toDouble() ?? 0,
      odometerKm: (json['odometerKm'] as num?)?.toInt(),
      note: json['note'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      imagePath: json['imagePath'] as String?,
    );
  }
}

/// Fuel economy between two consecutive odometer-tagged fill-ups.
class FuelConsumptionPoint {
  const FuelConsumptionPoint({
    required this.date,
    required this.distanceKm,
    required this.litresPer100Km,
    required this.brand,
  });

  final DateTime date;
  final double distanceKm;
  final double litresPer100Km;
  final String brand;
}

class FuelBrandStat {
  const FuelBrandStat({
    required this.brand,
    required this.entryCount,
    required this.totalLitres,
    required this.totalTry,
    this.avgLitresPer100Km,
  });

  final String brand;
  final int entryCount;
  final double totalLitres;
  final double totalTry;
  final double? avgLitresPer100Km;

  double get avgPricePerLitre => totalLitres <= 0 ? 0 : totalTry / totalLitres;
}

/// A single fill-up whose fuel economy deviates sharply from the rider's
/// recent average — surfaced as a maintenance-check nudge, not an error.
class FuelAnomaly {
  const FuelAnomaly({
    required this.point,
    required this.rollingAverageLitresPer100Km,
    required this.percentAboveAverage,
  });

  final FuelConsumptionPoint point;
  final double rollingAverageLitresPer100Km;
  final double percentAboveAverage;
}

class FuelSummary {
  const FuelSummary({
    required this.entryCount,
    required this.totalLitres,
    required this.totalTry,
  });

  final int entryCount;
  final double totalLitres;
  final double totalTry;

  double get averagePricePerLitre =>
      totalLitres <= 0 ? 0 : totalTry / totalLitres;
}

class FuelState {
  const FuelState({
    required this.isHydrating,
    required this.entries,
    required this.activeRange,
    required this.customStartIso,
    required this.customEndIso,
  });

  final bool isHydrating;
  final List<FuelEntry> entries;
  final FuelRange activeRange;
  final String? customStartIso;
  final String? customEndIso;

  FuelState copyWith({
    bool? isHydrating,
    List<FuelEntry>? entries,
    FuelRange? activeRange,
    String? customStartIso,
    String? customEndIso,
  }) {
    return FuelState(
      isHydrating: isHydrating ?? this.isHydrating,
      entries: entries ?? this.entries,
      activeRange: activeRange ?? this.activeRange,
      customStartIso: customStartIso ?? this.customStartIso,
      customEndIso: customEndIso ?? this.customEndIso,
    );
  }

  (DateTime start, DateTime end) get _rangeBounds {
    final now = DateTime.now();
    final start = switch (activeRange) {
      FuelRange.day => DateTime(now.year, now.month, now.day),
      FuelRange.week => DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: now.weekday - 1)),
      FuelRange.month => DateTime(now.year, now.month),
      FuelRange.year => DateTime(now.year),
      FuelRange.custom =>
        customStartIso == null
            ? DateTime(1970)
            : DateTime.parse(customStartIso!),
    };
    final end = activeRange == FuelRange.custom && customEndIso != null
        ? DateTime.parse(customEndIso!).add(const Duration(days: 1))
        : now.add(const Duration(days: 1));
    return (start, end);
  }

  List<FuelEntry> get filteredEntries {
    final (start, end) = _rangeBounds;
    return entries.where((entry) {
      final date = entry.date;
      return !date.isBefore(start) && date.isBefore(end);
    }).toList();
  }

  FuelSummary get summary {
    final items = filteredEntries;
    return FuelSummary(
      entryCount: items.length,
      totalLitres: items.fold<double>(0, (sum, item) => sum + item.litres),
      totalTry: items.fold<double>(0, (sum, item) => sum + item.totalTry),
    );
  }

  Map<String, FuelSummary> get dailyChart {
    final grouped = <String, List<FuelEntry>>{};
    for (final entry in filteredEntries) {
      final key = DateFormat('yyyy-MM-dd').format(entry.date);
      grouped.putIfAbsent(key, () => []).add(entry);
    }
    return {
      for (final item in grouped.entries)
        item.key: FuelSummary(
          entryCount: item.value.length,
          totalLitres: item.value.fold(0, (sum, e) => sum + e.litres),
          totalTry: item.value.fold(0, (sum, e) => sum + e.totalTry),
        ),
    };
  }

  /// Fuel economy between consecutive odometer-tagged fill-ups, computed
  /// across the entire history (economy needs continuity between fills,
  /// not just the selected window) then clipped to the active range so it
  /// stays consistent with [filteredEntries]/[summary].
  List<FuelConsumptionPoint> get consumptionTrend {
    final withOdometer = entries.where((e) => e.odometerKm != null).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final points = <FuelConsumptionPoint>[];
    for (var i = 1; i < withOdometer.length; i++) {
      final prev = withOdometer[i - 1];
      final curr = withOdometer[i];
      final distanceKm = (curr.odometerKm! - prev.odometerKm!).toDouble();
      // Guards against odometer resets/typos producing nonsensical points.
      if (distanceKm <= 0 || curr.litres <= 0) continue;
      points.add(
        FuelConsumptionPoint(
          date: curr.date,
          distanceKm: distanceKm,
          litresPer100Km: curr.litres / distanceKm * 100,
          brand: curr.brand,
        ),
      );
    }

    final (start, end) = _rangeBounds;
    return points
        .where((p) => !p.date.isBefore(start) && p.date.isBefore(end))
        .toList();
  }

  /// Per-brand comparison (average L/100km + average price/litre) within
  /// the active range. Brands with no odometer-derived consumption points
  /// still appear with `avgLitresPer100Km: null` rather than being dropped.
  List<FuelBrandStat> get brandComparison {
    final consumptionByBrand = <String, List<double>>{};
    for (final point in consumptionTrend) {
      final key = point.brand.trim().isEmpty ? '—' : point.brand.trim();
      consumptionByBrand.putIfAbsent(key, () => []).add(point.litresPer100Km);
    }

    final grouped = <String, List<FuelEntry>>{};
    for (final entry in filteredEntries) {
      final key = entry.brand.trim().isEmpty ? '—' : entry.brand.trim();
      grouped.putIfAbsent(key, () => []).add(entry);
    }

    final stats = grouped.entries.map((item) {
      final consumptions = consumptionByBrand[item.key];
      return FuelBrandStat(
        brand: item.key,
        entryCount: item.value.length,
        totalLitres: item.value.fold(0, (sum, e) => sum + e.litres),
        totalTry: item.value.fold(0, (sum, e) => sum + e.totalTry),
        avgLitresPer100Km: (consumptions == null || consumptions.isEmpty)
            ? null
            : consumptions.reduce((a, b) => a + b) / consumptions.length,
      );
    }).toList()..sort((a, b) => b.totalTry.compareTo(a.totalTry));
    return stats;
  }

  /// Total spend divided by total distance covered by odometer-tagged
  /// fill-ups in the active range. Null when there isn't enough odometer
  /// data yet to derive a distance.
  double? get costPerKm {
    final points = consumptionTrend;
    if (points.isEmpty) return null;
    final totalDistance = points.fold<double>(
      0,
      (sum, p) => sum + p.distanceKm,
    );
    if (totalDistance <= 0) return null;
    // Cost is attributed to the fill-up that closed each interval.
    final withOdometer = entries.where((e) => e.odometerKm != null).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final pointDates = points.map((p) => p.date).toSet();
    final totalCost = withOdometer
        .where((e) => pointDates.contains(e.date))
        .fold<double>(0, (sum, e) => sum + e.totalTry);
    return totalDistance <= 0 ? null : totalCost / totalDistance;
  }

  /// Flags the most recent fill-up if its consumption is >20% above the
  /// rolling average of the prior points in the active range — a quality
  /// nudge ("check tire pressure / air filter / chain"), not an error.
  FuelAnomaly? get latestConsumptionAnomaly {
    final points = consumptionTrend;
    if (points.length < 2) return null;
    final latest = points.last;
    final priorPoints = points.sublist(0, points.length - 1);
    final rollingAverage =
        priorPoints.fold<double>(0, (sum, p) => sum + p.litresPer100Km) /
        priorPoints.length;
    if (rollingAverage <= 0) return null;
    final percentAbove =
        (latest.litresPer100Km - rollingAverage) / rollingAverage * 100;
    if (percentAbove <= 20) return null;
    return FuelAnomaly(
      point: latest,
      rollingAverageLitresPer100Km: rollingAverage,
      percentAboveAverage: percentAbove,
    );
  }
}

final fuelStateProvider = NotifierProvider<FuelController, FuelState>(
  FuelController.new,
);

class FuelController extends Notifier<FuelState> {
  static const _storageKey = 'fuel.state.v1';

  @override
  FuelState build() {
    unawaited(_hydrate());
    return const FuelState(
      isHydrating: true,
      entries: [],
      activeRange: FuelRange.day,
      customStartIso: null,
      customEndIso: null,
    );
  }

  void addEntry({
    required DateTime date,
    required double litres,
    required double totalTry,
    int? odometerKm,
    required String note,
    required String brand,
    String? imagePath,
  }) {
    final entry = FuelEntry(
      dateIso: date.toIso8601String(),
      litres: litres,
      totalTry: totalTry,
      odometerKm: odometerKm,
      note: note.trim(),
      brand: brand.trim(),
      imagePath: imagePath,
    );
    final entries = [entry, ...state.entries]
      ..sort((a, b) => b.date.compareTo(a.date));
    state = state.copyWith(entries: entries);
    unawaited(_persist());
  }

  void setRange(FuelRange range) {
    state = state.copyWith(activeRange: range);
    unawaited(_persist());
  }

  void setCustomRange(DateTime start, DateTime end) {
    final first = start.isAfter(end) ? end : start;
    final last = start.isAfter(end) ? start : end;
    state = state.copyWith(
      activeRange: FuelRange.custom,
      customStartIso: DateTime(
        first.year,
        first.month,
        first.day,
      ).toIso8601String(),
      customEndIso: DateTime(last.year, last.month, last.day).toIso8601String(),
    );
    unawaited(_persist());
  }

  Future<void> _hydrate() async {
    final raw = await ApexKvStore.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      state = state.copyWith(isHydrating: false);
      return;
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final entries =
          (json['entries'] as List<dynamic>? ?? [])
              .map(
                (item) => FuelEntry.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date));
      state = state.copyWith(
        isHydrating: false,
        entries: entries,
        activeRange: FuelRange.values.firstWhere(
          (range) => range.name == json['activeRange'],
          orElse: () => FuelRange.day,
        ),
        customStartIso: json['customStartIso'] as String?,
        customEndIso: json['customEndIso'] as String?,
      );
    } catch (_) {
      state = state.copyWith(isHydrating: false);
    }
  }

  Future<void> _persist() async {
    final payload = {
      'entries': state.entries.map((entry) => entry.toJson()).toList(),
      'activeRange': state.activeRange.name,
      'customStartIso': state.customStartIso,
      'customEndIso': state.customEndIso,
    };
    await ApexKvStore.setString(_storageKey, jsonEncode(payload));
  }
}
