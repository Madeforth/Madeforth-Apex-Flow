# Rider Card Tasarım Spesifikasyonları

Rider Card, ApexFlow platformundaki her sürücünün benzersiz kimliğini, tarzını ve topluluğa olan katkı düzeyini temsil eden en premium arayüz bileşenidir.

---

## 📐 Kart Boyutları & Yerleşim

### Standart Mod (Full / Detaylı)
- **Genişlik:** `double.infinity` (ekran genişliğine yayılır)
- **İç Padding:** `16px` (ApexSpacing.x2 = 16)
- **Köşe Yuvarlaklığı:** `9px` (ApexSpacing.radius * 1.5 = 6 * 1.5)
- **Gölge:** `blurRadius: 16, offset: Offset(0, 8)`
- **Vektör Overlay:** Sağ alt köşede `Icons.two_wheeler` motosiklet silüeti (boyut: `64px`, alpha: `0.08`), `Positioned.fill` ile kaplı bezier çizim deseni.

### Kompakt Mod (Compact / Minimal)
- **Kullanım Yeri:** Arkadaşlar sekmesi, Yakınındaki Kişiler tarayıcısı vb.
- **Genişlik:** `double.infinity` (dikey listeler için optimize)
- **İç Padding:** `16px` sol, `12px` diğer yönler
- **Köşe Yuvarlaklığı:** `12px`
- **Tasarım:** İnce ve sadeleştirilmiş bir yerleşim sunar. Alt kısımdaki sürüş istatistikleri ve detaylı motosiklet alanları gizlenir; ancak avatar çerçevesi, seçilen rozetler/peçler, isim, plaka ve destekçi tier efektleri korunur.
- **Sol Kenar Vurgusu (Dynamic Accent Line):** Kompakt kartların sol kenarında, sürücünün aktif kart temasına ait gradyan renklerini taşıyan `4px` genişliğinde dikey bir vurgu çizgisi bulunur.

---

## 🎨 Tema Listesi

| # | Tema Adı (TR) | Tema Adı (EN) | Renkler | Erişim |
|---|---|---|---|---|
| 0 | Sakin Ulaşım | Urban Commuter | Cyan → Mor | Ücretsiz |
| 1 | Enduro Orman | Forest Enduro | Koyu Yeşil → Yeşil | Premium |
| 2 | Tur Gecesi | Midnight Touring | Gece Mavi → Okyanus | Premium |
| 3 | Süperbike Karbon | Superbike Carbon | Siyah → Koyu Gri | Ücretli |
| 4 | Yarış Kırmızısı | Racing Sport | Kırmızı → Parlak Kırmızı | Ücretli |
| 5 | Krom Cruiser | Chrome Cruiser | Gümüş → Açık Gri | Ücretli |
| 6 | Serüven Kumu | Adventure Sand | Turuncu → Bej | Ücretli |
| 7 | Günbatımı Ufku | Sunset Horizon | Koyu Turuncu → Turuncu | Ücretli |
| 8 | Neon Naked | Neon Naked | Koyu Mor → Mor | Ücretli |
| 9 | Aero Mavi | Sky Aero | Koyu Teal → Cyan | Ücretli |
| 10 | Apex Destekçisi | Apex Supporter | Siyah → Koyu Gri | Destekçi Paketi |

---

## 🏆 Peçler (Badges) & Simgeler

Sürücülerin sürüş başarılarına göre kartlarında sergileyebildikleri peçler şunlardır:
- **🏁 First Ride (first_ride):** İlk sürüş kaydını tamamlayanlara verilir. (Mavi-gri arka planlı)
- **🌟 Mileage 100 (mileage_100):** Toplam 100 km sürüşü aşanlara verilir. (Turuncu arka planlı)
- **🔥 Speed Demon (speed_demon):** Sürüş performans kriterlerine göre verilir. (Kırmızı-aksent arka planlı)
- **🌙 Night Rider (night_rider):** Gece sürüşü yapanlara verilir. (Koyu çivit mavi arka planlı)
- **🛠️ Maintenance Master (maintenance_master):** Bakımlarını aksatmayanlara verilir. (Teal arka planlı)

---

## 💎 Destekçi Tier Efektleri

Sürücülerin "Destekçi Flex Mağazası" üzerinden edindikleri seviyeler kartlarına anlık olarak yansır:
- **Tier 1 (Pit Crew):** Sürücü kartı üzerinde Tier 1 onay tik animasyonu / rozeti. Tema 10 (Apex Destekçisi) kilidi açılır.
- **Tier 2 (Track Rider):** Özel avatar çerçeve efekti, onay tik animasyonu ve kart arka planında beyazımsı kenarlıklar.
- **Tier 3 (Apex Founder):** Dönen altın elmas animasyonu, altın rengi gölgeleme, kart kenarında `1.5px` kalınlığında amber kenarlık ve isim üzerinde özel kehribar rengi gradyan.
