import 'dart:async';
import 'dart:convert';

import 'package:apexflow/core/i18n/app_settings_state.dart';
import 'package:apexflow/core/storage/apex_kv_store.dart';
import 'package:apexflow/fuel/application/fuel_state.dart';
import 'package:apexflow/garage/application/garage_state.dart';
import 'package:apexflow/garage/domain/motorcycle_profile.dart';
import 'package:apexflow/rides/application/ride_state.dart';
import 'package:apexflow/rides/domain/ride_session.dart';
import 'package:apexflow/documents/application/document_vault_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:apexflow/core/i18n/app_strings.dart';

class MaintenanceItem {
  const MaintenanceItem({
    required this.task,
    required this.dueDateIso,
    required this.note,
  });

  final String task;
  final String dueDateIso;
  final String note;

  Map<String, dynamic> toJson() => {
    'task': task,
    'dueDateIso': dueDateIso,
    'note': note,
  };

  factory MaintenanceItem.fromJson(Map<String, dynamic> json) {
    return MaintenanceItem(
      task: json['task'] as String? ?? '',
      dueDateIso: json['dueDateIso'] as String? ?? '2026-01-01',
      note: json['note'] as String? ?? '',
    );
  }
}

class CostEntry {
  const CostEntry({
    required this.label,
    required this.category,
    required this.amountTry,
  });

  final String label;
  final String category;
  final double amountTry;

  Map<String, dynamic> toJson() {
    return {'label': label, 'category': category, 'amountTry': amountTry};
  }

  factory CostEntry.fromJson(Map<String, dynamic> json) {
    return CostEntry(
      label: json['label'] as String? ?? '',
      category: json['category'] as String? ?? '',
      amountTry: (json['amountTry'] as num?)?.toDouble() ?? 0,
    );
  }
}

class PatternSignal {
  const PatternSignal({
    required this.label,
    required this.evidenceCount,
    required this.recommendation,
  });

  final String label;
  final int evidenceCount;
  final String recommendation;

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'evidenceCount': evidenceCount,
      'recommendation': recommendation,
    };
  }

  factory PatternSignal.fromJson(Map<String, dynamic> json) {
    return PatternSignal(
      label: json['label'] as String? ?? '',
      evidenceCount: json['evidenceCount'] as int? ?? 0,
      recommendation: json['recommendation'] as String? ?? '',
    );
  }
}

class WishlistPart {
  const WishlistPart({
    required this.name,
    required this.note,
    required this.url,
    this.priceTry,
  });

  final String name;
  final String note;
  final String url;
  final double? priceTry;

  Map<String, dynamic> toJson() {
    return {'name': name, 'note': note, 'url': url, 'priceTry': priceTry};
  }

  factory WishlistPart.fromJson(Map<String, dynamic> json) {
    return WishlistPart(
      name: json['name'] as String? ?? '',
      note: json['note'] as String? ?? '',
      url: json['url'] as String? ?? '',
      priceTry: (json['priceTry'] as num?)?.toDouble(),
    );
  }
}

class FuelSnapshot {
  const FuelSnapshot({
    required this.lastLitre,
    required this.lastPriceTry,
    required this.avgConsumptionL100,
    required this.estimatedRangeKm,
    required this.brandConsumption,
  });

  final double lastLitre;
  final double lastPriceTry;
  final double avgConsumptionL100;
  final int estimatedRangeKm;
  final Map<String, double> brandConsumption;

  Map<String, dynamic> toJson() {
    return {
      'lastLitre': lastLitre,
      'lastPriceTry': lastPriceTry,
      'avgConsumptionL100': avgConsumptionL100,
      'estimatedRangeKm': estimatedRangeKm,
      'brandConsumption': brandConsumption,
    };
  }

  factory FuelSnapshot.fromJson(Map<String, dynamic> json) {
    return FuelSnapshot(
      lastLitre: (json['lastLitre'] as num?)?.toDouble() ?? 0,
      lastPriceTry: (json['lastPriceTry'] as num?)?.toDouble() ?? 0,
      avgConsumptionL100: (json['avgConsumptionL100'] as num?)?.toDouble() ?? 0,
      estimatedRangeKm: json['estimatedRangeKm'] as int? ?? 0,
      brandConsumption: Map<String, double>.from(
        (json['brandConsumption'] as Map<dynamic, dynamic>?)?.map(
              (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
            ) ??
            {},
      ),
    );
  }
}

class InsightsState {
  const InsightsState({
    required this.isHydrating,
    required this.maintenanceCalendar,
    required this.costLedger,
    required this.patternSignals,
    required this.partsWishlist,
    required this.fuelSnapshot,
    required this.tirePressureLogs,
    required this.documentVault,
    required this.tripChecklist,
    required this.inspectionModeItems,
    required this.serviceEstimate,
    required this.routeMemories,
    required this.seasonalStoragePlan,
    required this.incidentLogs,
  });

