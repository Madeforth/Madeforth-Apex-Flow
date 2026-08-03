import 'package:apexflow/fuel/presentation/receipt_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses Turkish fuel receipt values with unit price noise', () {
    final result = parseReceipt('''
OPET
TARIH: 31.05.2026 18:35
URUN: KURSUNSUZ BENZIN
MIKTAR 12,345 LT
BIRIM FIYAT 45,67 TL/LT
SATIS TUTARI 563,70 TL
KDV 91,25
''');

    expect(result['brand'], 'Opet');
    expect(result['date'], '2026-05-31');
    expect(result['currency'], 'TRY');
    expect(result['litres'], closeTo(12.345, 0.001));
    expect(result['price'], closeTo(563.70, 0.01));
    expect(result['overall_confidence'], greaterThanOrEqualTo(70));
  });

  test('prefers total amount over litre price and tax lines', () {
    final result = parseReceipt('''
SHELL TURCAS
FIS NO 1842
LT 17,000
POMPA FIYATI 43,12 TL/LT
TOPLAM KDV 122,17
GENEL TOPLAM 733,04 TL
''');

    expect(result['brand'], 'Shell');
    expect(result['litres'], closeTo(17, 0.001));
    expect(result['price'], closeTo(733.04, 0.01));
    expect(result['price'], isNot(closeTo(43.12, 0.01)));
  });

  test('parses receipt without a detected station brand', () {
    final result = parseReceipt('''
AKARYAKIT SATISI
Tarih 01/06/26
LITRE: 8.75 L
ODENECEK TUTAR: ₺420,00
''');

    expect(result['brand'], '');
    expect(result['date'], '2026-06-01');
    expect(result['litres'], closeTo(8.75, 0.001));
    expect(result['price'], closeTo(420, 0.01));
    expect(result['currency'], 'TRY');
  });
}
