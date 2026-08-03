import 'dart:math';

double _clamp01(double value) {
  if (!value.isFinite) return 0;
  return value.clamp(0.0, 1.0).toDouble();
}

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

class _ValueCandidate {
  const _ValueCandidate({
    required this.value,
    required this.score,
    required this.confidence,
    this.currency,
  });

  final double value;
  final double score;
  final double confidence;
  final String? currency;
}

class _BrandCandidate {
  const _BrandCandidate(this.name, this.confidence);

  final String name;
  final double confidence;
}

class _DateCandidate {
  const _DateCandidate(this.iso, this.confidence);

  final String iso;
  final double confidence;
}

class _BrandAlias {
  const _BrandAlias(this.name, this.aliases);

  final String name;
  final List<String> aliases;
}

const _brandAliases = [
  _BrandAlias('Shell', ['SHELL', 'SHELL TURCAS']),
  _BrandAlias('Opet', ['OPET']),
  _BrandAlias('BP', ['BP', 'BRITISH PETROLEUM']),
  _BrandAlias('Petrol Ofisi', ['PETROL OFISI', 'PETROLOFISI', 'PO']),
  _BrandAlias('TotalEnergies', ['TOTALENERGIES', 'TOTAL ENERGIES', 'TOTAL']),
  _BrandAlias('Socar', ['SOCAR']),
  _BrandAlias('Aytemiz', ['AYTEMIZ']),
  _BrandAlias('Türkiye Petrolleri', ['TURKIYE PETROLLERI', 'TP PETROL']),
  _BrandAlias('Lukoil', ['LUKOIL']),
  _BrandAlias('Petronas', ['PETRONAS']),
  _BrandAlias('Gulf', ['GULF']),
  _BrandAlias('Alpet', ['ALPET']),
  _BrandAlias('Kadoil', ['KADOIL']),
  _BrandAlias('Moil', ['MOIL']),
  _BrandAlias('Sunpet', ['SUNPET']),
  _BrandAlias('Termopet', ['TERMOPET']),
  _BrandAlias('Repsol', ['REPSOL']),
  _BrandAlias('Esso', ['ESSO']),
  _BrandAlias('Texaco', ['TEXACO']),
  _BrandAlias('Chevron', ['CHEVRON']),
  _BrandAlias('Circle K', ['CIRCLE K']),
];

const _totalLabels = [
  'GENEL TOPLAM',
  'ODENECEK',
  'ODENEN',
  'TOPLAM',
  'TUTAR',
  'SATIS TUTARI',
  'SATIŞ TUTARI',
  'AKARYAKIT TUTARI',
  'MAL HIZMET TOPLAM',
  'MAL/HIZMET TOPLAM',
  'TOTAL',
  'AMOUNT',
];

const _paymentLabels = [
  'KREDI',
  'KREDI KARTI',
  'KART',
  'NAKIT',
  'BANKA',
  'POS',
  'CREDIT',
  'CASH',
];

const _taxLabels = [
  'KDV',
  'OTV',
  'ÖTV',
  'VERGI',
  'VERGİ',
  'MATRAH',
  'TAX',
  'VAT',
];

const _unitPriceLabels = [
  'BIRIM',
  'BİRİM',
  'FIYAT',
  'FİYAT',
  'TL/LT',
  'TL / LT',
  '/LT',
  '/ L',
  'LITRE FIYATI',
  'LITRE FİYATI',
  'POMPA FIYATI',
];

const _quantityLabels = [
  'MIKTAR',
  'MİKTAR',
  'LITRE',
  'LİTRE',
  'LITRES',
  'LITERS',
  'HACIM',
  'VOLUME',
  'QUANTITY',
];

class _MathMatch {
  final double litres;
  final double unitPrice;
  final double total;
  _MathMatch(this.litres, this.unitPrice, this.total);
}

List<double> _extractAllNumbers(List<String> lines) {
  final numbers = <double>[];
  for (final line in lines) {
    for (final token in _numberTokens(line)) {
      final value = _parseSmartNumber(token);
      if (value != null && value > 0 && !numbers.contains(value)) {
        numbers.add(value);
      }
    }
  }
  return numbers;
}

_MathMatch? _findMathMatch(List<double> allNumbers) {
  for (int i = 0; i < allNumbers.length; i++) {
    for (int j = 0; j < allNumbers.length; j++) {
      if (i == j) continue;
      for (int k = 0; k < allNumbers.length; k++) {
        if (k == i || k == j) continue;
        final a = allNumbers[i];
        final b = allNumbers[j];
        final c = allNumbers[k];

        if (a >= 1.0 &&
            a <= 50.0 &&
            b >= 20.0 &&
            b <= 100.0 &&
            c >= 20.0 &&
            c <= 2500.0) {
          final expectedTotal = a * b;
          if ((expectedTotal - c).abs() < 2.0) {
            return _MathMatch(a, b, c);
          }
        }
      }
    }
  }
  return null;
}

