# ApexFlow Developer Requests

Bu belge, proje sahibinin isteklerini uygulanabilir geliştirme kurallarına çevirir.

## Ürün ve Dokümantasyon

- Projeyle ilgili ana belgeler repo içinde tutulmalıdır.
- `docs/APEXFLOW_ULTIMATE_PRODUCT_ARCHITECTURE.txt` ana kaynak belge olarak korunmalıdır.
- Başka bir yapay zeka veya geliştirici projeyi devraldığında `docs/HANDOFF_FOR_AI.md` dosyasından başlayabilmelidir.
- Önemli geliştirme ilerlemeleri `docs/DEVLOG.md` içine kısa ve tarihli kayıt olarak eklenmelidir.

## Platform Öncelikleri

- Birincil yayın hedefi Android / Google Play Store'dur.
- iOS ve App Store desteği gelecek fazdır.
- Flutter web production hedefi değildir.
- Geliştirme önizlemesi ve manuel UI doğrulama yalnızca Google Chrome hedeflenerek yapılmalıdır.
- Safari, Firefox, Edge ve mobil browser uyumluluğu preview kapsamına alınmamalıdır.

## Mimari İstekler

- Offline-first yaklaşım korunmalıdır.
- Yerel veri katmanı için ana yön Isar Database, ikincil cache için Hive olarak düşünülmelidir.
- Firebase Firestore yalnızca backup/sync amacıyla kullanılmalıdır.
- Firebase Auth, Firebase Cloud Messaging ve `flutter_local_notifications` ileride platform sistemleri için planlanmalıdır.
- Ağ ve cloud bağımlılıkları ürünün temel kullanımını engellememelidir.

## Tasarım İstekleri

- ApexFlow generic Material Design gibi görünmemelidir.
- UI sade, güvenilir, motosiklet odaklı ve insan eliyle hazırlanmış hissettirmelidir.
- Neon, cyberpunk, futuristik gelecek teması, glow, agresif cyan vurgu, glassmorphism, büyük radius ve template layout'lardan kaçınılmalıdır.
- Mevcut nötr renk sistemi ve 8pt spacing dili korunmalıdır.
- Etkileşimlerde haptic feedback ve küçük scale feedback tercih edilmelidir.
- Sağlık oranı görsel etkileri çok hafif olmalı; navbar arkasından yukarı doğru beliren düşük opacity renk geçişi dışında ekran boyanmamalıdır.

## AI ve Premium İstekleri

- AI özellikleri uzun vadeli ürün değeri olarak ele alınmalıdır.
- İlk fazlarda AI zorunlu bağımlılık olmamalıdır.
- Premium özellikler; AI insights, predictive diagnostics, cloud sync, advanced analytics ve deep customization çevresinde şekillenmelidir.
- Kullanıcı verisi satılmamalı, tracking tabanlı agresif monetization yapılmamalıdır.
