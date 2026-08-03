# ApexFlow - iOS Derleme ve Kurulum Notları

Bu dosya, projenin gerçek bir iOS cihazında (iPhone) çalıştırılması sırasında karşılaşılan karmaşık macOS ve iOS hatalarının nasıl çözüldüğünü belgelemek amacıyla oluşturulmuştur. İleride benzer hatalarla karşılaşıldığında bu adımlar referans alınmalıdır.

## 1. Masaüstü (Desktop) iCloud Senkronizasyon Sorunu ve Karantina (Detritus)
**Hata:**
`Target release_unpack_ios failed: Exception: Failed to codesign Flutter.framework... resource fork, Finder information, or similar detritus not allowed`

**Nedeni:**
Projenin bilgisayarda bulunduğu `Masaüstü (Desktop)` klasörü, macOS'un yerleşik iCloud Drive özelliği ile eşzamanlanıyordu. Xcode, projeyi derlerken (build) klasör içine yeni dosyalar (örneğin Flutter.framework) oluşturduğunda, iCloud bu dosyaları saniyesinde fark edip eşzamanlamak için üzerlerine gizli Apple Finder etiketleri (`com.apple.FinderInfo`, `com.apple.metadata`) yapıştırıyordu. Code-signing (imzalama) işlemi, dosyanın üzerinde sonradan eklenmiş bu "yabancı/karantina" etiketleri görünce güvenlik gereği işlemi anında iptal ediyordu.

**Çözüm:**
* `xattr -cr` komutlarıyla karantina etiketlerini temizlemek tek başına yetersiz kaldı çünkü iCloud her derlemede etiketleri anlık olarak tekrar ekliyordu.
* Proje, iCloud'un erişemediği ve eşzamanlama yapmadığı **`~/Developer`** (Geliştirici) klasörüne taşındı. Bu sayede iOS derleme ve imzalama işlemi hiçbir müdahaleye uğramadan başarıyla tamamlandı.

## 2. iOS "Duplicate plugin key" (Anında Kapanma / Crash) Hatası
**Hata:**
Uygulama başarıyla cihaza kurulduktan sonra ikona tıklandığında anında kapanıyor. Debug loglarında şu hata belirdi:
`*** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'Duplicate plugin key: CameraPlugin'`

**Nedeni:**
Projede kullanılan `home_widget` eklentisi, arka planda veri güncellemek için uygulamanın "görünmez bir kopyasını" (Background Engine) çalıştırmaya çalışıyordu. `ios/Runner/AppDelegate.swift` dosyasında `FlutterImplicitEngineDelegate` tanımlanmıştı.
Ancak `CameraPlugin` gibi bazı iOS donanım eklentileri, aynı anda iki farklı Flutter motoruna (biri ön planda, biri arka planda) kaydedilmeyi (register) desteklemez. Sistem, Kamera eklentisini ikinci kez arka plan motoruna kaydetmeye çalıştığında "Çakışma" hatası verip güvenlik amacıyla uygulamayı başlatmadan çökertiyordu.

**Çözüm:**
* `AppDelegate.swift` dosyasındaki `FlutterImplicitEngineDelegate` entegrasyonu ve `didInitializeImplicitFlutterEngine` fonksiyonu tamamen kaldırıldı. 
* Arka planda tüm eklentileri kopyalayan yapı devre dışı bırakıldı. Uygulama sadece ana motor üzerinden tekil çalışacak şekilde ayarlandı ve çakışma ortadan kalktı.

## 3. Firebase "Web" Kimliği Çakışması
**Hata İhtimali:**
Firebase, `FirebaseOptions` üzerinden başlatılırken yanlışlıkla web platformu için üretilmiş bir App ID (`1:29839209813:web:e918a...`) girilmişti. iOS Firebase SDK'sı bu kimliğin formatını denetleyip bir iOS cihazında "web" anahtarı kullanıldığını gördüğünde doğrudan native bir hata fırlatmaktaydı.

**Çözüm:**
* App ID dizesindeki `:web:` ifadesi, manuel olarak `:ios:` olarak güncellendi. Nihai Firebase konfigürasyonlarında (ileride GoogleService-Info.plist kullanılmadığı sürece) her zaman geçerli bir iOS kimliği kullanılması gerektiği teyit edildi.

## 4. Google Maps "Nokta Belirle" (Harita) Ekranı Çökmesi
**Hata:**
Uygulama içinde harita ekranını (örneğin "Grup Sürüşü - Nokta Belirle") açan bir butona tıklandığında uygulama anında kapanıyor.

**Nedeni:**
Android cihazlar Google Haritalar API anahtarını `AndroidManifest.xml` dosyasından otomatik okuyup başlatabilirken, iOS'ta Google Haritalar SDK'sı manuel bir başlatma komutu bekler. `ios/Runner/AppDelegate.swift` içerisinde uygulamanın başlatılma sürecinde `GMSServices.provideAPIKey("YOUR_API_KEY")` metodu çağrılmazsa, haritanın ekranda çizilmeye çalışıldığı ilk an iOS sistemi bilinmeyen bir motorla karşılaştığı için güvenliği sağlayıp uygulamayı anında çökertir (Crash atar).

**Çözüm:**
* `AppDelegate.swift` dosyasına `import GoogleMaps` eklendi.
* `application(didFinishLaunchingWithOptions:)` bloğunun hemen en başına, Android ile aynı olan API anahtarı `GMSServices.provideAPIKey(...)` kullanılarak tanımlandı ve harita motorunun iOS üzerinde de meşru şekilde başlaması sağlandı.

## 5. iOS Bildirimlerinin (Local Notifications) Ekranda Görünmemesi
**Hata:**
Uygulama arka planda değil de aktif olarak ekrandayken gönderilen yerel bildirimler telefona düşmüyor (veya ses/titreşim gelmiyor).

**Nedeni:**
iOS işletim sistemi, varsayılan olarak kullanıcı uygulamayı o an aktif kullanıyorsa (Foreground) bildirimleri ekrana yansıtmaz, sessizce yutar. Bildirimlerin uygulama açıkken de yukarıdan düşmesi için iOS'un bildirim merkezine manuel bir delege (delegate) atanması zorunludur.

**Çözüm:**
* `AppDelegate.swift` dosyasına `import flutter_local_notifications` eklendi.
* Uygulamanın açılış bloğuna `UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate` kodu eklenerek uygulamanın ön plandayken de bildirimleri gösterebilmesi sağlandı.

## Sonuç
Projenin iOS ayağında yaşanan altyapısal darboğazlar tamamen aşıldı. Geliştirme ortamı `~/Developer/ApexFlow-Release` dizinine taşınarak Apple'ın güvenlik ve bulut sistemlerinin Xcode ile çakışması engellendi. Uygulama üretim (Release) kalitesinde, sorunsuz bir şekilde cihaza entegre edildi.