Map<String, dynamic> parseReceipt(String text) {
  final lines = _normalizedLines(text);
  final foldedText = _fold(lines.join('\n'));

  final hasTurkishContext =
      foldedText.contains('KDV') ||
      foldedText.contains('TOPLAM') ||
      foldedText.contains('FIS') ||
      foldedText.contains('TUTAR') ||
      foldedText.contains('LITRE');

  final currency = hasTurkishContext
      ? 'TRY'
      : (_detectCurrency(foldedText) ?? 'TRY');

  final allNumbers = _extractAllNumbers(lines);
  final mathMatch = _findMathMatch(allNumbers);

  _ValueCandidate? litres;
  _ValueCandidate? price;

  if (mathMatch != null) {
    litres = _ValueCandidate(
      value: mathMatch.litres,
      score: 10,
      confidence: 0.99,
      currency: currency,
    );
    price = _ValueCandidate(
      value: mathMatch.total,
      score: 10,
      confidence: 0.99,
      currency: currency,
    );
  } else {
    price = _pickPrice(lines, currency);
    litres = _pickLitres(lines, price?.value, currency);
  }

  final brand = _pickBrand(foldedText);
  final date = _pickDate(lines);

  var litresConfidence = litres?.confidence ?? 0.0;
  var priceConfidence = price?.confidence ?? 0.0;

  if (mathMatch != null) {
    litresConfidence = 0.99;
    priceConfidence = 0.99;
  } else if (litres != null && price != null) {
    final plausible = _plausiblePricePerLitre(
      price.value / litres.value,
      currency,
    );
    if (plausible) {
      litresConfidence = _clamp01(litresConfidence + 0.08);
      priceConfidence = _clamp01(priceConfidence + 0.08);
    } else {
      litresConfidence = _clamp01(litresConfidence * 0.78);
      priceConfidence = _clamp01(priceConfidence * 0.78);
    }
  }

  final brandConfidence = brand?.confidence ?? 0.0;
  final dateConfidence = date?.confidence ?? 0.0;
  final overall = _clamp01(
    litresConfidence * 0.38 +
        priceConfidence * 0.42 +
        brandConfidence * 0.12 +
        dateConfidence * 0.08,
  );

  return {
    'litres': litres?.value,
    'litres_confidence': (litresConfidence * 100).round(),
    'price': price?.value,
    'currency': currency,
    'price_confidence': (priceConfidence * 100).round(),
    'brand': brand?.name ?? '',
    'brand_confidence': (brandConfidence * 100).round(),
    'date': date?.iso,
    'date_confidence': (dateConfidence * 100).round(),
    'overall_confidence': (overall * 100).round(),
  };
}

List<String> _normalizedLines(String text) {
  return text
      .replaceAll('₺', ' TL ')
      .replaceAll('’', '\'')
      .split(RegExp(r'\r?\n'))
      .map((line) => line.trim().replaceAll(RegExp(r'\s+'), ' '))
      .where((line) => line.length >= 2)
      .toList();
}

String _fold(String input) {
  return input
      .replaceAll('İ', 'I')
      .replaceAll('I', 'I')
      .replaceAll('ı', 'I')
      .replaceAll('ğ', 'G')
      .replaceAll('Ğ', 'G')
      .replaceAll('ü', 'U')
      .replaceAll('Ü', 'U')
      .replaceAll('ş', 'S')
      .replaceAll('Ş', 'S')
      .replaceAll('ö', 'O')
      .replaceAll('Ö', 'O')
      .replaceAll('ç', 'C')
      .replaceAll('Ç', 'C')
      .toUpperCase();
}

_BrandCandidate? _pickBrand(String foldedText) {
  for (final brand in _brandAliases) {
    for (final alias in brand.aliases) {
      final foldedAlias = _fold(alias);
      if (_containsAlias(foldedText, foldedAlias)) {
        return _BrandCandidate(brand.name, 0.98);
      }
    }
  }

  _BrandCandidate? best;
  final words = foldedText
      .split(RegExp(r'[^A-Z0-9]+'))
      .where((word) => word.length >= 3)
      .toList();
  for (final word in words) {
    for (final brand in _brandAliases) {
      for (final alias in brand.aliases.where((alias) => alias.length >= 4)) {
        final compactAlias = _fold(alias).replaceAll(RegExp(r'[^A-Z0-9]'), '');
        final distance = _levenshtein(word, compactAlias);
        final maxLen = max(word.length, compactAlias.length).clamp(1, 100);
        final similarity = 1 - distance / maxLen;
        if (similarity > 0.72 &&
            (best == null || similarity > best.confidence)) {
          best = _BrandCandidate(brand.name, _clamp01(similarity * 0.9));
        }
      }
    }
  }
  return best;
}

