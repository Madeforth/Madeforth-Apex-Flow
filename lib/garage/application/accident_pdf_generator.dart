import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:apexflow/garage/domain/accident_report_model.dart';
import 'package:flutter/services.dart' show rootBundle;

class AccidentPdfGenerator {
  static const List<String> trLabels = [
    'Kırmızı ışık ihlalinde bulunmak',
    'Taşıt giremez işareti bulunan karayoluna girmek',
    'Karşı yönden gelen trafiğin kullandığı yola girmek',
    'Geçme yasağı (sollama yasağı) olan yerde geçiş yapmak',
    'Kavşakta geçiş önceliğine uymamak',
    'Yetkili memurun dur işaretinde geçmek',
    'Aynı istikamette önündeki araca arkadan çarpmak',
    'Sağa dönüş kurallarına uymamak',
    'Sola dönüş kurallarına uymamak',
    'Geri manevra kurallarına uymamak',
    'Geçme (sollama) kurallarına uymamak',
    'Geçiş önceliğine uymamak',
    'Parketme kurallarına uymamak',
    'Duraklama kurallarına uymamak',
    'Kurallara uygun park edilmiş araca çarpmak',
  ];

  static const List<String> euLabels = [
    'Parked / Stopped',
    'Leaving a parking place',
    'Entering a parking place',
    'Emerging from a car park / private grounds',
    'Entering a car park / private grounds',
    'Entering a roundabout',
    'Circulating a roundabout',
    'Striking the rear of the other vehicle',
    'Going in the same direction and in the same lane',
    'Changing lanes',
    'Overtaking',
    'Turning to the right',
    'Turning to the left',
    'Reversing',
    'Encroaching on a lane reserved for opposite traffic',
    'Coming from the right (at road junctions)',
    'Had not observed a right of way sign or a red light',
  ];