  final bool isHydrating;
  final List<MaintenanceItem> maintenanceCalendar;
  final List<CostEntry> costLedger;
  final List<PatternSignal> patternSignals;
  final List<WishlistPart> partsWishlist;
  final FuelSnapshot fuelSnapshot;
  final List<String> tirePressureLogs;
  final List<String> documentVault;
  final List<String> tripChecklist;
  final List<String> inspectionModeItems;
  final List<String> serviceEstimate;
  final List<String> routeMemories;
  final List<String> seasonalStoragePlan;
  final List<String> incidentLogs;

  double get totalCostTry {
    return costLedger.fold<double>(0, (sum, item) => sum + item.amountTry);
  }

  InsightsState copyWith({
    bool? isHydrating,
    List<MaintenanceItem>? maintenanceCalendar,
    List<CostEntry>? costLedger,
    List<PatternSignal>? patternSignals,
    List<WishlistPart>? partsWishlist,
    FuelSnapshot? fuelSnapshot,
    List<String>? tirePressureLogs,
    List<String>? documentVault,
    List<String>? tripChecklist,
    List<String>? inspectionModeItems,
    List<String>? serviceEstimate,
    List<String>? routeMemories,
    List<String>? seasonalStoragePlan,
    List<String>? incidentLogs,
  }) {
    return InsightsState(
      isHydrating: isHydrating ?? this.isHydrating,
      maintenanceCalendar: maintenanceCalendar ?? this.maintenanceCalendar,
      costLedger: costLedger ?? this.costLedger,
      patternSignals: patternSignals ?? this.patternSignals,
      partsWishlist: partsWishlist ?? this.partsWishlist,
      fuelSnapshot: fuelSnapshot ?? this.fuelSnapshot,
      tirePressureLogs: tirePressureLogs ?? this.tirePressureLogs,
      documentVault: documentVault ?? this.documentVault,
      tripChecklist: tripChecklist ?? this.tripChecklist,
      inspectionModeItems: inspectionModeItems ?? this.inspectionModeItems,
      serviceEstimate: serviceEstimate ?? this.serviceEstimate,
      routeMemories: routeMemories ?? this.routeMemories,
      seasonalStoragePlan: seasonalStoragePlan ?? this.seasonalStoragePlan,
      incidentLogs: incidentLogs ?? this.incidentLogs,
    );
  }
}

final insightsStateProvider =
    NotifierProvider<InsightsController, InsightsState>(InsightsController.new);

class InsightsController extends Notifier<InsightsState> {
  static const _storageKey = 'insights.state.v1';

  bool _mounted = true;
  List<CostEntry> _manualCostEntries = const [];

  @override
  InsightsState build() {
    ref.onDispose(() => _mounted = false);
    unawaited(_hydrate());
    final rides = ref.watch(rideStateProvider).sessions;
    final garage = ref.watch(garageStateProvider);
    final fuel = ref.watch(fuelStateProvider);
    final vault = ref.watch(documentVaultProvider);
    final isTurkish = ref.watch(appSettingsProvider).isTurkish;
    final hasBike = garage.motorcycles.isNotEmpty;
    final bike = garage.activeBike;
    return InsightsState(
      isHydrating: true,
      maintenanceCalendar: _deriveMaintenanceCalendar(
        bike,
        hasBike,
        vault,
        isTurkish,
      ),
      costLedger: [..._manualCostEntries, ..._deriveCostLedger(fuel.entries)],
      patternSignals: _derivePatternSignals(rides),
      partsWishlist: const [],
      fuelSnapshot: _deriveFuelSnapshot(fuel.entries),
      tirePressureLogs: const [],
      documentVault: const [],
      tripChecklist: const [],
      inspectionModeItems: const [],
      serviceEstimate: _deriveServiceEstimate(bike, hasBike, rides),
      routeMemories: const [],
      seasonalStoragePlan: const [],
      incidentLogs: const [],
    );
  }

