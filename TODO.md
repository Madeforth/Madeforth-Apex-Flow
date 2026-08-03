# ApexFlow Yapılacaklar Listesi (TODO)

Bu dosya, ApexFlow projesine eklenecek yeni özellikleri ve gelecek faz planlarını takip etmek için oluşturulmuştur.

## 📊 1. Gelişmiş Yakıt ve Ekonomi Analitiği (Fuel Economy Analytics)
* **Açıklama:** Kullanıcının girdiği yakıt kayıtları ve kilometre verilerini kullanarak yakıt ekonomisini analiz eden ve mekanik anormallikleri tespit eden sistem.
* **Alt Görevler:**
  - [ ] **İstasyon Performans Kıyaslaması:** Yakıt alınan markalara (Shell, BP, Opet vb.) göre tüketim verimliliğinin (L/100km) gruplanması ve kıyaslanması.
  - [ ] **Tüketim Anomali Algoritması:** Ortalama tüketim trendinin dışına çıkıldığında (örn: normal tüketimin %20 üzerine çıkılması) kullanıcıya bildirim/insight gösterilmesi (Hava filtresi, lastik basıncı veya zincir kontrolü uyarısı).
  - [ ] **Grafik Arayüzü:** Zaman içerisindeki tüketim (L/100km) değişimini ve harcama trendlerini gösteren çizgi grafikleri.
  - [ ] **Mesafe Başına Maliyet:** Motosikletin kilometre başına güncel yakıt maliyetini hesaplama.

## 🗃️ 2. Dijital Belge Cüzdanı ve Hatırlatıcı Sistem (Smart Document & Tax Ledger)
* **Açıklama:** Ehliyet, ruhsat, zorunlu trafik sigortası, kasko ve muayene tarihlerinin dijital cüzdanda toplanması ve son tarih yaklaşınca hatırlatılması.
* **Alt Görevler:**
  - [ ] **Yerel Evrak Depolama:** Ehliyet, ruhsat resimleri ve PDF'lerin şifrelenmiş yerel veri tabanında (Isar/Hive) saklanması.
  - [ ] **Son Ödeme/Yenileme Takvimi:** Yıllık MTV taksitleri, Trafik Sigortası ve Muayene son günlerinin girilmesi ve takip edilmesi.
  - [ ] **Proaktif Hatırlatıcı Bildirimler:** Son tarihe 30 gün, 15 gün ve 1 gün kala bildirim tetiklenmesi (flutter_local_notifications entegrasyonu).
  - [ ] **Resmi Kısayollar:** MTV ödemesi veya e-Devlet muayene randevusu için doğrudan devlet kanallarına yönlendiren web yönlendirme düğmeleri.

## 🪪 3. Sürücü Profili ve Arkadaşlık Sistemi (Rider Profile & Connection System)
* **Açıklama:** Sürücülerin kendi sürüş kimliklerini oluşturması, arkadaşlarını eklemesi ve garajlarını birbirlerine sergilemesi için gereken temel sosyal altyapı.
* **Alt Görevler:**
  - [x] **Dijital Sürücü Kartı (Biker ID):** Sürücünün fotoğrafı, sürüş tarzı rozetleri, kan grubu ve acil durum bilgilerinin yer aldığı premium kart arayüzü.
  - [x] **Rider Tag ve QR Kod Üretici:** Her kullanıcı için benzersiz etiket ve arkadaş eklemeyi saniyeler içinde sağlayan QR kod oluşturucu/okuyucu.
  - [x] **Gizlilik ve Hayalet Modu (Ghost Mode):** Haritada görünürlüğü "Her zaman kapalı", "Sadece grup sürüşünde açık" veya "Tamamen gizli" olarak kontrol eden gizlilik anahtarları.
  - [x] **Sanal Garaj Vitrini (Showcase Garage):** Kullanıcının motosikletlerini ve aksesuarlarını arkadaşlarının profillerinde sergileyebileceği sosyal garaj ekranı.
  - [x] **Arkadaş Listesi ve Liderlik Tablosu:** Haftalık/aylık yapılan toplam mesafe ve Harmony skoruna göre arkadaşlar arası mini rekabet sıralaması.

## 👥 4. [PREMIUM] Grup Sürüşü ve Canlı Konum Paylaşımı (Group Ride & Live Tracking)
* **Açıklama:** Sürücülerin arkadaşlarıyla grup sürüşleri planlamasını ve sürüş esnasında haritada birbirlerinin konumlarını canlı izlemesini sağlayan premium özellik.
* **Alt Görevler:**
  - [ ] **Grup Sürüşü Yönetimi:** Sürüş oluşturma, davet kodu/QR kod ile arkadaşları gruba ekleme ve katılım listesi ekranı.
  - [ ] **Gerçek Zamanlı Konum İletişimi:** Supabase Realtime / WebSocket üzerinden 5 saniyede bir koordinatların sunucuya senkronize edilmesi.
  - [ ] **Canlı Harita Arayüzü:** `flutter_map` ve OpenStreetMap kullanarak gruptaki tüm sürücüleri ve rotayı canlı gösteren harita paneli.
  - [ ] **Konum Yumuşatma (Interpolation):** Haritada arkadaşların konumlarının zıplayarak değil, akıcı şekilde hareket etmesini sağlayan lerp algoritması.
  - [ ] **Pil ve Veri Tasarrufu Modu:** Motor durduğunda veya hız sıfıra indiğinde konum yayınının otomatik durdurulması.



