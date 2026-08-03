import 'dart:convert';
import 'package:apexflow/rituals/application/rituals_state.dart';
import 'package:http/http.dart' as http;
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/core/storage/apex_kv_store.dart';
import 'package:flutter/foundation.dart';

String _normalizeTurkish(String input) {
  return input
      .replaceAll('İ', 'i')
      .replaceAll('I', 'i')
      .replaceAll('ı', 'i')
      .replaceAll('ş', 's')
      .replaceAll('Ş', 's')
      .replaceAll('ğ', 'g')
      .replaceAll('Ğ', 'g')
      .replaceAll('ü', 'u')
      .replaceAll('Ü', 'u')
      .replaceAll('ö', 'o')
      .replaceAll('Ö', 'o')
      .replaceAll('ç', 'c')
      .replaceAll('Ç', 'c')
      .toLowerCase()
      .trim();
}

class WeatherLookupException implements Exception {
  const WeatherLookupException(this.message);

  final String message;

  @override
  String toString() => message;
}

class PredefinedCity {
  final String nameTr;
  final String nameEn;
  final String categoryTr;
  final String categoryEn;
  final double latitude;
  final double longitude;
  final String countryCode;

  const PredefinedCity({
    required this.nameTr,
    required this.nameEn,
    required this.categoryTr,
    required this.categoryEn,
    required this.latitude,
    required this.longitude,
    required this.countryCode,
  });

  String displayName(bool tr) => tr ? nameTr : nameEn;
  String displayCategory(bool tr) => tr ? categoryTr : categoryEn;
  String get label => '$nameEn, $countryCode';
}

