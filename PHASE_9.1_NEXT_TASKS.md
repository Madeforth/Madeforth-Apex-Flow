# Phase 9.1: Core Optimizations (Telemetri, Batarya, Harmony)
**[DURUM: SIRADAKİ YAPILACAK İŞ (NEXT IN LINE)]**

Bu belge, `PHASE_9_OPTIMIZATIONS_ROADMAP.md` belgesindeki 2, 4 ve 5 numaralı kritik maddelerin doğrudan koda aktarılmasını hedefler. Bir sonraki aşamada **doğrudan bu hedefler uygulanacaktır.**

## Hedef
Cihazın aşırı ısınmasını önlemek için jiroskop veri akışını optimize etmek, gereksiz API çağrılarını azaltarak bataryayı korumak ve makine ruhu (Harmony Engine) hesaplamalarını kullanıcının manuel beyanından çıkartıp, **gerçek sürüş verileriyle (telemetri)** otomatize etmek.

## Uygulanacak Değişiklikler

### 1. Telemetry Isolate Throttling
Şu an `telemetry_isolate.dart`, sensörden saniyede 100 kez (100Hz) gelen ham veriyi doğrudan UI (arayüz) katmanına basıyor. Bu durum özellikle uzun sürüşlerde cihazın şişmesine sebep olur.
- **Yapılacaklar:** Isolate içerisine 200 milisaniyelik bir `Timer` eklenecek. Sensörden gelen son değerler bellekte (buffer) tutulacak ve bu Timer tetiklendiğinde (saniyede sadece 5 kez) ana iş parçacığına (UI) gönderilecek. Akıcılık bozulmadan batarya tüketimi %90 azalacak.

### 2. Weather API Caching
Sürüş hazırlık ekranı her açıldığında Open-Meteo'ya istek atılıyor.
- **Yapılacaklar:** `shared_preferences` entegre edilecek. Veri çekildiğinde JSON olarak kaydedilecek ve saati tutulacak. Bir sonraki istekte 30 dakikadan az zaman geçmişse, API yerine doğrudan cihaz hafızasındaki önbellek (cache) verisi döndürülecek.

### 3. Harmony Engine - Gerçek Veri Entegrasyonu
Şu an Makine Ruhu (Harmony Engine) sadece sürücünün sürüş sonundaki "Sakin", "Agresif" gibi butonlara basmasıyla parça aşınmasını hesaplıyor.
- **Yapılacaklar:** Parça ömrünü hesaplayan fonksiyon, `RideSession` içerisindeki telemetri verilerine göre refactor edilecek. Eğer kaydedilen `maxLeanAngle` (maksimum yatış açısı) 45 dereceden fazlaysa veya sürüşte 3'ten fazla Ani Fren (`hardBrakes`) kaydı varsa, sistem bunu "Agresif Sürüş" olarak tespit edip lastik ve fren balatası aşınmasını otomatik olarak artıracak.
