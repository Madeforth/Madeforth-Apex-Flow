import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:apexflow/shared/utils/pdf_font_loader.dart';
import 'package:apexflow/core/i18n/app_strings.dart';

class CircularStickerPdf {
  static Future<void> generateAndShare({
    required String riderTag,
    required bool isTurkish,
  }) async {
    final pdf = pw.Document();

    final regularFont = await PdfFontLoader.loadRegular();
    final boldFont = await PdfFontLoader.loadBold();

    // Modern Off-White Design Palette
    final bgA4 = PdfColor.fromHex(
      '#F8FAFC',
    ); // Slate 50 (Very light cool off-white)
    final bgCard = PdfColor.fromHex(
      '#E2E8F0',
    ); // Slate 200 (slightly darker than off-white)
    final borderDark = PdfColor.fromHex('#0F172A'); // Midnight Slate 900
    final goldAccent = PdfColor.fromHex('#AA7C11'); // Dark Rich Gold
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
                  'APEX FLOW RIDER PASS',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: borderDark,
                    letterSpacing: 2,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Container(width: 60, height: 2, color: goldAccent),
                pw.SizedBox(height: 8),
                pw.Text(
                  tInline(
                    AppStrings.currentLanguageCode,
                    'Premium Kask & Motor İrtibat Sticker Şablonu (300 DPI)',
                    'Premium Helmet & Bike Contact Sticker Template (300 DPI)',
                    'Premium-Helm- und Fahrrad-Kontaktaufkleber-Vorlage (300 DPI)',
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
                                  'SÜRÜCÜ KART',
                                  'RIDER PASS',
                                  'FAHRERPASS',
                                ),
                                style: pw.TextStyle(
                                  fontSize: 5.5,
                                  fontWeight: pw.FontWeight.bold,
                                  color: goldAccent,
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
                                  'https://apex-flow-7baea.web.app/?id=$riderTag',
                              width: 76,
                              height: 76,
                              barcode: pw.Barcode.qrCode(),
                            ),
                          ),

                          // Footer Info Pill (Gold background, Dark Text)
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
                                  'ARKADAŞ EKLEMEK İÇİN TARA',
                                  'SCAN TO ADD FRIEND',
                                  'SCANNEN, UM FREUND HINZUFÜGEN',
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
    final file = File('${output.path}/apexflow_qr_stickers.pdf');
    await file.writeAsBytes(await pdf.save());

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: tInline(
          AppStrings.currentLanguageCode,
          'Apex Flow Yazdırılabilir Kask/Motor QR Sticker Şablonu',
          'Apex Flow Printable Helmet/Bike QR Sticker Template',
          'Apex Flow druckbare Helm-/Fahrrad-QR-Aufkleber-Vorlage',
        ),
      ),
    );
  }
}