const predefinedCities = [
  // Türkiye
  PredefinedCity(
    nameTr: 'İstanbul',
    nameEn: 'Istanbul',
    categoryTr: 'Türkiye',
    categoryEn: 'Turkey',
    latitude: 41.0082,
    longitude: 28.9784,
    countryCode: 'TR',
  ),
  PredefinedCity(
    nameTr: 'Ankara',
    nameEn: 'Ankara',
    categoryTr: 'Türkiye',
    categoryEn: 'Turkey',
    latitude: 39.9334,
    longitude: 32.8597,
    countryCode: 'TR',
  ),
  PredefinedCity(
    nameTr: 'İzmir',
    nameEn: 'Izmir',
    categoryTr: 'Türkiye',
    categoryEn: 'Turkey',
    latitude: 38.4192,
    longitude: 27.1287,
    countryCode: 'TR',
  ),
  PredefinedCity(
    nameTr: 'Antalya',
    nameEn: 'Antalya',
    categoryTr: 'Türkiye',
    categoryEn: 'Turkey',
    latitude: 36.8841,
    longitude: 30.7056,
    countryCode: 'TR',
  ),
  PredefinedCity(
    nameTr: 'Bursa',
    nameEn: 'Bursa',
    categoryTr: 'Türkiye',
    categoryEn: 'Turkey',
    latitude: 40.1885,
    longitude: 29.0610,
    countryCode: 'TR',
  ),
  PredefinedCity(
    nameTr: 'Adana',
    nameEn: 'Adana',
    categoryTr: 'Türkiye',
    categoryEn: 'Turkey',
    latitude: 36.9914,
    longitude: 35.3308,
    countryCode: 'TR',
  ),
  PredefinedCity(
    nameTr: 'Trabzon',
    nameEn: 'Trabzon',
    categoryTr: 'Türkiye',
    categoryEn: 'Turkey',
    latitude: 41.0027,
    longitude: 39.7168,
    countryCode: 'TR',
  ),
  PredefinedCity(
    nameTr: 'Eskişehir',
    nameEn: 'Eskisehir',
    categoryTr: 'Türkiye',
    categoryEn: 'Turkey',
    latitude: 39.7767,
    longitude: 30.5206,
    countryCode: 'TR',
  ),
  PredefinedCity(
    nameTr: 'Muğla',
    nameEn: 'Mugla',
    categoryTr: 'Türkiye',
    categoryEn: 'Turkey',
    latitude: 37.2153,
    longitude: 28.3636,
    countryCode: 'TR',
  ),
  PredefinedCity(
    nameTr: 'Gaziantep',
    nameEn: 'Gaziantep',
    categoryTr: 'Türkiye',
    categoryEn: 'Turkey',
    latitude: 37.0662,
    longitude: 37.3833,
    countryCode: 'TR',
  ),
  PredefinedCity(
    nameTr: 'Konya',
    nameEn: 'Konya',
    categoryTr: 'Türkiye',
    categoryEn: 'Turkey',
    latitude: 37.8714,
    longitude: 32.4847,
    countryCode: 'TR',
  ),
  PredefinedCity(
    nameTr: 'Mersin',
    nameEn: 'Mersin',
    categoryTr: 'Türkiye',
    categoryEn: 'Turkey',
    latitude: 36.8121,
    longitude: 34.6415,
    countryCode: 'TR',
  ),
  PredefinedCity(
    nameTr: 'Diyarbakır',
    nameEn: 'Diyarbakir',
    categoryTr: 'Türkiye',
    categoryEn: 'Turkey',
    latitude: 37.9144,
    longitude: 40.2306,
    countryCode: 'TR',
  ),
  PredefinedCity(
    nameTr: 'Kayseri',
    nameEn: 'Kayseri',
    categoryTr: 'Türkiye',
    categoryEn: 'Turkey',
    latitude: 38.7205,
    longitude: 35.4826,
    countryCode: 'TR',
  ),
  PredefinedCity(
    nameTr: 'Samsun',
    nameEn: 'Samsun',
    categoryTr: 'Türkiye',
    categoryEn: 'Turkey',
    latitude: 41.2867,
    longitude: 36.3300,
    countryCode: 'TR',
  ),
  PredefinedCity(
    nameTr: 'Denizli',
    nameEn: 'Denizli',
    categoryTr: 'Türkiye',
    categoryEn: 'Turkey',
    latitude: 37.7760,
    longitude: 29.0864,
    countryCode: 'TR',
  ),
  PredefinedCity(
    nameTr: 'Şanlıurfa',
    nameEn: 'Sanliurfa',
    categoryTr: 'Türkiye',
    categoryEn: 'Turkey',
    latitude: 37.1591,
    longitude: 38.7969,
    countryCode: 'TR',
  ),
  PredefinedCity(
    nameTr: 'Kocaeli',
    nameEn: 'Kocaeli',
    categoryTr: 'Türkiye',
    categoryEn: 'Turkey',
    latitude: 40.8533,
    longitude: 29.8815,
    countryCode: 'TR',
  ),
  PredefinedCity(
    nameTr: 'Sakarya',
    nameEn: 'Sakarya',
    categoryTr: 'Türkiye',
    categoryEn: 'Turkey',
    latitude: 40.7569,
    longitude: 30.3789,
    countryCode: 'TR',
  ),
  PredefinedCity(
    nameTr: 'Malatya',
    nameEn: 'Malatya',
    categoryTr: 'Türkiye',
    categoryEn: 'Turkey',
    latitude: 38.3552,
    longitude: 38.3095,
    countryCode: 'TR',
  ),
  PredefinedCity(
    nameTr: 'Kahramanmaraş',
    nameEn: 'Kahramanmaras',
    categoryTr: 'Türkiye',
    categoryEn: 'Turkey',
    latitude: 37.5858,
    longitude: 36.9371,
    countryCode: 'TR',
  ),
  PredefinedCity(
    nameTr: 'Erzurum',
    nameEn: 'Erzurum',
    categoryTr: 'Türkiye',
    categoryEn: 'Turkey',
    latitude: 39.9056,
    longitude: 41.2658,
    countryCode: 'TR',
  ),
  PredefinedCity(
    nameTr: 'Van',
    nameEn: 'Van',
    categoryTr: 'Türkiye',
    categoryEn: 'Turkey',
    latitude: 38.5012,
    longitude: 43.3730,
    countryCode: 'TR',
  ),
  PredefinedCity(
    nameTr: 'Batman',
    nameEn: 'Batman',
    categoryTr: 'Türkiye',
    categoryEn: 'Turkey',
    latitude: 37.8812,
    longitude: 41.1351,
    countryCode: 'TR',
  ),
  PredefinedCity(
    nameTr: 'Elazığ',
    nameEn: 'Elazig',
    categoryTr: 'Türkiye',
    categoryEn: 'Turkey',
    latitude: 38.6810,
    longitude: 39.2230,
    countryCode: 'TR',
  ),
  PredefinedCity(
    nameTr: 'Sivas',
    nameEn: 'Sivas',
    categoryTr: 'Türkiye',
    categoryEn: 'Turkey',
    latitude: 39.7505,
    longitude: 37.0150,
    countryCode: 'TR',
  ),
  PredefinedCity(
    nameTr: 'Manisa',
    nameEn: 'Manisa',
    categoryTr: 'Türkiye',
    categoryEn: 'Turkey',
    latitude: 38.6191,
    longitude: 27.4287,
    countryCode: 'TR',
  ),
  PredefinedCity(
    nameTr: 'Balıkesir',
    nameEn: 'Balikesir',
    categoryTr: 'Türkiye',
    categoryEn: 'Turkey',
    latitude: 39.6484,
    longitude: 27.8826,
    countryCode: 'TR',
  ),
  PredefinedCity(
    nameTr: 'Çanakkale',
    nameEn: 'Canakkale',
    categoryTr: 'Türkiye',
    categoryEn: 'Turkey',
    latitude: 40.1553,
    longitude: 26.4142,
    countryCode: 'TR',
  ),
  PredefinedCity(
    nameTr: 'Tekirdağ',
    nameEn: 'Tekirdag',
    categoryTr: 'Türkiye',
    categoryEn: 'Turkey',
    latitude: 40.9780,
    longitude: 27.5110,
    countryCode: 'TR',
  ),
  PredefinedCity(
    nameTr: 'Edirne',
    nameEn: 'Edirne',
    categoryTr: 'Türkiye',
    categoryEn: 'Turkey',
    latitude: 41.6772,
    longitude: 26.5560,
    countryCode: 'TR',
  ),
  PredefinedCity(
    nameTr: 'Rize',
    nameEn: 'Rize',
    categoryTr: 'Türkiye',
    categoryEn: 'Turkey',
    latitude: 41.0201,
    longitude: 40.5234,
    countryCode: 'TR',
  ),
  PredefinedCity(
    nameTr: 'Yalova',
    nameEn: 'Yalova',
    categoryTr: 'Türkiye',
    categoryEn: 'Turkey',
    latitude: 40.6549,
    longitude: 29.2738,
    countryCode: 'TR',
  ),
  PredefinedCity(
    nameTr: 'Kars',
    nameEn: 'Kars',
    categoryTr: 'Türkiye',
    categoryEn: 'Turkey',
    latitude: 40.6013,
    longitude: 43.0975,
    countryCode: 'TR',
  ),
  PredefinedCity(
    nameTr: 'Hatay',
    nameEn: 'Hatay',
    categoryTr: 'Türkiye',
    categoryEn: 'Turkey',
    latitude: 36.2021,
    longitude: 36.1606,
    countryCode: 'TR',
  ),

  // Avrupa
  PredefinedCity(
    nameTr: 'Londra',
    nameEn: 'London',
    categoryTr: 'Avrupa',
    categoryEn: 'Europe',
    latitude: 51.5074,
    longitude: -0.1278,
    countryCode: 'GB',
  ),
  PredefinedCity(
    nameTr: 'Paris',
    nameEn: 'Paris',
    categoryTr: 'Avrupa',
    categoryEn: 'Europe',
    latitude: 48.8566,
    longitude: 2.3522,
    countryCode: 'FR',
  ),
  PredefinedCity(
    nameTr: 'Berlin',
    nameEn: 'Berlin',
    categoryTr: 'Avrupa',
    categoryEn: 'Europe',
    latitude: 52.5200,
    longitude: 13.4050,
    countryCode: 'DE',
  ),
  PredefinedCity(
    nameTr: 'Roma',
    nameEn: 'Rome',
    categoryTr: 'Avrupa',
    categoryEn: 'Europe',
    latitude: 41.9028,
    longitude: 12.4964,
    countryCode: 'IT',
  ),
  PredefinedCity(
    nameTr: 'Amsterdam',
    nameEn: 'Amsterdam',
    categoryTr: 'Avrupa',
    categoryEn: 'Europe',
    latitude: 52.3676,
    longitude: 4.9041,
    countryCode: 'NL',
  ),
  PredefinedCity(
    nameTr: 'Viyana',
    nameEn: 'Vienna',
    categoryTr: 'Avrupa',
    categoryEn: 'Europe',
    latitude: 48.2082,
    longitude: 16.3738,
    countryCode: 'AT',
  ),
  PredefinedCity(
    nameTr: 'Madrid',
    nameEn: 'Madrid',
    categoryTr: 'Avrupa',
    categoryEn: 'Europe',
    latitude: 40.4168,
    longitude: -3.7038,
    countryCode: 'ES',
  ),
  PredefinedCity(
    nameTr: 'Brüksel',
    nameEn: 'Brussels',
    categoryTr: 'Avrupa',
    categoryEn: 'Europe',
    latitude: 50.8503,
    longitude: 4.3517,
    countryCode: 'BE',
  ),
  PredefinedCity(
    nameTr: 'Münih',
    nameEn: 'Munich',
    categoryTr: 'Avrupa',
    categoryEn: 'Europe',
    latitude: 48.1351,
    longitude: 11.5820,
    countryCode: 'DE',
  ),
  PredefinedCity(
    nameTr: 'Prag',
    nameEn: 'Prague',
    categoryTr: 'Avrupa',
    categoryEn: 'Europe',
    latitude: 50.0755,
    longitude: 14.4378,
    countryCode: 'CZ',
  ),

  // Amerika
  PredefinedCity(
    nameTr: 'New York',
    nameEn: 'New York',
    categoryTr: 'Amerika',
    categoryEn: 'America',
    latitude: 40.7128,
    longitude: -74.0060,
    countryCode: 'US',
  ),
  PredefinedCity(
    nameTr: 'Los Angeles',
    nameEn: 'Los Angeles',
    categoryTr: 'Amerika',
    categoryEn: 'America',
    latitude: 34.0522,
    longitude: -118.2437,
    countryCode: 'US',
  ),
  PredefinedCity(
    nameTr: 'Miami',
    nameEn: 'Miami',
    categoryTr: 'Amerika',
    categoryEn: 'America',
    latitude: 25.7617,
    longitude: -80.1918,
    countryCode: 'US',
  ),
  PredefinedCity(
    nameTr: 'Chicago',
    nameEn: 'Chicago',
    categoryTr: 'Amerika',
    categoryEn: 'America',
    latitude: 41.8781,
    longitude: -87.6298,
    countryCode: 'US',
  ),
  PredefinedCity(
    nameTr: 'San Francisco',
    nameEn: 'San Francisco',
    categoryTr: 'Amerika',
    categoryEn: 'America',
    latitude: 37.7749,
    longitude: -122.4194,
    countryCode: 'US',
  ),
  PredefinedCity(
    nameTr: 'Toronto',
    nameEn: 'Toronto',
    categoryTr: 'Amerika',
    categoryEn: 'America',
    latitude: 43.6532,
    longitude: -79.3832,
    countryCode: 'CA',
  ),
  PredefinedCity(
    nameTr: 'Meksika',
    nameEn: 'Mexico City',
    categoryTr: 'Amerika',
    categoryEn: 'America',
    latitude: 19.4326,
    longitude: -99.1332,
    countryCode: 'MX',
  ),
  PredefinedCity(
    nameTr: 'São Paulo',
    nameEn: 'Sao Paulo',
    categoryTr: 'Amerika',
    categoryEn: 'America',
    latitude: -23.5505,
    longitude: -46.6333,
    countryCode: 'BR',
  ),
  PredefinedCity(
    nameTr: 'Buenos Aires',
    nameEn: 'Buenos Aires',
    categoryTr: 'Amerika',
    categoryEn: 'America',
    latitude: -34.6037,
    longitude: -58.3816,
    countryCode: 'AR',
  ),
  PredefinedCity(
    nameTr: 'Washington',
    nameEn: 'Washington',
    categoryTr: 'Amerika',
    categoryEn: 'America',
    latitude: 38.9072,
    longitude: -77.0369,
    countryCode: 'US',
  ),

  // Balkanlar
  PredefinedCity(
    nameTr: 'Saraybosna',
    nameEn: 'Sarajevo',
    categoryTr: 'Balkanlar',
    categoryEn: 'Balkans',
    latitude: 43.8563,
    longitude: 18.4131,
    countryCode: 'BA',
  ),
  PredefinedCity(
    nameTr: 'Belgrad',
    nameEn: 'Belgrade',
    categoryTr: 'Balkanlar',
    categoryEn: 'Balkans',
    latitude: 44.7872,
    longitude: 20.4573,
    countryCode: 'RS',
  ),
  PredefinedCity(
    nameTr: 'Üsküp',
    nameEn: 'Skopje',
    categoryTr: 'Balkanlar',
    categoryEn: 'Balkans',
    latitude: 41.9981,
    longitude: 21.4254,
    countryCode: 'MK',
  ),
  PredefinedCity(
    nameTr: 'Sofya',
    nameEn: 'Sofia',
    categoryTr: 'Balkanlar',
    categoryEn: 'Balkans',
    latitude: 42.6977,
    longitude: 23.3219,
    countryCode: 'BG',
  ),
  PredefinedCity(
    nameTr: 'Atina',
    nameEn: 'Athens',
    categoryTr: 'Balkanlar',
    categoryEn: 'Balkans',
    latitude: 37.9838,
    longitude: 23.7275,
    countryCode: 'GR',
  ),
  PredefinedCity(
    nameTr: 'Zagreb',
    nameEn: 'Zagreb',
    categoryTr: 'Balkanlar',
    categoryEn: 'Balkans',
    latitude: 45.8150,
    longitude: 15.9819,
    countryCode: 'HR',
  ),
  PredefinedCity(
    nameTr: 'Tiran',
    nameEn: 'Tirana',
    categoryTr: 'Balkanlar',
    categoryEn: 'Balkans',
    latitude: 41.3275,
    longitude: 19.8187,
    countryCode: 'AL',
  ),
  PredefinedCity(
    nameTr: 'Bükreş',
    nameEn: 'Bucharest',
    categoryTr: 'Balkanlar',
    categoryEn: 'Balkans',
    latitude: 44.4268,
    longitude: 26.1025,
    countryCode: 'RO',
  ),
  PredefinedCity(
    nameTr: 'Priştine',
    nameEn: 'Pristina',
    categoryTr: 'Balkanlar',
    categoryEn: 'Balkans',
    latitude: 42.6629,
    longitude: 21.1655,
    countryCode: 'XK',
  ),
  PredefinedCity(
    nameTr: 'Podgorica',
    nameEn: 'Podgorica',
    categoryTr: 'Balkanlar',
    categoryEn: 'Balkans',
    latitude: 42.4304,
    longitude: 19.2594,
    countryCode: 'ME',
  ),

  // Arap Dünyası
  PredefinedCity(
    nameTr: 'Dubai',
    nameEn: 'Dubai',
    categoryTr: 'Arap Dünyası',
    categoryEn: 'Arab World',
    latitude: 25.2048,
    longitude: 55.2708,
    countryCode: 'AE',
  ),
  PredefinedCity(
    nameTr: 'Riyad',
    nameEn: 'Riyadh',
    categoryTr: 'Arap Dünyası',
    categoryEn: 'Arab World',
    latitude: 24.7136,
    longitude: 46.6753,
    countryCode: 'SA',
  ),
  PredefinedCity(
    nameTr: 'Kahire',
    nameEn: 'Cairo',
    categoryTr: 'Arap Dünyası',
    categoryEn: 'Arab World',
    latitude: 30.0444,
    longitude: 31.2357,
    countryCode: 'EG',
  ),
  PredefinedCity(
    nameTr: 'Doha',
    nameEn: 'Doha',
    categoryTr: 'Arap Dünyası',
    categoryEn: 'Arab World',
    latitude: 25.2854,
    longitude: 51.5310,
    countryCode: 'QA',
  ),
  PredefinedCity(
    nameTr: 'Amman',
    nameEn: 'Amman',
    categoryTr: 'Arap Dünyası',
    categoryEn: 'Arab World',
    latitude: 31.9539,
    longitude: 35.9106,
    countryCode: 'JO',
  ),
  PredefinedCity(
    nameTr: 'Abu Dabi',
    nameEn: 'Abu Dhabi',
    categoryTr: 'Arap Dünyası',
    categoryEn: 'Arab World',
    latitude: 24.4539,
    longitude: 54.3773,
    countryCode: 'AE',
  ),
  PredefinedCity(
    nameTr: 'Kuveyt',
    nameEn: 'Kuwait City',
    categoryTr: 'Arap Dünyası',
    categoryEn: 'Arab World',
    latitude: 29.3759,
    longitude: 47.9774,
    countryCode: 'KW',
  ),
  PredefinedCity(
    nameTr: 'Maskat',
    nameEn: 'Muscat',
    categoryTr: 'Arap Dünyası',
    categoryEn: 'Arab World',
    latitude: 23.5859,
    longitude: 58.4059,
    countryCode: 'OM',
  ),
  PredefinedCity(
    nameTr: 'Manama',
    nameEn: 'Manama',
    categoryTr: 'Arap Dünyası',
    categoryEn: 'Arab World',
    latitude: 26.2285,
    longitude: 50.5860,
    countryCode: 'BH',
  ),
  PredefinedCity(
    nameTr: 'Kazablanka',
    nameEn: 'Casablanca',
    categoryTr: 'Arap Dünyası',
    categoryEn: 'Arab World',
    latitude: 33.5731,
    longitude: -7.5898,
    countryCode: 'MA',
  ),
];

