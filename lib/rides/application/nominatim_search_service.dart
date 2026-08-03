import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:apexflow/rides/domain/meeting_point.dart';

class NominatimSearchService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org/search';

  /// Searches for a place by [query] and returns a list of [MeetingPoint]s.
  Future<List<MeetingPoint>> search(String query) async {
    if (query.trim().isEmpty) return const [];

    try {
      final uri = Uri.parse(
        '$_baseUrl?q=${Uri.encodeComponent(query)}&format=json&limit=5',
      );
      final response = await http
          .get(
            uri,
            headers: {
              'User-Agent':
                  'ApexFlow-Motorcycle-App/1.0.0 (contact: support@apexflow.example.org)',
              'Accept-Language': 'tr,en;q=0.9',
            },
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        return const [];
      }

      final List<dynamic> data = json.decode(response.body);
      final List<MeetingPoint> results = [];

      for (final item in data) {
        if (item is Map<String, dynamic>) {
          final String displayName = item['display_name'] as String? ?? '';
          // Clean display name to make it look nicer on mobile UI (shorten it)
          final String name = _shortenAddress(displayName);

          final double lat =
              double.tryParse(item['lat']?.toString() ?? '') ?? 0.0;
          final double lon =
              double.tryParse(item['lon']?.toString() ?? '') ?? 0.0;

          if (lat != 0.0 && lon != 0.0) {
            results.add(
              MeetingPoint(name: name, latitude: lat, longitude: lon),
            );
          }
        }
      }

      return results;
    } catch (_) {
      return const [];
    }
  }

  String _shortenAddress(String fullAddress) {
    final parts = fullAddress.split(',');
    if (parts.length > 2) {
      // Return the first two parts of the address (e.g., "Kadıköy Sahil, İstanbul")
      return '${parts[0].trim()}, ${parts[1].trim()}';
    }
    return fullAddress;
  }
}