  void addWishlistPart({
    required String name,
    required String note,
    required String url,
    required double? priceTry,
  }) {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      return;
    }
    final part = WishlistPart(
      name: normalizedName,
      note: note.trim().isEmpty
          ? tInline(
              AppStrings.currentLanguageCode,
              'Not yok',
              'No note',
              'Keine Notiz',
            )
          : note.trim(),
      url: url.trim(),
      priceTry: priceTry,
    );
    state = state.copyWith(partsWishlist: [part, ...state.partsWishlist]);
    unawaited(_persist());
  }

  void removeWishlistPart(WishlistPart part) {
    final next = [...state.partsWishlist]..remove(part);
    state = state.copyWith(partsWishlist: next);
    unawaited(_persist());
  }

  Future<void> addCostEntry({
    required String label,
    required String category,
    required double amountTry,
  }) async {
    final normalizedLabel = label.trim();
    if (normalizedLabel.isEmpty || !amountTry.isFinite || amountTry <= 0) {
      throw ArgumentError('A label and a positive amount are required.');
    }

    final entry = CostEntry(
      label: normalizedLabel,
      category: category,
      amountTry: amountTry,
    );
    final previousManualEntries = _manualCostEntries;
    final previousLedger = state.costLedger;
    _manualCostEntries = [entry, ..._manualCostEntries];
    state = state.copyWith(costLedger: [entry, ...state.costLedger]);
    try {
      await _persist();
    } catch (_) {
      _manualCostEntries = previousManualEntries;
      state = state.copyWith(costLedger: previousLedger);
      rethrow;
    }
  }

  Future<void> _hydrate() async {
    final raw = await ApexKvStore.getString(_storageKey);
    if (!_mounted) {
      return;
    }
    if (raw == null || raw.isEmpty) {
      state = state.copyWith(isHydrating: false);
      return;
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      _manualCostEntries =
          (json['manualCostLedger'] as List<dynamic>? ?? const [])
              .map(
                (item) =>
                    CostEntry.fromJson(Map<String, dynamic>.from(item as Map)),
              )
              .toList();
      state = state.copyWith(
        isHydrating: false,
        costLedger: [
          ..._manualCostEntries,
          ..._deriveCostLedger(ref.read(fuelStateProvider).entries),
        ],
        partsWishlist: (json['partsWishlist'] as List<dynamic>? ?? [])
            .map(
              (item) =>
                  WishlistPart.fromJson(Map<String, dynamic>.from(item as Map)),
            )
            .toList(),
      );
    } catch (_) {
      // keep defaults
    }
    state = state.copyWith(isHydrating: false);
  }

  Future<void> _persist() async {
    final payload = {
      'manualCostLedger': _manualCostEntries
          .map((item) => item.toJson())
          .toList(),
      'partsWishlist': state.partsWishlist
          .map((item) => item.toJson())
          .toList(),
    };
    await ApexKvStore.setString(_storageKey, jsonEncode(payload));
  }
}

