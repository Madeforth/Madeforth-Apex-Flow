import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:apexflow/rides/domain/meeting_point.dart';
import 'package:apexflow/rides/application/nominatim_search_service.dart';

class MapsLinkParser {
  static final RegExp _coordsRegex = RegExp(r'(-?\d+\.\d+)\s*,\s*(-?\d+\.\d+)');
  static final RegExp _placeMarkerRegex = RegExp(
    r'!3d(-?\d+\.\d+)!4d(-?\d+\.\d+)',
  );
  static final RegExp _llParamRegex = RegExp(
    r'(?:[?&](?:ll|q|query)=)(-?\d+\.\d+),(-?\d+\.\d+)',
  );

  /// Parses coordinates from a string input, which can be a raw coordinates pair
  /// or a Google Maps URL (supporting mobile short links and web search URLs).
  static Future<MeetingPoint?> parseInput(
    String input, {
    String defaultName = 'Buluşma Noktası',
  }) async {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    // Detect if input is a URL
    final isUrl =
        trimmed.startsWith('http://') ||
        trimmed.startsWith('https://') ||
        trimmed.contains('maps.app.goo.gl') ||
        trimmed.contains('goo.gl/maps') ||
        trimmed.contains('google.com/maps');

    // 1. If NOT a URL, try directly parsing raw coordinates
    if (!isUrl) {
      final directMatch = _coordsRegex.firstMatch(trimmed);
      if (directMatch != null) {
        final lat = double.tryParse(directMatch.group(1)!);
        final lng = double.tryParse(directMatch.group(2)!);
        if (lat != null && lng != null) {
          return MeetingPoint(name: defaultName, latitude: lat, longitude: lng);
        }
      }
      return null;
    }

    // 2. If it is a shortened Google Maps URL, resolve the redirect first
    String targetUrl = trimmed;
    if (trimmed.contains('maps.app.goo.gl') ||
        trimmed.contains('goo.gl/maps')) {
      try {
        final client = HttpClient();
        if (!kReleaseMode) {
          client.badCertificateCallback = (cert, host, port) => true;
        }
        client.connectionTimeout = const Duration(seconds: 6);

        String currentUrl = trimmed;
        int hops = 0;

        debugPrint("MapsLinkParser: Starting redirect tracing for $currentUrl");
        while (hops < 5) {
          final request = await client.getUrl(Uri.parse(currentUrl));
          request.followRedirects = false;
          final response = await request.close();

          final redirectUrl = response.headers.value('location');
          debugPrint(
            "MapsLinkParser: Hop $hops returned status ${response.statusCode}, redirect location: $redirectUrl",
          );
          if (redirectUrl != null && redirectUrl.isNotEmpty) {
            if (redirectUrl.startsWith('/')) {
              final originalUri = Uri.parse(currentUrl);
              currentUrl = Uri(
                scheme: originalUri.scheme,
                host: originalUri.host,
                path: redirectUrl,
              ).toString();
            } else {
              currentUrl = redirectUrl;
            }
            targetUrl = currentUrl;
            hops++;

            final decoded = Uri.decodeFull(currentUrl);
            if (_coordsRegex.hasMatch(decoded)) {
              debugPrint("MapsLinkParser: Coords found in url: $decoded");
              break;
            }
          } else {
            break;
          }
        }
      } catch (e) {
        debugPrint(
          "MapsLinkParser: Redirect tracing failed with exception: $e",
        );
      }
    }

    // 3. Extract name from URL structure
    String name = defaultName;
    try {
      final uri = Uri.parse(targetUrl);
      if (uri.queryParameters.containsKey('q')) {
        name = uri.queryParameters['q']!.replaceAll('+', ' ');
      } else if (uri.queryParameters.containsKey('query')) {
        name = uri.queryParameters['query']!.replaceAll('+', ' ');
      } else {
        final segments = uri.pathSegments;
        final placeIndex = segments.indexOf('place');
        if (placeIndex != -1 && placeIndex + 1 < segments.length) {
          name = segments[placeIndex + 1].replaceAll('+', ' ');
        }
      }
      try {
        name = Uri.decodeFull(name);
      } catch (_) {}
      debugPrint("MapsLinkParser: Extracted place name: $name");
    } catch (e) {
      debugPrint("MapsLinkParser: Name extraction failed: $e");
      try {
        final placeIndex = targetUrl.indexOf('/place/');
        if (placeIndex != -1) {
          final start = placeIndex + 7;
          var end = targetUrl.indexOf('/', start);
          if (end == -1) end = targetUrl.indexOf('?', start);
          if (end == -1) end = targetUrl.length;
          final segment = targetUrl.substring(start, end);
          name = _safeDecode(segment).replaceAll('+', ' ');
        }
      } catch (_) {}
    }

    // 4. Try parsing coordinates from the full resolved URL, prioritizing exact marker
    final decodedUrl = _safeDecode(targetUrl);

    // Check ll/q parameters first
    final llMatch = _llParamRegex.firstMatch(decodedUrl);
    if (llMatch != null) {
      final lat = double.tryParse(llMatch.group(1)!);
      final lng = double.tryParse(llMatch.group(2)!);
      if (lat != null && lng != null) {
        debugPrint("MapsLinkParser: Found coords via llParam: $lat, $lng");
        return MeetingPoint(name: name, latitude: lat, longitude: lng);
      }
    }

    // Check exact place marker coordinates second (!3d...!4d...)
    final placeMatch = _placeMarkerRegex.firstMatch(decodedUrl);
    if (placeMatch != null) {
      final lat = double.tryParse(placeMatch.group(1)!);
      final lng = double.tryParse(placeMatch.group(2)!);
      if (lat != null && lng != null) {
        debugPrint("MapsLinkParser: Found coords via placeMarker: $lat, $lng");
        return MeetingPoint(name: name, latitude: lat, longitude: lng);
      }
    }

    // Fallback to general coordinates pattern (e.g. @lat,lng)
    final urlCoordsMatch = _coordsRegex.firstMatch(decodedUrl);
    if (urlCoordsMatch != null) {
      final lat = double.tryParse(urlCoordsMatch.group(1)!);
      final lng = double.tryParse(urlCoordsMatch.group(2)!);
      if (lat != null && lng != null) {
        debugPrint(
          "MapsLinkParser: Found coords via generalCoords: $lat, $lng",
        );
        return MeetingPoint(name: name, latitude: lat, longitude: lng);
      }
    }

    // Geocoding fallback using Nominatim
    if (name.isNotEmpty && name != defaultName) {
      try {
        debugPrint(
          "MapsLinkParser: Falling back to Nominatim geocoding for: $name",
        );
        final service = NominatimSearchService();
        var geocoded = await service.search(name);

        if (geocoded.isEmpty) {
          debugPrint(
            "MapsLinkParser: Nominatim full search empty. Trying segments...",
          );
          final parts = name.split(',');
          if (parts.isNotEmpty) {
            final firstPart = parts[0].trim();
            if (firstPart.isNotEmpty) {
              String fallbackQuery = firstPart;
              if (parts.length > 1) {
                final lastPart = parts.last.trim();
                final cleanLast = lastPart
                    .replaceAll(RegExp(r'\d+'), '')
                    .replaceAll('/', ' ')
                    .trim();
                if (cleanLast.isNotEmpty) {
                  fallbackQuery = '$firstPart, $cleanLast';
                }
              }
              debugPrint(
                "MapsLinkParser: Segment search query: $fallbackQuery",
              );
              geocoded = await service.search(fallbackQuery);
            }
          }
        }

        if (geocoded.isNotEmpty) {
          debugPrint(
            "MapsLinkParser: Nominatim found coords: ${geocoded.first.latitude}, ${geocoded.first.longitude}",
          );
          return MeetingPoint(
            name: name,
            latitude: geocoded.first.latitude,
            longitude: geocoded.first.longitude,
          );
        } else {
          debugPrint("MapsLinkParser: Nominatim geocoding found no results.");
        }
      } catch (e) {
        debugPrint("MapsLinkParser: Nominatim geocoding threw exception: $e");
      }
    }

    return null;
  }

  static String _safeDecode(String url) {
    try {
      return Uri.decodeFull(url);
    } catch (_) {
      try {
        return Uri.decodeComponent(url);
      } catch (_) {
        return url
            .replaceAll('%2B', '+')
            .replaceAll('%2F', '/')
            .replaceAll('%20', ' ')
            .replaceAll('%3D', '=');
      }
    }
  }
}
