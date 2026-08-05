import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:apexflow/shared/utils/pdf_font_loader.dart';
import 'package:apexflow/core/i18n/app_strings.dart';

class RideVibePdf {
  static Future<void> generateAndShare({
    required String riderName,
    required String riderTag,
    required String vibeKey, // sparkly, sunset, coffee, sporty
    required String bikeName,
    required double distanceKm,
    required bool isTurkish,
  }) async {
    final pdf = pw.Document();

    final regularFont = await PdfFontLoader.loadRegular();
    final boldFont = await PdfFontLoader.loadBold();

    // Map vibe details
    String titleTr = 'Işıltılı Sürüş';
    String titleEn = 'Sparkly Ride';
    String quoteTr = 'Işıltılı yollar, mutlu kız kardeşlik sürüşleri! ✨';
    String quoteEn = 'Sparkling roads, happy sisterhood rides! ✨';
    PdfColor colorStart = PdfColor.fromHex('#FAE8FF'); // soft pink/fuchsia
    PdfColor colorEnd = PdfColor.fromHex('#E0F2FE'); // soft sky blue
    PdfColor accentColor = PdfColor.fromHex('#DB2777'); // pink 600

    if (vibeKey == 'sunset') {
      titleTr = 'Gün Batımı Sürüşü';
      titleEn = 'Sunset Ride';
      quoteTr = 'Güneş batarken, özgürlük yollarda başlar. 🌻';
      quoteEn = 'As the sun goes down, freedom begins on the road. 🌻';
      colorStart = PdfColor.fromHex('#FEF3C7'); // soft amber
      colorEnd = PdfColor.fromHex('#FFEDD5'); // soft orange
      accentColor = PdfColor.fromHex('#D97706'); // amber 600
    } else if (vibeKey == 'coffee') {
      titleTr = 'Dedikodu & Kahve Turu';
      titleEn = 'Coffee & Gossip Run';
      quoteTr = 'Kahve kokusu, motor sesi ve bolca sohbet! ☕';
      quoteEn = 'Coffee aroma, engine rumble and lots of talk! ☕';
      colorStart = PdfColor.fromHex('#FFFBEB'); // cozy cream
      colorEnd = PdfColor.fromHex('#F5F5F4'); // warm stone
      accentColor = PdfColor.fromHex('#78350F'); // warm amber/brown
    } else if (vibeKey == 'sporty') {
      titleTr = 'Rüzgarlı Spor Sürüş';
      titleEn = 'Sporty Wind Ride';
      quoteTr = 'Rüzgarı hisset, virajların tadını çıkar! 💨';
      quoteEn = 'Feel the wind, enjoy the curvy corners! 💨';
      colorStart = PdfColor.fromHex('#F0FDFA'); // mint
      colorEnd = PdfColor.fromHex('#E0F2FE'); // sky
      accentColor = PdfColor.fromHex('#0D9488'); // teal 600
    }

    final title = isTurkish ? titleTr : titleEn;
    final quote = isTurkish ? quoteTr : quoteEn;
    final dateStr = _formatCurrentDate(isTurkish);

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
                begin: pw.Alignment.topLeft,
                end: pw.Alignment.bottomRight,
              ),
            ),
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 32,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Top Header Brand
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'APEX FLOW',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: accentColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                    pw.Text(
                      dateStr,
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                pw.Divider(
                  color: PdfColor(
                    accentColor.red,
                    accentColor.green,
                    accentColor.blue,
                    0.2,
                  ),
                  thickness: 1,
                ),
                pw.SizedBox(height: 20),

                // Polaroid Style Main Container
                pw.Container(
                  width: 320,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(8),
                    boxShadow: [
                      pw.BoxShadow(
                        color: PdfColor.fromHex(
                          '#14000000',
                        ), // 0.08 opacity black
                        blurRadius: 10,
                        offset: const PdfPoint(0, 4),
                      ),
                    ],
                  ),
                  padding: const pw.EdgeInsets.all(16),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Photo Area Placeholder with a stylish geometric design
                      pw.Container(
                        width: double.infinity,
                        height: 200,
                        decoration: pw.BoxDecoration(
                          color: PdfColor(
                            colorStart.red,
                            colorStart.green,
                            colorStart.blue,
                            0.4,
                          ),
                          borderRadius: pw.BorderRadius.circular(6),
                          border: pw.Border.all(color: colorEnd, width: 2),
                        ),
                        child: pw.Center(
                          child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Text(
                                '🏍️',
                                style: const pw.TextStyle(fontSize: 48),
                              ),
                              pw.SizedBox(height: 10),
                              pw.Text(
                                title,
                                style: pw.TextStyle(
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold,
                                  color: accentColor,
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                bikeName.isNotEmpty ? bikeName : 'Apex Rider',
                                style: const pw.TextStyle(
                                  fontSize: 10,
                                  color: PdfColors.grey600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 16),

                      // Text Info
                      pw.Text(
                        riderName.isEmpty
                            ? (tInline(
                                AppStrings.currentLanguageCode,
                                'Apex Sürücüsü',
                                'Apex Rider',
                                'Apex-Fahrer',
                              ))
                            : riderName,
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#1E293B'), // Slate 800
                        ),
                      ),
                      pw.Text(
                        riderTag,
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                      pw.SizedBox(height: 12),

                      pw.Text(
                        quote,
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontStyle: pw.FontStyle.italic,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Spacer(),

                // Bottom Stats Row
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#80FFFFFF'), // 0.5 opacity white
                    borderRadius: pw.BorderRadius.circular(20),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(
                        tInline(
                          AppStrings.currentLanguageCode,
                          'Mesafe',
                          'Distance',
                          'Distanz',
                        ),
                        '${distanceKm.toStringAsFixed(1)} KM',
                        accentColor,
                      ),
                      pw.Container(
                        width: 1,
                        height: 20,
                        color: PdfColors.grey400,
                      ),
                      _buildStatColumn(
                        tInline(
                          AppStrings.currentLanguageCode,
                          'Sürüş Modu',
                          'Ride Vibe',
                          'Fahrstimmung',
                        ),
                        title.split(' ').first,
                        accentColor,
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),

                // Footer Community Note
                pw.Text(
                  tInline(
                    AppStrings.currentLanguageCode,
                    'Apex Flow Kadın Sürücü Topluluğu',
                    'Apex Flow Female Rider Community',
                    'Apex Flow-Community für weibliche Fahrer',
                  ),
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor(
                      accentColor.red,
                      accentColor.green,
                      accentColor.blue,
                      0.8,
                    ),
                    letterSpacing: 0.5,
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
    final file = File('${tempDir.path}/ride_vibe_${vibeKey}.pdf');
    await file.writeAsBytes(await pdf.save());

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: tInline(
          AppStrings.currentLanguageCode,
          'Apex Flow ile bugün sürüşümün ruh halini paylaştım! 🏍️✨',
          'Shared my ride vibe today with Apex Flow! 🏍️✨',
          'Habe heute meine Fahrstimmung mit Apex Flow geteilt! 🏍️✨',
        ),
      ),
    );
  }

  static pw.Widget _buildStatColumn(
    String label,
    String value,
    PdfColor accentColor,
  ) {
    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(
          label.toUpperCase(),
          style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: accentColor,
          ),
        ),
      ],
    );
  }

  static String _formatCurrentDate(bool isTurkish) {
    final now = DateTime.now();
    final monthsTr = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    final monthsEn = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    if (isTurkish) {
      return '${now.day} ${monthsTr[now.month - 1]} ${now.year}';
    } else {
      return '${monthsEn[now.month - 1]} ${now.day}, ${now.year}';
    }
  }
}
