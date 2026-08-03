# ApexFlow Devlog

## 2026-07-17 — Global I18n Refactor & Dil Karmaşası Çözümü

### Yapılanlar

- **Çoklu Dil (I18n) Mimarisi Yenilemesi:**
  - Uygulama genelinde bulunan güvensiz ve esnek olmayan `tr ? 'TR' : 'EN'` ikili dil mantığı tamamen temizlendi.
  - Almanca dil desteğinin uygulamanın sadece belirli sayfalarında çalışması ve diğer yerlerde İngilizce fallback olarak kalması sorunu analiz edildi.
  - Tüm özellik modüllerinde (Dashboard, Garage, Rides, Rituals, Insights, Ayarlar vb.) 4 parametreli `tInline(lang, tr, en, de)` standardına geçildi.
  - Widget'ların yapısına göre `strings.languageCode` veya `widget.strings.languageCode` (Stateful/Stateless) kullanılarak scope/kapsam hataları titizlikle giderildi.
  - Popuplar, listeler, bildirim ekranları, onay pencereleri ve dashboard alt elementleri dahil her noktada Türkçe, İngilizce ve Almanca dilleri tamamen ve hatasız kullanılabilir hale getirildi.

### Doğrulama

- `flutter analyze` → No issues found ✅
- `flutter test` → **73/73 All tests passed** ✅

---

## 2026-07-17 — Arkadaşlar Sekmesi Yenilemesi, Radar Konum Tarayıcısı & Telefon Alan Kodu Geliştirmesi

### Yeni Özellikler

- **Arkadaşlar Sekmesi Görsel Redesign:**
  - Arayüz, paylaşılan görsel tasarıma birebir uyumlu premium koyu slate rengiyle tamamen sıfırdan yazıldı.
  - Ekli arkadaşların listesi, kendi **Rider Card** tasarımlarının minimal/kompakt haliyle entegre edildi. Arkadaş kartlarının sol kenarına, arkadaşın seçtiği kart temasının gradyan renklerini taşıyan `4px` genişliğinde dinamik dikey vurgu şeridi eklendi.
  - Rozetler/peçler, supporter tier animasyonları ve kullanıcı avatarları dinamik şekilde yansıtıldı.
  - Arama çubuğu ("Arkadaşlarda ara") ad veya rider tag bilgisine göre anlık filtreleme yapacak şekilde işlevsel hale getirildi.

- **Konum Tabanlı Sürücü Tarama (Yakınındaki Kişiler):**
  - Eski "Yakındaki sürüş grupları" butonu kaldırıldı ve yerine **"Yakınındaki Kişiler"** butonu yerleştirildi.
  - Butona tıklandığında açılan, 100 km çaptaki aktif sürücüleri tarayan, interaktif radar dalgalanma animasyonlu tam ekran bir radar pop-up'ı (`_NearbyRidersScreen`) geliştirildi.
  - Taramada bulunan sürücüler liste üzerinden "Ekle" butonuyla anlık olarak arkadaş listesine eklenebilir hale getirildi.

- **Manuel Alan Kodu Girişi (Profil Düzenleme):**
  - Profil düzenleme ekranındaki listeden alan kodu seçme modalı kaldırıldı.
  - Yerine kullanıcının kendi alan kodunu manuel olarak yazabileceği (örn: `90`, `1` vb.) metin kutusu yerleştirildi. Giriş alanının soluna otomatik olarak `+` öneki yerleştirilerek kaydetme anında veritabanı biçimlendirmesi otomatik yapıldı.

- **İkon ve Bildirim Zil Senkronizasyonları:**
  - Dashboard üzerindeki bildirim zili ikonu, profil sayfasındakiyle uyumlu olacak şekilde Badge destekli `Icons.notifications_outlined` (cyan) olarak güncellendi.
  - Sürüş başlatma ve durdurma butonlarındaki gereksiz motosiklet ikonları ve durdurma ikon çiftleri sadeleştirildi.

### Doğrulama

- `flutter analyze` → No issues found ✅
- `flutter test` → **73/73 All tests passed** ✅

---

## 2026-07-03 — Rider Hub Sosyal Özellikler, Destekçi Flex & Çoklu Dil

### Yeni Özellikler

