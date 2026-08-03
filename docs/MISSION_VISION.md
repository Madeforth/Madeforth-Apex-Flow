# ApexFlow Mission & Vision

## Misyon

ApexFlow'un misyonu motosiklet bakımını, sürüş ritüelini ve sürücünün makineyle kurduğu bağı tek bir bilinçli sistemde toplamaktır. Uygulama yalnızca servis hatırlatan bir araç değil; motosikletin kondisyonunu, sürüş alışkanlıklarını ve duygusal sürüş hafızasını birlikte okuyan bir makine ilişki ekosistemidir.

## Vizyon

ApexFlow, premium ve sakin bir "machine relationship OS" olarak konumlanır. Nihai ürün; yaşayan motosiklet garajı, bakım zekası, ritüel tabanlı sürüş günlüğü, yerel öncelikli veri mimarisi ve gelecekte AI destekli içgörülerden oluşan üretim kalitesinde bir mobil deneyim olmalıdır.

İlk yayın hedefi Android / Google Play Store'dur. iOS, Apple Watch, WidgetKit, Live Activities ve benzeri Apple ekosistemi özellikleri gelecek fazlarda ele alınır.

## Güncel Tasarım Yönü

ApexFlow karanlık neon veya karmaşık cyberpunk temalar yerine; sakin, endüstriyel, son derece premium koyu tonlarda (Dark Slate) bir tasarıma sahiptir. Uygulama, motosiklet odağı net olan, gözü yormayan sakin ve derin tonlara sahiptir.

## Deneyim İlkeleri

- Kullanıcı motosikletiyle daha bağlı, daha sorumlu ve daha bilinçli hissetmelidir.
- Arayüz normal bir mobil uygulama değil, premium garaj işletim sistemi (Machine OS) gibi hissettirmelidir.
- Ürün mekanik, canlı, niyetli, sade, güvenilir ve insan eliyle yapılmış görünmelidir.
- Tasarım generic Material UI, hazır template, ucuz startup arayüzü veya yapay zeka üretimi gibi görünmemelidir.
- Uygulama offline-first çalışmalı, düşük batarya tüketmeli ve gereksiz ağ bağımlılığı oluşturmamalıdır.

## Tasarım İlkeleri

- Sade, nötr ve okunabilir tasarım dili korunur.
- **Ana Renk Sistemi**: Derin Koyu Lacivert/Slate arka plan (`#0B1528` ve `#0F172A`), koyu panel yüzeyleri (`#1E293B`), ince zarif sınır çizgileri (`Border.all`), sakin Cyan vurgu rengi, kontrollü uyarı kırmızısı ve yüksek kontrastlı beyaz/mat gri metinler.
- **Kart Vurguları**: Kompakt listelerde sol kenara yerleştirilen gradyan çizgileri gibi zarif detaylar kullanılarak karmaşıklıktan uzak, premium bir hava oluşturulur.
- **Boşluk Sistemi**: Sadece 8pt spacing sistemi kullanılır.
- **Komponent Radius Değerleri**: Komponentler için radius değerleri küçük tutulur; 4px-6px aralığı hedeflenir. Kartlar ve modallar 12-16px arası yumuşatılabilir.
- **Animasyonlar & Radar Etkileri**: Taramalar ve geçişler dalgalanan radar efektleri gibi akıcı mikro animasyonlarla zenginleştirilir.
- Mikro etkileşimlerde scale feedback, haptic feedback ve `easeOutQuad` hissi korunur.
