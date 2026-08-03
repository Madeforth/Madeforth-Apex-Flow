import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:apexflow/shared/utils/pdf_font_loader.dart';
import 'package:apexflow/core/i18n/app_strings.dart';

class ParkStickerPdf {
  static Future<void> generateAndShare({
    required String riderTag,
    required String bikeModel,
    required bool isTurkish,
  }) async {
    final pdf = pw.Document();

    final regularFont = await PdfFontLoader.loadRegular();
    final boldFont = await PdfFontLoader.loadBold();

    // Modern Off-White Design Palette (Tech Neon Cyan edition)
    final bgA4 = PdfColor.fromHex(
      '#F8FAFC',
    ); // Slate 50 (Very light cool off-white)
    final bgCard = PdfColor.fromHex(
      '#E2E8F0',
    ); // Slate 200 (slightly darker than off-white)
    final borderDark = PdfColor.fromHex('#0F172A'); // Midnight Slate 900
    final cyanAccent = PdfColor.fromHex('#0891B2'); // Deep Cyan Accent
    final textDark = PdfColor.fromHex('#1E293B'); // Slate 800
    final textMuted = PdfColor.fromHex('#64748B'); // Slate 500

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
        build: (pw.Context context) {
          return pw.Container(
            color: bgA4,
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Modern Minimalist Document Header
                pw.Text(
                  'APEX FLOW SMART PARK PASS',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: borderDark,
                    letterSpacing: 2,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Container(width: 60, height: 2, color: cyanAccent),
                pw.SizedBox(height: 8),
                pw.Text(
                  tInline(
                    AppStrings.currentLanguageCode,
                    'Motor Üzeri Tarat-Bildir Akıllı Sticker Şablonu (300 DPI)',
                    'On-Bike Scan-to-Alert Smart Sticker Template (300 DPI)',
                    'On-Bike-Scan-to-Alert-Smart-Sticker-Vorlage (300 DPI)',
                  ),
                  style: pw.TextStyle(fontSize: 8, color: textMuted),
                ),
                pw.SizedBox(height: 40),

                // Grid of 4 Rectangular Cards (No Circles!)
                pw.Wrap(
                  spacing: 40,
                  runSpacing: 40,
                  children: List.generate(4, (index) {
                    return pw.Container(
                      width: 140,
                      height: 190,
                      decoration: pw.BoxDecoration(
                        color: bgCard,
                        borderRadius: pw.BorderRadius.circular(12),
                        border: pw.Border.all(color: borderDark, width: 2),
                        boxShadow: [
                          pw.BoxShadow(
                            color: PdfColor.fromHex('#1A000000'),
                            blurRadius: 6,
                            offset: const PdfPoint(2, -2),
                          ),
                        ],
                      ),
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 16,
                      ),
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          // Header Section
                          pw.Column(
                            children: [
                              pw.Text(
                                'A P E X   F L O W',
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.bold,
                                  color: borderDark,
                                  letterSpacing: 1,
                                ),
                              ),
                              pw.SizedBox(height: 2),
                              pw.Text(
                                tInline(
                                  AppStrings.currentLanguageCode,
                                  'PARK İRTİBAT',
                                  'PARK CONTACT',
                                  'PARKKONTAKT',
                                ),
                                style: pw.TextStyle(
                                  fontSize: 5.5,
                                  fontWeight: pw.FontWeight.bold,
                                  color: cyanAccent,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),

                          // Custom Bracket-Framed QR Code Block
                          pw.Container(
                            padding: const pw.EdgeInsets.all(5),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.white,
                              borderRadius: pw.BorderRadius.circular(6),
                              border: pw.Border.all(
                                color: PdfColors.grey200,
                                width: 1,
                              ),
                            ),
                            child: pw.BarcodeWidget(
                              data:
                                  'https://apex-flow-7baea.web.app/?id=${Uri.encodeComponent(riderTag)}',
                              width: 100,
                              height: 100,
                              barcode: pw.Barcode.qrCode(),
                            ),
                          ),

                          // Footer Info Pill (Slate background, off-white text)
                          pw.Column(
                            children: [
                              pw.Container(
                                padding: const pw.EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: pw.BoxDecoration(
                                  color: borderDark,
                                  borderRadius: pw.BorderRadius.circular(4),
                                ),
                                child: pw.Text(
                                  riderTag,
                                  style: pw.TextStyle(
                                    fontSize: 8,
                                    fontWeight: pw.FontWeight.bold,
                                    color: bgCard,
                                  ),
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                tInline(
                                  AppStrings.currentLanguageCode,
                                  'ACİL DURUMDA BİLDİRMEK İÇİN TARA',
                                  'SCAN TO SEND PARK ALERT',
                                  'SCANNEN, UM PARKWARNUNG ZU SENDEN',
                                ),
                                style: pw.TextStyle(
                                  fontSize: 4.5,
                                  color: textMuted,
                                  fontWeight: pw.FontWeight.bold,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/apexflow_park_stickers.pdf');
    await file.writeAsBytes(await pdf.save());

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: tInline(
          AppStrings.currentLanguageCode,
          'Apex Flow Akıllı Park QR Sticker Şablonu: $bikeModel',
          'Apex Flow Smart Park QR Sticker Template: $bikeModel',
          'Apex Flow Smart Park QR-Aufklebervorlage: $bikeModel',
        ),
      ),
    );
  }
}