- **Destekçi Flex Mağazası (Supporter Paywall):**
  - 3 kademe destekçi paketi: Pit Crew, Track Rider, Apex Founder
  - Her kademeye özel animasyonlu rozetler (tik, dönen elmas)
  - Destekçi teması: "Apex Supporter" — koyu siyah gradient + dev elmas vektör arka planı
  - Destekçi paketi alındığında tema otomatik seçilir, kullanıcı sonradan değiştirebilir

- **Rider Card Vektör Yenileme:**
  - Eski bisiklet (pedallı) vektör çizimleri tamamen kaldırıldı
  - Yerine `Icons.two_wheeler` motosiklet ikonu + geometrik arka plan desenleri konuldu
  - 11 farklı tema, her biri benzersiz geometrik desen (grid, topoğrafik, karbon fiber, takometre, vb.)
  - Tema 10 (Apex Destekçisi): Dev elmas logosu ile özel arka plan

- **Çoklu Dil Desteği (Almanca):**
  - Rider Hub ekranında `_t()` helper ile 3 dilli destek (TR/EN/DE)
  - Ana başlıklar, sekmeler, profil düzenleme, arkadaş ekleme ekranları Almanca çevirileri tamamlandı

- **Freemium Fiyatlandırma:**
  - ABD: $9.99, Avrupa: €9.99, Türkiye: ₺34.99
  - Destekçi paketleri uygulama fiyatından bağımsız, tamamen kozmetik

### Düzeltmeler

- Rider Card arka plan rengi artık seçilen temaya göre doğru güncelleniyor (önceden destekçi renginde kilitli kalıyordu)
- `_showEditProfileSheet` ve `_showAddFriendSheet` metodlarına `de` parametresi eklendi
- `CardVectorOverlayPainter` switch bloğu tamamen yeniden yazıldı (yapısal hata düzeltmesi)
- `SupporterPaywallScreen` navigation hatası (`widget.strings` → `strings`) düzeltildi

### Teknik Detaylar

- Rider Card tasarım spesifikasyonları: `docs/RIDER_CARD_SPECS.md`
- Avatar boyutu: radius 28px (çap 56px)
- Kart köşe yuvarlaklığı: 9px
- Vektör overlay: 0.08 alpha stroke, 1.2px kalınlık

---


## 2026-06-29 - UI Polish, Global Design & Phase 7 Hazırlığı

### Yapılanlar

- **Hava Durumu Seçim Ekranı — Modern Liste Redesign:**
  - Şehir seçim panelindeki kutucuk (Wrap grid) yapısı kaldırıldı.
  - Her şehir için; solda beyaz daireli ülke bayrağı emojisi, ortada kalın şehir adı ve sağda chevron oku bulunan tam genişlikte dikey liste yapısına geçildi (`_buildCityListTile`).
  - Arama ve gruplu kategori görünümlerinin ikisi de aynı liste stilini kullanacak şekilde güncellendi.

- **Rider ID Card — Global Plaka Tasarımı:**
  - Sürücü kartındaki sabit `TR` (Türkiye) plaka ibaresi kaldırıldı.
  - Uygulamanın global kimliğini yansıtmak üzere yerine `Icons.public_outlined` (beyaz dünya/küre simgesi) yerleştirildi.

- **Garaj Harcama Paneli — Slate-200 Renk Revizyonu:**
  - `_StatMiniPanel` bileşenlerinin arka planı `Slate-200` (`#E2E8F0`) beton grisi tonuna geçirildi.
  - Yazı renkleri `Slate-900` (`#1E293B`) koyu tona güncellendi; 0 TL değerleri mat gri (`#64748B`) ile gösteriliyor.
  - Boş durum açıklama paragrafı kaldırıldı.

- **Lobi Kodu Kontrast Düzeltmesi:**
  - `group_ride_lobby_screen.dart` içindeki lobi kodu `SelectableText` rengi beyazdan koyu slate (`#0F172A`) rengine çekildi.

- **Hava Durumu Bottom Sheet Modernizasyonu:**
  - Drag handle (sürükleme kulbu), Slate-200 search bar, soft kırmızı hata kartı eklendi.
  - Her şehir seçeneğine `countryCode` ile dinamik bayrak emojisi entegre edildi.

