import 'package:apexflow/garage/domain/motorcycle_profile.dart';
import 'package:apexflow/garage/domain/service_record.dart';
import 'package:apexflow/core/i18n/app_strings.dart';

/// Aggregate snapshot of a motorcycle's complete history,
/// assembled for display on the Garage Passport screen.
class GaragePassport {
  const GaragePassport({
    required this.bike,
    required this.serviceRecords,
    required this.totalRides,
    required this.totalDistanceKm,
    required this.averageRideDistanceKm,
    required this.harmonyScore,
    required this.harmonyLevel,
    required this.harmonyInsight,
    required this.generatedAtIso,
  });

  final MotorcycleProfile bike;
  final List<ServiceRecord> serviceRecords;
  final int totalRides;
  final double totalDistanceKm;
  final double averageRideDistanceKm;
  final int harmonyScore;
  final String harmonyLevel;
  final String harmonyInsight;
  final String generatedAtIso;

  /// Produces a compact, shareable text representation of this passport.
  String toShareableText({required bool tr}) {
    final buf = StringBuffer();

    // Header
    buf.writeln(
      '═══ ${tInline(AppStrings.currentLanguageCode, 'GARAJ PASAPORTU', 'GARAGE PASSPORT', 'GARAGEPASS')} ═══',
    );
    buf.writeln('Apex Flow • ${_formatDate(generatedAtIso, tr)}');
    buf.writeln();

    // Machine identity
    buf.writeln(
      tInline(
        AppStrings.currentLanguageCode,
        '▸ Makine Kimliği',
        '▸ Machine Identity',
        '▸ Maschinenidentität',
      ),
    );
    buf.writeln('  ${bike.name} — ${bike.model}');
    buf.writeln(
      '  ${tInline(AppStrings.currentLanguageCode, 'Kilometre', 'Odometer', 'Kilometerzähler')}: ${bike.odometerKm} km',
    );
    buf.writeln();

    // Harmony
    buf.writeln(
      tInline(
        AppStrings.currentLanguageCode,
        '▸ Harmony Durumu',
        '▸ Harmony Status',
        '▸ Harmony-Status',
      ),
    );
    buf.writeln(
      '  ${tInline(AppStrings.currentLanguageCode, 'Skor', 'Score', 'Punktzahl')}: $harmonyScore / 100 ($harmonyLevel)',
    );
    buf.writeln();

    // Component health
    buf.writeln(
      tInline(
        AppStrings.currentLanguageCode,
        '▸ Parça Kondisyonu',
        '▸ Component Health',
        '▸ Komponentenzustand',
      ),
    );
    buf.writeln(
      '  ${tInline(AppStrings.currentLanguageCode, 'Zincir', 'Chain', 'Kette')}: ${bike.chainWearPercent}% '
      '${tInline(AppStrings.currentLanguageCode, 'aşınma', 'wear', 'tragen')}',
    );
    buf.writeln(
      '  ${tInline(AppStrings.currentLanguageCode, 'Lastik', 'Tires', 'Reifen')}: ${bike.tireWearPercent}% '
      '${tInline(AppStrings.currentLanguageCode, 'aşınma', 'wear', 'tragen')}',
    );
    buf.writeln(
      '  ${tInline(AppStrings.currentLanguageCode, 'Fren', 'Brakes', 'Bremsen')}: ${bike.brakeWearPercent}% '
      '${tInline(AppStrings.currentLanguageCode, 'aşınma', 'wear', 'tragen')}',
    );
    buf.writeln(
      '  ${tInline(AppStrings.currentLanguageCode, 'Yağ', 'Oil', 'Öl')}: ${bike.oilHealthPercent}% '
      '${tInline(AppStrings.currentLanguageCode, 'sağlık', 'health', 'Gesundheit')}',
    );
    buf.writeln(
      '  ${tInline(AppStrings.currentLanguageCode, 'Akü', 'Battery', 'Batterie')}: ${bike.batteryHealthPercent}% '
      '${tInline(AppStrings.currentLanguageCode, 'sağlık', 'health', 'Gesundheit')}',
    );
    buf.writeln();

    // Maintenance window
    buf.writeln(
      tInline(
        AppStrings.currentLanguageCode,
        '▸ Bakım Penceresi',
        '▸ Maintenance Window',
        '▸ Wartungsfenster',
      ),
    );
    final windowLabel = switch (bike.serviceWindowState) {
      ServiceWindowState.stable => tInline(
        AppStrings.currentLanguageCode,
        'Stabil',
        'Stable',
        'Im Rhythmus',
      ),
      ServiceWindowState.dueSoon => tInline(
        AppStrings.currentLanguageCode,
        'Yaklaşıyor',
        'Due soon',
        'Bald fällig',
      ),
      ServiceWindowState.overdue => tInline(
        AppStrings.currentLanguageCode,
        'Gecikmiş',
        'Overdue',
        'Überfällig',
      ),
    };
    buf.writeln(
      '  ${tInline(AppStrings.currentLanguageCode, 'Durum', 'Status', 'Status')}: $windowLabel '
      '(${bike.kmSinceService} / ${bike.serviceIntervalKm} km)',
    );
    buf.writeln();

    // Ride statistics
    buf.writeln(
      tInline(
        AppStrings.currentLanguageCode,
        '▸ Sürüş İstatistikleri',
        '▸ Ride Statistics',
        '▸ Fahrstatistik',
      ),
    );
    buf.writeln(
      '  ${tInline(AppStrings.currentLanguageCode, 'Toplam sürüş', 'Total rides', 'Gesamtfahrten')}: $totalRides',
    );
    buf.writeln(
      '  ${tInline(AppStrings.currentLanguageCode, 'Toplam mesafe', 'Total distance', 'Gesamtstrecke')}: '
      '${totalDistanceKm.toStringAsFixed(1)} km',
    );
    if (totalRides > 0) {
      buf.writeln(
        '  ${tInline(AppStrings.currentLanguageCode, 'Ort. mesafe', 'Avg. distance', 'Durchschn. Distanz')}: '
        '${averageRideDistanceKm.toStringAsFixed(1)} km',
      );
    }
    buf.writeln();

    // Service history summary
    if (serviceRecords.isNotEmpty) {
      buf.writeln(
        tInline(
          AppStrings.currentLanguageCode,
          '▸ Son Servis Kayıtları',
          '▸ Recent Service Records',
          '▸ Aktuelle Serviceaufzeichnungen',
        ),
      );
      final displayRecords = serviceRecords.take(5);
      for (final record in displayRecords) {
        final date = _formatDate(record.loggedAtIso, tr);
        buf.writeln('  • ${record.label} — ${record.odometerKm} km ($date)');
      }
      if (serviceRecords.length > 5) {
        buf.writeln(
          '  … ${tInline(AppStrings.currentLanguageCode, 've ${serviceRecords.length - 5} kayıt daha', 'and ${serviceRecords.length - 5} more', 'und ${serviceRecords.length - 5} mehr')}',
        );
      }
    }

    buf.writeln();
    buf.writeln('═══════════════════════════');

    return buf.toString();
  }

  static String _formatDate(String isoDate, bool tr) {
    final date = DateTime.tryParse(isoDate)?.toLocal();
    if (date == null || date.year <= 1970) {
      return tInline(
        AppStrings.currentLanguageCode,
        'Bilinmiyor',
        'Unknown',
        'Unbekannt',
      );
    }
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    if (tr) {
      return '$d.$m.${date.year}';
    }
    return '$m/$d/${date.year}';
  }
}
