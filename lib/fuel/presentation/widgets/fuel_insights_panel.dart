import 'package:apexflow/core/design/apex_spacing.dart';
import 'package:apexflow/core/design/theme_extensions.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/fuel/application/fuel_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fuel-economy analytics: consumption trend, per-brand comparison, cost
/// per km, and an anomaly nudge when the latest fill-up's economy deviates
/// sharply from the rider's recent average. Reads the same [fuelStateProvider]
/// as [FuelHistoryList], scoped to the same active date range.
class FuelInsightsPanel extends ConsumerWidget {
  const FuelInsightsPanel({super.key, required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fuelStateProvider);
    final trend = state.consumptionTrend;
    final brands = state.brandComparison;
    final costPerKm = state.costPerKm;
    final anomaly = state.latestConsumptionAnomaly;

    if (trend.isEmpty && brands.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            tInline(
              strings.languageCode,
              'Yakıt Ekonomisi',
              'Fuel Economy',
              'Kraftstoffverbrauch',
            ),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),

        if (anomaly != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _AnomalyBanner(anomaly: anomaly, strings: strings),
          ),
          const SizedBox(height: 12),
        ],

        if (trend.length >= 2) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(ApexSpacing.radius),
                border: Border.all(color: context.colors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tInline(
                          strings.languageCode,
                          'Tüketim Trendi (L/100km)',
                          'Consumption Trend (L/100km)',
                          'Verbrauchstrend (L/100km)',
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: context.colors.textSecondary,
                        ),
                      ),
                      if (costPerKm != null)
                        Text(
                          '${costPerKm.toStringAsFixed(2)} ₺/km',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: context.colors.cyan,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: _ConsumptionTrendPainter(
                        points: trend,
                        cyanColor: context.colors.cyan,
                        cautionColor: context.colors.caution,
                        gridColor: Colors.white.withValues(alpha: 0.12),
                        labelColor: context.colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        if (brands.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              tInline(
                strings.languageCode,
                'İstasyon Kıyaslaması',
                'Station Comparison',
                'Tankstellenvergleich',
              ),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.colors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: brands
                  .map((b) => _BrandRow(stat: b, strings: strings))
                  .toList(),
            ),
          ),
        ],
      ],
    );
  }
}

class _AnomalyBanner extends StatelessWidget {
  const _AnomalyBanner({required this.anomaly, required this.strings});

  final FuelAnomaly anomaly;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.caution.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ApexSpacing.radius),
        border: Border.all(
          color: context.colors.caution.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: context.colors.caution, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tInline(
                strings.languageCode,
                'Son doldurmanız ortalamanın %${anomaly.percentAboveAverage.toStringAsFixed(0)} üzerinde tüketim gösteriyor. Lastik basıncı, hava filtresi veya zincir gerginliğini kontrol etmek isteyebilirsiniz.',
                'Your latest fill-up shows consumption %${anomaly.percentAboveAverage.toStringAsFixed(0)} above your average. You may want to check tire pressure, air filter, or chain tension.',
                'Ihre letzte Tankfüllung zeigt einen Verbrauch, der %${anomaly.percentAboveAverage.toStringAsFixed(0)} über Ihrem Durchschnitt liegt. Überprüfen Sie ggf. Reifendruck, Luftfilter oder Kettenspannung.',
              ),
              style: TextStyle(
                fontSize: 12,
                color: context.colors.caution,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandRow extends StatelessWidget {
  const _BrandRow({required this.stat, required this.strings});

  final FuelBrandStat stat;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(ApexSpacing.radius),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stat.brand,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${stat.entryCount} ${tInline(strings.languageCode, 'dolum', 'fill-ups', 'Tankfüllungen')} · ${stat.avgPricePerLitre.toStringAsFixed(2)} ₺/L',
                    style: TextStyle(
                      fontSize: 11,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (stat.avgLitresPer100Km != null)
              Text(
                '${stat.avgLitresPer100Km!.toStringAsFixed(1)} L/100km',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: context.colors.cyan,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ConsumptionTrendPainter extends CustomPainter {
  _ConsumptionTrendPainter({
    required this.points,
    required this.cyanColor,
    required this.cautionColor,
    required this.gridColor,
    required this.labelColor,
  });

  final List<FuelConsumptionPoint> points;
  final Color cyanColor;
  final Color cautionColor;
  final Color gridColor;
  final Color labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    const paddingLeft = 40.0;
    const paddingRight = 6.0;
    const paddingTop = 6.0;
    const paddingBottom = 6.0;

    final chartWidth = size.width - paddingLeft - paddingRight;
    final chartHeight = size.height - paddingTop - paddingBottom;

    final maxValue = points
        .map((p) => p.litresPer100Km)
        .fold<double>(0, (a, b) => a > b ? a : b);
    final ceilingValue = maxValue <= 0 ? 1.0 : maxValue * 1.15;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;
    for (var i = 0; i <= 3; i++) {
      final y = paddingTop + (chartHeight / 3) * i;
      canvas.drawLine(
        Offset(paddingLeft, y),
        Offset(size.width - paddingRight, y),
        gridPaint,
      );
    }

    final labelPainter = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i <= 3; i++) {
      final value = ceilingValue - (ceilingValue / 3) * i;
      final y = paddingTop + (chartHeight / 3) * i;
      labelPainter.text = TextSpan(
        text: value.toStringAsFixed(1),
        style: TextStyle(color: labelColor, fontSize: 8),
      );
      labelPainter.layout();
      labelPainter.paint(
        canvas,
        Offset(
          paddingLeft - labelPainter.width - 6,
          y - labelPainter.height / 2,
        ),
      );
    }

    final barWidth = chartWidth / points.length;
    final average =
        points.fold<double>(0, (sum, p) => sum + p.litresPer100Km) /
        points.length;
    final averageY =
        paddingTop + chartHeight - (average / ceilingValue) * chartHeight;
    final avgLinePaint = Paint()
      ..color = cautionColor.withValues(alpha: 0.5)
      ..strokeWidth = 1.0;
    _drawDashedLine(
      canvas,
      Offset(paddingLeft, averageY),
      Offset(size.width - paddingRight, averageY),
      avgLinePaint,
    );

    for (var i = 0; i < points.length; i++) {
      final value = points[i].litresPer100Km;
      final barHeight = (value / ceilingValue) * chartHeight;
      final x = paddingLeft + barWidth * i + barWidth * 0.2;
      final barPaint = Paint()
        ..color = value > average
            ? cautionColor.withValues(alpha: 0.8)
            : cyanColor.withValues(alpha: 0.8);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x,
            paddingTop + chartHeight - barHeight,
            barWidth * 0.6,
            barHeight,
          ),
          const Radius.circular(2),
        ),
        barPaint,
      );
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 4.0;
    const dashSpace = 3.0;
    final totalDistance = (end - start).distance;
    var covered = 0.0;
    final direction = (end - start) / totalDistance;
    while (covered < totalDistance) {
      final segmentEnd = covered + dashWidth < totalDistance
          ? covered + dashWidth
          : totalDistance;
      canvas.drawLine(
        start + direction * covered,
        start + direction * segmentEnd,
        paint,
      );
      covered += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _ConsumptionTrendPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