class WeatherService {
  const WeatherService({http.Client? client}) : _client = client;

  final http.Client? _client;

  Future<http.Response> _get(Uri uri) {
    if (_client != null) {
      return _client.get(uri);
    }
    return http.get(uri);
  }

  Future<WeatherSnapshot> fetchByLocation(
    String location, {
    String languageCode = 'en',
  }) async {
    final normalized = _normalizeTurkish(location);
    if (normalized.length < 2) {
      throw const WeatherLookupException('Enter a city or area.');
    }

    // Check if the location matches any predefined city
    final matched = predefinedCities.firstWhere(
      (c) =>
          _normalizeTurkish(c.nameEn) == normalized ||
          _normalizeTurkish(c.nameTr) == normalized,
      orElse: () => const PredefinedCity(
        nameTr: '',
        nameEn: '',
        categoryTr: '',
        categoryEn: '',
        latitude: 0,
        longitude: 0,
        countryCode: '',
      ),
    );

    if (matched.nameEn.isNotEmpty) {
      final name = languageCode == 'tr' ? matched.nameTr : matched.nameEn;
      return fetchByCoordinates(
        matched.latitude,
        matched.longitude,
        '$name, ${matched.countryCode}',
        languageCode: languageCode,
      );
    }

    _WeatherLocation? geo;
    try {
      geo = await _fetchLocation(
        normalized,
        languageCode: languageCode,
        countryCode: 'TR',
      );
    } catch (_) {
      geo = null;
    }

    geo ??= await () async {
      try {
        return await _fetchLocation(normalized, languageCode: languageCode);
      } catch (_) {
        return null;
      }
    }();

    geo ??= await () async {
      try {
        return await _fetchLocation(
          location.trim(),
          languageCode: languageCode,
        );
      } catch (_) {
        return null;
      }
    }();

    if (geo == null) {
      throw const WeatherLookupException('Location was not found.');
    }
    return _fetchForecast(geo, languageCode: languageCode);
  }

