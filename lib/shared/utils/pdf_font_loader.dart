import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;

class PdfFontLoader {
  static Future<pw.Font> loadRegular() async {
    try {
      final data = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
      return pw.Font.ttf(data);
    } catch (_) {}
    return pw.Font.helvetica();
  }

  static Future<pw.Font> loadBold() async {
    try {
      final data = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
      return pw.Font.ttf(data);
    } catch (_) {}
    return pw.Font.helveticaBold();
  }
}
