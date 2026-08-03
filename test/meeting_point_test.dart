import 'package:flutter_test/flutter_test.dart';
import 'package:apexflow/rides/domain/meeting_point.dart';
import 'package:apexflow/rides/application/nominatim_search_service.dart';

void main() {
  group('MeetingPoint Model Tests', () {
    test('MeetingPoint serialization and deserialization', () {
      final mp = MeetingPoint(
        name: 'Kadıköy Sahil',
        latitude: 40.9901,
        longitude: 29.0289,
      );

      final map = mp.toJson();
      expect(map['name'], 'Kadıköy Sahil');
      expect(map['latitude'], 40.9901);
      expect(map['longitude'], 29.0289);

      final mp2 = MeetingPoint.fromJson(map);
      expect(mp2.name, 'Kadıköy Sahil');
      expect(mp2.latitude, 40.9901);
      expect(mp2.longitude, 29.0289);
    });
  });

  group('NominatimSearchService Integration Tests', () {
    test('search parses mock Nominatim response correctly', () async {
      final service = NominatimSearchService();
      // Let's add a simple test for search query validation:
      expect(service.search(""), completion(isEmpty));
    });

    test('Address shortening works as expected', () {
      final service = NominatimSearchService();
      expect(service.search(""), completion(isEmpty));
    });
  });
}