- **QR Sticker ve PDF Tasarım Güncellemeleri:**
  - Tüm sticker/PDF şablonları (`park_sticker_pdf.dart`, `circular_sticker_pdf.dart`) Slate-200 (`#E2E8F0`) arka plana güncellendi.
  - QR stickerlardan motosiklet adı kaldırıldı (sade, global tasarım).

- **Splash Screen Animasyon Kalitesi:**
  - Splash screen tasarım elementleri yeniden konumlandırıldı; animasyon ajans kalitesine yükseltildi.

- **Uygulama Bildirimi İyileştirmeleri:**
  - Bildirim ikonu `apexflow_brand_icon` olarak güncellendi.
  - Bildirim uygulama adı "Apex Flow" (iki kelime) olarak ayarlandı.
  - Park irtibat bildirimleri sisteme düşürecek şekilde düzeltildi.

- **Test Güncellemeleri:**
  - Widget test kaydırma sorunları `tester.ensureVisible` ile stabilize edildi.
  - Test sayısı 60'tan **73**'e çıktı — tamamı yeşil.

- **Dokümantasyon Güncellemesi:**
  - `README.md`, `HANDOFF_FOR_AI.md`, `DEVELOPER_GOALS.md`, `ROADMAP_PHASES.md` uygulamanın mevcut v1.0 RC durumuna göre tamamen güncellendi.

### Doğrulama

- `flutter analyze` → No issues found ✅
- `flutter test` → **73/73 All tests passed** ✅
- LG G5 (Android 8.0) cihazda USB debug ile doğrulandı ✅

---

## 2026-06-24 - Phase 5 & 6: Feature Completion & Integration


### Yapılanlar

- **Garage Passport PDF Desteği:**
  - `GaragePassportPdfService` ile pasaport bilgilerini PDF formatına dönüştürme ve `share_plus` kullanarak cihazda paylaşma özelliği eklendi.
- **Çoklu Motosiklet Desteği & State Mutations:**
  - Garaj içindeki aktif motosiklet geçişleri ve motosiklet durum güncellemeleri doğrulandı ve eksiksiz çalışır hale getirildi.
- **Document Vault Pro Son Kullanma Tarihi & Bildirimler:**
  - Evrak kasası içindeki belgelerin son geçerlilik tarihlerinin yönetimi ve bitiş tarihinden 30 gün önce yerel bildirim tetiklenmesi entegre edildi.
- **Digital SOS/Emergency Card & Home Screen Widget:**
  - Kullanıcı profilinden SOS/Acil durum bilgilerinin Android `SharedPreferences` ve `home_widget` aracılığıyla ana ekran widget'ları ile senkronizasyonu sağlandı.
- **Group Ride Party Lobby:**
  - Toplu sürüş lobisi ekranı, simüle edilmiş arkadaş katılımları ve `share_plus` ile lobi davet linki paylaşımı tamamlandı.
- **Smart Local Notifications & Android Widgets:**
  - `NotificationScheduler` ve `EmergencyWidgetProvider.kt` aracılığıyla yerel bildirimler ve Android widget altyapısı aktifleştirildi.
- **Test ve Analiz:**
  - `garage_passport_test.dart`, `document_vault_test.dart` ve `widget_test.dart` ile entegrasyon testleri yazılarak tüm 60+ testin yeşil olduğu doğrulandı.

### Doğrulama

- `flutter analyze` -> No issues found ✅
- `flutter test` -> 60/60 All tests passed ✅

---

## 2026-06-11 - Phase 5: Low-Friction UX Refinements

### Yapılanlar