bool _containsAlias(String text, String alias) {
  if (alias.length <= 2) {
    return RegExp('(^|[^A-Z0-9])$alias([^A-Z0-9]|\$)').hasMatch(text);
  }
  return text.contains(alias);
}

_ValueCandidate? _pickPrice(List<String> lines, String forceCurrency) {
  _ValueCandidate? best;
  for (final line in lines) {
    final folded = _fold(line);
    if (_isDateHeavyLine(folded)) continue;

    final hasCurrency = _currencyFromLine(folded) != null;
    final hasTotal = _containsAny(folded, _totalLabels);
    final hasPayment = _containsAny(folded, _paymentLabels);
    final hasUnitPrice = _containsAny(folded, _unitPriceLabels);
    final hasTax = _containsAny(folded, _taxLabels);
    final hasVolume = _hasVolumeSignal(folded);

    for (final token in _numberTokens(line)) {
      final value = _parseSmartNumber(token);
      if (value == null || value <= 0 || value > 250000) continue;

      var score = 0.0;
      if (hasCurrency) score += 3.0;
      if (hasTotal) score += 5.0;
      if (hasPayment) score += 2.0;
      if (hasUnitPrice) score -= 5.5;
      if (hasTax) score -= 2.0;
      if (hasVolume && !hasTotal) score -= 3.5;
      if (_fractionDigits(token) == 2) score += 1.2;
      if (value >= 20) score += min(value / 1500, 2.0);

      if (score < 1.0) continue;
      final confidence = _scoreToConfidence(score, maxScore: 10.0);
      final candidate = _ValueCandidate(
        value: value,
        score: score,
        confidence: confidence,
        currency: forceCurrency,
      );
      if (_isBetterCandidate(candidate, best)) {
        best = candidate;
      }
    }
  }
  return best;
}

_ValueCandidate? _pickLitres(
  List<String> lines,
  double? totalPrice,
  String currency,
) {
  _ValueCandidate? best;
  for (final line in lines) {
    final folded = _fold(line);
    if (_isDateHeavyLine(folded)) continue;

    final hasUnit = _hasVolumeSignal(folded);
    final hasQuantity = _containsAny(folded, _quantityLabels);
    final hasUnitPrice = _containsAny(folded, _unitPriceLabels);
    final hasTotal = _containsAny(folded, _totalLabels);
    final hasTax = _containsAny(folded, _taxLabels);

    for (final token in _numberTokens(line)) {
      final value = _parseSmartNumber(token);
      if (value == null || value <= 0 || value > 150) continue;

      var score = 0.0;
      if (hasUnit) score += 4.0;
      if (hasQuantity) score += 3.0;
      if (hasUnitPrice) score -= 6.0;
      if (hasTotal) score -= 3.0;
      if (hasTax) score -= 2.0;
      if (value >= 1 && value <= 80) {
        score += 2.0;
      } else if (value <= 120) {
        score += 0.6;
      }
      if (_fractionDigits(token) >= 2) score += 1.0;
      if (totalPrice != null &&
          _plausiblePricePerLitre(totalPrice / value, currency)) {
        score += 2.0;
      }

      if (score < 1.0) continue;
      final confidence = _scoreToConfidence(score, maxScore: 11.0);
      final candidate = _ValueCandidate(
        value: value,
        score: score,
        confidence: confidence,
      );
      if (_isBetterCandidate(candidate, best)) {
        best = candidate;
      }
    }
  }
  return best;
}

bool _isBetterCandidate(_ValueCandidate candidate, _ValueCandidate? current) {
  if (current == null) return true;
  if ((candidate.score - current.score).abs() < 0.35) {
    return candidate.value > current.value;
  }
  return candidate.score > current.score;
}

double _scoreToConfidence(double score, {required double maxScore}) {
  return _clamp01(0.35 + (score / maxScore) * 0.63);
}

bool _plausiblePricePerLitre(double value, String currency) {
  if (!value.isFinite || value <= 0) return false;
  final highValueCurrency = {'USD', 'EUR', 'GBP'}.contains(currency);
  if (highValueCurrency) {
    return value >= 0.4 && value <= 6.0;
  }
  return value >= 5.0 && value <= 180.0;
}