  Future<WeatherSnapshot> fetchByCoordinates(
    double latitude,
    double longitude,
    String label, {
    String languageCode = 'en',
  }) async {
    final loc = _WeatherLocation(
      name: label.split(',').first.trim(),
      admin1: null,
      countryCode: label.contains(',') ? label.split(',').last.trim() : null,
      latitude: latitude,
      longitude: longitude,
    );
    return _fetchForecast(loc, languageCode: languageCode);
  }

  Future<_WeatherLocation?> _fetchLocation(
    String location, {
    required String languageCode,
    String? countryCode,
  }) async {
    final query = {
      'name': location,
      'count': '5',
      'language': languageCode,
      'format': 'json',
    };
    if (countryCode != null) {
      query['country_code'] = countryCode;
    }
    try {
      final uri = Uri.https(
        'geocoding-api.open-meteo.com',
        '/v1/search',
        query,
      );
      final response = await _get(uri);
      if (response.statusCode != 200) {
        throw WeatherLookupException(
          'Geocoding failed: ${response.statusCode}',
        );
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>? ?? {};
      final results = data['results'] as List<dynamic>? ?? const [];
      if (results.isEmpty) {
        return null;
      }
      final first = Map<String, dynamic>.from(results.first as Map? ?? {});
      final latVal = first['latitude'];
      final lonVal = first['longitude'];
      if (latVal == null || lonVal == null) {
        return null;
      }
      return _WeatherLocation(
        name: first['name'] as String? ?? location,
        admin1: first['admin1'] as String?,
        countryCode: first['country_code'] as String?,
        latitude: (latVal as num).toDouble(),
        longitude: (lonVal as num).toDouble(),
      );
    } catch (e) {
      if (e is WeatherLookupException) rethrow;
      throw WeatherLookupException('Location geocoding failed: $e');
    }
  }

  Future<WeatherSnapshot> _fetchForecast(
    _WeatherLocation location, {
    required String languageCode,
  }) async {
    final cacheKey =
        'weather_cache_${location.latitude.toStringAsFixed(3)}_${location.longitude.toStringAsFixed(3)}';
    String? cachedString;
    try {
      await ApexKvStore.init();
      cachedString = await ApexKvStore.getString(cacheKey);
      if (cachedString != null && cachedString.isNotEmpty) {
        final cachedData = jsonDecode(cachedString) as Map<String, dynamic>;
        final snapshot = WeatherSnapshot.fromJson(cachedData);
        final observed = snapshot.observedAt;
        if (observed != null) {
          final difference = DateTime.now().toLocal().difference(observed);
          if (difference.inMinutes < 30) {
            return snapshot;
          }
        }
      }
    } catch (e) {
      debugPrint('[WeatherService] Cache read or init error: $e');
    }

    try {
      final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': location.latitude.toStringAsFixed(5),
        'longitude': location.longitude.toStringAsFixed(5),
        'current_weather': 'true',
        'current': 'temperature_2m,weather_code,wind_speed_10m',
        'hourly': 'precipitation_probability',
        'forecast_days': '1',
        'timezone': 'auto',
        'wind_speed_unit': 'kmh',
      });
      final response = await _get(uri);
      if (response.statusCode != 200) {
        throw WeatherLookupException('Weather failed: ${response.statusCode}');
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>? ?? {};
      final currentMap =
          data['current'] as Map<String, dynamic>? ??
          data['current_weather'] as Map<String, dynamic>? ??
          {};
      final hourly = Map<String, dynamic>.from(data['hourly'] as Map? ?? {});
      final precip = hourly['precipitation_probability'] as List<dynamic>?;
      final precipValue = precip == null || precip.isEmpty
          ? 0
          : ((precip.first as num?)?.toDouble() ?? 0).round();
      final weatherCode =
          (currentMap['weather_code'] as num?)?.toInt() ??
          (currentMap['weathercode'] as num?)?.toInt() ??
          0;
      final tempVal = currentMap['temperature_2m'] ?? currentMap['temperature'];
      final windVal = currentMap['wind_speed_10m'] ?? currentMap['windspeed'];

      final snapshot = WeatherSnapshot(
        locationLabel: location.label,
        condition: weatherConditionLabel(
          weatherCode,
          languageCode: languageCode,
        ),
        tempC: tempVal != null ? (tempVal as num).toDouble().round() : 20,
        windKph: windVal != null ? (windVal as num).toDouble().round() : 15,
        precipChancePercent: precipValue.clamp(0, 100).toInt(),
        observedAtIso: DateTime.now().toUtc().toIso8601String(),
      );

      try {
        await ApexKvStore.setString(cacheKey, jsonEncode(snapshot.toJson()));
      } catch (e) {
        debugPrint('[WeatherService] Cache write error: $e');
      }

      return snapshot;
    } catch (e) {
      if (e is WeatherLookupException) rethrow;
      throw WeatherLookupException('Failed to fetch forecast: $e');
    }
  }
}

