import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:apexflow/garage/domain/garage_passport.dart';
import 'package:apexflow/core/i18n/app_strings.dart';

class GaragePassportPdfService {
  static Future<String> generatePdf(GaragePassport passport, bool tr) async {
    final pdf = pw.Document();

    final primaryColor = PdfColor.fromHex('#245C55'); // Orman Yeşili
    final creamColor = PdfColor.fromHex('#F4F1EA'); // Krem
    final borderLight = PdfColors.white;

    final bikeIdShort = passport.bike.id.length > 6
        ? passport.bike.id.substring(0, 6).toUpperCase()
        : passport.bike.id.toUpperCase();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero, // Arka planın taşması için sıfır margin
        build: (pw.Context context) {
          return pw.Container(
            color: primaryColor,
            padding: const pw.EdgeInsets.all(24),
            child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: borderLight, width: 1.5),
              ),
              padding: const pw.EdgeInsets.all(20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Teknik Başlık Bloğu
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            tInline(
                              AppStrings.currentLanguageCode,
                              'FABRİKA TEKNİK PASAPORTU',
                              'FACTORY TECHNICAL PASSPORT',
                              'TECHNISCHER FABRIKPASS',
                            ),
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                              color: borderLight,
                              letterSpacing: 1.5,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            tInline(
                              AppStrings.currentLanguageCode,
                              'SİSTEM: APEXFLOW GARAJ GÜVENLİK PROTOKOLÜ',
                              'SYSTEM: APEXFLOW GARAGE PROTOCOL',
                              'SYSTEM: APEXFLOW GARAGE PROTOKOLL',
                            ),
                            style: pw.TextStyle(
                              fontSize: 8,
                              color: creamColor,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'APEXFLOW OS',
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: borderLight,
                              letterSpacing: 2.0,
                            ),
                          ),
                          pw.Text(
                            'REV. 03',
                            style: pw.TextStyle(fontSize: 8, color: creamColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 12),
                  pw.Container(height: 1.5, color: borderLight),
                  pw.SizedBox(height: 16),

                  // Ana Gövde (2 Sütun)
                  pw.Expanded(
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Sol Sütun: Motosiklet Özellikleri
                        pw.Expanded(
                          flex: 1,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              _sectionHeader(
                                tInline(
                                  AppStrings.currentLanguageCode,
                                  '01 // MOTOSİKLET DETAYLARI',
                                  '01 // MOTORCYCLE DETAYLS',
                                  '01 // MOTORRAD-DETAYLS',
                                ),
                                borderLight,
                              ),
                              pw.SizedBox(height: 8),
                              _specRow(
                                tInline(
                                  AppStrings.currentLanguageCode,
                                  'MARKA/MODEL',
                                  'MAKE/MODEL',
                                  'HERSTELLER/MODELL',
                                ),
                                '${passport.bike.name} ${passport.bike.model}'
                                    .toUpperCase(),
                                borderLight,
                                creamColor,
                              ),
                              _specRow(
                                tInline(
                                  AppStrings.currentLanguageCode,
                                  'KİLOMETRE',
                                  'ODOMETER',
                                  'KILOMETERZÄHLER',
                                ),
                                '${passport.bike.odometerKm} KM',
                                borderLight,
                                creamColor,
                              ),
                              _specRow(
                                tInline(
                                  AppStrings.currentLanguageCode,
                                  'SERVİS PERİYODU',
                                  'SERVICE INTERVAL',
                                  'WARTUNGSINTERVALL',
                                ),
                                '${passport.bike.serviceIntervalKm} KM',
                                borderLight,
                                creamColor,
                              ),
                              _specRow(
                                tInline(
                                  AppStrings.currentLanguageCode,
                                  'DURUM BELGE',
                                  'DOC STATUS',
                                  'DOC-STATUS',
                                ),
                                tInline(
                                  AppStrings.currentLanguageCode,
                                  'ONAYLI',
                                  'VERIFIED',
                                  'VERIFIZIERT',
                                ),
                                borderLight,
                                creamColor,
                              ),

                              pw.SizedBox(height: 20),

                              _sectionHeader(
                                tInline(
                                  AppStrings.currentLanguageCode,
                                  '02 // PARAMETRİK BÜTÜNLÜK (HARMONY)',
                                  '02 // INTEGRITY SCORE (HARMONY)',
                                  '02 // INTEGRITÄTSWERTE (HARMONIE)',
                                ),
                                borderLight,
                              ),
                              pw.SizedBox(height: 8),
                              pw.Container(
                                decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                    color: borderLight,
                                    width: 1,
                                  ),
                                  color: PdfColor.fromHex('#1a443e'),
                                ),
                                padding: const pw.EdgeInsets.all(12),
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.spaceBetween,
                                      children: [
                                        pw.Text(
                                          'HARMONY INDEX:',
                                          style: pw.TextStyle(
                                            fontSize: 9,
                                            fontWeight: pw.FontWeight.bold,
                                            color: borderLight,
                                          ),
                                        ),
                                        pw.Text(
                                          '${passport.harmonyScore}%',
                                          style: pw.TextStyle(
                                            fontSize: 16,
                                            fontWeight: pw.FontWeight.bold,
                                            color: creamColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    pw.SizedBox(height: 6),
                                    pw.Text(
                                      '${tInline(AppStrings.currentLanguageCode, "SEVİYE", "GRADE", "GRAD")}: ${passport.harmonyLevel.toUpperCase()}',
                                      style: pw.TextStyle(
                                        fontSize: 9,
                                        fontWeight: pw.FontWeight.bold,
                                        color: borderLight,
                                      ),
                                    ),
                                    pw.SizedBox(height: 6),
                                    pw.Text(
                                      passport.harmonyInsight,
                                      style: pw.TextStyle(
                                        fontSize: 8,
                                        color: creamColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        pw.SizedBox(width: 24),

                        // Sağ Sütun: Bileşen Durumu
                        pw.Expanded(
                          flex: 1,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              _sectionHeader(
                                tInline(
                                  AppStrings.currentLanguageCode,
                                  '03 // BİLEŞEN SAĞLIK ANALİZİ',
                                  '03 // COMPONENT DIAGNOSTICS',
                                  '03 // KOMPONENTENDIAGNOSE',
                                ),
                                borderLight,
                              ),
                              pw.SizedBox(height: 8),
                              _wearIndicator(
                                tInline(
                                  AppStrings.currentLanguageCode,
                                  'ZİNCİR AŞINMASI',
                                  'CHAIN WEAR',
                                  'Kettenverschleiß',
                                ),
                                passport.bike.chainWearPercent,
                                borderLight,
                                creamColor,
                              ),
                              _wearIndicator(
                                tInline(
                                  AppStrings.currentLanguageCode,
                                  'LASTİK DİŞ SAĞLIĞI',
                                  'TIRE TREAD HEALTH',
                                  'GESUNDHEIT DES REIFENPROFILS',
                                ),
                                100 - passport.bike.tireWearPercent,
                                borderLight,
                                creamColor,
                              ),
                              _wearIndicator(
                                tInline(
                                  AppStrings.currentLanguageCode,
                                  'FREN BALATA ÖMRÜ',
                                  'BRAKE PAD LIFE',
                                  'LEBENSDAUER DER BREMSBELÄGE',
                                ),
                                100 - passport.bike.brakeWearPercent,
                                borderLight,
                                creamColor,
                              ),
                              _healthIndicator(
                                tInline(
                                  AppStrings.currentLanguageCode,
                                  'MOTOR YAĞ SAĞLIĞI',
                                  'ENGINE OIL HEALTH',
                                  'GESUNDHEIT DES MOTORÖLS',
                                ),
                                passport.bike.oilHealthPercent,
                                borderLight,
                                creamColor,
                              ),
                              _healthIndicator(
                                tInline(
                                  AppStrings.currentLanguageCode,
                                  'AKÜ ŞARJ SEVİYESİ',
                                  'BATTERY HEALTH',
                                  'BATTERIEGESUNDHEIT',
                                ),
                                passport.bike.batteryHealthPercent,
                                borderLight,
                                creamColor,
                              ),

                              pw.SizedBox(height: 20),

                              _sectionHeader(
                                tInline(
                                  AppStrings.currentLanguageCode,
                                  '04 // TEKNİK UYARILAR',
                                  '04 // SYSTEM WARNINGS',
                                  '04 // SYSTEMWARNUNGEN',
                                ),
                                borderLight,
                              ),
                              pw.SizedBox(height: 8),
                              pw.Text(
                                tInline(
                                  AppStrings.currentLanguageCode,
                                  '* BÜTÜN VERİLER SÜRÜCÜNÜN HAREKET VE YAKIT VERİLERİNDEN ELDE EDİLMİŞTİR.\n* BU BELGE RESMİ BİR TEKNİK PASAPORT DOKÜMANIDIR VE BİLGİLER GÜNCELDİR.\n* BİLEŞEN SAĞLIĞI PERİYODİK OLARAK FİZİKSEL KONTROL EDİLMELİDİR.',
                                  '* ALL DIAGNOSTICS DERIVED FROM SENSORS AND LOGGED RIDERSHIP DATA.\n* THIS IS AN OFFICIAL VEHICLE PASSPORT DOCUMENT WITH UP-TO-DATE STATUS.\n* ENSURE PHYSICAL VERIFICATION AT SPECIFIED MILEAGE INTERVALS.',
                                  '* ALLE DIAGNOSEWERTE WERDEN VON SENSOREN UND AUFGEZEICHNETEN FAHRERDATEN ABGEWIESEN.\n* Dies ist ein offizielles Fahrzeugpassdokument mit aktuellem Status.\n* Stellen Sie eine physische Überprüfung in festgelegten Kilometerintervallen sicher.',
                                ),
                                style: pw.TextStyle(
                                  fontSize: 7,
                                  color: creamColor,
                                  fontStyle: pw.FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 16),

                  // Çizim Bilgi Kutusu (Title Block)
                  pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: borderLight, width: 1.5),
                    ),
                    child: pw.Row(
                      children: [
                        _footerCell(
                          tInline(
                            AppStrings.currentLanguageCode,
                            'ÇİZEN',
                            'DRAWN BY',
                            'GEZEICHNET VON',
                          ),
                          'APEXFLOW OS',
                          borderLight,
                          creamColor,
                          flex: 3,
                        ),
                        _footerCell(
                          tInline(
                            AppStrings.currentLanguageCode,
                            'TARİH',
                            'DATE',
                            'DATUM',
                          ),
                          passport.generatedAtIso.substring(0, 10),
                          borderLight,
                          creamColor,
                          flex: 3,
                        ),
                        _footerCell(
                          tInline(
                            AppStrings.currentLanguageCode,
                            'ÖLÇEK',
                            'SCALE',
                            'SKALA',
                          ),
                          'NTS (1:1)',
                          borderLight,
                          creamColor,
                          flex: 2,
                        ),
                        _footerCell(
                          tInline(
                            AppStrings.currentLanguageCode,
                            'PASAPORT ID',
                            'PASSPORT ID',
                            'PASS-ID',
                          ),
                          'APX-$bikeIdShort',
                          borderLight,
                          creamColor,
                          flex: 4,
                          hasRightBorder: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/garage_passport_${passport.bike.id}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  static pw.Widget _sectionHeader(String title, PdfColor borderLight) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: borderLight,
            letterSpacing: 1.0,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Container(height: 1, color: borderLight),
      ],
    );
  }

  static pw.Widget _specRow(
    String label,
    String value,
    PdfColor borderLight,
    PdfColor creamColor,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 9, color: borderLight)),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: creamColor,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _wearIndicator(
    String label,
    int percent,
    PdfColor borderLight,
    PdfColor creamColor,
  ) {
    final displayPercent = percent.clamp(0, 100);
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                label,
                style: pw.TextStyle(fontSize: 8, color: borderLight),
              ),
              pw.Text(
                '$displayPercent%',
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  color: creamColor,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 3),
          _progressBar(displayPercent, creamColor),
        ],
      ),
    );
  }

  static pw.Widget _healthIndicator(
    String label,
    int percent,
    PdfColor borderLight,
    PdfColor creamColor,
  ) {
    return _wearIndicator(label, percent, borderLight, creamColor);
  }

  static pw.Widget _progressBar(int percent, PdfColor creamColor) {
    final bars = (percent / 10).round().clamp(0, 10);
    final activeText = 'I' * bars;
    final inactiveText = '.' * (10 - bars);
    return pw.Text(
      '[$activeText$inactiveText]',
      style: pw.TextStyle(
        fontSize: 9,
        fontWeight: pw.FontWeight.bold,
        color: creamColor,
        letterSpacing: 2.0,
      ),
    );
  }

  static pw.Widget _footerCell(
    String label,
    String value,
    PdfColor borderLight,
    PdfColor creamColor, {
    int flex = 1,
    bool hasRightBorder = true,
  }) {
    return pw.Expanded(
      flex: flex,
      child: pw.Container(
        padding: const pw.EdgeInsets.all(6),
        decoration: pw.BoxDecoration(
          border: pw.Border(
            right: hasRightBorder
                ? pw.BorderSide(color: borderLight, width: 1.5)
                : pw.BorderSide.none,
          ),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 6,
                color: borderLight,
                letterSpacing: 0.5,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                color: creamColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