  static Future<Uint8List> generatePdf(
    AccidentReport report, {
    bool isEurope = false,
  }) async {
    final pdf = pw.Document();

    final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final font = pw.Font.ttf(fontData);
    final boldFontData = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
    final fontBold = pw.Font.ttf(boldFontData);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(10),
        build: (pw.Context context) {
          if (isEurope) {
            return _buildEuropeLayout(report, font, fontBold);
          } else {
            return _buildTurkishLayout(report, font, fontBold);
          }
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildEuropeLayout(
    AccidentReport report,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Title block
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'AGREED STATEMENT OF FACTS ON MOTOR VEHICLE ACCIDENT',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 8.5,
                    color: PdfColors.black,
                  ),
                ),
                pw.Text(
                  'Does NOT constitute an admission of liability, but a summary of identities and of facts.',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 5.5,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
            pw.Text(
              'Must be signed by BOTH drivers',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 6.5,
                color: PdfColors.red800,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 3),

        // Boxes 1 to 5: Header block
        pw.Row(
          children: [
            pw.Expanded(
              flex: 3,
              child: _buildHeaderBox(
                '1. Date of accident | Time',
                '${report.date.toString().substring(0, 10)} | ${report.date.toString().substring(11, 16)}',
                font,
                fontBold,
              ),
            ),
            pw.SizedBox(width: 3),
            pw.Expanded(
              flex: 5,
              child: _buildHeaderBox(
                '2. Place (exact location of accident)',
                report.location,
                font,
                fontBold,
              ),
            ),
            pw.SizedBox(width: 2.5),
            pw.Expanded(
              flex: 2,
              child: _buildHeaderBox(
                '3. Injuries?',
                report.hasInjuries == true
                    ? 'NO [ ]  YES [x]'
                    : 'NO [x]  YES [ ]',
                font,
                fontBold,
              ),
            ),
            pw.SizedBox(width: 2.5),
            pw.Expanded(
              flex: 2,
              child: _buildHeaderBox(
                '4. Other damage?',
                report.hasOtherPropertyDamage == true
                    ? 'NO [ ]  YES [x]'
                    : 'NO [x]  YES [ ]',
                font,
                fontBold,
              ),
            ),
            pw.SizedBox(width: 3),
            pw.Expanded(
              flex: 4,
              child: _buildHeaderBox(
                '5. Witnesses (names, addresses, tel)',
                report.witnesses.isNotEmpty ? report.witnesses : '—',
                font,
                fontBold,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 3),

        // Main Section: Vehicle A, Checklist, Vehicle B
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Vehicle A Column
            pw.Expanded(
              flex: 38,
              child: _buildEuropeDriverColumn(
                'A',
                report.driverA,
                report.impactPointBytesA,
                report.driverA.visibleDamage,
                report.remarksA,
                font,
                fontBold,
              ),
            ),
            pw.SizedBox(width: 3),

            // Circumstances Checklist (Center)
            pw.Expanded(
              flex: 24,
              child: _buildCenterChecklist(
                report,
                euLabels,
                font,
                fontBold,
                true,
              ),
            ),
            pw.SizedBox(width: 3),

            // Vehicle B Column
            pw.Expanded(
              flex: 38,
              child: _buildEuropeDriverColumn(
                'B',
                report.driverB,
                report.impactPointBytesB,
                report.driverB.visibleDamage,
                report.remarksB,
                font,
                fontBold,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 4),

        // Bottom Section: Sketch Plan & Signatures
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Plan/Sketch (Box 13)
            pw.Expanded(
              flex: 75,
              child: pw.Container(
                height: 120,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black, width: 0.8),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(1),
                  ),
                ),
                padding: const pw.EdgeInsets.all(3),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '13. Plan of the accident (Sketch)',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 6,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.Divider(thickness: 0.4, color: PdfColors.grey400),
                    pw.Expanded(
                      child: report.sketchBytes.isNotEmpty
                          ? pw.Center(
                              child: pw.Image(
                                pw.MemoryImage(
                                  Uint8List.fromList(report.sketchBytes),
                                ),
                                fit: pw.BoxFit.contain,
                              ),
                            )
                          : pw.Center(
                              child: pw.Text(
                                'No sketch drawn.',
                                style: pw.TextStyle(
                                  font: font,
                                  fontSize: 6.5,
                                  color: PdfColors.grey600,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            pw.SizedBox(width: 4),

            // Signatures (Box 15)
            pw.Expanded(
              flex: 45,
              child: pw.Container(
                height: 120,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black, width: 0.8),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(1),
                  ),
                ),
                padding: const pw.EdgeInsets.all(3),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '15. Signatures of the drivers',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 6,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.Divider(thickness: 0.4, color: PdfColors.grey400),
                    pw.Expanded(
                      child: pw.Row(
                        children: [
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.Text(
                                  'Driver A',
                                  style: pw.TextStyle(
                                    font: fontBold,
                                    fontSize: 5,
                                  ),
                                ),
                                pw.Spacer(),
                                if (report.signatureBytesA.isNotEmpty)
                                  pw.Image(
                                    pw.MemoryImage(
                                      Uint8List.fromList(
                                        report.signatureBytesA,
                                      ),
                                    ),
                                    height: 40,
                                    fit: pw.BoxFit.contain,
                                  )
                                else
                                  pw.Text(
                                    'Unsigned',
                                    style: pw.TextStyle(
                                      font: font,
                                      fontSize: 5,
                                      color: PdfColors.red,
                                    ),
                                  ),
                                pw.Spacer(),
                              ],
                            ),
                          ),
                          pw.VerticalDivider(
                            thickness: 0.4,
                            color: PdfColors.grey400,
                          ),
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.Text(
                                  'Driver B',
                                  style: pw.TextStyle(
                                    font: fontBold,
                                    fontSize: 5,
                                  ),
                                ),
                                pw.Spacer(),
                                if (report.signatureBytesB.isNotEmpty)
                                  pw.Image(
                                    pw.MemoryImage(
                                      Uint8List.fromList(
                                        report.signatureBytesB,
                                      ),
                                    ),
                                    height: 40,
                                    fit: pw.BoxFit.contain,
                                  )
                                else
                                  pw.Text(
                                    'Unsigned',
                                    style: pw.TextStyle(
                                      font: font,
                                      fontSize: 5,
                                      color: PdfColors.red,
                                    ),
                                  ),
                                pw.Spacer(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildEuropeDriverColumn(
    String code,
    DriverInfo driver,
    List<int> impactBytes,
    String visibleDamage,
    String remarks,
    pw.Font font,
    pw.Font fontBold,
  ) {
    final isA = code == 'A';
    final title = 'vehicle $code';
    final fullName = '${driver.name} ${driver.surname}'.trim();
    final headerBgColor = isA
        ? PdfColor.fromHex('#2563EB')
        : PdfColor.fromHex('#EAB308'); // Blue or Yellow
    final headerTextColor = PdfColors.white;
    final columnBgColor = isA
        ? PdfColor.fromHex('#EFF6FF')
        : PdfColor.fromHex('#FEFCE8'); // Very light blue / yellow tint

    return pw.Container(
      height: 320,
      decoration: pw.BoxDecoration(
        color: columnBgColor,
        border: pw.Border.all(color: PdfColors.black, width: 0.8),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(1)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: double.infinity,
            color: headerBgColor,
            padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 3),
            child: pw.Text(
              title.toUpperCase(),
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 7,
                color: headerTextColor,
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(3),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // 6. Insured
                pw.Text(
                  '6. Insured policyholder',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 5.5,
                    color: PdfColors.black,
                  ),
                ),
                _buildFieldRow('Name Surname:', fullName, font, fontBold),
                _buildFieldRow(
                  'Address:',
                  driver.address,
                  font,
                  font,
                  isAddress: true,
                ),
                _buildFieldRow('Tel No:', driver.phone, font, fontBold),
                _buildFieldRow(
                  'Recover VAT?:',
                  driver.canRecoverVat == true ? 'yes' : 'no',
                  font,
                  font,
                ),
                pw.SizedBox(height: 2),

                // 7. Vehicle
                pw.Text(
                  '7. Vehicle',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 5.5,
                    color: PdfColors.black,
                  ),
                ),
                _buildFieldRow(
                  'Make, Type:',
                  driver.vehicleMake,
                  font,
                  fontBold,
                ),
                _buildFieldRow(
                  'Registration No:',
                  driver.vehiclePlate,
                  font,
                  fontBold,
                ),
                pw.SizedBox(height: 2),

                // 8. Insurance Company
                pw.Text(
                  '8. Insurance Company',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 5.5,
                    color: PdfColors.black,
                  ),
                ),
                _buildFieldRow(
                  'Policy No:',
                  driver.insurancePolicyNumber,
                  font,
                  fontBold,
                ),
                _buildFieldRow(
                  'Agent / Broker:',
                  driver.insuranceAgentNumber,
                  font,
                  fontBold,
                ),
                _buildFieldRow(
                  'Green Card No:',
                  driver.greenCardNumber ?? '—',
                  font,
                  fontBold,
                ),
                _buildFieldRow(
                  'TRAMER No:',
                  driver.tramerNumber,
                  font,
                  fontBold,
                ),
                _buildFieldRow(
                  'Valid until:',
                  driver.policyPeriod,
                  font,
                  fontBold,
                ),
                _buildFieldRow(
                  'Damage insured?:',
                  driver.isDamageInsured == true ? 'yes' : 'no',
                  font,
                  font,
                ),
                pw.SizedBox(height: 2),

                // 9. Driver
                pw.Text(
                  '9. Driver (see driving licence)',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 5.5,
                    color: PdfColors.black,
                  ),
                ),
                _buildFieldRow('Name Surname:', fullName, font, fontBold),
                _buildFieldRow(
                  'Address:',
                  driver.address,
                  font,
                  font,
                  isAddress: true,
                ),
                _buildFieldRow(
                  'Licence No:',
                  driver.licenseNumber,
                  font,
                  fontBold,
                ),
                _buildFieldRow(
                  'Groups / Issued by:',
                  '${driver.licenseClass} / ${driver.licenseIssuingPlace}',
                  font,
                  fontBold,
                ),
                pw.SizedBox(height: 2),

                // 10. Initial Impact
                pw.Text(
                  '10. Point of Initial Impact',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 5.5,
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(height: 1),
                pw.Container(
                  height: 48,
                  alignment: pw.Alignment.center,
                  child: _buildSilhouettesDrawing(impactBytes),
                ),
                pw.SizedBox(height: 2),

                // 11. Visible Damage
                pw.Text(
                  '11. Visible Damage',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 5.5,
                    color: PdfColors.black,
                  ),
                ),
                pw.Text(
                  visibleDamage.isNotEmpty ? visibleDamage : '—',
                  style: pw.TextStyle(font: font, fontSize: 5.5),
                  maxLines: 1,
                ),
                pw.SizedBox(height: 2),

                // 14. Remarks
                pw.Text(
                  '14. Remarks',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 5.5,
                    color: PdfColors.black,
                  ),
                ),
                pw.Text(
                  remarks.isNotEmpty ? remarks : '—',
                  style: pw.TextStyle(font: font, fontSize: 5.5),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTurkishLayout(
    AccidentReport report,
    pw.Font font,
    pw.Font fontBold,
  ) {
    final title = 'MADDİ HASARLI TRAFİK KAZASI TESPİT TUTANAĞI';
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // 1. DİKKAT Warning Header
        _buildWarningHeader(font, fontBold),

        // 2. Official Title Banner
        pw.Container(
          alignment: pw.Alignment.center,
          padding: const pw.EdgeInsets.symmetric(vertical: 3),
          color: PdfColors.black,
          child: pw.Text(
            title,
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 9.5,
              color: PdfColors.white,
            ),
          ),
        ),
        pw.SizedBox(height: 3),

        // 3. Boxes 1, 2, 3: Date, Location, Witnesses
        pw.Row(
          children: [
            pw.Expanded(
              flex: 3,
              child: _buildHeaderBox(
                '1- Kaza Tarihi / Saat',
                '${report.date.toString().substring(0, 10)} - ${report.date.toString().substring(11, 16)}',
                font,
                fontBold,
              ),
            ),
            pw.SizedBox(width: 3),
            pw.Expanded(
              flex: 5,
              child: _buildHeaderBox(
                '2- Kaza Yeri (İl, İlçe, Mahalle, Cadde, Sokak)',
                report.location,
                font,
                fontBold,
              ),
            ),
            pw.SizedBox(width: 3),
            pw.Expanded(
              flex: 4,
              child: _buildHeaderBox(
                '3- Görgü Tanıkları (Adı Soyadı, Adres, Tel)',
                report.witnesses.isNotEmpty ? report.witnesses : '—',
                font,
                fontBold,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 3),

        // 4. Main Twin Columns + Checklist Comparison Grid
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Left Column: Sürücü A
            pw.Expanded(
              flex: 38,
              child: _buildDriverColumn(
                'A',
                report.driverA,
                font,
                fontBold,
                false,
              ),
            ),
            pw.SizedBox(width: 3),

            // Center Checklist: 15 items (Box 7)
            pw.Expanded(
              flex: 24,
              child: _buildCenterChecklist(
                report,
                trLabels,
                font,
                fontBold,
                false,
              ),
            ),
            pw.SizedBox(width: 3),

            // Right Column: Sürücü B
            pw.Expanded(
              flex: 38,
              child: _buildDriverColumn(
                'B',
                report.driverB,
                font,
                fontBold,
                false,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 3),

        // 5. Box 9 & 10: Impact points & Sketch
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Box 9: Impact description & motorcycle/car silhouette vector drawings
            pw.Expanded(
              flex: 5,
              child: pw.Container(
                height: 140,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black, width: 0.8),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(1),
                  ),
                ),
                padding: const pw.EdgeInsets.all(3),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '9- Aracın ilk darbe aldığı yeri bir ok (->) ile gösteriniz.',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 6,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.Divider(thickness: 0.4, color: PdfColors.grey400),
                    pw.SizedBox(height: 2),
                    // Vector silhouettes for A & B
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                      children: [
                        pw.Column(
                          children: [
                            pw.Text(
                              'ARAÇ A',
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 5.5,
                              ),
                            ),
                            pw.SizedBox(height: 2),
                            _buildSilhouettesDrawing(report.impactPointBytesA),
                          ],
                        ),
                        pw.Column(
                          children: [
                            pw.Text(
                              'ARAÇ B',
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 5.5,
                              ),
                            ),
                            pw.SizedBox(height: 2),
                            _buildSilhouettesDrawing(report.impactPointBytesB),
                          ],
                        ),
                      ],
                    ),
                    pw.Spacer(),
                    pw.Text(
                      'İlk darbe yönünü ve bölgesini çıktı üzerinde ok çizerek belirtiniz.',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 5,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            pw.SizedBox(width: 3),

            // Box 10: Sketch Container
            pw.Expanded(
              flex: 7,
              child: pw.Container(
                height: 140,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black, width: 0.8),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(1),
                  ),
                ),
                padding: const pw.EdgeInsets.all(3),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '10- Çarpışma yerinin ve anının taslağını çiziniz / ACCIDENT SKETCH',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 6,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.Divider(thickness: 0.4, color: PdfColors.grey400),
                    pw.Expanded(
                      child: report.sketchBytes.isNotEmpty
                          ? pw.Center(
                              child: pw.Image(
                                pw.MemoryImage(
                                  Uint8List.fromList(report.sketchBytes),
                                ),
                                fit: pw.BoxFit.contain,
                              ),
                            )
                          : pw.Center(
                              child: pw.Text(
                                'Kroki çizilmemiştir / No sketch.',
                                style: pw.TextStyle(
                                  font: font,
                                  fontSize: 7,
                                  color: PdfColors.grey600,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 3),

        // 6. Box 11: Driver Remarks / Görüşler
        pw.Row(
          children: [
            pw.Expanded(
              child: _buildRemarksBox(
                '11- Sürücü görüşleri (ARAÇ A)',
                report.remarksA,
                font,
              ),
            ),
            pw.SizedBox(width: 3),
            pw.Expanded(
              child: _buildRemarksBox(
                '11- Sürücü görüşleri (ARAÇ B)',
                report.remarksB,
                font,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 3),

        // 7. Box 12: Driver Signatures / İmzalar
        pw.Row(
          children: [
            pw.Expanded(
              child: _buildSignatureBox(
                '12- Araç A Sürücüsünün İmzası',
                report.signatureBytesA,
                font,
              ),
            ),
            pw.SizedBox(width: 3),
            pw.Expanded(
              child: _buildSignatureBox(
                '12- Araç B Sürücüsünün İmzası',
                report.signatureBytesB,
                font,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildWarningHeader(pw.Font font, pw.Font fontBold) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 4),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.red800, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(1)),
      ),
      padding: const pw.EdgeInsets.all(3),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'DİKKAT!',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 7,
              color: PdfColors.red800,
            ),
          ),
          pw.Text(
            'a) Kaza tespit tutanağını gerçeğe uygun şekilde düzenleyiniz. Gerçeğe aykırı tutanak düzenlemek özel evrakta sahtekarlık niteliğinde olup, cezai yaptırımı söz konusu olduğu gibi, bu kişiler riski yüksek sigortalı olarak değerlendirilecek ve poliçe yenilemelerinde yüksek prim uygulanacaktır.',
            style: pw.TextStyle(
              font: font,
              fontSize: 5,
              color: PdfColors.red800,
            ),
          ),
          pw.Text(
            'b) Tutanak tanzimi için kaza yerinde beklenmesi gerekli değildir. Mümkünse fotoğrafı çekildikten sonra araçların trafiği aksatmayacak şekilde uygun bir yere çekilerek, tutanağın düzenlenmesi imkân dahilindedir.',
            style: pw.TextStyle(
              font: font,
              fontSize: 5,
              color: PdfColors.red800,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildHeaderBox(
    String title,
    String value,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Container(
      height: 30,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 0.8),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(1)),
      ),
      padding: const pw.EdgeInsets.all(2.5),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 5,
              color: PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 1),
          pw.Text(
            value.isNotEmpty ? value : '—',
            style: pw.TextStyle(font: font, fontSize: 6.5),
            maxLines: 2,
            overflow: pw.TextOverflow.clip,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDriverColumn(
    String code,
    DriverInfo driver,
    pw.Font font,
    pw.Font fontBold,
    bool isEurope,
  ) {
    final title = 'ARAÇ $code';
    final fullName = '${driver.name} ${driver.surname}'.trim();

    return pw.Container(
      height: 320,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 0.8),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(1)),
      ),
      padding: const pw.EdgeInsets.all(3),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 7.5,
              color: PdfColors.black,
            ),
          ),
          pw.Divider(thickness: 0.4, color: PdfColors.grey500),

          // 4- Sürücü Bilgileri
          pw.Text(
            '4- Sürücü Bilgileri',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 6,
              color: PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 1.5),
          _buildFieldRow('Adı Soyadı:', fullName, font, fontBold),
          _buildFieldRow(
            'T.C. Kimlik No:',
            driver.identityNumber,
            font,
            fontBold,
          ),
          _buildFieldRow(
            'Sürücü Belge No. Ve Sınıfı:',
            '${driver.licenseNumber} / ${driver.licenseClass}',
            font,
            fontBold,
          ),
          _buildFieldRow(
            'Alındığı Yer (il/ilçe):',
            driver.licenseIssuingPlace,
            font,
            fontBold,
          ),
          _buildFieldRow('Adres:', driver.address, font, font, isAddress: true),
          _buildFieldRow('Tel No:', driver.phone, font, fontBold),

          pw.SizedBox(height: 3),
          // 5- Araç Bilgileri
          pw.Text(
            '5- Araç Bilgileri',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 6,
              color: PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 1.5),
          _buildFieldRow('Şasi No:', driver.vehicleChassis, font, fontBold),
          _buildFieldRow(
            'Marka ve Modeli:',
            driver.vehicleMake,
            font,
            fontBold,
          ),
          _buildFieldRow('Plaka:', driver.vehiclePlate, font, fontBold),
          _buildFieldRow(
            'Kullanım Şekli:',
            driver.vehicleUsage,
            font,
            fontBold,
          ),

          pw.SizedBox(height: 3),
          // 6- Trafik Sigortası Poliçe Bilgileri
          pw.Text(
            '6- Trafik Sigortası Poliçe Bilgileri',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 6,
              color: PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 1.5),
          _buildFieldRow('Sigortalının Adı Soyadı:', fullName, font, fontBold),
          _buildFieldRow(
            'T.C. Kimlik / Vergi No:',
            driver.identityNumber,
            font,
            fontBold,
          ),
          _buildFieldRow(
            'Sigorta Şirketinin Unvanı:',
            driver.insuranceCompany,
            font,
            fontBold,
          ),
          _buildFieldRow(
            'Acente No:',
            driver.insuranceAgentNumber,
            font,
            fontBold,
          ),
          _buildFieldRow(
            'Poliçe No.:',
            driver.insurancePolicyNumber,
            font,
            fontBold,
          ),
          _buildFieldRow(
            'TRAMER Belge No:',
            driver.tramerNumber,
            font,
            fontBold,
          ),
          _buildFieldRow(
            'Poliçenin Başlangıç-Bitiş Tarihi:',
            driver.policyPeriod,
            font,
            fontBold,
          ),

          // 8- Yeşil Kart Section
          if (isEurope &&
              driver.greenCardNumber != null &&
              driver.greenCardNumber!.isNotEmpty) ...[
            pw.SizedBox(height: 3),
            pw.Text(
              '8- Yeşil Kart (Green Card) Bilgileri',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 6,
                color: PdfColors.black,
              ),
            ),
            _buildFieldRow(
              'Yeşil Kart No / Ülke:',
              '${driver.greenCardNumber} / —',
              font,
              fontBold,
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildFieldRow(
    String label,
    String value,
    pw.Font font,
    pw.Font valueFont, {
    bool isAddress = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 1.5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              font: font,
              fontSize: 5.5,
              color: PdfColors.grey800,
            ),
          ),
          pw.SizedBox(width: 2.5),
          pw.Expanded(
            child: pw.Text(
              value.isNotEmpty ? value : '—',
              style: pw.TextStyle(font: valueFont, fontSize: 6),
              maxLines: isAddress ? 2 : 1,
              overflow: pw.TextOverflow.clip,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCenterChecklist(
    AccidentReport report,
    List<String> labels,
    pw.Font font,
    pw.Font fontBold,
    bool isEurope,
  ) {
    final selectedA = isEurope
        ? report.circumstancesA.euSelectedBoxes
        : report.circumstancesA.trSelectedBoxes;
    final selectedB = isEurope
        ? report.circumstancesB.euSelectedBoxes
        : report.circumstancesB.trSelectedBoxes;

    return pw.Container(
      height: 320,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 0.8),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(1)),
      ),
      padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 1),
      child: pw.Column(
        children: [
          pw.Text(
            isEurope
                ? '12. CIRCUMSTANCES'
                : '7- Uygun Kutulara (x) İşareti Koyunuz',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 6,
              color: PdfColors.black,
            ),
          ),
          pw.Divider(thickness: 0.4, color: PdfColors.grey500),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 3),
                child: pw.Text(
                  'A',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 6,
                    color: PdfColors.black,
                  ),
                ),
              ),
              pw.Text(
                isEurope ? 'ITEMS' : 'MADDELER / CODES',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 5,
                  color: PdfColors.grey700,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(right: 3),
                child: pw.Text(
                  'B',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 6,
                    color: PdfColors.black,
                  ),
                ),
              ),
            ],
          ),
          pw.Divider(thickness: 0.3, color: PdfColors.grey300),

          ...List.generate(labels.length, (idx) {
            final hasA = selectedA.contains(idx);
            final hasB = selectedB.contains(idx);
            final text = labels[idx];

            return pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 1),
              child: pw.Row(
                children: [
                  // A Checkbox
                  pw.SizedBox(width: 2),
                  pw.Container(
                    width: 7.5,
                    height: 7.5,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.black, width: 0.5),
                      color: hasA ? PdfColors.grey200 : PdfColors.white,
                    ),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      hasA ? 'X' : '',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 5.5,
                        color: PdfColors.black,
                      ),
                    ),
                  ),

                  // Label text in the middle
                  pw.Expanded(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 2),
                      child: pw.Text(
                        text,
                        style: pw.TextStyle(font: font, fontSize: 4.8),
                        textAlign: pw.TextAlign.center,
                        maxLines: 2,
                        overflow: pw.TextOverflow.clip,
                      ),
                    ),
                  ),

                  // B Checkbox
                  pw.Container(
                    width: 7.5,
                    height: 7.5,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.black, width: 0.5),
                      color: hasB ? PdfColors.grey200 : PdfColors.white,
                    ),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      hasB ? 'X' : '',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 5.5,
                        color: PdfColors.black,
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 2),
                ],
              ),
            );
          }),

          pw.Spacer(),
          pw.Divider(thickness: 0.3, color: PdfColors.grey400),
          // Hız Durumu
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 1),
            child: pw.Row(
              children: [
                pw.SizedBox(width: 2),
                pw.Text(
                  report.speedA.isNotEmpty ? '${report.speedA} km/h' : '— km/h',
                  style: pw.TextStyle(font: font, fontSize: 5.5),
                ),
                pw.Spacer(),
                pw.Text(
                  isEurope ? 'Speed' : 'Hız Durumu',
                  style: pw.TextStyle(font: font, fontSize: 5.5),
                ),
                pw.Spacer(),
                pw.Text(
                  report.speedB.isNotEmpty ? '${report.speedB} km/h' : '— km/h',
                  style: pw.TextStyle(font: font, fontSize: 5.5),
                ),
                pw.SizedBox(width: 2),
              ],
            ),
          ),
          // Fren İzi
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 1),
            child: pw.Row(
              children: [
                pw.SizedBox(width: 2),
                pw.Text(
                  report.brakeTrackA.isNotEmpty
                      ? '${report.brakeTrackA} m'
                      : '— m',
                  style: pw.TextStyle(font: font, fontSize: 5.5),
                ),
                pw.Spacer(),
                pw.Text(
                  isEurope ? 'Brake Track' : 'Fren İzi Uzunluğu',
                  style: pw.TextStyle(font: font, fontSize: 5.5),
                ),
                pw.Spacer(),
                pw.Text(
                  report.brakeTrackB.isNotEmpty
                      ? '${report.brakeTrackB} m'
                      : '— m',
                  style: pw.TextStyle(font: font, fontSize: 5.5),
                ),
                pw.SizedBox(width: 2),
              ],
            ),
          ),
          pw.Divider(thickness: 0.3, color: PdfColors.grey400),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 3),
                child: pw.Text(
                  '${selectedA.length}',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 6.5,
                    color: PdfColors.black,
                  ),
                ),
              ),
              pw.Text(
                isEurope ? 'Crosses Count' : 'Toplam İşaret Sayısı',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 5,
                  color: PdfColors.grey600,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(right: 3),
                child: pw.Text(
                  '${selectedB.length}',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 6.5,
                    color: PdfColors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildImpactRow(
    String label,
    String value,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              font: font,
              fontSize: 6,
              color: PdfColors.grey700,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 6.5,
              color: PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildRemarksBox(
    String title,
    String remarks,
    pw.Font font,
  ) {
    return pw.Container(
      height: 44,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 0.8),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(1)),
      ),
      padding: const pw.EdgeInsets.all(3.5),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              font: font,
              fontSize: 6.2,
              color: PdfColors.grey600,
            ),
          ),
          pw.SizedBox(height: 1.5),
          pw.Expanded(
            child: pw.Text(
              remarks.isNotEmpty
                  ? remarks
                  : 'Görüş yazılmamıştır / No remarks.',
              style: pw.TextStyle(font: font, fontSize: 7),
              maxLines: 4,
              overflow: pw.TextOverflow.clip,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSignatureBox(
    String title,
    List<int> signatureBytes,
    pw.Font font,
  ) {
    return pw.Container(
      height: 44,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 0.8),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(1)),
      ),
      padding: const pw.EdgeInsets.all(3.5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              font: font,
              fontSize: 6.2,
              color: PdfColors.grey600,
            ),
          ),
          if (signatureBytes.isNotEmpty)
            pw.Container(
              width: 90,
              height: 38,
              child: pw.Image(
                pw.MemoryImage(Uint8List.fromList(signatureBytes)),
                fit: pw.BoxFit.contain,
              ),
            )
          else
            pw.Text(
              'İmza Eksik / Unsigned',
              style: pw.TextStyle(
                font: font,
                fontSize: 6.5,
                color: PdfColors.red800,
              ),
            ),
        ],
      ),
    );
  }

  /// Programmatically draw SBM Vehicle Silhouettes (Motorcycle, Sedan, Truck)
  static pw.Widget _buildSilhouettesDrawing(List<int> impactBytes) {
    final silhouettes = pw.CustomPaint(
      size: const PdfPoint(82, 60),
      painter: (PdfGraphics g, PdfPoint size) {
        g.setColor(PdfColors.black);
        g.setLineWidth(0.6);

        // 1. Scooter Silhouette (Left: x=2 to x=18)
        _drawScooter(g, 10, 5);

        // 2. Sedan Silhouette (Center: x=24 to x=54)
        _drawSedan(g, 39, 5);

        // 3. Truck Silhouette (Right: x=60 to x=80)
        _drawTruck(g, 70, 5);
      },
    );

    if (impactBytes.isNotEmpty) {
      return pw.Container(
        width: 82,
        height: 60,
        alignment: pw.Alignment.center,
        child: pw.Image(
          pw.MemoryImage(Uint8List.fromList(impactBytes)),
          fit: pw.BoxFit.contain,
        ),
      );
    }

    return pw.Container(
      width: 82,
      height: 60,
      alignment: pw.Alignment.center,
      child: silhouettes,
    );
  }

  static void _drawScooter(PdfGraphics g, double cx, double bottomY) {
    // Front wheel
    g.drawEllipse(cx, bottomY + 35, 2.5, 2.5);
    // Rear wheel
    g.drawEllipse(cx, bottomY + 8, 2.5, 2.5);
    g.strokePath();

    // Frame connecting wheels
    g.moveTo(cx, bottomY + 8);
    g.lineTo(cx, bottomY + 30);
    // Handlebars
    g.moveTo(cx - 5, bottomY + 30);
    g.lineTo(cx + 5, bottomY + 30);
    // Mirrors
    g.moveTo(cx - 4, bottomY + 30);
    g.lineTo(cx - 5, bottomY + 34);
    g.moveTo(cx + 4, bottomY + 30);
    g.lineTo(cx + 5, bottomY + 34);

    // Seat
    g.drawRect(cx - 2, bottomY + 14, 4, 10);
    g.strokePath();

    // Labels
    // "ön" (front) at top
    // "arka" (rear) at bottom
  }

  static void _drawSedan(PdfGraphics g, double cx, double bottomY) {
    // Overhead sedan layout: w=18, h=40
    final x = cx - 9;
    final y = bottomY + 5;

    // Main Body
    g.drawRect(x, y, 18, 40);

    // Tires (4 corners)
    g.drawRect(x - 2, y + 4, 2, 6);
    g.drawRect(x + 18, y + 4, 2, 6);
    g.drawRect(x - 2, y + 30, 2, 6);
    g.drawRect(x + 18, y + 30, 2, 6);

    // Windshields
    g.moveTo(x + 2, y + 12);
    g.lineTo(x + 16, y + 12); // Front
    g.moveTo(x + 2, y + 32);
    g.lineTo(x + 16, y + 32); // Rear

    // Side Mirrors
    g.moveTo(x, y + 10);
    g.lineTo(x - 2, y + 8);
    g.moveTo(x + 18, y + 10);
    g.lineTo(x + 20, y + 8);

    g.strokePath();
  }

  static void _drawTruck(PdfGraphics g, double cx, double bottomY) {
    // Overhead truck layout: w=16, h=44
    final x = cx - 8;
    final y = bottomY + 3;

    // Cargo bed (rear)
    g.drawRect(x, y + 14, 16, 30);
    // Cabin (front)
    g.drawRect(x + 1, y, 14, 14);

    // Tires
    g.drawRect(x - 2, y + 6, 2, 6);
    g.drawRect(x + 16, y + 6, 2, 6);

    g.drawRect(x - 2, y + 22, 2, 6);
    g.drawRect(x + 16, y + 22, 2, 6);
    g.drawRect(x - 2, y + 36, 2, 6);
    g.drawRect(x + 16, y + 36, 2, 6);

    g.strokePath();
  }
}
