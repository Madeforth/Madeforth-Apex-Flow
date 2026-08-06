import 'package:flutter/widgets.dart';

class AppStrings {
  AppStrings(this.locale) {
    currentLanguageCode = locale.languageCode;
  }

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('tr'), Locale('de')];
  static String currentLanguageCode = 'en';

  String get languageCode => locale.languageCode;

  String _t({required String tr, required String en, required String de}) {
    switch (languageCode) {
      case 'tr':
        return tr;
      case 'de':
        return de;
      case 'en':
      default:
        return en;
    }
  }

  /// Public convenience method — use in screens instead of inline ternaries.
  /// Example: strings.t(tr: 'Kaydet', en: 'Save', de: 'Speichern')
  String t({required String tr, required String en, required String de}) =>
      _t(tr: tr, en: en, de: de);

  String get appTitle => 'Apex Flow';

  // Dashboard
  String get dashboardSubtitle => _t(
    tr: 'Sürüşe hazırlık, servis hafızası ve makine sağlığı.',
    en: 'Ride readiness, service memory, machine health.',
    de: 'Fahrbereitschaft, Service-Historie und Maschinenzustand.',
  );

  String get latestRideTitle =>
      _t(tr: 'Son sürüş', en: 'Latest ride', de: 'Letzte Fahrt');

  String get latestRideStatus => _t(tr: 'Kayıtlı', en: 'Logged', de: 'Erfasst');

  String get startRide =>
      _t(tr: 'Sürüşü Başlat', en: 'Start Ride', de: 'Fahrt starten');

  String get reflectRide =>
      _t(tr: 'Sürüş Notu', en: 'Reflect', de: 'Fahrtnotiz');

  String get startRideFallback => _t(
    tr: 'Sürüş akışı Sürüşler sekmesinden başlatılır.',
    en: 'Start flow runs from the Rides tab.',
    de: 'Start-Ablauf wird vom Fahrten-Tab gestartet.',
  );

  String get reflectRideFallback => _t(
    tr: 'Sürüş özeti Sürüşler sekmesinden açılır.',
    en: 'Reflection flow runs from the Rides tab.',
    de: 'Zusammenfassung wird vom Fahrten-Tab geöffnet.',
  );

  // Common labels
  String get commonOdometer =>
      _t(tr: 'Kilometre', en: 'Odometer', de: 'Kilometerstand');

  String get commonServiceDelta =>
      _t(tr: 'Servis farkı', en: 'Service delta', de: 'Service-Intervall');

  String get commonOilHealth =>
      _t(tr: 'Yağ sağlığı', en: 'Oil health', de: 'Motoröl-Zustand');

  String get commonBattery => _t(tr: 'Akü', en: 'Battery', de: 'Batterie');

  // Quick capture
  String get quickCaptureTitle =>
      _t(tr: 'Hızlı işlemler', en: 'Quick capture', de: 'Schnellzugriff');

  String get quickCaptureCount =>
      _t(tr: '4 araç', en: '4 tools', de: '4 Werkzeuge');

  String get quickService => _t(tr: 'Servis', en: 'Service', de: 'Service');

  String get quickFuel => _t(tr: 'Yakıt', en: 'Fuel', de: 'Tanken');

  String get quickTires => _t(tr: 'Lastik', en: 'Tires', de: 'Reifen');

  String get quickDailyCheck =>
      _t(tr: 'Günlük Kontrol', en: 'Daily Check', de: 'Tages-Check');

  String quickCaptureFallback(String label) => _t(
    tr: '$label özelliği Analizler sekmesinde aktif.',
    en: '$label is active in Insights.',
    de: '$label ist im Bereich Analysen aktiv.',
  );

  // Maintenance signals
  String get maintenanceSignalsTitle => _t(
    tr: 'Bakım sinyalleri',
    en: 'Maintenance signals',
    de: 'Wartungssignale',
  );

  String maintenanceSignalsCount(int count) => count == 0
      ? _t(tr: 'Sakin', en: 'Clear', de: 'Keine Auffälligkeiten')
      : _t(tr: '$count Aktif', en: '$count Active', de: '$count Aktiv');

  String get signalClear => _t(
    tr: 'Aktif bakım sinyali yok',
    en: 'No active maintenance signals',
    de: 'Keine aktiven Wartungssignale',
  );

  String get signalServiceOverdue => _t(
    tr: 'Servis aralığı geçti',
    en: 'Service window overdue',
    de: 'Service-Intervall überschritten',
  );

  String get signalServiceDueSoon => _t(
    tr: 'Servis aralığı yaklaşıyor',
    en: 'Service window approaching',
    de: 'Service-Intervall rückt näher',
  );

  String get signalChainWear => _t(
    tr: 'Zincir kontrolü gerekiyor',
    en: 'Chain check needed',
    de: 'Kette überprüfen',
  );

  String get signalTireWear => _t(
    tr: 'Lastik aşınması izlenmeli',
    en: 'Tire wear needs monitoring',
    de: 'Reifenverschleiß beobachten',
  );

  String get signalBrakeWear => _t(
    tr: 'Fren hissi kontrol edilmeli',
    en: 'Brake feel needs inspection',
    de: 'Bremsgefühl prüfen',
  );

  String get signalOilHealth => _t(
    tr: 'Yağ sağlığı düşüyor',
    en: 'Oil health is dropping',
    de: 'Motoröl-Zustand sinkt',
  );

  String get signalBatteryHealth => _t(
    tr: 'Akü sağlığı izlenmeli',
    en: 'Battery health needs monitoring',
    de: 'Batteriezustand beobachten',
  );

  // Preview notice
  String previewNotice(String browser) => _t(
    tr: '$browser önizleme dışında tarayıcı doğrulaması kapsam dışı.',
    en: '$browser preview only. Cross-browser validation is outside preview scope.',
    de: 'Nur $browser-Vorschau. Browserübergreifende Validierung außerhalb des Vorschau-Umfangs.',
  );

  String get navHome => _t(tr: 'Ana Sayfa', en: 'Home', de: 'Start');
  String get navGarage => _t(tr: 'Garaj', en: 'Garage', de: 'Garage');
  String get navRides => _t(tr: 'Sürüşler', en: 'Rides', de: 'Fahrten');
  String get navFuel => _t(tr: 'Yakıt', en: 'Fuel', de: 'Tanken');
  String get navInsights => _t(tr: 'Analizler', en: 'Insights', de: 'Analysen');
  String get navSettings =>
      _t(tr: 'Ayarlar', en: 'Settings', de: 'Einstellungen');
  String get settingsTitle =>
      _t(tr: 'Ayarlar', en: 'Settings', de: 'Einstellungen');
  String get language => _t(tr: 'Dil', en: 'Language', de: 'Sprache');
  String get english => 'English';
  String get turkish => 'Türkçe';
  String get german => 'Deutsch';

  String get settingsNotificationTitle => _t(
    tr: 'Bildirim Ayarları',
    en: 'Notification Settings',
    de: 'Benachrichtigungen',
  );
  String get settingsNotificationDesc => _t(
    tr: 'Bakım uyarıları ve sürüş öncesi hatırlatıcı bildirimlerini yönet.',
    en: 'Manage maintenance alerts and pre-ride reminder notifications.',
    de: 'Wartungswarnungen und Erinnerungen vor der Fahrt verwalten.',
  );
  String get settingsNotificationPermissionBtn => _t(
    tr: 'Bildirim İzni İste',
    en: 'Request Notification Permission',
    de: 'Berechtigung anfordern',
  );
  String get settingsNotificationPermissionGranted => _t(
    tr: 'Bildirim izni verildi!',
    en: 'Notifications permission granted!',
    de: 'Benachrichtigungsberechtigung erteilt!',
  );
  String get settingsNotificationPermissionDenied => _t(
    tr: 'İzin reddedildi veya zaten açık.',
    en: 'Permission denied or already enabled.',
    de: 'Berechtigung verweigert oder bereits aktiviert.',
  );

  String get insightsTitle => _t(
    tr: 'Bakım Analizleri',
    en: 'Maintenance Intelligence',
    de: 'Wartungs-Intelligenz',
  );

  String get insightsSubtitle => _t(
    tr: 'Takvim, maliyet ve bakım sinyallerini tek panelden yönet.',
    en: 'Calendar, cost, patterns and parts planning in one surface.',
    de: 'Kalender, Kosten, Muster und Teileplanung auf einer Oberfläche.',
  );

  String get maintenanceCalendar => _t(
    tr: 'Bakım Takvimi',
    en: 'Maintenance Calendar',
    de: 'Wartungskalender',
  );
  String get costLedger =>
      _t(tr: 'Maliyet Defteri', en: 'Cost Ledger', de: 'Kostenbuch');
  String get insightsCostSaved => _t(
    tr: 'Maliyet kaydı kaydedildi.',
    en: 'Cost entry saved.',
    de: 'Kosteneintrag gespeichert.',
  );
  String get insightsCostInvalid => _t(
    tr: 'Açıklama ve sıfırdan büyük bir tutar girin.',
    en: 'Enter a description and an amount greater than zero.',
    de: 'Gib eine Beschreibung und einen Betrag größer als null ein.',
  );
  String get insightsCostSaveFailed => _t(
    tr: 'Maliyet kaydı kaydedilemedi. Tekrar deneyin.',
    en: 'The cost entry could not be saved. Please try again.',
    de: 'Der Kosteneintrag konnte nicht gespeichert werden. Bitte erneut versuchen.',
  );
  String get problemPatterns => _t(
    tr: 'Problem Örüntü Tespiti',
    en: 'Problem Pattern Detection',
    de: 'Problemmuster-Erkennung',
  );
  String get partsWishlist =>
      _t(tr: 'Parça Listesi', en: 'Parts Wishlist', de: 'Teileliste');
  String get addPart =>
      _t(tr: 'Parça Ekle', en: 'Add Part', de: 'Teil hinzufügen');
  String get pasteLinkHint => _t(
    tr: 'Ürün linki ekleyebilirsin',
    en: 'You can attach a product link',
    de: 'Du kannst einen Produktlink anfügen',
  );

  String get garagePartStatusTitle =>
      _t(tr: 'Parça durumu', en: 'Part status', de: 'Teilezustand');
  String get garagePartStatusSubtitle => _t(
    tr: 'Gözleme dayalı kayıt',
    en: 'Observation-based log',
    de: 'Beobachtungsbasiertes Protokoll',
  );
  String get garagePartStatusHelper => _t(
    tr: 'Yüzde tahmini yerine makinene en yakın hissi seç.',
    en: 'Skip the percentage guess and choose the feel closest to your machine.',
    de: 'Verzichte auf Prozentschätzungen und wähle das Gefühl, das deiner Maschine am nächsten kommt.',
  );
  String get garagePartStatusSave => _t(
    tr: 'Parça durumunu güncelle',
    en: 'Update part status',
    de: 'Teilezustand aktualisieren',
  );

  String garageComponentLabel(String component) {
    return switch (component.toLowerCase()) {
      'chain' => _t(tr: 'Zincir', en: 'Chain', de: 'Kette'),
      'tires' || 'tire' => _t(tr: 'Lastikler', en: 'Tires', de: 'Reifen'),
      'brakes' || 'brake' => _t(tr: 'Frenler', en: 'Brakes', de: 'Bremsen'),
      'oil' => _t(tr: 'Yağ', en: 'Oil', de: 'Motoröl'),
      'battery' => _t(tr: 'Akü', en: 'Battery', de: 'Batterie'),
      'service' => _t(tr: 'Servis', en: 'Service', de: 'Wartung'),
      _ => component,
    };
  }

  String garageComponentEditorLabel(String component) {
    return switch (component.toLowerCase()) {
      'chain' => _t(
        tr: 'Zincir durumu',
        en: 'Chain condition',
        de: 'Kettenzustand',
      ),
      'tire' => _t(
        tr: 'Lastik durumu',
        en: 'Tire condition',
        de: 'Reifenzustand',
      ),
      'brake' => _t(tr: 'Fren hissi', en: 'Brake feel', de: 'Bremsgefühl'),
      'oil' => _t(tr: 'Yağ durumu', en: 'Oil state', de: 'Motoröl-Zustand'),
      'battery' => _t(
        tr: 'Akü davranışı',
        en: 'Battery behavior',
        de: 'Batterieverhalten',
      ),
      _ => component,
    };
  }

  String garageComponentEditorHint(String component) {
    return switch (component.toLowerCase()) {
      'chain' => _t(
        tr: 'Zincirdeki kuruluğa, sürüş esnasındaki şıkırtı sesine ve ne kadar sarktığına göre karar verin.',
        en: 'Decide based on how dry it looks, any rattling noise while riding, and how much it sags.',
        de: 'Entscheide basierend auf Trockenheit, Klappergeräuschen beim Fahren und wie stark sie durchhängt.',
      ),
      'tire' => _t(
        tr: 'Lastiğin dış görünüşü, tırtıkları ve viraja girerken verdiği güven hissine göre seçiminizi yapın.',
        en: 'Make your choice based on the tread appearance and how confident the bike feels in corners.',
        de: 'Wähle basierend auf dem Profilbild und dem Vertrauen, das das Motorrad in Kurven vermittelt.',
      ),
      'brake' => _t(
        tr: 'Fren kolunu sıktığınızdaki hissiyata ve motorun ne kadar çabuk durduğuna odaklanın.',
        en: 'Focus on how the brake lever feels when squeezed and how quickly the bike stops.',
        de: 'Achte darauf, wie sich der Bremshebel anfühlt und wie schnell das Motorrad bremst.',
      ),
      'oil' => _t(
        tr: 'Son yağ değişiminden bu yana motorun çalışma sesindeki ve titreşimindeki değişimi baz alın.',
        en: 'Consider any changes in engine noise and vibration since your last oil change.',
        de: 'Achte auf Veränderungen bei Motorgeräuschen und Vibrationen seit dem letzten Ölwechsel.',
      ),
      'battery' => _t(
        tr: 'Özellikle sabahları ilk marşa basarken motorun ne kadar canlı veya zorlanarak çalıştığına dikkat edin.',
        en: 'Pay attention to how lively or sluggish the engine sounds during the first cold start of the day.',
        de: 'Achte darauf, wie lebhaft oder träge der Motor beim ersten Kaltstart am Morgen anspringt.',
      ),
      _ => component,
    };
  }

  String garageConditionLabel(String key) {
    return switch (key) {
      'fresh' => _t(tr: 'Yeni Gibi', en: 'Like New', de: 'Wie neu'),
      'stable' => _t(
        tr: 'İyi / Sorunsuz',
        en: 'Good / Normal',
        de: 'Gut / Unauffällig',
      ),
      'watch' => _t(tr: 'Kontrol Et', en: 'Inspect Soon', de: 'Bald prüfen'),
      'service_soon' => _t(
        tr: 'Bakım Zamanı',
        en: 'Needs Service',
        de: 'Wartung fällig',
      ),
      'fresh_tread' => _t(
        tr: 'Yeni / Çok İyi',
        en: 'Excellent',
        de: 'Hervorragend',
      ),
      'balanced' => _t(
        tr: 'İyi Durumda',
        en: 'Good Condition',
        de: 'Guter Zustand',
      ),
      'watch_tread' => _t(
        tr: 'Aşınma Başladı',
        en: 'Wear Started',
        de: 'Verschleiß beginnt',
      ),
      'replace_soon' => _t(
        tr: 'Değişim Yakın',
        en: 'Replace Soon',
        de: 'Bald austauschen',
      ),
      'fresh_service' => _t(
        tr: 'Yeni Değişti',
        en: 'Freshly Changed',
        de: 'Frisch gewechselt',
      ),
      'mid_interval' => _t(
        tr: 'Normal / Yarı Ömür',
        en: 'Good / Mid-Life',
        de: 'Gut / Halbe Lebensdauer',
      ),
      'due_soon' => _t(
        tr: 'Değişim Yakın',
        en: 'Due Soon',
        de: 'Wechsel fällig',
      ),
      'change_now' => _t(
        tr: 'Hemen Değiştir',
        en: 'Change Now',
        de: 'Sofort wechseln',
      ),
      'instant_start' => _t(
        tr: 'Çok Sağlıklı',
        en: 'Healthy',
        de: 'Sehr gesund',
      ),
      'routine_use' => _t(
        tr: 'İyi / Sorunsuz',
        en: 'Good / Stable',
        de: 'Gut / Stabil',
      ),
      'monitor' => _t(
        tr: 'Takip Et',
        en: 'Monitor Volt',
        de: 'Spannung beobachten',
      ),
      'charge_check' => _t(
        tr: 'Şarj Et / Değiştir',
        en: 'Charge / Replace',
        de: 'Laden / Austauschen',
      ),
      'on_rhythm' => _t(tr: 'Ritimde', en: 'On rhythm', de: 'Im Rhythmus'),
      'overdue' => _t(tr: 'Gecikmiş', en: 'Overdue', de: 'Überfällig'),
      _ => key,
    };
  }

  String garageServiceStateLabel(String key) {
    return switch (key) {
      'on_rhythm' => _t(tr: 'Ritimde', en: 'On rhythm', de: 'Im Rhythmus'),
      'due_soon' => _t(tr: 'Yaklaşıyor', en: 'Due soon', de: 'Bald fällig'),
      'overdue' => _t(tr: 'Gecikmiş', en: 'Overdue', de: 'Überfällig'),
      _ => key,
    };
  }

  String garageConditionSignal(String component, String key) {
    return switch ('$component:$key') {
      'chain:fresh' => _t(
        tr: 'Zinciriniz pırıl pırıl ve gerginliği tam kıvamında. Sürüşe hazırsınız!',
        en: 'Your chain is spotless and tension is spot on. Ready to ride!',
        de: 'Kette ist frisch geschmiert, Spannung hervorragend.',
      ),
      'chain:stable' => _t(
        tr: 'Zinciriniz iyi durumda, rahatsız edici bir ses yok. Aynen devam.',
        en: 'Chain is in good shape, no annoying noise. Keep going.',
        de: 'Kette in gutem Zustand, keine Laufgeräusche.',
      ),
      'chain:watch' => _t(
        tr: 'Zincir hafiften kurumuş veya bollaşmış olabilir. Yakın zamanda bir göz atmanızda fayda var.',
        en: 'Chain feels a bit dry or slack. Consider checking it soon.',
        de: 'Trockenheit oder Spiel erkannt, sollte geprüft werden.',
      ),
      'chain:service_soon' => _t(
        tr: 'Zinciriniz oldukça gevşek veya bakımsız kalmış. Sürüş güvenliği için bakım yapmalısınız!',
        en: 'Chain is too loose or neglected. You need to service it for a safe ride!',
        de: 'Kette zu locker oder verschlissen, Wartung erforderlich.',
      ),
      'tire:fresh_tread' => _t(
        tr: 'Lastikleriniz yeni gibi, diş derinliği ve yol tutuşu mükemmel seviyede.',
        en: 'Tires look pristine. Excellent tread depth and grip.',
        de: 'Reifen fast neuwertig, Profiltiefe hervorragend.',
      ),
      'tire:balanced' => _t(
        tr: 'Lastiklerinizin durumu gayet iyi, güvenle yola çıkabilirsiniz.',
        en: 'Tires are in good shape, ride with confidence.',
        de: 'Reifen in gutem Zustand, Grip ist normal.',
      ),
      'tire:watch_tread' => _t(
        tr: 'Lastiklerinizde hafif aşınmalar başlamış. Özellikle ıslak zeminlerde biraz daha dikkatli olun.',
        en: 'Tires are showing some wear. Take it easy on wet surfaces.',
        de: 'Lauffläche oder Flanken beginnen zu verschleißen.',
      ),
      'tire:replace_soon' => _t(
        tr: 'Lastikleriniz ömrünü tamamlamak üzere. Yol tutuşu zayıflamıştır, en kısa sürede yenilemelisiniz.',
        en: 'Tires are near end of life. Grip is compromised, replace them very soon.',
        de: 'Reifen fast abgefahren, bald austauschen.',
      ),
      'brake:fresh' => _t(
        tr: 'Frenleriniz çok iyi durumda. Dokunduğunuz an güvenle duruyorsunuz!',
        en: 'Brakes are phenomenal. Perfect bite and stopping power!',
        de: 'Bremsleistung hervorragend, schnelles Ansprechen.',
      ),
      'brake:stable' => _t(
        tr: 'Frenleriniz gayet sağlıklı çalışıyor. Frenleme gücünde hiçbir sorun yok.',
        en: 'Brakes are working flawlessly. Solid stopping power.',
        de: 'Bremsen arbeiten normal, gute Verzögerung.',
      ),
      'brake:watch' => _t(
        tr: 'Fren kolunda biraz yumuşama var gibi. Balataları veya hidroliği kontrol etmeniz iyi olur.',
        en: 'Brake lever feels slightly spongy. Good time to inspect pads and fluid.',
        de: 'Bremshebel oder Pedal fühlt sich weich an, Beläge prüfen.',
      ),
      'brake:service_soon' => _t(
        tr: 'Fren performansınız ciddi oranda düşmüş. Güvenliğiniz için lütfen hemen servise başvurun.',
        en: 'Braking performance dropped drastically. Please get it serviced immediately.',
        de: 'Bremsleistung nachgelassen, sofortige Wartung nötig.',
      ),
      'oil:fresh_service' => _t(
        tr: 'Motor yağınız tertemiz, motorunuz saat gibi sessiz ve pürüzsüz çalışıyor.',
        en: 'Oil is super fresh. Your engine is purring like a kitten.',
        de: 'Motoröl frisch gewechselt, Motor läuft seidenweich.',
      ),
      'oil:mid_interval' => _t(
        tr: 'Yağ seviyeniz ve durumu gayet iyi. Motorunuz sağlıklı çalışmaya devam ediyor.',
        en: 'Oil condition is great. Engine is running smoothly.',
        de: 'Ölstand und Zustand gut, noch viel Laufleistung übrig.',
      ),
      'oil:due_soon' => _t(
        tr: 'Motor yağınızın ömrü azalmaya başlamış. Yavaş yavaş yağ değişimini planlayın.',
        en: 'Oil is getting old. Start planning an oil change soon.',
        de: 'Motoröl nähert sich dem Ende, Motorlauf etwas rauer.',
      ),
      'oil:change_now' => _t(
        tr: 'Yağınız artık özelliğini yitirmiş. Motorun zarar görmemesi için acilen değişim yapmalısınız.',
        en: 'Oil is completely degraded. Change it immediately to protect the engine.',
        de: 'Öllebensdauer erschöpft, sofort wechseln.',
      ),
      'battery:instant_start' => _t(
        tr: 'Akünüz çok güçlü. Marşa bastığınız an motorunuz tek seferde canlanıyor.',
        en: 'Battery is very strong. Fires right up on the first crank.',
        de: 'Batteriespannung sehr gut, springt sofort an.',
      ),
      'battery:routine_use' => _t(
        tr: 'Akü durumunuz normal seviyede, günlük kullanımlar için gayet yeterli.',
        en: 'Battery health is solid. Good for everyday riding.',
        de: 'Batteriezustand normal, alltagstauglich.',
      ),
      'battery:monitor' => _t(
        tr: 'Marş basarken motor biraz nazlanıyor olabilir. Akü voltajını ölçtürmenizde fayda var.',
        en: 'Starts are a bit sluggish. You might want to check the voltage.',
        de: 'Startet etwas träge, Spannung beobachten.',
      ),
      'battery:charge_check' => _t(
        tr: 'Akünüz çok zayıflamış, yolda kalmamak için şarj ettirmeli veya yenisini almalısınız.',
        en: 'Battery is practically dead. Charge or replace it so you do not get stranded.',
        de: 'Batterie sehr schwach, laden oder austauschen.',
      ),
      _ => key,
    };
  }

  String garageServiceSignal({
    required int kmSinceService,
    required int kmUntilService,
  }) {
    if (kmUntilService < 0) {
      return _t(
        tr: 'Servis ${kmUntilService.abs()} km gecikti.',
        en: 'Service is overdue by ${kmUntilService.abs()} km.',
        de: 'Service ist um ${kmUntilService.abs()} km überfällig.',
      );
    }
    if (kmUntilService <= 500) {
      return _t(
        tr: 'Servise $kmUntilService km kaldı.',
        en: '$kmUntilService km left until service.',
        de: 'Noch $kmUntilService km bis zum Service.',
      );
    }
    return _t(
      tr: 'Son servisten beri $kmSinceService km yapıldı.',
      en: '$kmSinceService km since the last service.',
      de: '$kmSinceService km seit dem letzten Service.',
    );
  }

  String get garageServiceEntryHelper => _t(
    tr: 'Garaj kilometresi hazır. Uygunsa bir servis etiketi seçip sadece notu güncelle.',
    en: 'Garage odometer is ready. Pick a service label if it fits, then just update the note.',
    de: 'Garagen-Kilometerstand bereit. Service-Label wählen, falls passend, und Notiz aktualisieren.',
  );

  String garageServicePresetLabel(String key) {
    return switch (key) {
      'inspection' => _t(
        tr: 'Servis kontrolü',
        en: 'Service inspection',
        de: 'Inspektion',
      ),
      'oil' => _t(tr: 'Yağ servisi', en: 'Oil service', de: 'Ölwechsel'),
      'chain' => _t(
        tr: 'Zincir bakımı',
        en: 'Chain service',
        de: 'Kettenpflege',
      ),
      'brake' => _t(
        tr: 'Fren kontrolü',
        en: 'Brake check',
        de: 'Bremsenkontrolle',
      ),
      'tire' => _t(
        tr: 'Lastik kontrolü',
        en: 'Tire check',
        de: 'Reifenkontrolle',
      ),
      _ => key,
    };
  }

  String get rideStartHelper => _t(
    tr: 'Son sürüş modu hazır. Uygunsa tek dokunuşla başlat.',
    en: 'Last ride mood is ready. Begin with one tap if it still fits.',
    de: 'Letzter Fahrtmodus bereit. Wenn passend, mit einem Tippen starten.',
  );

  String rideQuickMoodLabel(String key) {
    return switch (key) {
      'focused' => _t(tr: 'Odaklı', en: 'Focused', de: 'Fokussiert'),
      'calm' => _t(tr: 'Sakin', en: 'Calm', de: 'Ruhig'),
      'open_road' => _t(tr: 'Açık yol', en: 'Open road', de: 'Freie Straße'),
      'reset' => 'Reset',
      _ => key,
    };
  }

  String get rideEndHelper => _t(
    tr: 'Yaklaşık değerler yeterli. Dikkat çeken bir şey yoksa notu boş bırakabilirsiniz.',
    en: 'Approximate values are enough. Leave the note empty if nothing stood out.',
    de: 'Ungefähre Werte genügen. Notiz leer lassen, falls es nichts Auffälliges gab.',
  );

  String get rideEndUseLastBaseline => _t(
    tr: 'Son sürüşü baz al',
    en: 'Use last ride baseline',
    de: 'Werte der letzten Fahrt nutzen',
  );

  String rideEndBaselineMeta({
    required double distanceKm,
    required int durationMinutes,
    required double averageSpeedKmh,
  }) {
    return _t(
      tr: '${distanceKm.toStringAsFixed(1)} km • $durationMinutes dk • ${averageSpeedKmh.toStringAsFixed(1)} kmh',
      en: '${distanceKm.toStringAsFixed(1)} km • $durationMinutes min • ${averageSpeedKmh.toStringAsFixed(1)} kmh',
      de: '${distanceKm.toStringAsFixed(1)} km • $durationMinutes min • ${averageSpeedKmh.toStringAsFixed(1)} km/h',
    );
  }

  // Zero-Friction UX
  String get settingsAutoRideTitle => _t(
    tr: 'Otomatik Sürüş Algılama',
    en: 'Automatic Ride Detection',
    de: 'Automatische Fahrterkennung',
  );
  String get settingsAutoRideDesc => _t(
    tr: 'Uygulama açıkken cihaz hareketini kullanarak sürüşe başladığınızı algılar ve sorar (pil dostu, arka planda çalışmaz).',
    en: 'While the app is open, detects likely ride motion and asks you to confirm (battery-safe, does not run in the background).',
    de: 'Erkennt bei geöffneter App wahrscheinliche Fahrtbewegung und fragt zur Bestätigung (akkuschonend, läuft nicht im Hintergrund).',
  );
  String get settingsAutoRideToggle => _t(
    tr: 'Otomatik Algılamayı Etkinleştir',
    en: 'Enable Auto Detection',
    de: 'Automatische Erkennung aktivieren',
  );
  String get settingsAutoRideSimBt => _t(
    tr: 'Bluetooth Bağlantısını Simüle Et',
    en: 'Simulate Bluetooth Connection',
    de: 'Bluetooth-Verbindung simulieren',
  );
  String get settingsAutoRideSimMotion => _t(
    tr: 'Cihaz Hareketini Simüle Et',
    en: 'Simulate Device Motion',
    de: 'Gerätebewegung simulieren',
  );
  String get dashboardAutoRideTitle =>
      _t(tr: 'Sürüş Algılandı', en: 'Ride Detected', de: 'Fahrt erkannt');
  String get dashboardAutoRideMsg => _t(
    tr: 'Bu sürüş seansını kaydetmeye başlamak ister misiniz?',
    en: 'Would you like to start logging this ride session?',
    de: 'Möchtest du diese Fahrt aufzeichnen?',
  );
  String get dashboardAutoRideStart =>
      _t(tr: 'Başlat', en: 'Begin', de: 'Starten');
  String get dashboardAutoRideDismiss =>
      _t(tr: 'Kapat', en: 'Dismiss', de: 'Schließen');
  String get dailyCheckQuickAllClear => _t(
    tr: 'Tek Tıkla Kaydet: Hepsi Temiz',
    en: 'One-Tap Log: All Clear',
    de: '1-Klick-Protokoll: Alles in Ordnung',
  );

  // Weather Location UI
  String get weatherLocationTitle => _t(
    tr: 'Hava durumu konumu',
    en: 'Weather location',
    de: 'Wetterstandort',
  );
  String get weatherLocationSubtitle => _t(
    tr: 'Yerel sürüş koşulları için bir şehir bulun.',
    en: 'Find a city for local ride conditions.',
    de: 'Finden Sie eine Stadt für lokale Fahrbedingungen.',
  );
  String get weatherSearchHint => _t(
    tr: 'Şehir veya ülke ara',
    en: 'Search city or country',
    de: 'Stadt oder Land suchen',
  );
  String get weatherWorldwide =>
      _t(tr: 'Tüm Dünya', en: 'Worldwide', de: 'Weltweit');
  String get weatherCountry => _t(tr: 'Ülke', en: 'Country', de: 'Land');
  String get weatherRegion => _t(tr: 'Bölge', en: 'Region', de: 'Region');
  String get weatherAllCountries =>
      _t(tr: 'Tüm ülkeler', en: 'All countries', de: 'Alle Länder');
  String get weatherAllRegions =>
      _t(tr: 'Tüm bölgeler', en: 'All regions', de: 'Alle Regionen');
  String get weatherReset => _t(tr: 'Sıfırla', en: 'Reset', de: 'Zurücksetzen');
  String get weatherRecent =>
      _t(tr: 'SON ARANANLAR', en: 'RECENT', de: 'KÜRZLICH');
  String get weatherSuggested => _t(
    tr: 'ÖNERİLEN ŞEHİRLER',
    en: 'SUGGESTED CITIES',
    de: 'VORGESCHLAGENE STÄDTE',
  );
  String get weatherBasedOnRecent => _t(
    tr: 'Son seçimlere göre',
    en: 'Based on recent selections',
    de: 'Basierend auf kürzlichen Auswahlen',
  );
  String get weatherSearchCovers => _t(
    tr: 'Arama tüm dünyadaki ülke ve şehirleri kapsar.',
    en: 'Search covers countries and cities worldwide.',
    de: 'Die Suche umfasst Länder und Städte weltweit.',
  );

  // Garage Passport
  String get garagePassportTitle =>
      _t(tr: 'Garaj Pasaportu', en: 'Garage Passport', de: 'Garagen-Pass');
  String get garagePassportSubtitle => _t(
    tr: 'Makinenin bakım geçmişi ve kondisyon özeti.',
    en: 'Maintenance history and condition summary.',
    de: 'Wartungshistorie und Zustandszusammenfassung.',
  );
  String get garagePassportMachineId => _t(
    tr: 'Makine Kimliği',
    en: 'Machine Identity',
    de: 'Maschinen-Identität',
  );
  String get garagePassportComponentHealth => _t(
    tr: 'Parça Kondisyonu',
    en: 'Component Health',
    de: 'Komponentenzustand',
  );
  String get garagePassportServiceHistory =>
      _t(tr: 'Servis Geçmişi', en: 'Service History', de: 'Service-Historie');
  String get garagePassportRideStats => _t(
    tr: 'Sürüş İstatistikleri',
    en: 'Ride Statistics',
    de: 'Fahrstatistiken',
  );
  String get garagePassportHarmony =>
      _t(tr: 'Harmony Durumu', en: 'Harmony Status', de: 'Harmony-Status');
  String get garagePassportMaintenanceWindow => _t(
    tr: 'Bakım Penceresi',
    en: 'Maintenance Window',
    de: 'Wartungsfenster',
  );
  String get garagePassportShare =>
      _t(tr: 'Pasaportu Paylaş', en: 'Share Passport', de: 'Pass teilen');
  String get garagePassportGenerated =>
      _t(tr: 'Oluşturulma tarihi', en: 'Generated at', de: 'Erstellt am');
  String get garagePassportNoService => _t(
    tr: 'Henüz servis kaydı yok',
    en: 'No service records yet',
    de: 'Noch keine Service-Einträge',
  );
  String get garagePassportNoRides => _t(
    tr: 'Henüz sürüş kaydı yok',
    en: 'No ride records yet',
    de: 'Noch keine Fahrten aufgezeichnet',
  );
  String get garagePassportTotalRides =>
      _t(tr: 'Toplam sürüş', en: 'Total rides', de: 'Fahrten gesamt');
  String get garagePassportTotalDistance =>
      _t(tr: 'Toplam mesafe', en: 'Total distance', de: 'Gesamtdistanz');
  String get garagePassportAvgDistance =>
      _t(tr: 'Ort. mesafe', en: 'Avg. distance', de: 'Durchschn. Distanz');
  String get garagePassportWear =>
      _t(tr: 'aşınma', en: 'wear', de: 'Verschleiß');
  String get garagePassportHealth =>
      _t(tr: 'sağlık', en: 'health', de: 'Gesundheit');

  // Document Vault & Tax
  String get navDocuments =>
      _t(tr: 'Belgeler', en: 'Documents', de: 'Dokumente');
  String get vaultTitle =>
      _t(tr: 'Belge Deposu', en: 'Document Vault', de: 'Dokumenten-Tresor');
  String get vaultSubtitle => _t(
    tr: 'Ruhsat, ehliyet ve finansal/yasal tarih takipleri.',
    en: 'License, registration, and financial/legal due dates.',
    de: 'Zulassung, Führerschein und finanzielle/rechtliche Fristen.',
  );
  String get vaultAddDoc =>
      _t(tr: 'Belge Ekle', en: 'Add Document', de: 'Dokument hinzufügen');
  String get vaultNoDocs => _t(
    tr: 'Kayıtlı belge bulunmuyor.',
    en: 'No documents saved yet.',
    de: 'Noch keine Dokumente gespeichert.',
  );
  String get vaultTaxTab =>
      _t(tr: 'Vergi & Muayene', en: 'Tax & Dates', de: 'Steuern & Fristen');
  String get vaultDocTab =>
      _t(tr: 'Belgelerim', en: 'Documents', de: 'Meine Dokumente');
  String get taxAmount => _t(tr: 'Tutar', en: 'Amount', de: 'Betrag');
  String get taxDueDate =>
      _t(tr: 'Son Tarih', en: 'Due Date', de: 'Fälligkeitsdatum');
  String get taxStatusPaid => _t(tr: 'Ödendi', en: 'Paid', de: 'Bezahlt');
  String get taxStatusUnpaid =>
      _t(tr: 'Ödenmedi', en: 'Unpaid', de: 'Ausstehend');
  String get taxTemplateButton => _t(
    tr: 'Varsayılan Şablon Yükle',
    en: 'Load Default Templates',
    de: 'Standardvorlagen laden',
  );
  String get taxAddButton => _t(
    tr: 'Ödeme / Tarih Ekle',
    en: 'Add Due Date',
    de: 'Frist / Zahlung hinzufügen',
  );

  String taxLabel(String key) {
    return switch (key) {
      'mtv_1' => _t(
        tr: 'MTV 1. Taksit (Ocak)',
        en: 'Motor Tax 1st Half',
        de: 'Kfz-Steuer 1. Halbjahr',
      ),
      'mtv_2' => _t(
        tr: 'MTV 2. Taksit (Temmuz)',
        en: 'Motor Tax 2nd Half',
        de: 'Kfz-Steuer 2. Halbjahr',
      ),
      'insurance' => _t(
        tr: 'Trafik Sigortası',
        en: 'Insurance Renewal',
        de: 'Haftpflichtversicherung',
      ),
      'inspection' => _t(
        tr: 'TÜVTÜRK Muayene',
        en: 'Vehicle Inspection',
        de: 'Hauptuntersuchung (HU)',
      ),
      'global_insurance' => _t(
        tr: 'Motosiklet Sigortası',
        en: 'Motorcycle Insurance',
        de: 'Motorradversicherung',
      ),
      'global_inspection' => _t(
        tr: 'Araç Muayenesi',
        en: 'Vehicle Inspection',
        de: 'Fahrzeuginspektion',
      ),
      'road_tax' => _t(
        tr: 'Yıllık Taşıt Vergisi',
        en: 'Annual Road Tax',
        de: 'Jährliche Kfz-Steuer',
      ),
      _ => _t(
        tr: 'Diğer Ödeme / Tarih',
        en: 'Other Payment / Date',
        de: 'Andere Zahlung / Frist',
      ),
    };
  }

  // Notifications
  String get notifServiceOverdueTitle => _t(
    tr: 'Bakım Gecikti! ⚠️',
    en: 'Service Overdue! ⚠️',
    de: 'Service Überfällig! ⚠️',
  );
  String notifServiceOverdueBody(String bikeName) => _t(
    tr: '$bikeName için servis aralığı aşıldı. Lütfen bakımını kontrol et.',
    en: 'Service window exceeded for $bikeName. Please check maintenance.',
    de: 'Wartungsintervall für $bikeName überschritten. Bitte Inspektion prüfen.',
  );

  String get notifServiceSoonTitle => _t(
    tr: 'Bakım Yaklaşıyor',
    en: 'Service Window Approaching',
    de: 'Inspektion Naht',
  );
  String notifServiceSoonBody(String bikeName, int km) => _t(
    tr: '$bikeName için bakım aralığına $km km kaldı.',
    en: '$km km left until next service for $bikeName.',
    de: 'Noch $km km bis zur nächsten Inspektion für $bikeName.',
  );

  String get notifComponentWarningTitle => _t(
    tr: 'Parça Kontrolü Gerekiyor 🔧',
    en: 'Component Inspection Needed 🔧',
    de: 'Teileprüfung Erforderlich 🔧',
  );
  String notifComponentWarningBody(String components) => _t(
    tr: 'Motosikletinde yakın kontrol gerektiren parçalar var: $components.',
    en: 'Some components need close attention: $components.',
    de: 'Einige Komponenten benötigen Aufmerksamkeit: $components.',
  );

  String get notifDailyCheckTitle => _t(
    tr: 'Sürüş Öncesi Güvenlik Kontrolü 🏍️',
    en: 'Pre-Ride Checklist Reminder 🏍️',
    de: 'Pre-Ride Check Erinnerung 🏍️',
  );
  String get notifDailyCheckBody => _t(
    tr: 'Gözden geçir: Lastikler, frenler, zincir ve akü durumunu kontrol etmeyi unutma.',
    en: 'Don\'t forget to run your pre-ride safety checks on tires, brakes, and chain.',
    de: 'Vergiss nicht, vor der Fahrt Reifen, Bremsen und Kette zu prüfen.',
  );

  String get notifDocExpiryTitle => _t(
    tr: 'Belge Geçerlilik Uyarısı 📄',
    en: 'Document Expiry Warning 📄',
    de: 'Dokumentenablauf Warnung 📄',
  );
  String notifDocExpiryBody(String title, int daysLeft) => _t(
    tr: daysLeft <= 1
        ? '"$title" belgesinin geçerlilik süresi yarın doluyor.'
        : '"$title" belgesinin geçerlilik süresi $daysLeft gün içinde dolacak.',
    en: daysLeft <= 1
        ? 'The document "$title" expires tomorrow.'
        : 'The document "$title" will expire in $daysLeft days.',
    de: daysLeft <= 1
        ? 'Das Dokument "$title" läuft morgen ab.'
        : 'Das Dokument "$title" läuft in $daysLeft Tagen ab.',
  );

  String get notifTaxDueTitle => _t(
    tr: 'Ödeme Hatırlatıcısı 🧾',
    en: 'Payment Reminder 🧾',
    de: 'Zahlungserinnerung 🧾',
  );
  String notifTaxDueBody(String typeLabel, int daysLeft) => _t(
    tr: daysLeft <= 1
        ? '$typeLabel son ödeme tarihi yarın.'
        : '$typeLabel son ödeme tarihine $daysLeft gün kaldı.',
    en: daysLeft <= 1
        ? '$typeLabel is due tomorrow.'
        : '$typeLabel is due in $daysLeft days.',
    de: daysLeft <= 1
        ? '$typeLabel ist morgen fällig.'
        : '$typeLabel ist in $daysLeft Tagen fällig.',
  );

  String get notifChain => _t(tr: 'Zincir', en: 'Chain', de: 'Kette');
  String get notifTires => _t(tr: 'Lastik', en: 'Tires', de: 'Reifen');
  String get notifBrakes => _t(tr: 'Frenler', en: 'Brakes', de: 'Bremsen');
  String get notifOil => _t(tr: 'Yağ', en: 'Oil', de: 'Öl');
  String get notifBattery => _t(tr: 'Akü', en: 'Battery', de: 'Batterie');

  String get notifAchievementTitle => _t(
    tr: '🏆 Rozet Kazanıldı!',
    en: '🏆 Achievement Unlocked!',
    de: '🏆 Erfolg freigeschaltet!',
  );
  String notifAchievementBody(String name) => _t(
    tr: 'Yeni rozet kazandın: "$name"',
    en: 'You unlocked: "$name"',
    de: 'Du hast freigeschaltet: "$name"',
  );

  String get notifWeatherAlertTitle => _t(
    tr: '⚠️ Hava Durumu Uyarısı',
    en: '⚠️ Weather Alert',
    de: '⚠️ Wetterwarnung',
  );
  String get notifSevereWeatherTitle => _t(
    tr: '⚠️ Olumsuz Hava Uyarısı',
    en: '⚠️ Severe Weather',
    de: '⚠️ Unwetterwarnung',
  );
  String get notifWeatherBody => _t(
    tr: 'Bölgenizde olumsuz hava koşulları tespit edildi! Sürüş öncesi günlük kontrollerinizi yapmayı unutmayın.',
    en: 'Poor weather detected in your region! Do not forget to perform your daily readiness check.',
    de: 'Schlechtes Wetter in Ihrer Region! Vergessen Sie nicht, vor der Fahrt Ihre täglichen Kontrollen durchzuführen.',
  );
}

/// Inline translator — requires explicit [languageCode] from AppStrings instance.
/// Usage: tInline(strings.languageCode, 'TR metin', 'EN text', 'DE Text')
/// This avoids the stale static-field bug where the old currentLanguageCode
/// was read after a locale change without a widget rebuild.
String tInline(String languageCode, String trStr, String enStr, String deStr) {
  if (languageCode == 'tr') return trStr;
  if (languageCode == 'de') return deStr;
  return enStr;
}

/// @deprecated — kept for backward compatibility only. Do NOT add new calls.
/// Use tInline(strings.languageCode, ...) or strings.t(...) instead.
String tInlineLegacy(String trStr, String enStr, String deStr) {
  if (AppStrings.currentLanguageCode == 'tr') return trStr;
  if (AppStrings.currentLanguageCode == 'de') return deStr;
  return enStr;
}
