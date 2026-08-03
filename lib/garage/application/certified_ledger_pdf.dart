import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:apexflow/garage/domain/motorcycle_profile.dart';
import 'package:apexflow/garage/domain/service_record.dart';
import 'package:apexflow/shared/utils/pdf_font_loader.dart';
import 'package:apexflow/core/i18n/app_strings.dart';

class CertifiedLedgerPdf {
  static Future<void> generateAndShare({
    required MotorcycleProfile bike,
    required List<ServiceRecord> records,
    required String riderTag,
    required bool isTurkish,
  }) async {
    final regularFont = await PdfFontLoader.loadRegular();
    final boldFont = await PdfFontLoader.loadBold();

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
    );

    final darkMidnight = PdfColor.fromHex('#111827');
    final brandCyan = PdfColor.fromHex('#0E7490');
    final lightGrey = PdfColor.fromHex('#F9FAFB');
    final borderGrey = PdfColor.fromHex('#E5E7EB');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Branded Premium Header
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: darkMidnight,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'APEX FLOW MOTORCYCLE PASSPORT',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                              color: brandCyan,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            tInline(
                              AppStrings.currentLanguageCode,
                              'ONAYLI MAKİNE SİCİL RAPORU',
                              'CERTIFIED MACHINE LEDGER REPORT',
                              'ZERTIFIZIERTER MASCHINEN-LEDGER-BERICHT',
                            ),
                            style: const pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.white,
                            ),
                          ),
                        ],
                      ),
                      pw.Container(
                        color: PdfColors.white,
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.BarcodeWidget(
                          data: 'https://apex-flow-7baea.web.app/?id=$riderTag',
                          width: 45,
                          height: 45,
                          barcode: pw.Barcode.qrCode(),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 25),

                // Machine details card layout
                pw.Text(
                  tInline(
                    AppStrings.currentLanguageCode,
                    'MAKİNE DETAYLARI',
                    'MACHINE DETAILS',
                    'MASCHINEN-DETAILS',
                  ),
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: brandCyan,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: borderGrey),
                    borderRadius: pw.BorderRadius.circular(6),
                    color: lightGrey,
                  ),
                  child: pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            tInline(
                              AppStrings.currentLanguageCode,
                              'Marka / Model:',
                              'Brand / Model:',
                              'Marke/Modell:',
                            ),
                            style: const pw.TextStyle(color: PdfColors.grey700),
                          ),
                          pw.Text(
                            '${bike.name} ${bike.model}',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: darkMidnight,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 6),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            tInline(
                              AppStrings.currentLanguageCode,
                              'Kilometre Sayacı:',
                              'Odometer:',
                              'Kilometerzähler:',
                            ),
                            style: const pw.TextStyle(color: PdfColors.grey700),
                          ),
                          pw.Text(
                            '${bike.odometerKm} km',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: darkMidnight,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 6),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            tInline(
                              AppStrings.currentLanguageCode,
                              'Sürücü Etiketi:',
                              'Rider Tag:',
                              'Fahrer-Tag:',
                            ),
                            style: const pw.TextStyle(color: PdfColors.grey700),
                          ),
                          pw.Text(
                            riderTag,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: brandCyan,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 25),

                // Service History section
                pw.Text(
                  tInline(
                    AppStrings.currentLanguageCode,
                    'SERVİS GEÇMİŞİ',
                    'SERVICE HISTORY',
                    'SERVICEGESCHICHTE',
                  ),
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: brandCyan,
                  ),
                ),
                pw.SizedBox(height: 8),

                records.isEmpty
                    ? pw.Text(
                        tInline(
                          AppStrings.currentLanguageCode,
                          'Kayıtlı servis geçmişi bulunamadı.',
                          'No service records found.',
                          'Keine Serviceaufzeichnungen gefunden.',
                        ),
                        style: pw.TextStyle(
                          fontStyle: pw.FontStyle.italic,
                          color: PdfColors.grey600,
                        ),
                      )
                    : pw.Table(
                        border: pw.TableBorder.all(color: borderGrey, width: 1),
                        children: [
                          pw.TableRow(
                            decoration: pw.BoxDecoration(color: darkMidnight),
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  tInline(
                                    AppStrings.currentLanguageCode,
                                    'Tarih',
                                    'Date',
                                    'Datum',
                                  ),
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.white,
                                  ),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  tInline(
                                    AppStrings.currentLanguageCode,
                                    'Açıklama',
                                    'Description',
                                    'Beschreibung',
                                  ),
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.white,
                                  ),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  tInline(
                                    AppStrings.currentLanguageCode,
                                    'Maliyet',
                                    'Cost',
                                    'Kosten',
                                  ),
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          for (int i = 0; i < records.length; i++)
                            pw.TableRow(
                              decoration: pw.BoxDecoration(
                                color: i % 2 == 0 ? PdfColors.white : lightGrey,
                              ),
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Text(
                                    records[i].loggedAtIso.length >= 10
                                        ? records[i].loggedAtIso.substring(
                                            0,
                                            10,
                                          )
                                        : records[i].loggedAtIso,
                                    style: const pw.TextStyle(
                                      color: PdfColors.grey800,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Text(
                                    records[i].note,
                                    style: const pw.TextStyle(
                                      color: PdfColors.grey800,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Text(
                                    '${records[i].cost.toStringAsFixed(2)} TL',
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      color: darkMidnight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                pw.Spacer(),

                // Verification footer section
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColor.fromHex('#62B2C2')),
                    borderRadius: pw.BorderRadius.circular(6),
                    color: PdfColor.fromHex('#E0F2FE'),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Icon(
                        const pw.IconData(
                          0xe85d,
                        ), // verified check icon or similar representation
                        color: brandCyan,
                        size: 24,
                      ),
                      pw.SizedBox(width: 12),
                      pw.Expanded(
                        child: pw.Text(
                          tInline(
                            AppStrings.currentLanguageCode,
                            'BU BELGE APEX FLOW SİSTEMİ TARAFINDAN DİJİTAL OLARAK ONAYLANMIŞ OLUP, İLGİLİ ARACIN GÜVENLİ VE RESMİ SERVİS GEÇMİŞİNİ TEMSİL ETMEKTEDİR.',
                            'THIS DOCUMENT IS DIGITALLY VERIFIED BY APEX FLOW AND REPRESENTS THE SECURE AND OFFICIAL SERVICE RECORDS Registry.',
                            'DIESES DOKUMENT WIRD VON APEX FLOW DIGITAL VERIFIZIERT UND STELLT DAS SICHERE UND OFFIZIELLE SERVICE RECORDS-Register dar.',
                          ),
                          style: pw.TextStyle(
                            fontSize: 8,
                            color: darkMidnight,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/apexflow_certified_ledger.pdf');
    await file.writeAsBytes(await pdf.save());

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: tInline(
          AppStrings.currentLanguageCode,
          'Apex Flow Onaylı Makine Sicil Raporu: ${bike.name} ${bike.model}',
          'Apex Flow Certified Machine Ledger: ${bike.name} ${bike.model}',
          'Apex Flow-zertifiziertes Maschinenbuch: ${bike.name} ${bike.model}',
        ),
      ),
    );
  }
}
