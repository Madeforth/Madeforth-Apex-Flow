import 'package:apexflow/rituals/application/weather_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:apexflow/core/i18n/app_strings.dart';

void main() {
  test(
    'fetches a Turkish city weather snapshot from geocoding and forecast',
    () async {
      AppStrings.currentLanguageCode = 'tr';
      final service = WeatherService(
        client: MockClient((request) async {
          if (request.url.host == 'geocoding-api.open-meteo.com') {
            return http.Response('''
{
  "results": [
    {
      "name": "Antalya",
      "admin1": "Antalya",
      "country_code": "TR",
      "latitude": 36.90812,
      "longitude": 30.69556
    }
  ]
}
''', 200);
          }
          return http.Response('''
{
  "current": {
    "temperature_2m": 27.4,
    "weather_code": 1,
    "wind_speed_10m": 14.2
  },
  "hourly": {
    "precipitation_probability": [12]
  }
}
''', 200);
        }),
      );

      final snapshot = await service.fetchByLocation(
        'Antalya',
        languageCode: 'tr',
      );

      expect(snapshot.locationLabel, 'Antalya, TR');
      expect(snapshot.condition, 'Parçalı bulutlu');
      expect(snapshot.tempC, 27);
      expect(snapshot.windKph, 14);
      expect(snapshot.precipChancePercent, 12);
      expect(snapshot.observedAtIso, isNotEmpty);
    },
  );

  test('weather code labels stay rider-readable', () {
    AppStrings.currentLanguageCode = 'en';
    expect(weatherConditionLabel(0), 'Clear');
    AppStrings.currentLanguageCode = 'tr';
    expect(weatherConditionLabel(61, languageCode: 'tr'), 'Yağış riski');
    AppStrings.currentLanguageCode = 'en';
    expect(weatherConditionLabel(95), 'Thunderstorm');
  });
}
