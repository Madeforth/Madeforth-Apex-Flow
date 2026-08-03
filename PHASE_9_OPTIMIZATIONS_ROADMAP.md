# Phase 9: Core Optimizations & Scalability Roadmap

Bu yol haritası, uygulamanın mimari darboğazlarını çözmek, batarya tüketimini azaltmak, i18n (çoklu dil) altyapısını güçlendirmek ve Harmony Engine'i gerçek telemetri verisiyle buluşturmak için tasarlanmıştır. Yarıda kalması durumunda buradan devam edilebilir.

## 🟢 Item 1: Background Service & Wakelock (Batarya ve Arkaplan)
- **Problem:** GPS konum takibi ve Telemetri hesaplamaları ekran kapalıyken işletim sistemi tarafından (iOS/Android) 15-20 dakika içinde öldürülebilir.
- **Çözüm:** `flutter_background_service` veya Android için `Foreground Service` (kalıcı bildirim) mekanizması kurulacak. iOS için `UIBackgroundModes` location ayarları netleştirilecek. Sürüş başladığında uygulama işletim sistemine "Kapatma beni" diyecek.
- **Dosyalar:** `AndroidManifest.xml`, `Info.plist`, `ride_location_service.dart`.

## 🟢 Item 2: Harmony Engine Telemetry Integration (Makine Ruhu)
- **Problem:** `HarmonyEngine` şu an sürücünün "Sakin", "Agresif" gibi metin tabanlı (mood) seçimine güvenerek ceza/puan veriyor.
- **Çözüm:** `RideSession` içerisindeki `maxSpeedKmh`, `maxLeanAngle`, `hardAccelerations` ve `hardBrakes` alanları doğrudan kullanılacak. Eğer `maxLeanAngle > 45` veya `hardBrakes > 3` ise Harmony Engine bunu gerçek bir "Agresif Sürüş" sayıp zincir/fren balatası aşınmasını (wear penalty) ikiye katlayacak.
- **Dosyalar:** `harmony_engine.dart`, `ride_location_service.dart` (Hard brake/accel hesaplaması için).

## 🟢 Item 3: i18n Architecture Migration (Çoklu Dil Altyapısı)
- **Problem:** Şu an kodun her yerinde `tInline(strings.languageCode, 'TR', 'EN', 'DE')` şeklinde satır içi if-else mantığıyla çeviri yapılıyor. Yeni dil eklendiğinde yüzlerce dosyanın güncellenmesi gerekir.
- **Çözüm:** `slang` veya Flutter'ın kendi lokalizasyon (`app_tr.arb`, `app_en.arb`) altyapısına geçilecek.
- **Dosyalar:** Tüm `presentation` dosyaları ve `pubspec.yaml`. *(Not: Bu çok büyük bir refactoring işlemidir, diğerlerinden ayrı yapılmalıdır).*

## 🟢 Item 4: Telemetry Isolate Throttling (Veri Darboğazı)
- **Problem:** `telemetry_isolate.dart`, jiroskoptan veri geldiği milisaniye arayüze (UI thread) mesaj atıyor. Bu saniyede ~100 mesaj demek ve cihazı ısıtır.
- **Çözüm:** Isolate içinde bir `Timer` veya `Buffer` tutulacak. Saniyede sadece 5 kez (5Hz, her 200ms'de bir) en güncel telemetri paketi ana iş parçacığına (SendPort) gönderilecek. 
- **Dosyalar:** `telemetry_isolate.dart`.

## 🟢 Item 5: Weather API Caching (Hava Durumu Önbelleği)
- **Problem:** Sürüş hazırlık ekranına her girildiğinde Open-Meteo API'sine HTTP isteği atılıyor.
- **Çözüm:** `shared_preferences` kullanılarak son çekilen hava durumu, lokasyon (enlem/boylam) ve saat ile birlikte kaydedilecek. Son istekten bu yana 30 dakika geçmediyse ve konum 5 km'den fazla değişmediyse API'ye istek atmak yerine hafızadaki veri kullanılacak.
- **Dosyalar:** `weather_service.dart`.
