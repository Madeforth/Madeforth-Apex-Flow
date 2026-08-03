// ignore_for_file: avoid_print

import 'dart:math';

int _levenshtein(String a, String b) {
  final la = a.length;
  final lb = b.length;
  if (la == 0) return lb;
  if (lb == 0) return la;
  final dp = List.generate(la + 1, (_) => List<int>.filled(lb + 1, 0));
  for (var i = 0; i <= la; i++) {
    dp[i][0] = i;
  }
  for (var j = 0; j <= lb; j++) {
    dp[0][j] = j;
  }
  for (var i = 1; i <= la; i++) {
    for (var j = 1; j <= lb; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      dp[i][j] = [
        dp[i - 1][j] + 1,
        dp[i][j - 1] + 1,
        dp[i - 1][j - 1] + cost,
      ].reduce(min);
    }
  }
  return dp[la][lb];
}

double _clamp01(double v) => v.isFinite ? v.clamp(0.0, 1.0) : 0.0;

Map<String, dynamic> parseReceipt(String text) {
  final lowered = text.toLowerCase();

  // Extract candidate numbers with nearby markers
  final litreRe = RegExp(
    r'(?:(\d+[\.,]?\d*)\s?(l|litre|lt)\b)',
    caseSensitive: false,
  );
  final litreMatches = litreRe.allMatches(text).toList();
  String? litresStr;
  double litresConfidence = 0.0;
  if (litreMatches.isNotEmpty) {
    litresStr = litreMatches.first.group(1)?.replaceAll(',', '.');
    litresConfidence = 0.98;
  } else {
    final numRe = RegExp(r'(\d+[\.,]?\d{1,3})');
    final candidates = numRe
        .allMatches(text)
        .map((m) => m.group(1))
        .whereType<String>()
        .toList();
    if (candidates.isNotEmpty) {
      for (final c in candidates) {
        final v = double.tryParse(c.replaceAll(',', '.'));
        if (v != null && v > 0 && v <= 100) {
          litresStr = c.replaceAll(',', '.');
          litresConfidence = 0.5;
          break;
        }
      }
    }
  }

  // Extract price candidates
  final priceRe = RegExp(
    r'(\d+[\.,]?\d{1,2})\s?(?:tl|try|₺|tl\.|tl)?',
    caseSensitive: false,
  );
  final priceMatches = priceRe.allMatches(text).toList();
  double? priceVal;
  double priceConfidence = 0.0;
  if (priceMatches.isNotEmpty) {
    for (final m in priceMatches) {
      final span = m.group(0) ?? '';
      final raw = m.group(1) ?? '';
      final numv = double.tryParse(raw.replaceAll(',', '.'));
      if (numv == null) continue;
      if (RegExp(r'(tl|try|₺)', caseSensitive: false).hasMatch(span)) {
        priceVal = numv;
        priceConfidence = 0.95;
        break;
      }
      if (priceVal == null || numv > priceVal) {
        priceVal = numv;
        priceConfidence = 0.6;
      }
    }
  }

  final brands = [
    'Shell',
    'Opet',
    'BP',
    'Total',
    'Socar',
    'Petronas',
    'A101',
    'PO Gaz',
    'MİLE',
    'Lukoil',
  ];
  String detectedBrand = '';
  double brandConfidence = 0.0;
  for (final b in brands) {
    final loweredB = b.toLowerCase();
    if (lowered.contains(loweredB)) {
      detectedBrand = b;
      brandConfidence = 0.98;
      break;
    }
  }
  if (brandConfidence < 0.98) {
    final words = lowered.split(RegExp(r'\s+'));
    for (final w in words) {
      for (final b in brands) {
        final dist = _levenshtein(
          w.replaceAll(RegExp(r'[^a-z0-9]'), ''),
          b.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), ''),
        );
        final maxLen = max(w.length, b.length).clamp(1, 100);
        final sim = 1.0 - (dist / maxLen);
        if (sim > brandConfidence && sim > 0.6) {
          detectedBrand = b;
          brandConfidence = _clamp01(sim);
        }
      }
    }
  }

  String? dateIso;
  double dateConfidence = 0.0;
  final d1 = RegExp(r'(\d{4}-\d{2}-\d{2})').firstMatch(text)?.group(1);
  if (d1 != null) {
    dateIso = d1;
    dateConfidence = 0.95;
  } else {
    final d2 = RegExp(r'(\d{2}\.\d{2}\.\d{4})').firstMatch(text)?.group(1);
    if (d2 != null) {
      final parts = d2.split('.');
      dateIso = '${parts[2]}-${parts[1]}-${parts[0]}';
      dateConfidence = 0.9;
    }
  }

  double consistencyScore = 0.0;
  if (litresStr != null && priceVal != null) {
    final lval = double.tryParse(litresStr.replaceAll(',', '.')) ?? 0.0;
    if (lval > 0) {
      final ppl = priceVal / lval;
      if (ppl > 0.5 && ppl < 30) {
        consistencyScore = 1.0;
      } else if (ppl > 0 && ppl < 100) {
        consistencyScore = 0.4;
      }
    }
  }

  final litresVal = litresStr != null ? double.tryParse(litresStr) : null;
  final litresConf = _clamp01(
    litresConfidence * (0.6 + 0.4 * consistencyScore),
  );
  final priceConf = _clamp01(priceConfidence * (0.6 + 0.4 * consistencyScore));
  final brandConf = _clamp01(brandConfidence);
  final dateConf = _clamp01(dateConfidence);

  final eps = 1e-6;
  final weighted =
      pow((litresConf + eps), 0.35) *
      pow((priceConf + eps), 0.45) *
      pow((brandConf + eps), 0.15) *
      pow((dateConf + eps), 0.05);
  final overall = ((weighted is double) ? weighted : weighted.toDouble()).clamp(
    0.0,
    1.0,
  );

  return {
    'litres': litresVal,
    'litres_confidence': (litresConf * 100).round(),
    'price': priceVal,
    'price_confidence': (priceConf * 100).round(),
    'brand': detectedBrand,
    'brand_confidence': (brandConf * 100).round(),
    'date': dateIso,
    'date_confidence': (dateConf * 100).round(),
    'overall_confidence': (overall * 100).round(),
  };
}

void main() {
  final samples = [
    // English receipts
    'Shell Station\nDate: 2024-05-12\nLitres: 12.40 L\nTotal: 250.00 TRY',
    'BP\n12.5 L\nPrice: 345.00 TL',
    'Total Gas\n15 L\nAmount: 450.50 TL',
    // Turkish receipts
    'OPET\nTarih 12.05.2024\nLitre: 10,5 L\nToplam: 300,00 TL',
    'Socar Akaryakit\n12 L\nTutar: 360 TL',
    // noisy OCR-like samples
    'SH ELL\n12.4 L\n250,00 TL',
    'SHEL L\n12,4L\nTUTAR 250TL',
    'Random shop\n1.5 kg\n3.00 TL',
    'A101\n05.05.2024\nL: 8.2\nTotal 200',
  ];

  final results = <int>[];
  for (final s in samples) {
    final r = parseReceipt(s);
    print(
      'SAMPLE: "${s.replaceAll('\n', ' / ')}" -> overall ${r['overall_confidence']}% (litres:${r['litres_confidence']}% price:${r['price_confidence']}% brand:${r['brand_confidence']}%)',
    );
    results.add(r['overall_confidence'] as int);
  }
  final avg = results.isEmpty
      ? 0
      : (results.reduce((a, b) => a + b) / results.length);
  print('AVERAGE_OVERALL_CONFIDENCE:${avg.toStringAsFixed(1)}%');
}