String weatherConditionLabel(int code, {String languageCode = 'en'}) {
  if (code == 0) {
    return tInline(languageCode, 'Açık', 'Clear', 'Klar');
  }
  if (code == 1 || code == 2 || code == 3) {
    return tInline(
      languageCode,
      'Parçalı bulutlu',
      'Partly cloudy',
      'Teilweise bewölkt',
    );
  }
  if (code == 45 || code == 48) {
    return tInline(languageCode, 'Sis', 'Fog', 'Nebel');
  }
  if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82)) {
    return tInline(languageCode, 'Yağış riski', 'Rain risk', 'Regengefahr');
  }
  if (code >= 71 && code <= 77) {
    return tInline(languageCode, 'Kar', 'Snow', 'Schnee');
  }
  if (code >= 95) {
    return tInline(languageCode, 'Fırtına', 'Thunderstorm', 'Gewitter');
  }
  return tInline(languageCode, 'Hava verisi', 'Weather data', 'Wetterdaten');
}

class _WeatherLocation {
  const _WeatherLocation({
    required this.name,
    required this.admin1,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final String? admin1;
  final String? countryCode;
  final double latitude;
  final double longitude;

  String get label {
    final parts = [
      name,
      if (admin1 != null && admin1!.trim().isNotEmpty && admin1 != name)
        admin1!,
      if (countryCode != null && countryCode!.trim().isNotEmpty) countryCode!,
    ];
    return parts.join(', ');
  }
}