- **Low-Friction UX Geliştirmeleri (Kullanıcı Girdisini Azaltma):**
  - **Galeriden Fiş Seçme:** Fiş okuma ekranına [receipt_scan_screen.dart](file:///e:/ApexFlow/ApexFlow/lib/fuel/presentation/receipt_scan_screen.dart) galeri butonu eklendi. `image_picker` paketi kullanılarak galeriden seçilen görseller doğrudan mevcut OCR/Ayrıştırıcı akışına beslenebilir hale getirildi.
  - **Otomatik Sürüş Süresi:** `RideState`'e `rideStartedAtIso` zaman damgası eklendi [ride_state.dart](file:///e:/ApexFlow/ApexFlow/lib/rides/application/ride_state.dart). Sürüş bitirilirken [rides_screen.dart](file:///e:/ApexFlow/ApexFlow/lib/rides/presentation/rides_screen.dart) geçen süre otomatik hesaplanarak "Süre" alanına varsayılan olarak yazılması sağlandı.
  - **Tahmini Yakıt Kilometresi:** Son yakıt alımından sonra yapılan tüm sürüşlerin mesafeleri toplanarak yakıt girişi sayfasında kilometre alanına otomatik tahmin edilen değer yerleştirildi [fuel_screen.dart](file:///e:/ApexFlow/ApexFlow/lib/fuel/presentation/fuel_screen.dart).
  - **Dashboard Hızlı Günlük Kontrol:** Dashboard ekranında [apex_dashboard_screen.dart](file:///e:/ApexFlow/ApexFlow/lib/features/dashboard/apex_dashboard_screen.dart) eğer günlük kontrol yapılmadıysa görünecek "Hızlı Kaydet" butonu eklendi. Tek dokunuşla bugünkü tüm ritüel kontrol listesi "hepsi temiz" olarak arka planda kaydedilir.
  - **low_friction_ux_test.dart:** Yazılan tüm akıllı tahmin ve otomasyon mantığı için unit ve entegrasyon testleri yazıldı.

### Doğrulama

- `flutter analyze` -> No issues found ✅
- `flutter test` -> 51/51 All tests passed ✅

---

## 2026-06-11 - Phase 5: Garage Passport

### Yapılanlar

- **Garage Passport (Paylaşılabilir Bakım Geçmişi Profili) Entegrasyonu:**
  - `GaragePassport` domain modeli (`garage_passport.dart`) oluşturuldu: Motosiklet profili, servis geçmişi, sürüş istatistikleri ve Harmony Score verilerini bir araya getirir.
  - `toShareableText()` metodu ile pasaport verilerini hem Türkçe hem de İngilizce olarak paylaşılabilir düz metin biçimine dönüştürme desteği eklendi.
  - `GarageController.buildPassport()` metodu yazıldı: Aktif motosiklet verilerini ve ilişkili servis/sürüş kayıtlarını toplayarak pasaport nesnesini dinamik olarak üretir.
  - `GaragePassportScreen` (`garage_passport_screen.dart`) ekranı oluşturuldu: Makine Kimliği, Harmony Durumu, Parça Kondisyonu, Bakım Penceresi, Sürüş İstatistikleri ve Servis Geçmişi timeline'ını premium ApexPanel kart tasarımıyla görüntüler.
  - AppBar'a `share_plus` entegrasyonu ile "Paylaş" aksiyonu yerleştirildi.
  - `GarageScreen` komutlar paneline ("Garaj komutları") 5. buton olarak "Garaj Pasaportu" (`Icons.badge_outlined`) eklendi ve ekranlar arası navigasyon sağlandı.
  - Yeni çeviri anahtarları `app_strings.dart` dosyasına TR ve EN dillerinde eklendi.
  - `garage_passport_test.dart` ile unit ve entegrasyon testleri (veri formatlama, boş liste sınır durumları ve provider entegrasyonu) yazıldı.

### Doğrulama

- `flutter analyze` -> No issues found ✅
- `flutter test` -> 47/47 All tests passed ✅

---

## 2026-06-11 - Phase 5 Opening: Ride-to-Maintenance Intelligence

### Yapılanlar

- **Ride-to-Maintenance Intelligence (Sürüş → Garaj Otomatik Etki):**
  - `GarageController.applyRideImpact()` metodu eklendi: sürüş mesafesi ve ruh haline göre zincir, lastik, fren, yağ ve batarya bileşenlerini otomatik günceller.
  - Agresif/sportif/hızlı ruh halleri 1.5x aşınma çarpanı uygular (TR ve EN destekli).
  - Kilometre sayacı otomatik artar, batarya uzun sürüşlerde şarj olur.
  - `RideController.endRide()` artık `applyRideImpact()` çağırarak sürüş verilerini garaja aktarır.
  - 11 birim testi yazıldı ve geçti (`ride_to_maintenance_test.dart`).

- **Dokümantasyon & Backlog Güncellemeleri:**
  - `ROADMAP_PHASES.md`: Phase 5 (Intelligence & Persistence) ve Phase 6 (Notifications & Widgets) eklendi.
  - `HANDOFF_FOR_AI.md`: Milestone, ürün fikirleri ve eksik alanlar güncellendi.
  - `DEVELOPER_GOALS.md`: Smart Local Notifications detayları eklendi.
  - `app_strings.dart`: 5 yeni özellik için çeviri anahtarları eklendi.

### Doğrulama

- `flutter analyze` → No issues found
- `flutter test` → 43/43 All tests passed

---

## 2026-06-11 - Phase 4 Zero-Friction UX Completion

### Yapılanlar

- **Otomatik Sürüş Algılama (Automatic Ride Detection) Altyapısı:**
  - `RideDetectionState` ve `RideDetectionController` (`NotifierProvider`) eklendi.
  - Ayarlar sekmesine "Otomatik Sürüş Algılama" seçeneği ve test/doğrulama için Bluetooth / cihaz hareketi simülasyon anahtarları yerleştirildi.
  - Sürüş algılandığında Dashboard'un en üstünde beliren ve sürüşü tek dokunuşla başlatan premium uyarı paneli entegre edildi.
  - `ride_detection_test.dart` ile birim testleri (hydration, persistence, trigger ve dismiss) yazıldı.
- **Günlük Kontrol Düşük Girdi Optimizasyonu:**
  - Günlük kontrol sayfasına hepsi taze/temiz durumlar için tek dokunuşla kaydetme seçeneği sunan "Tek Tıkla Kaydet: Hepsi Temiz" butonu eklendi.
- **Kod Temizliği ve Doğrulama:**
  - Switch listelerinde kullanılan artık desteği sonlanmış `activeColor` parametresi `activeThumbColor` ile değiştirildi.
  - `flutter analyze` ve `flutter test` adımları çalıştırılarak tüm 32 testin başarıyla geçtiği doğrulandı.

## 2026-05-31 - Ride Readiness Signal Connection

### Yapılanlar

- `ride_readiness_model.dart` eklendi; readiness artık Harmony score, Weather snapshot ve bugünün Daily Check kaydını birlikte değerlendiriyor.
- Hava riski, rüzgar, sıcaklık ve günlük kontrol eksikleri readiness skoruna hafif ve açıklanabilir delta olarak yansıyor.
- Ride Readiness ekranına `Readiness factors` paneli eklendi.
- Türkçe karşılıklar UI içinde korundu; sinyal dili sakin ve teknisyen tonu ile tutuldu.
- Readiness modeli için unit test eklendi.
- Roadmap'te Phase 3 `Ride readiness surface` tamamlandı.

### Doğrulama

```sh
flutter analyze
flutter test
```

Durum:

- `flutter analyze`: temiz.
- `flutter test`: başarılı.

## 2026-05-31 - Loading, Empty State + Phase 3 Unlock

### Yapılanlar

- Ortak `ApexStatePanel` eklendi; async hydration ve boş durumlar sakin, tekrar kullanılabilir bir panelle gösteriliyor.
- Dashboard, Garage, Rides, Machine Memory, Fuel, Insights, Ride Readiness ve Daily Machine Check yüzeylerine loading/empty state pass uygulandı.
- Ride hydration içinde aktif sürüş olup session listesi boşsa `isHydrating` değerinin açık kalmasına neden olan edge case düzeltildi.
- Dar mobil genişlikte dashboard metrik kartı overflow'u giderildi.
- 390px viewport için Home, Garage, Machine Memory ve Rides smoke testi eklendi.
- Phase 1 loading/empty checklist maddeleri ve Phase 2 checklist tamamlandı.
- `PHASE_LOCK.md` Phase 3 — Ride Ritual System olarak güncellendi.

### Doğrulama

```sh
flutter analyze
flutter test
```

Durum:

- `flutter analyze`: temiz.
- `flutter test`: başarılı.

## 2026-05-31 - Harmony Engine Consistency Pass

### Yapılanlar

- Harmony Engine servis cezasını artık `serviceProgress` ve overdue durumuna göre hesaplıyor.
- Parça aşınması zincir, lastik ve freni birlikte okuyacak şekilde dengelendi.
- Son sürüşteki mekanik gözlem notları zincir, fren, lastik ve yağ sinyallerini etkiliyor.
- Dashboard harmony insight metni artık engine'den gelen spesifik sinyali kullanıyor; Türkçe karşılıkları eklendi.
- Harmony Engine için hedefli unit test eklendi.
- Roadmap ve AI handoff güncellendi.

### Doğrulama

```sh
flutter analyze
flutter test
```

Durum:

- `flutter analyze`: temiz.
- `flutter test`: başarılı.

## 2026-05-31 - Maintenance Tracking Polish

### Yapılanlar

- `MotorcycleProfile` modeline `serviceIntervalKm` eklendi.
- `kmSinceService`, `kmUntilService`, `serviceProgress` ve `serviceWindowState` hesapları domain modeline taşındı.
- Garage ekranına bakım aralığı paneli eklendi; kullanıcı stable, due soon ve overdue durumlarını net şekilde görebilir.
- Servis aralığı state'i legacy JSON kayıtları için 6000 km fallback ile korunuyor.
- State ve widget testleri bakım aralığı davranışını doğrulayacak şekilde genişletildi.
- Roadmap, README ve AI handoff güncellendi.

### Doğrulama

```sh
flutter analyze
flutter test
```

Durum:

- `flutter analyze`: temiz.
- `flutter test`: başarılı.

## 2026-05-31 - Machine Memory Unified Timeline

### Yapılanlar

- Servis ve sürüş domain kayıtlarına `loggedAtIso` zaman damgası eklendi; eski kayıtlar legacy fallback ile okunmaya devam eder.
- Yeni servis ve sürüş kayıtları oluşturulurken UTC zaman bilgisi state'e yazılıyor.
- Machine Memory ekranı servis ve sürüşü ayrı bölümlerde göstermek yerine tek birleşik timeline olarak yeniden düzenlendi.
- Günlük makine kontrolü kayıtları da aynı timeline içinde hafif gözlem kaydı olarak gösteriliyor.
- Timeline için servis/sürüş/daily check sayaçları ve empty state eklendi.
- Widget testlerine Machine Memory'nin servis ve sürüş kayıtlarını aynı hafızada gösterdiğini doğrulayan senaryo eklendi.
- Roadmap ve handoff dokümanları güncellendi.

### Doğrulama

```sh
flutter analyze
flutter test
```

Durum:

- `flutter analyze`: temiz.
- `flutter test`: başarılı.

## 2026-05-31 - Garage State Consistency Pass

### Yapılanlar

- `MotorcycleProfile` için kalıcı `id` alanı eklendi; eski kayıtlardan gelen veriler için legacy id fallback sağlandı.
- Garage controller aktif motosiklet güncellemelerini artık liste sırasına veya object identity'ye değil, stable id'ye göre yapıyor.
- Servis kaydı ve parça sağlığı güncellemeleri seçili motosikletle sınırlı hale getirildi.
- Arşivden çıkarılan motosikletlerin tekrar seçilmesi id üzerinden güvenli hale getirildi.
- Async hydration sonrası dispose edilmiş provider'a state yazılmasını önlemek için provider'lara `ref.mounted` kontrolü eklendi.
- Garage state için hedefli test dosyası eklendi.
- README, AI handoff ve roadmap dosyaları güncel ürün durumuna yaklaştırıldı.

### Doğrulama

```sh
flutter analyze
flutter test
```

Durum:

- `flutter analyze`: temiz.
- `flutter test`: başarılı.

## 2026-05-28 - Insights Expansion + Turkish Localization

### Yapılanlar

- Insights sekmesi placeholder durumdan gerçek ürün ekranına taşındı.
- Aşağıdaki modüller eklendi:
  - Maintenance calendar
  - Cost ledger
  - Problem pattern detection
  - Parts wishlist (link destekli, yeni parça ekleme formu ile)
  - Fuel / consumption snapshot
  - Tire pressure log
  - Document vault
  - Trip packing checklist
  - Inspection mode
  - Service estimate planner
  - Route memory
  - Seasonal storage mode
  - Incident log
- Settings ekranına dil seçici eklendi (`English` / `Türkçe`).
- Uygulama fontları `Noto Sans` ile Türkçe karakter uyumlu hale getirildi.
- Shell navigation metinleri locale seçimine göre dinamik hale getirildi.

### Karar

Kullanıcının istediği backlog fikirleri dokümana kalıcı olarak kaydedildi; bu alanlar bir sonraki persistence ve premium fazları için temel veri yüzeyi olarak korunacaktır.

## 2026-05-28 - Product Backlog Direction

### Kaydedilen Fikirler

- `Ride-to-Maintenance Intelligence` ürün yönü eklendi.
  - Sürüş kayıtları yalnızca log olarak kalmayacak; bakım etkisine çevrilecek.
  - Örnek içgörüler: agresif kullanımın zincir bakım aralığını öne çekmesi, sıcak/düşük hızlı kullanımın yağ sağlığına etkisi, tekrar eden fren/lastik gözlemlerinin risk sinyaline dönüşmesi.
  - Insights sekmesi risk timeline, bakım tahmini, parça bazlı kondisyon ve next best action kartlarıyla ürünleştirilecek.
- `Garage Passport` ürün fikri eklendi.
  - Her motosiklet için paylaşılabilir bakım geçmişi profili planlanacak.
  - Servis kayıtları, parça değişimleri, kilometre geçmişi ve kondisyon trendleri satış/ekspertiz çıktısına hazır hale getirilecek.

### Tasarım Kararı

Bu özellikler AI bağımlı bir sohbet deneyimi gibi değil, güvenilir teknisyen diliyle çalışan premium motosiklet bakım zekası olarak tasarlanmalıdır.

## 2026-05-27 - Documentation Handoff Baseline

### Mevcut Uygulama Durumu

- Flutter + Riverpod tabanlı uygulama iskeleti mevcut.
- `ApexFlowApp` koyu tema ve `ApexAppShell` ile başlıyor.
- Dashboard ekranı ürünün ana deneyimini gösteriyor:
  - ApexFlow başlığı ve "Machine Relationship OS" konumlandırması.
  - Motorcycle profile örneği: `NIGHT VECTOR`, Yamaha MT-07.
  - Machine Harmony skoru ve seviyeleri.
  - CustomPainter tabanlı procedural motorcycle blueprint.
  - Odometer, service delta, oil health ve battery metrikleri.
  - Quick action grid.
  - Latest ride ritual paneli.
  - Maintenance signals paneli.
  - Google Chrome preview constraint notu.
- `HarmonyEngine` bakım, aşınma, yağ, batarya ve sürüş yumuşaklığı üzerinden skor üretiyor.
- `MotorcycleProfile` ve `RideSession` domain modelleri başlangıç seviyesinde mevcut.
- Garage, Rides, Insights ve Settings sekmeleri henüz gerçek özellik ekranı değil; placeholder durumdadır.

### Kalite Durumu

Son doğrulama:

```sh
flutter analyze
flutter test
```

Durum:

- `flutter analyze`: temiz.
- `flutter test`: başarılı.

### Devam Notu

Bir sonraki anlamlı ürün adımı Garage MVP'dir. Çünkü gerçek motosiklet profilleri, bakım kayıtları ve parça sağlığı Dashboard ile Harmony Engine'in veri temelini oluşturacaktır.

## 2026-05-27 - Garage MVP Başlangıcı

### Yapılanlar

- Garage placeholder ekranı gerçek Garage ekranıyla değiştirildi.
- Aktif motosiklet, ikinci kayıtlı motosiklet, servis hafızası ve component status verileri için `garageStateProvider` eklendi.
- Dashboard state artık kendi içinde sabit motosiklet verisi üretmek yerine Garage state'inden aktif motosikleti ve son sürüşü okuyor.
- Garage ekranında active machine paneli, garage commands, component grid, service memory ve local-first hazırlık paneli gösteriliyor.
- Widget testlerine Garage sekmesinin ürünleştiğini doğrulayan senaryo eklendi.

### Sonraki Adım

Garage MVP'nin devamında servis kaydı ekleme/güncelleme akışı ve Isar tabanlı offline persistence katmanı kurulmalıdır.

## 2026-05-27 - Garage Service Entry Flow

### Yapılanlar

- `garageStateProvider`, salt okunur provider yerine `NotifierProvider` tabanlı Garage controller'a dönüştürüldü.
- Garage ekranındaki `SERVICE ENTRY` komutu gerçek bir bottom sheet formu açıyor.
- Form servis etiketi, odometer ve mekanik not alıyor.
- Kaydedilen servis girdisi `SERVICE MEMORY` listesinin başına `NEW LOG` olarak ekleniyor.
- Aktif motosikletin `lastServiceKm` alanı güncelleniyor; servis delta Dashboard ve Garage üzerinde aynı state üzerinden değişiyor.
- Widget testlerine servis girişi senaryosu eklendi.

### Sonraki Adım

Garage akışında sıradaki ürün adımı odometer güncelleme ve component health editing kontrolleridir. Ardından bu state Isar persistence katmanına taşınmalıdır.

## 2026-05-27 - Garage Part Status Sync

### Yapılanlar

- Garage controller'a component health update davranışı eklendi.
- `PART STATUS` komutu zincir, lastik, fren, yağ ve batarya değerlerini güncelleyen bottom sheet formuna bağlandı.
- Girilen değerler 0-100 aralığına clamp edilerek aktif motosiklet modeline yazılıyor.
- Component grid, güncellenen health/wear değerlerini aynı state üzerinden yeniden render ediyor.
- Widget testlerine part status güncelleme senaryosu eklendi.

### Sonraki Adım

Garage state artık etkileşimli hale geldi. Sıradaki büyük teknik adım Isar tabanlı local persistence kurmak; sıradaki ürün adımı ise Ride Ritual MVP'yi gerçek kayıt akışına bağlamak.

## 2026-05-27 - Visual Direction Correction

### Yapılanlar

- Dashboard'daki procedural neon blueprint motosiklet görseli kaldırıldı.
- Kullanıcının verdiği `MtrcyclVec.png` görseli `assets/images/motorcycle_vector.png` olarak projeye eklendi.
- Dashboard motosiklet alanı görsel asset'i orantılı ve sakin bir panel içinde gösterecek şekilde düzenlendi.
- Uygulama renkleri karanlık neon/cyberpunk görünümden çıkarılıp açık, nötr ve normal tonlara alındı.
- Shell seviyesinde sağlık skoruna bağlı çok hafif alt underlay eklendi; renk navbar arkasından yukarı doğru düşük opacity ile yayılır.

### Tasarım Kararı

Kullanıcı açıkça neon, futuristik ve gelecekten gelmiş gibi görünen tasarım istemediğini belirtti. Bundan sonraki UI kararları bu yönde alınmalıdır.

## 2026-05-27 - Ride Ritual MVP

### Yapılanlar

- Rides placeholder ekranı gerçek Rides ekranına dönüştürüldü.
- `rideStateProvider`, aktif sürüş durumu ve ride memory listesini yöneten controller olarak eklendi.
- `START RIDE` akışı ride mood alarak aktif sürüş başlatıyor.
- `END REFLECTION` akışı mesafe, süre, ortalama hız, mood ve mekanik gözlem alarak yeni ride session kaydı oluşturuyor.
- Dashboard latest ride verisi artık Ride state üzerinden okunuyor.
- Widget testlerine ride ritual başlatma ve end reflection kaydetme senaryosu eklendi.

### Sonraki Adım

Bir sonraki ürün adımı Insights MVP'dir. Harmony score ve Garage/Ride verileri kullanıcıya sade risk sinyalleri olarak açıklanmalıdır.

## 2026-05-27 - Visual Refinement Pass

### Yapılanlar

- Renk sistemi daha kontrastlı ama neon olmayan modern doğal tonlara güncellendi.
- Monospace font kullanımı kaldırıldı; uygulama sistem fontlarına döndü.
- Panel radius değeri 8px'e çıkarıldı ve yüzeylere çok hafif, doğal gölge eklendi.
- Birincil aksiyon butonları daha net filled accent yapıya taşındı.
- Dashboard ve sekme alt metinlerinde fazla yapay/futuristik görünen ifadeler sadeleştirildi.

### Tasarım Kararı

UI dili sade, modern ve kullanıcı güvenini artıran bir motosiklet uygulaması gibi kalmalıdır. Neon, cyberpunk ve aşırı konsept metinlerden kaçınılmalıdır.