List<MaintenanceItem> _deriveMaintenanceCalendar(
  MotorcycleProfile bike,
  bool hasBike,
  DocumentVaultState vault,
  bool isTurkish,
) {
  if (!hasBike) {
    return const [];
  }
  final items = <MaintenanceItem>[];
  final now = DateTime.now();

  // 1. Add Service Window status
  if (bike.serviceWindowState == ServiceWindowState.overdue) {
    items.add(
      MaintenanceItem(
        task: tInline(
          AppStrings.currentLanguageCode,
          'Servis aralığı geçti',
          'Service window overdue',
          'Servicefenster überfällig',
        ),
        dueDateIso: DateFormat('yyyy-MM-dd').format(now),
        note: tInline(
          AppStrings.currentLanguageCode,
          'Geciken ${bike.kmUntilService.abs()} km servis aralığını kapat.',
          'Close the ${bike.kmUntilService.abs()} km overdue interval.',
          'Schließen Sie das überfällige km-Intervall ${bike.kmUntilService.abs()}.',
        ),
      ),
    );
  } else if (bike.serviceWindowState == ServiceWindowState.dueSoon) {
    items.add(
      MaintenanceItem(
        task: tInline(
          AppStrings.currentLanguageCode,
          'Servis aralığı yaklaşıyor',
          'Service window approaching',
          'Das Servicefenster rückt näher',
        ),
        dueDateIso: DateFormat(
          'yyyy-MM-dd',
        ).format(now.add(const Duration(days: 14))),
        note: bike.kmUntilService < 0
            ? tInline(
                AppStrings.currentLanguageCode,
                'Mevcut aralıkta ${bike.kmUntilService.abs()} km aşıldı.',
                '${bike.kmUntilService.abs()} km overdue in the current interval.',
                '${bike.kmUntilService.abs()} km überfällig im aktuellen Intervall.',
              )
            : tInline(
                AppStrings.currentLanguageCode,
                'Mevcut aralıkta ${bike.kmUntilService} km kaldı.',
                '${bike.kmUntilService} km remains in the current interval.',
                '${bike.kmUntilService} km verbleiben im aktuellen Intervall.',
              ),
      ),
    );
  }

  // 2. Add unpaid tax/inspection records for this bike due within 90 days or overdue
  final bikeTaxes = vault.taxRecords
      .where((t) => t.bikeStableId == bike.id && !t.isPaid)
      .toList();
  for (final tax in bikeTaxes) {
    final diffDays = tax.dueDate.difference(now).inDays;
    if (diffDays < 90) {
      // Resolve localized label
      String taskName = '';
      switch (tax.type) {
        case 'mtv_1':
          taskName = tInline(
            AppStrings.currentLanguageCode,
            'MTV 1. Taksit',
            'Motor Tax 1st Half',
            'Kfz-Steuer 1. Hälfte',
          );
          break;
        case 'mtv_2':
          taskName = tInline(
            AppStrings.currentLanguageCode,
            'MTV 2. Taksit',
            'Motor Tax 2nd Half',
            'Kfz-Steuer 2. Hälfte',
          );
          break;
        case 'insurance':
          taskName = tInline(
            AppStrings.currentLanguageCode,
            'Trafik Sigortası',
            'Insurance Renewal',
            'Versicherungsverlängerung',
          );
          break;
        case 'inspection':
          taskName = tInline(
            AppStrings.currentLanguageCode,
            'TÜVTÜRK Muayene',
            'Vehicle Inspection',
            'Fahrzeuginspektion',
          );
          break;
        case 'global_insurance':
          taskName = tInline(
            AppStrings.currentLanguageCode,
            'Motosiklet Sigortası',
            'Motorcycle Insurance',
            'Motorradversicherung',
          );
          break;
        case 'global_inspection':
          taskName = tInline(
            AppStrings.currentLanguageCode,
            'Araç Muayenesi',
            'Vehicle Inspection',
            'Fahrzeuginspektion',
          );
          break;
        case 'road_tax':
          taskName = tInline(
            AppStrings.currentLanguageCode,
            'Yıllık Taşıt Vergisi',
            'Annual Road Tax',
            'Jährliche Kfz-Steuer',
          );
          break;
        default:
          taskName = tInline(
            AppStrings.currentLanguageCode,
            'Ödeme / Tarih',
            'Other Payment',
            'Sonstige Zahlung',
          );
      }

      final amountStr = tax.amount.toStringAsFixed(0);
      final noteText = diffDays < 0
          ? (tInline(
              AppStrings.currentLanguageCode,
              'Ödeme $amountStr ${tax.currency} tutarıyla ${diffDays.abs()} gün gecikti.',
              'Payment overdue by ${diffDays.abs()} days ($amountStr ${tax.currency}).',
              'Zahlung um ${diffDays.abs()} Tage überfällig ($amountStr ${tax.currency}).',
            ))
          : (tInline(
              AppStrings.currentLanguageCode,
              'Son ödemeye $diffDays gün kaldı ($amountStr ${tax.currency}).',
              'Payment due in $diffDays days ($amountStr ${tax.currency}).',
              'Fällige Zahlung in $diffDays Tagen ($amountStr ${tax.currency}).',
            ));

      items.add(
        MaintenanceItem(
          task: taskName,
          dueDateIso: tax.dueDateIso.split('T').first,
          note: noteText,
        ),
      );
    }
  }

  return items;
}

