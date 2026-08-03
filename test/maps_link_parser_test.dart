import 'package:flutter_test/flutter_test.dart';
import 'package:apexflow/rides/application/maps_link_parser.dart';

void main() {
  group('MapsLinkParser Tests', () {
    test('parseInput extracts raw coordinates successfully', () async {
      final point1 = await MapsLinkParser.parseInput('36.86259,30.64090');
      expect(point1, isNotNull);
      expect(point1!.latitude, 36.86259);
      expect(point1.longitude, 30.64090);
      expect(point1.name, 'Buluşma Noktası');

      final point2 = await MapsLinkParser.parseInput(
        '  -12.04333 , -77.02833  ',
        defaultName: 'Lima',
      );
      expect(point2, isNotNull);
      expect(point2!.latitude, -12.04333);
      expect(point2.longitude, -77.02833);
      expect(point2.name, 'Lima');
    });

    test('parseInput extracts coordinates from full Google Maps URL', () async {
      const url =
          'https://www.google.com/maps/place/Antalya/@36.8625967,30.6409092,15z/data=!4m2!3m1!1s0x14c39aa9a19c5c7f:0xef67d93b3f46f481';
      final point = await MapsLinkParser.parseInput(url);
      expect(point, isNotNull);
      expect(point!.latitude, 36.8625967);
      expect(point.longitude, 30.6409092);
      expect(point.name, 'Antalya');
    });

    test('parseInput extracts query parameters from Google Maps URL', () async {
      const url =
          'https://www.google.com/maps?q=My+Target+Lobby&ll=36.86259,30.64090';
      final point = await MapsLinkParser.parseInput(url);
      expect(point, isNotNull);
      expect(point!.latitude, 36.86259);
      expect(point.longitude, 30.64090);
      expect(point.name, 'My Target Lobby');
    });

    test(
      'parseInput extracts coordinates from shortened maps.app.goo.gl URL',
      () async {
        const url = 'https://maps.app.goo.gl/xPS2oZrJb7LXWpHr5';
        final point = await MapsLinkParser.parseInput(url);
        expect(point, isNotNull);
        // Beach Park coords should be extracted from the redirect destination
        expect(point!.latitude, closeTo(36.876207, 0.0001));
        expect(point.longitude, closeTo(30.660529, 0.0001));
        expect(point.name, 'Beach Park');
      },
    );

    test('parseInput returns null on invalid input', () async {
      final point = await MapsLinkParser.parseInput(
        'This is just some random text with no coordinates',
      );
      expect(point, isNull);
    });
  });
}
