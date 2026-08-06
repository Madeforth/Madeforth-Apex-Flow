import 'package:uuid/uuid.dart';

class ServiceRecord {
  const ServiceRecord({
    required this.id,
    required this.type, // 'mechanic' or 'diy'
    required this.label,
    required this.odometerKm,
    required this.status,
    required this.note,
    this.loggedAtIso = '1970-01-01T00:00:00.000Z',
  });

  final String id;
  final String type;
  final String label;
  final int odometerKm;
  final String status;
  final String note;
  final String loggedAtIso;

  // KNOWN LIMITATION: this regex captures only the numeric amount and
  // ignores which currency suffix matched (tl/try/usd/$/lira are treated
  // identically) — a note like "$150 oil change" is silently summed as if
  // it were 150 TRY everywhere this cost is aggregated (Insights, etc.).
  // Full multi-currency support needs a real currency field on
  // ServiceRecord and is out of scope for this fix pass; flagged here so
  // it isn't mistaken for correct behavior.
  double get cost {
    final noteLower = note.toLowerCase();
    final regExp = RegExp(r'(\d+)\s*(?:tl|try|usd|\$|lira)');
    final match = regExp.firstMatch(noteLower);
    if (match != null) {
      final valStr = match.group(1);
      if (valStr != null) {
        final val = double.tryParse(valStr);
        if (val != null) return val;
      }
    }

    // DIY maintenance usually costs much less or is free (just materials)
    if (type == 'diy') {
      if (label.toLowerCase().contains('zincir')) return 150.0;
      if (label.toLowerCase().contains('hava')) return 0.0;
      if (label.toLowerCase().contains('yıkama')) return 50.0;
      return 100.0;
    }

    final labelLower = label.toLowerCase();
    if (labelLower.contains('yağ') ||
        labelLower.contains('oil') ||
        labelLower.contains('bakım') ||
        labelLower.contains('service')) {
      return 1500.0;
    }
    if (labelLower.contains('lastik') || labelLower.contains('tire')) {
      return 8000.0;
    }
    if (labelLower.contains('balata') ||
        labelLower.contains('brake') ||
        labelLower.contains('fren')) {
      return 1200.0;
    }
    if (labelLower.contains('zincir') || labelLower.contains('chain')) {
      return 2000.0;
    }
    return 800.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'label': label,
      'odometerKm': odometerKm,
      'status': status,
      'note': note,
      'loggedAtIso': loggedAtIso,
    };
  }

  factory ServiceRecord.fromJson(Map<String, dynamic> json) {
    return ServiceRecord(
      id: json['id'] as String? ?? const Uuid().v4(),
      type: json['type'] as String? ?? 'mechanic',
      label: json['label'] as String? ?? 'Service',
      odometerKm: json['odometerKm'] as int? ?? 0,
      status: json['status'] as String? ?? 'Logged',
      note: json['note'] as String? ?? '',
      loggedAtIso: json['loggedAtIso'] as String? ?? '1970-01-01T00:00:00.000Z',
    );
  }
}