List<CostEntry> _deriveCostLedger(List<FuelEntry> fuelEntries) {
  return fuelEntries
      .take(10)
      .map((entry) {
        final date = DateFormat('yyyy-MM-dd').format(entry.date);
        return CostEntry(
          label:
              '${tInline(AppStrings.currentLanguageCode, 'Yakıt alımı', 'Fuel refill', 'Tanken')} $date',
          category: 'Fuel',
          amountTry: entry.totalTry,
        );
      })
      .toList(growable: false);
}

FuelSnapshot _deriveFuelSnapshot(List<FuelEntry> entries) {
  if (entries.isEmpty) {
    return const FuelSnapshot(
      lastLitre: 0,
      lastPriceTry: 0,
      avgConsumptionL100: 0,
      estimatedRangeKm: 0,
      brandConsumption: {},
    );
  }

  final sorted = [...entries]..sort((a, b) => b.date.compareTo(a.date));
  final latest = sorted.first;
  final odometerEntries =
      entries.where((entry) => entry.odometerKm != null).toList()
        ..sort((a, b) => a.odometerKm!.compareTo(b.odometerKm!));

  var averageConsumption = 0.0;
  if (odometerEntries.length >= 2) {
    final distanceKm =
        odometerEntries.last.odometerKm! - odometerEntries.first.odometerKm!;
    final litres = odometerEntries
        .skip(1)
        .fold<double>(0, (sum, entry) => sum + entry.litres);
    if (distanceKm > 0 && litres > 0) {
      averageConsumption = litres / distanceKm * 100;
    }
  }

  // Calculate brand consumption
  final brandDistance = <String, double>{};
  final brandLitres = <String, double>{};

  for (int i = 0; i < odometerEntries.length - 1; i++) {
    final current = odometerEntries[i];
    final next = odometerEntries[i + 1];
    final distance = (next.odometerKm! - current.odometerKm!).toDouble();
    if (distance > 0) {
      var brand = current.brand.trim();
      if (brand.isEmpty) {
        brand = 'Unknown';
      }
      brandDistance[brand] = (brandDistance[brand] ?? 0) + distance;
      brandLitres[brand] = (brandLitres[brand] ?? 0) + next.litres;
    }
  }

  final brandConsumption = <String, double>{};
  for (final brand in brandDistance.keys) {
    final dist = brandDistance[brand]!;
    final lit = brandLitres[brand]!;
    if (dist > 0 && lit > 0) {
      brandConsumption[brand] = (lit / dist) * 100.0;
    }
  }

  return FuelSnapshot(
    lastLitre: latest.litres,
    lastPriceTry: latest.totalTry,
    avgConsumptionL100: averageConsumption,
    estimatedRangeKm: 0,
    brandConsumption: brandConsumption,
  );
}

double _calculateDailyKmAverage(List<RideSession> rides) {
  if (rides.isEmpty) {
    return 15.0; // varsayılan günlük commuter ortalaması
  }

  final now = DateTime.now();
  final thirtyDaysAgo = now.subtract(const Duration(days: 30));

  final recentRides = rides.where((r) {
    try {
      final date = DateTime.parse(r.loggedAtIso);
      return date.isAfter(thirtyDaysAgo);
    } catch (_) {
      return false;
    }
  }).toList();

  final sourceRides = recentRides.isNotEmpty ? recentRides : rides;

  DateTime firstDate = now;
  for (final r in sourceRides) {
    try {
      final date = DateTime.parse(r.loggedAtIso);
      if (date.isBefore(firstDate)) {
        firstDate = date;
      }
    } catch (_) {}
  }

  int daysActive = now.difference(firstDate).inDays;
  if (daysActive < 1) {
    daysActive = 1;
  }

  final totalDist = sourceRides.fold<double>(
    0.0,
    (sum, r) => sum + r.distanceKm,
  );

  if (totalDist == 0) {
    return 10.0; // Hiç sürüş verisi yoksa (örn. sadece manuel ekleme)
  }

  final calculatedAvg = totalDist / daysActive;

  // Günlük ortalamanın saçma değerlere düşmemesi için minimum 5, maksimum 500 ile sınırla
  // Böylece sadece 1 km'lik bir test sürüşü yapsanız bile 100 km için 100 gün demez, en az 5 kabul eder (20 gün).
  return calculatedAvg.clamp(5.0, 500.0);
}