_DateCandidate? _pickDate(List<String> lines) {
  for (final line in lines) {
    final folded = _fold(line);
    final isoMatch = RegExp(
      r'\b(20\d{2})[-/.](\d{1,2})[-/.](\d{1,2})\b',
    ).firstMatch(line);
    if (isoMatch != null) {
      final iso = _dateIso(
        int.parse(isoMatch.group(1)!),
        int.parse(isoMatch.group(2)!),
        int.parse(isoMatch.group(3)!),
      );
      if (iso != null) return _DateCandidate(iso, 0.95);
    }

    final localMatch = RegExp(
      r'\b(\d{1,2})[-/.](\d{1,2})[-/.](\d{2,4})\b',
    ).firstMatch(line);
    if (localMatch == null) continue;

    final first = int.parse(localMatch.group(1)!);
    final second = int.parse(localMatch.group(2)!);
    var year = int.parse(localMatch.group(3)!);
    if (year < 100) {
      year += 2000;
    }

    final dayFirst = first > 12 || second <= 12 || folded.contains('TARIH');
    final day = dayFirst ? first : second;
    final month = dayFirst ? second : first;
    final iso = _dateIso(year, month, day);
    if (iso != null) {
      return _DateCandidate(iso, dayFirst ? 0.92 : 0.74);
    }
  }
  return null;
}

String? _dateIso(int year, int month, int day) {
  if (year < 2020 || year > 2100) return null;
  if (month < 1 || month > 12 || day < 1 || day > 31) return null;
  final date = DateTime(year, month, day);
  if (date.year != year || date.month != month || date.day != day) {
    return null;
  }
  final mm = month.toString().padLeft(2, '0');
  final dd = day.toString().padLeft(2, '0');
  return '$year-$mm-$dd';
}

String? _detectCurrency(String foldedText) {
  return _currencyFromLine(foldedText);
}

String? _currencyFromLine(String foldedLine) {
  if (foldedLine.contains('USD')) return 'USD';
  if (foldedLine.contains('EUR')) return 'EUR';
  if (foldedLine.contains('GBP')) return 'GBP';
  if (foldedLine.contains(' TL') ||
      foldedLine.contains('TL ') ||
      foldedLine.contains('TRY') ||
      foldedLine.contains('₺')) {
    return 'TRY';
  }
  return null;
}

bool _containsAny(String text, List<String> tokens) {
  return tokens.any((token) => text.contains(_fold(token)));
}

bool _hasVolumeSignal(String foldedLine) {
  return RegExp(
    r'(^|[^A-Z])(?:L|LT|LTR|LITRE|LITRES|LITER)([^A-Z]|$)',
  ).hasMatch(foldedLine);
}

bool _isDateHeavyLine(String foldedLine) {
  return RegExp(r'\b\d{1,2}[-/.]\d{1,2}[-/.]\d{2,4}\b').hasMatch(foldedLine);
}

Iterable<String> _numberTokens(String line) sync* {
  final matches = RegExp(
    r'(?:^|[^\d])(\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{1,3})?|\d+(?:[.,]\d{1,3})?)(?=$|[^\d])',
  ).allMatches(line);
  for (final match in matches) {
    final token = match.group(1);
    if (token != null) {
      yield token;
    }
  }
}

double? _parseSmartNumber(String? value) {
  if (value == null) return null;
  var cleaned = value.replaceAll(RegExp(r'[^0-9,.\-]'), '').trim();
  if (cleaned.isEmpty || cleaned == '-' || cleaned == '.' || cleaned == ',') {
    return null;
  }

  final lastDot = cleaned.lastIndexOf('.');
  final lastComma = cleaned.lastIndexOf(',');
  if (lastDot >= 0 && lastComma >= 0) {
    final decimalSeparator = lastDot > lastComma ? '.' : ',';
    final thousandsSeparator = decimalSeparator == '.' ? ',' : '.';
    cleaned = cleaned
        .replaceAll(thousandsSeparator, '')
        .replaceAll(decimalSeparator, '.');
    return double.tryParse(cleaned);
  }

  final separator = cleaned.contains(',')
      ? ','
      : cleaned.contains('.')
      ? '.'
      : null;
  if (separator == null) {
    return double.tryParse(cleaned);
  }

  final parts = cleaned.split(separator);
  if (parts.length > 2 && parts.skip(1).every((part) => part.length == 3)) {
    return double.tryParse(parts.join());
  }

  cleaned = cleaned.replaceAll(separator, '.');
  return double.tryParse(cleaned);
}

int _fractionDigits(String token) {
  final comma = token.lastIndexOf(',');
  final dot = token.lastIndexOf('.');
  final index = max(comma, dot);
  if (index < 0 || index == token.length - 1) return 0;
  return token.length - index - 1;
}
