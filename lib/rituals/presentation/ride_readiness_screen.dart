import 'package:apexflow/core/design/apex_spacing.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/core/i18n/app_settings_state.dart';
import 'package:apexflow/core/storage/apex_kv_store.dart';
import 'package:apexflow/features/dashboard/dashboard_state.dart';
import 'package:apexflow/rituals/application/ride_readiness_model.dart';
import 'package:apexflow/rituals/application/rituals_state.dart';
import 'package:apexflow/rituals/application/weather_service.dart';
import 'package:apexflow/rituals/presentation/daily_machine_check_screen.dart';
import 'package:apexflow/shared/widgets/apex_panel.dart';
import 'package:apexflow/shared/widgets/apex_state_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apexflow/core/design/theme_extensions.dart';
import 'dart:convert';

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

class RideReadinessScreen extends ConsumerWidget {
  const RideReadinessScreen({super.key, required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = strings.locale.languageCode == 'tr';
    final dashboard = ref.watch(dashboardStateProvider);
    final rituals = ref.watch(ritualsStateProvider);
    final today = DateTime.now().toIso8601String().split('T').first;
    final todayCheck = rituals.dailyChecks.cast<DailyCheckEntry?>().firstWhere(
      (entry) => entry?.isoDate == today,
      orElse: () => null,
    );
    final readinessSnapshot = evaluateRideReadiness(
      harmonyScore: dashboard.harmony.score,
      weather: rituals.weather,
      todayCheck: todayCheck,
    );
    final readiness = readinessSnapshot.score;
    final weatherFreshness = weatherFreshnessFor(rituals.weather);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tInline(
            AppStrings.currentLanguageCode,
            'Sürüşe Hazırlık',
            'Ride readiness',
            'Fahrbereitschaft',
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(ApexSpacing.x2),
          children: [
            if (rituals.isHydrating) ...[
              ApexStatePanel(
                icon: Icons.fact_check_outlined,
                title: tInline(
                  AppStrings.currentLanguageCode,
                  'Ritüel hafızası okunuyor',
                  'Reading ritual memory',
                  'Ritualgedächtnis lesen',
                ),
                message: tInline(
                  AppStrings.currentLanguageCode,
                  'Günlük kontrol ve hava snapshot kayıtları hazırlanıyor.',
                  'Daily check and weather snapshot records are being prepared.',
                  'Tägliche Kontrollen und Aufzeichnungen von Wetterschnappschüssen werden vorbereitet.',
                ),
                loading: true,
              ),
              const SizedBox(height: ApexSpacing.x2),
            ],
            ApexPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tInline(
                      AppStrings.currentLanguageCode,
                      'Bugun',
                      'Today',
                      'Heute',
                    ),
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$readiness%',
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w900,
                          height: 0.9,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          tr ? _labelTr(readiness) : _labelEn(readiness),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    tr ? _guidanceTr(readiness) : _guidanceEn(readiness),
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: ApexSpacing.x2),
            ApexPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tInline(
                      AppStrings.currentLanguageCode,
                      'Hazirlik sinyalleri',
                      'Readiness factors',
                      'Bereitschaftsfaktoren',
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final factor in readinessSnapshot.factors) ...[
                    _ReadinessFactorRow(factor: factor, tr: tr),
                    if (factor != readinessSnapshot.factors.last)
                      const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
            const SizedBox(height: ApexSpacing.x2),
            ApexPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tInline(
                      AppStrings.currentLanguageCode,
                      'Hizli kontrol',
                      'Quick check',
                      'Schneller Check',
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _ChecklistRow(
                    title: tInline(
                      AppStrings.currentLanguageCode,
                      'Lastikler',
                      'Tires',
                      'Reifen',
                    ),
                    subtitle: tInline(
                      AppStrings.currentLanguageCode,
                      'Basinc ve yuzey',
                      'Pressure and surface',
                      'Druck und Oberfläche',
                    ),
                    ok: dashboard.bike.tireWearPercent < 70,
                  ),
                  const SizedBox(height: 8),
                  _ChecklistRow(
                    title: tInline(
                      AppStrings.currentLanguageCode,
                      'Zincir',
                      'Chain',
                      'Kette',
                    ),
                    subtitle: tInline(
                      AppStrings.currentLanguageCode,
                      'Bosluk ve yaglama',
                      'Slack and lubrication',
                      'Spiel und Schmierung',
                    ),
                    ok: dashboard.bike.chainWearPercent < 70,
                  ),
                  const SizedBox(height: 8),
                  _ChecklistRow(
                    title: tInline(
                      AppStrings.currentLanguageCode,
                      'Yag',
                      'Oil',
                      'Öl',
                    ),
                    subtitle: tInline(
                      AppStrings.currentLanguageCode,
                      'Saglik ve sizinti',
                      'Health and leaks',
                      'Gesundheit und Lecks',
                    ),
                    ok: dashboard.bike.oilHealthPercent > 40,
                  ),
                  const SizedBox(height: 8),
                  _ChecklistRow(
                    title: tInline(
                      AppStrings.currentLanguageCode,
                      'Aku',
                      'Battery',
                      'Batterie',
                    ),
                    subtitle: tInline(
                      AppStrings.currentLanguageCode,
                      'Mars ve voltaj',
                      'Crank and voltage',
                      'Kurbel und Spannung',
                    ),
                    ok: dashboard.bike.batteryHealthPercent > 40,
                  ),
                ],
              ),
            ),
            const SizedBox(height: ApexSpacing.x2),
            ApexPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tInline(
                      AppStrings.currentLanguageCode,
                      'Hava',
                      'Weather',
                      'Wetter',
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${rituals.weather.locationLabel} • ${rituals.weather.condition}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tInline(
                      AppStrings.currentLanguageCode,
                      '${rituals.weather.tempC}°C • Ruzgar ${rituals.weather.windKph} km/sa • Yagis ${rituals.weather.precipChancePercent}%',
                      '${rituals.weather.tempC}°C • Wind ${rituals.weather.windKph} kph • Precip ${rituals.weather.precipChancePercent}%',
                      '${rituals.weather.tempC}°C • Wind ${rituals.weather.windKph} km/h • Niederschlag ${rituals.weather.precipChancePercent}%',
                    ),
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _weatherFreshnessLine(
                      rituals.weather,
                      weatherFreshness,
                      tr,
                    ),
                    style: TextStyle(
                      color: weatherFreshness == WeatherFreshness.stale
                          ? context.colors.caution
                          : context.colors.textSecondary,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => showWeatherSheet(context, ref, tr),
                      icon: const Icon(
                        Icons.edit_location_alt_outlined,
                        size: 18,
                      ),
                      label: Text(
                        weatherFreshness == WeatherFreshness.fresh
                            ? (tInline(
                                AppStrings.currentLanguageCode,
                                'Havayı Yenile',
                                'Refresh weather',
                                'Wetter aktualisieren',
                              ))
                            : (tInline(
                                AppStrings.currentLanguageCode,
                                'Hava Al',
                                'Fetch weather',
                                'Wetter holen',
                              )),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: ApexSpacing.x2),
            ApexPanel(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tInline(
                            AppStrings.currentLanguageCode,
                            'Günlük Makine Kontrolü',
                            'Daily machine check',
                            'Täglicher Maschinencheck',
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _dailyCheckStatusLine(todayCheck, tr),
                          style: TextStyle(
                            color: context.colors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              DailyMachineCheckScreen(strings: strings),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chevron_right, size: 18),
                    label: Text(
                      todayCheck == null
                          ? (tInline(
                              AppStrings.currentLanguageCode,
                              'Baslat',
                              'Start',
                              'Start',
                            ))
                          : (tInline(
                              AppStrings.currentLanguageCode,
                              'Gözden Geçir',
                              'Review',
                              'Rezension',
                            )),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  String _labelTr(int score) {
    if (score >= 85) return 'Hazir. Akis temiz.';
    if (score >= 65) return 'Hazir. Dengeyi koru.';
    if (score >= 45) return 'Dikkat. Kucuk bakim iyi gelir.';
    return 'Bugun sakin ol. Once kontrol.';
  }

  String _labelEn(int score) {
    if (score >= 85) return 'Ready. Clean flow.';
    if (score >= 65) return 'Ready. Keep it stable.';
    if (score >= 45) return 'Caution. Small maintenance helps.';
    return 'Keep it calm. Check first.';
  }

  String _guidanceTr(int score) {
    if (score >= 85) {
      return 'Kisa bir gorsel kontrol yeterli. Yol boyunca tek bir sey sec: ritmi bozmadan sur.';
    }
    if (score >= 65) {
      return 'Servis disiplinini bozmadan sur. Donuste zincir ve lastige bir bakis ekle.';
    }
    if (score >= 45) {
      return 'Surusten once 3 dakikalik kontrol yap. Kucuk bir ayar, gunun tonunu degistirir.';
    }
    return 'Once temel kontroller. Gerekirse kisa rota sec ve sakin ilerle.';
  }

  String _guidanceEn(int score) {
    if (score >= 85) {
      return 'A quick visual check is enough. Pick one intention: keep the rhythm clean.';
    }
    if (score >= 65) {
      return 'Ride steady. Add a quick chain and tire look on return.';
    }
    if (score >= 45) {
      return 'Do a 3-minute check before moving. Small adjustments change the day.';
    }
    return 'Start with basics. Choose a shorter route and keep it calm.';
  }

  String _weatherFreshnessLine(
    WeatherSnapshot weather,
    WeatherFreshness freshness,
    bool tr,
  ) {
    final observedAt = weather.observedAt;
    if (observedAt == null) {
      return tInline(
        AppStrings.currentLanguageCode,
        'Snapshot zamanı bilinmiyor. Sürüşten önce yenile.',
        'Snapshot time is unknown. Refresh before riding.',
        'Die Snapshot-Zeit ist unbekannt. Erfrischen Sie sich vor der Fahrt.',
      );
    }
    final ageLabel = _relativeAgeLabel(
      DateTime.now().difference(observedAt),
      tr,
    );
    return switch (freshness) {
      WeatherFreshness.fresh => tInline(
        AppStrings.currentLanguageCode,
        'Snapshot $ageLabel güncellendi.',
        'Snapshot updated $ageLabel.',
        'Snapshot $ageLabel aktualisiert.',
      ),
      WeatherFreshness.aging => tInline(
        AppStrings.currentLanguageCode,
        'Snapshot $ageLabel güncellendi. Uzun rota öncesi yenile.',
        'Snapshot updated $ageLabel. Refresh before a longer route.',
        'Snapshot $ageLabel aktualisiert. Aktualisieren Sie sich vor einer längeren Route.',
      ),
      WeatherFreshness.stale => tInline(
        AppStrings.currentLanguageCode,
        'Snapshot $ageLabel güncellendi. Sürüşten önce havayı yenile.',
        'Snapshot updated $ageLabel. Refresh before heading out.',
        'Snapshot $ageLabel aktualisiert. Erfrischen Sie sich, bevor Sie losfahren.',
      ),
    };
  }

  String _dailyCheckStatusLine(DailyCheckEntry? entry, bool tr) {
    if (entry == null) {
      return tInline(
        AppStrings.currentLanguageCode,
        'Bugün için ritüel bekliyor. Kısa bir kontrol hazırlık puanını netleştirir.',
        'Today is still waiting for a ritual. A short check will sharpen the readiness score.',
        'Heute wartet noch auf ein Ritual. Ein kurzer Check schärft den Readiness-Score.',
      );
    }
    final time = _formatTime(entry.loggedAt);
    if (entry.allClear) {
      return tInline(
        AppStrings.currentLanguageCode,
        '$time itibarıyla 5/5 temiz. Değişen bir şey varsa gün içinde güncelleyebilirsin.',
        'Logged at $time with 5/5 clear. Update it later today only if something changes.',
        'Bei $time mit 5/5 klar protokolliert. Aktualisieren Sie es später heute nur, wenn sich etwas ändert.',
      );
    }
    return tInline(
      AppStrings.currentLanguageCode,
      '$time itibarıyla ${entry.failedCount} madde dikkat istiyor.',
      'Logged at $time with ${entry.failedCount} item needing attention.',
      'Um $time mit ${entry.failedCount} Element protokolliert, das Aufmerksamkeit erfordert.',
    );
  }

  String _relativeAgeLabel(Duration age, bool tr) {
    if (age.inMinutes < 60) {
      return tInline(
        AppStrings.currentLanguageCode,
        'az önce',
        'just now',
        'soeben',
      );
    }
    if (age.inHours < 24) {
      return tInline(
        AppStrings.currentLanguageCode,
        '${age.inHours} saat önce',
        '${age.inHours}h ago',
        'Vor ${age.inHours}h',
      );
    }
    return tInline(
      AppStrings.currentLanguageCode,
      '${age.inDays} gün önce',
      '${age.inDays}d ago',
      'Vor ${age.inDays}d',
    );
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

Future<void> showWeatherSheet(
  BuildContext context,
  WidgetRef ref,
  bool tr,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.surface,
    barrierColor: context.colors.background.withValues(alpha: 0.72),
    builder: (context) {
      return WeatherSheetContent(tr: tr);
    },
  );
}

class WeatherSheetContent extends ConsumerStatefulWidget {
  const WeatherSheetContent({required this.tr});

  final bool tr;

  @override
  ConsumerState<WeatherSheetContent> createState() =>
      WeatherSheetContentState();
}

enum WeatherFilterMode { worldwide, country, region }

class WeatherSheetContentState extends ConsumerState<WeatherSheetContent> {
  late final TextEditingController _controller;
  var _loading = false;
  String? _error;
  var _query = '';

  WeatherFilterMode _filterMode = WeatherFilterMode.worldwide;
  String? _selectedCountry;
  String? _selectedRegion;

  List<String> _recentCities = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _loadRecentCities();
  }

  Future<void> _loadRecentCities() async {
    final recentStr = await ApexKvStore.getString('rituals.weather_recent');
    if (recentStr != null && recentStr.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(recentStr);
        if (mounted) {
          setState(() {
            _recentCities = decoded.cast<String>();
          });
        }
      } catch (_) {}
    }
    if (_recentCities.isEmpty && mounted) {
      // Defaults
      setState(() {
        _recentCities = ['Antalya, TR', 'London, GB', 'Berlin, DE'];
      });
    }
  }

  Future<void> _saveRecentCity(String cityLabel) async {
    final next = [
      cityLabel,
      ..._recentCities.where((c) => c != cityLabel),
    ].take(5).toList();
    if (mounted) {
      setState(() {
        _recentCities = next;
      });
    }
    await ApexKvStore.setString('rituals.weather_recent', jsonEncode(next));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchWeatherForCity(
    String cityLabel,
    double? lat,
    double? lon,
  ) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      WeatherSnapshot snapshot;
      if (lat != null && lon != null) {
        snapshot = await const WeatherService().fetchByCoordinates(
          lat,
          lon,
          cityLabel,
          languageCode: tInline(
            AppStrings.currentLanguageCode,
            'tr',
            'en',
            'de',
          ),
        );
      } else {
        snapshot = await const WeatherService().fetchByLocation(
          cityLabel,
          languageCode: tInline(
            AppStrings.currentLanguageCode,
            'tr',
            'en',
            'de',
          ),
        );
      }
      ref.read(ritualsStateProvider.notifier).setWeather(snapshot);
      await _saveRecentCity(cityLabel);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on WeatherLookupException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = widget.tr
            ? _weatherErrorTr(e.message)
            : _weatherErrorEn(e.message);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = tInline(
          AppStrings.currentLanguageCode,
          'Hava verisi alınamadı. Bağlantıyı kontrol et.',
          'Weather could not be fetched. Check the connection.',
          'Das Wetter konnte nicht abgerufen werden. Überprüfen Sie die Verbindung.',
        );
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _weatherErrorTr(String message) {
    if (message.contains('Location was not found')) {
      return 'Konum bulunamadı. Şehir adını biraz daha net yaz.';
    }
    if (message.contains('Enter a city')) {
      return 'Şehir veya bölge gir.';
    }
    return 'Hava verisi alınamadı. Bağlantıyı kontrol et.';
  }

  String _weatherErrorEn(String message) {
    if (message.contains('Location was not found')) {
      return 'Location was not found. Try a more specific city name.';
    }
    if (message.contains('Enter a city')) {
      return 'Enter a city or area.';
    }
    return 'Weather could not be fetched. Check the connection.';
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(ref.watch(appSettingsProvider).locale);
    final filterText = _normalizeTurkish(_query);
    final isSearching = filterText.isNotEmpty;

    // Filter predefined cities based on search & dropdowns
    var filteredCities = predefinedCities.where((c) {
      final name = _normalizeTurkish(c.displayName(strings.languageCode));
      final cat = _normalizeTurkish(c.displayCategory(strings.languageCode));
      return name.contains(filterText) || cat.contains(filterText);
    }).toList();

    if (_filterMode == WeatherFilterMode.country && _selectedCountry != null) {
      filteredCities = filteredCities
          .where((c) => c.countryCode == _selectedCountry)
          .toList();
    } else if (_filterMode == WeatherFilterMode.region &&
        _selectedRegion != null) {
      filteredCities = filteredCities
          .where(
            (c) => c.displayCategory(strings.languageCode) == _selectedRegion,
          )
          .toList();
    }

    // Find recent cities from predefined list if possible for rich display
    final recentPredefined = _recentCities.map((label) {
      final parts = label.split(', ');
      final code = parts.length > 1 ? parts.last : '';
      final name = parts.first;
      return predefinedCities.firstWhere(
        (c) => c.countryCode == code && c.nameEn == name,
        orElse: () => PredefinedCity(
          nameTr: name,
          nameEn: name,
          categoryTr: '',
          categoryEn: '',
          latitude: 0,
          longitude: 0,
          countryCode: code,
        ),
      );
    }).toList();

    // Find current selected city
    final currentWeather = ref.watch(ritualsStateProvider).weather;

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.9,
      decoration: BoxDecoration(
        color: context
            .colors
            .surface, // Matches the dark blueish theme of bottom sheets
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: context.colors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),

            // Header Section
            Row(
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.cloud_outlined,
                        color: context.colors.cyan,
                        size: 40,
                      ),
                      Positioned(
                        bottom: 6,
                        child: Icon(
                          Icons.location_on,
                          color: context.colors.cyan,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.weatherLocationTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        strings.weatherLocationSubtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_loading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.colors.cyan,
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context
                            .colors
                            .background, // Darker bg for close button
                        shape: BoxShape.circle,
                        border: Border.all(color: context.colors.border),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Search Field
            TextField(
              controller: _controller,
              enabled: !_loading,
              textInputAction: TextInputAction.search,
              onChanged: (val) => setState(() => _query = val),
              onSubmitted: (val) {
                if (val.trim().isNotEmpty) {
                  _fetchWeatherForCity(val.trim(), null, null);
                }
              },
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: context.colors.background,
                hintText: strings.weatherSearchHint,
                hintStyle: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),

                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ApexSpacing.radius),
                  borderSide: BorderSide(color: context.colors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ApexSpacing.radius),
                  borderSide: BorderSide(color: context.colors.cyan),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Error display
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.caution.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(ApexSpacing.radius),
                  border: Border.all(color: context.colors.caution),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: context.colors.caution,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: context.colors.caution,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isSearching) ...[
                      // RECENT
                      Text(
                        strings.weatherRecent,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: recentPredefined
                              .map(
                                (c) =>
                                    _buildRecentChip(c, strings.languageCode),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // SUGGESTED CITIES
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          isSearching
                              ? tInline(
                                  AppStrings.currentLanguageCode,
                                  'SONUÇLAR',
                                  'RESULTS',
                                  'ERGEBNISSE',
                                )
                              : strings.weatherSuggested,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF94A3B8),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!isSearching)
                          Text(
                            strings.weatherBasedOnRecent,
                            style: TextStyle(
                              fontSize: 11,
                              color: context.colors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (filteredCities.isEmpty && isSearching)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.colors.cyan,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _loading
                              ? null
                              : () => _fetchWeatherForCity(
                                  _query.trim(),
                                  null,
                                  null,
                                ),
                          icon: const Icon(Icons.public, size: 18),
                          label: Text(
                            tInline(
                              AppStrings.currentLanguageCode,
                              "Tüm Dünyada Ara: '$_query'",
                              "Search Globally: '$_query'",
                              "Global suchen: '$_query'",
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: context.colors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: context.colors.border),
                        ),
                        child: Column(
                          children: filteredCities.map((city) {
                            final isSelected =
                                city.label.contains(
                                  currentWeather.locationLabel,
                                ) ||
                                currentWeather.locationLabel.contains(
                                  city.nameEn,
                                );
                            return _buildSuggestedRow(
                              city,
                              isSelected,
                              strings.languageCode,
                              city == filteredCities.last,
                            );
                          }).toList(),
                        ),
                      ),

                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Icon(
                          Icons.public,
                          size: 16,
                          color: context.colors.cyan,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            strings.weatherSearchCovers,
                            style: TextStyle(
                              fontSize: 12,
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle(
    IconData icon,
    String label,
    WeatherFilterMode mode,
    BuildContext context,
  ) {
    final isSelected = _filterMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _filterMode = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? context.colors.cyan : Colors.transparent,
            borderRadius: BorderRadius.circular(ApexSpacing.radius),
            border: Border.all(
              color: isSelected ? context.colors.cyan : context.colors.border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.black : Colors.white,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? Colors.black : Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentChip(PredefinedCity city, String languageCode) {
    return GestureDetector(
      onTap: _loading
          ? null
          : () {
              _controller.text = city.displayName(languageCode);
              _fetchWeatherForCity(city.label, city.latitude, city.longitude);
            },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: context.colors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 14,
              color: context.colors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              '${city.displayName(languageCode)}, ${city.countryCode == 'GB' ? 'UK' : city.displayCategory(languageCode)}',
              style: TextStyle(
                fontSize: 12,
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedRow(
    PredefinedCity city,
    bool isSelected,
    String languageCode,
    bool isLast,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _loading
            ? null
            : () {
                _controller.text = city.displayName(languageCode);
                _fetchWeatherForCity(city.label, city.latitude, city.longitude);
              },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : Border(bottom: BorderSide(color: context.colors.border)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on,
                  size: 16,
                  color: context.colors.cyan,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      city.displayName(languageCode),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${city.countryCode == 'GB' ? 'United Kingdom' : city.categoryTr} • ${city.displayCategory(languageCode)}',
                        style: TextStyle(
                          color: context.colors.textSecondary,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: context.colors.cyan,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 12, color: Colors.black),
                )
              else
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: context.colors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSelectionSheet(
    BuildContext context,
    String title,
    List<String> items,
    Function(String) onSelect,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: items.map((item) {
                      return GestureDetector(
                        onTap: () {
                          onSelect(item);
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(
                              ApexSpacing.radius,
                            ),
                            border: Border.all(color: const Color(0xFF334155)),
                          ),
                          child: Text(
                            item,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReadinessFactorRow extends StatelessWidget {
  const _ReadinessFactorRow({required this.factor, required this.tr});

  final ReadinessFactor factor;
  final bool tr;

  @override
  Widget build(BuildContext context) {
    final delta = factor.delta;
    final color = delta < 0
        ? context.colors.red
        : delta > 0
        ? context.colors.healthy
        : context.colors.cyan;
    final deltaLabel = delta == 0
        ? '0'
        : delta > 0
        ? '+$delta'
        : '$delta';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            border: Border.all(color: color.withValues(alpha: 0.28)),
            borderRadius: BorderRadius.circular(ApexSpacing.radius),
          ),
          child: Text(
            deltaLabel,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: ApexSpacing.x1),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _factorLabel(factor.label),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                _factorNote(factor.note),
                style: TextStyle(
                  color: context.colors.textSecondary,
                  height: 1.35,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _factorLabel(String input) {
    if (!tr) {
      return input;
    }
    return switch (input) {
      'Harmony' => 'Harmony',
      'Weather' => 'Hava',
      'Daily check' => 'Gunluk kontrol',
      _ => input,
    };
  }

  String _factorNote(String input) {
    if (!tr) {
      return input;
    }
    if (input.startsWith('1 check item')) {
      return '1 kontrol maddesi surus oncesi dikkat istiyor.';
    }
    final failedMatch = RegExp(r'^(\d+) check item').firstMatch(input);
    if (failedMatch != null) {
      return '${failedMatch.group(1)} kontrol maddesi surus oncesi dikkat istiyor.';
    }
    return switch (input) {
      'Machine state is within riding range.' =>
        'Makine durumu surus araliginda.',
      'Machine state asks for a calmer route.' =>
        'Makine durumu daha sakin rota istiyor.',
      'Weather snapshot is stale. Refresh before heading out.' =>
        'Hava snapshoti eskidi. Surusten once yenile.',
      'Weather snapshot is aging. Refresh if the route may stretch.' =>
        'Hava snapshoti yaslaniyor. Uzun rota oncesi yenile.',
      'Rain risk is high. Keep the route short and visible.' =>
        'Yagis riski yuksek. Rotayi kisa ve gorunur tut.',
      'Wind is strong. Avoid exposed roads.' =>
        'Ruzgar guclu. Acik yollari azalt.',
      'Temperature is outside the comfort window.' =>
        'Sicaklik konfor araliginin disinda.',
      'Weather is inside the normal riding window.' =>
        'Hava normal surus araliginda.',
      'Daily machine check has not been logged yet.' =>
        'Gunluk makine kontrolu henuz kaydedilmedi.',
      'Daily check is clean.' => 'Gunluk kontrol temiz.',
      _ => input,
    };
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({
    required this.title,
    required this.subtitle,
    required this.ok,
  });

  final String title;
  final String subtitle;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ok
                ? context.colors.healthy.withValues(alpha: 0.12)
                : context.colors.caution.withValues(alpha: 0.12),
            border: Border.all(
              color: ok
                  ? context.colors.healthy.withValues(alpha: 0.28)
                  : context.colors.caution.withValues(alpha: 0.28),
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            ok ? Icons.check : Icons.remove,
            size: 14,
            color: ok ? context.colors.healthy : context.colors.caution,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
