# ApexFlow AI Handoff

Bu belge, ApexFlow projesini devralan başka bir yapay zeka veya geliştirici için hızlı başlangıç bağlamıdır.

## Proje Amacı

ApexFlow; motosiklet bakım zekası, sürüş günlüğü, makineyle duygusal bağ ve AI destekli içgörüleri birleştiren premium Flutter uygulamasıdır. Normal bir maintenance tracker değil, **"living machine relationship ecosystem"** ve **"machine relationship OS"** olarak tasarlanmıştır.

## Ana Kaynak

Ana ürün ve mimari kaynak:

```text
docs/APEXFLOW_ULTIMATE_PRODUCT_ARCHITECTURE.txt
```

Bu dosya product bible olarak kabul edilir. Yeni kararlar bu belgedeki yönle çelişmemelidir.

## Mevcut Teknik Durum (v1.2 — Temmuz 2026)

- **Framework:** Flutter (Dart)
- **State Management:** Riverpod
- **Tema:** Custom premium koyu slate tasarım sistemi (ApexColors, ApexTheme)
- **Ana giriş:** `lib/main.dart`
- **Shell/Navigation:** `lib/features/shell/apex_app_shell.dart`
- **Dashboard:** `lib/features/dashboard/apex_dashboard_screen.dart`
- **Splash Screen:** `lib/features/splash/presentation/apex_splash_screen.dart`
- **Harmony Engine:** `lib/harmony_engine/harmony_engine.dart`
- **Garage domain modeli:** `lib/garage/domain/motorcycle_profile.dart`
- **Ride domain modeli:** `lib/rides/domain/ride_session.dart`
- **Shared panel component:** `lib/shared/widgets/apex_panel.dart`
- **Bildirimler:** `lib/notifications/apex_notification_service.dart`

## Çalışan Özellikler (Tüm Phase 1-7 Tamamlandı)

- Dashboard render + Harmony Score hesabı
- Çoklu motosiklet Garage: profil, servis, parça durumu, Machine Memory timeline
- Ride Start → End Reflection kayıt akışı
- Ride Readiness: Harmony + Weather + Daily Check skorlaması
- Weather Intelligence: şehir seçimi (modern liste UI), OpenMeteo API entegrasyonu
- Fuel Tracker + Fiş OCR (receipt scan)
- Insights + harcama analitiği (servis/yakıt grafikleri, `_StatMiniPanel`)
- Ride-to-Maintenance Intelligence (sürüş → otomatik parça aşınması)
- Garage Passport PDF + paylaşım
- Park QR Sticker PDF + Circular Sticker PDF
- Certified Ledger PDF
- Ride Vibe PDF + Ride Invite PDF
- Document Vault Pro (son kullanma bildirimi, 30 gün önceden)
- Digital SOS / Emergency Card
- Android Home Screen Widget (EmergencyWidgetProvider)
- Group Ride Party Lobby (lobi kodu, davet linki, simüle katılımlar, gerçek telemetri)
- Smart Local Notifications (`flutter_local_notifications` + cyan bildirim Badge)
- Rider ID Card (11 tema, destekçi efektleri, peçler, özelleştirilebilir sürücü kartları)
- Arkadaşlar Sekmesi (minimal Rider Card tasarımları, arama filtresi, tam ekran istekler yönetimi)
- Yakınındaki Kişiler Tarayıcısı (100 km çapta radar animasyonlu aktif sürücü tarama)
- Manuel alan kodu girişi ve otomatik '+' formatı (Profil düzenleme)
- QR Kod Tarayıcı (`qr_scanner_screen.dart`)
- Animasyonlu Splash Screen
- Premium Paywall ekranı
- Türkçe / İngilizce / Almanca dil desteği (runtime switch)
- Offline-first veri katmanı (`ApexKvStore` → `SharedPreferences`)
- Firebase Auth + Firestore cloud sync

## Test Durumu

**73 test — tamamı ✅ yeşil**

```sh
flutter test     # → 73/73 All tests passed
flutter analyze  # → No issues found
```

## Tasarım Kuralları

- Generic Material görünümden kaçın.
- Neon, cyberpunk tema yapma.
- Sakin, koyu slate, premium, motosiklet odaklı, günlük kullanılabilir arayüz dili.
- Renk paleti: Koyu slate (`#0B1528` ve `#0F172A`), panel arka planı (`#1E293B`), Cyan vurgu.
- 8pt spacing, küçük radius (4-6), haptic feedback.
- Glow, agresif gradient, glassmorphism, büyük radius ve template hissinden kaçın.
- Rider Card listelerinde, arkadaşların minimal card tasarımlarını gösterirken sol kenarda renk gradyanlı çizgiler kullan.
- Alan kodları gibi kritik telefon veri girişlerinde manuel yazımı kolaylaştır ve önekleri sistemde otomatik biçimlendir.

## Sonraki Milestone

**Google Play Store & Apple App Store gönderimi**

- Android App Bundle (`flutter build appbundle --release`) derle
- Play Console'a yükle, mağaza listesini hazırla
- iOS için TestFlight süreci başlat
- Apple App Store Review Guidelines uyumluluk kontrolü

## Doğrulama Komutları

```sh
flutter analyze
flutter test
flutter run -d <device_id>
```