List<String> _deriveServiceEstimate(
  MotorcycleProfile bike,
  bool hasBike,
  List<RideSession> rides,
) {
  if (!hasBike) {
    return const [];
  }
  final lines = <String>[];
  final dailyAvg = _calculateDailyKmAverage(rides);

  if (bike.serviceWindowState == ServiceWindowState.overdue) {
    lines.add('Service overdue by ${bike.kmUntilService.abs()} km');
  } else {
    final kmLeft = bike.kmUntilService;
    final daysLeft = (kmLeft / dailyAvg).round();
    if (daysLeft <= 0) {
      lines.add('Service due in $kmLeft km (Today)');
    } else {
      lines.add('Service due in $kmLeft km (Approx. $daysLeft days)');
    }
  }

  // Zincir yağlama tahmini (500 km'de bir tavsiye edilir)
  const lubeInterval = 500;
  final currentOdoMod = bike.odometerKm % lubeInterval;
  final kmUntilLube = lubeInterval - currentOdoMod;
  final daysUntilLube = (kmUntilLube / dailyAvg).round();
  if (daysUntilLube <= 0) {
    lines.add('Chain lube due (Today)');
  } else {
    lines.add(
      'Chain lube due in $kmUntilLube km (Approx. $daysUntilLube days)',
    );
  }

  _addWearEstimate(lines, 'Chain inspection', bike.chainWearPercent);
  _addWearEstimate(lines, 'Tire inspection', bike.tireWearPercent);
  _addWearEstimate(lines, 'Brake inspection', bike.brakeWearPercent);
  _addHealthEstimate(lines, 'Oil service check', bike.oilHealthPercent);
  _addHealthEstimate(lines, 'Battery health check', bike.batteryHealthPercent);
  return lines;
}

void _addWearEstimate(List<String> lines, String label, int wearPercent) {
  if (wearPercent >= 70) {
    lines.add('$label: $wearPercent% wear');
  }
}

void _addHealthEstimate(List<String> lines, String label, int healthPercent) {
  if (healthPercent <= 45) {
    lines.add('$label: $healthPercent% health');
  }
}

List<PatternSignal> _derivePatternSignals(List<RideSession> rides) {
  int brakeMentions = 0;
  int chainMentions = 0;
  int tireMentions = 0;
  for (final ride in rides.take(8)) {
    final note = ride.mechanicalObservation.toLowerCase();
    if (note.contains('brake') || note.contains('fren')) {
      brakeMentions++;
    }
    if (note.contains('chain') || note.contains('zincir')) {
      chainMentions++;
    }
    if (note.contains('tire') ||
        note.contains('tyre') ||
        note.contains('lastik') ||
        note.contains('rear') ||
        note.contains('arka')) {
      tireMentions++;
    }
  }
  return [
    if (brakeMentions > 0)
      PatternSignal(
        label: tInline(
          AppStrings.currentLanguageCode,
          'Fren geri bildirimi eğilimi',
          'Brake feedback trend',
          'Brems-Feedback-Trend',
        ),
        evidenceCount: brakeMentions,
        recommendation: tInline(
          AppStrings.currentLanguageCode,
          'Bu hafta fren hissiyatı ve balata aşınma kontrolü planlayın.',
          'Plan a brake feel and pad wear check this week.',
          'Planen Sie diese Woche eine Überprüfung des Bremsgefühls und des Bremsbelagverschleißes.',
        ),
      ),
    if (chainMentions > 0)
      PatternSignal(
        label: tInline(
          AppStrings.currentLanguageCode,
          'Zincir sesi bildirimleri',
          'Chain noise mentions',
          'Kettengeräusche-Erwähnungen',
        ),
        evidenceCount: chainMentions,
        recommendation: tInline(
          AppStrings.currentLanguageCode,
          'Yağlama aralığını 80 km geriye çekin.',
          'Move lubrication interval 80 km earlier.',
          'Schmierintervall 80 km vorverlegen.',
        ),
      ),
    if (tireMentions > 0)
      PatternSignal(
        label: tInline(
          AppStrings.currentLanguageCode,
          'Lastik stresi bildirimleri',
          'Tire stress mentions',
          'Reifenbelastungs-Erwähnungen',
        ),
        evidenceCount: tireMentions,
        recommendation: tInline(
          AppStrings.currentLanguageCode,
          'Bir sonraki uzun sürüşten önce basınç denetimi yapın.',
          'Run pressure audit before the next long ride.',
          'Führen Sie vor der nächsten langen Fahrt eine Druckprüfung durch.',
        ),
      ),
  ];
}
