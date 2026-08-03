import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:apexflow/shared/utils/pdf_font_loader.dart';
import 'package:apexflow/core/i18n/app_strings.dart';

class RideInvitePdf {
  static Future<void> generateAndShare({
    required String riderTag,
    required String dateStr,
    required String timeStr,
    required String locationStr,
    required bool isTurkish,
  }) async {
    final pdf = pw.Document();

    final regularFont = await PdfFontLoader.loadRegular();
    final boldFont = await PdfFontLoader.loadBold();

    // Warm elegant colors
    final colorStart = PdfColor.fromHex('#FFFDF9'); // Warm cream
    final colorEnd = PdfColor.fromHex('#F5EBE0'); // Soft beige
    final accentColor = PdfColor.fromHex('#8C5A3C'); // Rich coffee brown
    final darkGrey = PdfColor.fromHex('#2F2F2F');

    final title = tInline(
      AppStrings.currentLanguageCode,
      'KAHVE & SÜRÜŞ DAVETİ',
      'COFFEE & RIDE INVITATION',
      'KAFFEE- UND FAHRTEINLADUNG',
    );
    final invitationMsg = tInline(
      AppStrings.currentLanguageCode,
      'Rüzgarı arkamıza alıp kahveye çıkıyoruz. Sen de bize katılmak ister misin?',
      'Riding with the wind for a fresh brew. Care to join us?',
      'Reiten Sie mit dem Wind für ein frisches Gebräu. Möchten Sie sich uns anschließen?',
    );

    pdf.addPage(
      pw.Page(
        // Custom mobile-story ratio: 400 width by 650 height
        pageFormat: const PdfPageFormat(400, 650, marginAll: 0),
        theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
        build: (pw.Context context) {
          return pw.Container(
            width: 400,
            height: 650,
            decoration: pw.BoxDecoration(
              gradient: pw.LinearGradient(
                colors: [colorStart, colorEnd],
                begin: pw.Alignment.topCenter,
                end: pw.Alignment.bottomCenter,
              ),
            ),
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 36,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Top Badge
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: accentColor, width: 1),
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Text(
                    'APEX FLOW RIDER CLUB',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: accentColor,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                pw.SizedBox(height: 30),

                // Main Title
                pw.Text(
                  title,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: accentColor,
                    letterSpacing: 0.5,
                  ),
                ),
                pw.SizedBox(height: 16),

                // Cute Coffee Icon Illustration block
                pw.Container(
                  width: 80,
                  height: 80,
                  alignment: pw.Alignment.center,
                  decoration: pw.BoxDecoration(
                    color: PdfColor(
                      accentColor.red,
                      accentColor.green,
                      accentColor.blue,
                      0.08,
                    ),
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Text(
                    '☕🏍️',
                    style: const pw.TextStyle(fontSize: 32),
                  ),
                ),
                pw.SizedBox(height: 24),

                // Message Block
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 16),
                  child: pw.Text(
                    invitationMsg,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: darkGrey,
                    ),
                  ),
                ),
                pw.SizedBox(height: 36),

                // Meeting Details Card
                pw.Container(
                  width: 320,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(12),
                    boxShadow: [
                      pw.BoxShadow(
                        color: PdfColor.fromHex(
                          '#0D000000',
                        ), // 0.05 opacity black
                        blurRadius: 8,
                        offset: const PdfPoint(0, 3),
                      ),
                    ],
                  ),
                  padding: const pw.EdgeInsets.all(20),
                  child: pw.Column(
                    children: [
                      _buildDetailRow(
                        tInline(
                          AppStrings.currentLanguageCode,
                          'Tarih / Gün',
                          'Date / Day',
                          'Datum/Tag',
                        ),
                        dateStr,
                        accentColor,
                        boldFont,
                      ),
                      pw.Divider(color: PdfColors.grey200, thickness: 0.8),
                      _buildDetailRow(
                        tInline(
                          AppStrings.currentLanguageCode,
                          'Buluşma Saati',
                          'Time',
                          'Zeit',
                        ),
                        timeStr,
                        accentColor,
                        boldFont,
                      ),
                      pw.Divider(color: PdfColors.grey200, thickness: 0.8),
                      _buildDetailRow(
                        tInline(
                          AppStrings.currentLanguageCode,
                          'Buluşma Yeri',
                          'Location',
                          'Standort',
                        ),
                        locationStr,
                        accentColor,
                        boldFont,
                      ),
                    ],
                  ),
                ),
                pw.Spacer(),

                // Sender tag info
                pw.Text(
                  tInline(
                    AppStrings.currentLanguageCode,
                    'Davet Eden:',
                    'Invited by:',
                    'Eingeladen von:',
                  ),
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  riderTag,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                pw.SizedBox(height: 20),

                // Footer Note
                pw.Text(
                  tInline(
                    AppStrings.currentLanguageCode,
                    'Grup sürüşü kurallarına ve güvenlik ekipmanı yönergelerine uyunuz.',
                    'Please follow group ride safety and equipment guidelines.',
                    'Bitte befolgen Sie die Sicherheits- und Ausrüstungsrichtlinien für Gruppenfahrten.',
                  ),
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(
                    fontSize: 7,
                    color: PdfColors.grey500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Save and Share the document
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/coffee_ride_invite.pdf');
    await file.writeAsBytes(await pdf.save());

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: tInline(
          AppStrings.currentLanguageCode,
          'Buluşalım mı? Kahve sürüşü davetiyen hazır! ☕🏍️',
          'Shall we meet? Your coffee ride invitation is ready! ☕🏍️',
          'Sollen wir uns treffen? Ihre Einladung zur Kaffeefahrt ist fertig! ☕🏍️',
        ),
      ),
    );
  }

  static pw.Widget _buildDetailRow(
    String label,
    String value,
    PdfColor accentColor,
    pw.Font boldFont,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}
