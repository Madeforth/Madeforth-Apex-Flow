import 'package:apexflow/core/design/theme_extensions.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apexflow/core/design/apex_theme.dart';
import 'package:apexflow/core/design/apex_spacing.dart';
import 'package:apexflow/core/i18n/app_settings_state.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/fuel/application/fuel_state.dart';
import 'package:intl/intl.dart';

class FuelHistoryList extends ConsumerWidget {
  const FuelHistoryList({super.key, required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fuelStateProvider);
    final currencySymbol = ref.watch(appSettingsProvider).currencySymbol;
    final tr = strings.locale.languageCode == 'tr';

    final ranges = [
      FuelRange.day,
      FuelRange.week,
      FuelRange.month,
      FuelRange.year,
      FuelRange.custom,
    ];

    String rangeLabel(FuelRange r) {
      return switch (r) {
        FuelRange.day => tInline(strings.languageCode, 'Gün', 'Day', 'Tag'),
        FuelRange.week => tInline(
          strings.languageCode,
          'Hafta',
          'Week',
          'Woche',
        ),
        FuelRange.month => tInline(
          strings.languageCode,
          'Ay',
          'Month',
          'Monat',
        ),
        FuelRange.year => tInline(strings.languageCode, 'Yıl', 'Year', 'Jahr'),
        FuelRange.custom => tInline(
          strings.languageCode,
          'Tümü',
          'All',
          'Alle',
        ),
      };
    }

    final entries = state.filteredEntries.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            tInline(strings.languageCode, 'Geçmiş', 'History', 'Verlauf'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: ranges.map((r) {
              final active = state.activeRange == r;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(rangeLabel(r)),
                  selected: active,
                  onSelected: (_) =>
                      ref.read(fuelStateProvider.notifier).setRange(r),
                  selectedColor: context.colors.cyan.withValues(alpha: 0.2),
                  backgroundColor: context.colors.surface,
                  side: BorderSide(
                    color: active ? context.colors.cyan : context.colors.border,
                  ),
                  labelStyle: TextStyle(
                    color: active
                        ? context.colors.cyan
                        : context.colors.textSecondary,
                    fontWeight: active ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  showCheckmark: false,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                tInline(
                  strings.languageCode,
                  'Bu tarih aralığında kayıt bulunamadı.',
                  'No records found in this range.',
                  'Keine Aufzeichnungen in diesem Bereich gefunden.',
                ),
                style: TextStyle(color: context.colors.textSecondary),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: entries.length,
            separatorBuilder: (context, index) =>
                Divider(color: context.colors.border, height: 24),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return _FuelHistoryItem(
                entry: entry,
                strings: strings,
                currencySymbol: currencySymbol,
              );
            },
          ),
      ],
    );
  }
}

class _FuelHistoryItem extends StatelessWidget {
  const _FuelHistoryItem({
    required this.entry,
    required this.strings,
    required this.currencySymbol,
  });

  final FuelEntry entry;
  final AppStrings strings;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM yyyy, HH:mm', strings.locale.languageCode);
    final dateStr = df.format(entry.date);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(ApexSpacing.radius),
            border: Border.all(color: context.colors.border),
          ),
          child: Center(
            child: Icon(
              Icons.local_gas_station,
              size: 20,
              color: context.colors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.brand.isEmpty
                        ? tInline(
                            strings.languageCode,
                            'İstasyon',
                            'Station',
                            'Tankstelle',
                          )
                        : entry.brand,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${entry.totalTry.toStringAsFixed(2)} $currencySymbol',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: context.colors.cyan,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateStr,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.textSecondary,
                    ),
                  ),
                  Text(
                    '${entry.litres.toStringAsFixed(2)} L',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
              if (entry.odometerKm != null && entry.odometerKm! > 0) ...[
                const SizedBox(height: 4),
                Text(
                  '${entry.odometerKm} km',
                  style: TextStyle(
                    fontSize: 11,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
              if (entry.note.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  entry.note,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.muted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
