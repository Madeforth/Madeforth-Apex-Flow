# ApexFlow — Google Play Kapalı Test (Closed Testing) Rehberi

> **Uygulama**: ApexFlow  
> **Paket Adı**: `com.apexflow.app`  
> **Versiyon**: 1.0.0+27  
> **Tarih**: 2026-08-04  

---

## 1. Ön Koşullar

| Gereksinim | Durum |
|---|---|
| Google Play Console hesabı (25$ ücret ödendi) | ☐ |
| Uygulama Google Play Console'da oluşturuldu | ☐ |
| Signing key (upload key) hazır (`key.properties`) | ☐ |
| Privacy Policy URL mevcut | ☐ |
| En az 20 kapalı test kullanıcısı (e-posta listesi) | ☐ |

---

## 2. Release AAB Oluşturma

```bash
# Temiz build
flutter clean
flutter pub get

# AAB (Android App Bundle) oluştur
flutter build appbundle --release --build-number=27 --build-name=1.0.0

# Çıktı konumu:
# build/app/outputs/bundle/release/app-release.aab
```

### Doğrulama
```bash
# AAB boyutunu kontrol et
dir build\app\outputs\bundle\release\app-release.aab

# İmza doğrulama
jarsigner -verify build/app/outputs/bundle/release/app-release.aab
```

---

## 3. Google Play Console — Kapalı Test Kurulumu

### 3.1 Test Track Oluşturma

1. [Google Play Console](https://play.google.com/console) → **ApexFlow** uygulaması
2. Sol menü → **Testing** → **Closed testing**
3. **"Create track"** → Track adı: `closed-beta`
4. **"Manage track"** tıkla

### 3.2 Tester Ekleme

**Seçenek A — E-posta listesi ile:**
1. **Testers** sekmesi → **"Create email list"**
2. Liste adı: `apexflow-beta-testers`
3. Test kullanıcılarının e-posta adreslerini gir (Google hesapları)
4. **Minimum 20 kişi** gerekli (Google'ın kapalı test politikası)

**Seçenek B — Google Groups ile:**
1. Bir Google Group oluştur (ör. `apexflow-testers@googlegroups.com`)
2. Test kullanıcılarını gruba ekle
3. Play Console'da grup bağlantısını gir

### 3.3 AAB Yükleme

1. **Releases** sekmesi → **"Create new release"**
2. **App signing by Google Play** → kabul et (ilk seferde)
3. `app-release.aab` dosyasını sürükle-bırak ile yükle
4. **Release name**: `1.0.0 (27) — Closed Beta`
5. **Release notes** (Türkçe):
   ```
   ApexFlow v1.0.0 Kapalı Beta
   - Motosiklet bakım takip sistemi
   - Sürüş ritüeli ve rota planlama
   - Gerçek zamanlı sensör entegrasyonu
   - Firebase bulut senkronizasyonu
   ```
6. **"Review release"** → **"Start rollout to Closed testing"**

---

## 4. Store Listing (Mağaza Bilgileri)

Kapalı test öncesi doldurulması gerekenler:

### 4.1 Ana Bilgiler

| Alan | Değer |
|---|---|
| **App name** | ApexFlow |
| **Short description** | Motosiklet bakım zekası ve sürüş ritüeli sistemi |
| **Full description** | Aşağıda detaylı |
| **Category** | Auto & Vehicles |
| **Contact email** | destek@apexflow.app |

### 4.2 Full Description (Tam Açıklama)

```
ApexFlow, motosiklet tutkunları için geliştirilmiş akıllı bakım ve sürüş yönetim sistemidir.

🔧 Bakım Takibi
- Motor yağı, filtre, zincir bakım hatırlatıcıları
- Kilometre bazlı akıllı bildirimler
- Geçmiş bakım raporu

🏍️ Sürüş Ritüeli
- Sürüş öncesi kontrol listesi
- Gerçek zamanlı sensör verileri (AHRS)
- Rota kaydı ve paylaşım

☁️ Bulut Senkronizasyon
- Firebase entegrasyonu
- Çoklu cihaz desteği
- Otomatik yedekleme

📊 Analitik
- Sürüş istatistikleri
- Bakım maliyet takibi
- Performans raporları
```

### 4.3 Görseller

| Tür | Boyut | Adet |
|---|---|---|
| App icon | 512x512 px | 1 |
| Feature graphic | 1024x500 px | 1 |
| Phone screenshots | 16:9 veya 9:16 | Min 2, max 8 |
| Tablet screenshots (opsiyonel) | 16:9 veya 9:16 | Min 0, max 8 |

---

## 5. Content Rating & Uyumluluk

### 5.1 İçerik Derecelendirme Anketi
1. **Policy** → **App content** → **Content rating**
2. Anket tipi: **Utility, Productivity, Communication**
3. Tüm sorulara "Hayır" (şiddet, kumar, vb. yok)
4. Beklenen sonuç: **PEGI 3 / Everyone**

### 5.2 Data Safety
1. **Policy** → **App content** → **Data safety**
2. Toplanan veriler:
   - ✅ E-posta adresi (hesap oluşturma)
   - ✅ Konum (sürüş rotası — kullanıcı izniyle)
   - ✅ Cihaz sensör verileri (AHRS)
   - ✅ Uygulama kullanım verileri (Firebase Analytics)
3. Veri şifreleme: ✅ Transit'te şifrelenir
4. Veri silme: ✅ Kullanıcılar hesap silme talep edebilir

---

## 6. Test Kullanıcıları İçin Davet

Test başladıktan sonra, her kullanıcıya aşağıdaki bağlantıyı gönderin:

```
https://play.google.com/apps/testing/com.apexflow.app
```

Kullanıcılar bu bağlantıya tıklayarak:
1. Test programına katılır
2. Uygulamayı Google Play'den indirir
3. Geri bildirim gönderebilir

---

## 7. Kapalı Testten Açık Teste Geçiş Kontrol Listesi

| # | Adım | Durum |
|---|---|---|
| 1 | Kapalı test en az 14 gün sürdü | ☐ |
| 2 | Minimum 20 tester katıldı | ☐ |
| 3 | Kritik crash oranı < %2 | ☐ |
| 4 | ANR oranı < %0.5 | ☐ |
| 5 | Kullanıcı geri bildirimleri değerlendirildi | ☐ |
| 6 | Store listing tamamlandı | ☐ |
| 7 | Content rating onaylandı | ☐ |
| 8 | Data safety formu dolduruldu | ☐ |
| 9 | Tüm ekran görüntüleri yüklendi | ☐ |
| 10 | Privacy policy URL girildi | ☐ |

---

## 8. CI/CD Otomasyon (Opsiyonel)

GitHub Actions ile otomatik AAB yükleme:

```yaml
# .github/workflows/closed_test_deploy.yml
name: Deploy to Closed Testing

on:
  push:
    tags:
      - 'v*-beta'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.32.x'
          channel: 'stable'

      - name: Build AAB
        run: |
          echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > android/app/upload-keystore.jks
          echo "${{ secrets.KEY_PROPERTIES }}" > android/key.properties
          flutter build appbundle --release

      - name: Upload to Play Console
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAY_STORE_SERVICE_ACCOUNT_JSON }}
          packageName: com.apexflow.app
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: internal
          status: completed
```

### Gerekli GitHub Secrets

| Secret | Açıklama |
|---|---|
| `KEYSTORE_BASE64` | Upload keystore dosyasının base64 hali |
| `KEY_PROPERTIES` | `key.properties` dosyasının içeriği |
| `PLAY_STORE_SERVICE_ACCOUNT_JSON` | Google Play API service account JSON |

---

## 9. Sorun Giderme

### Sık Karşılaşılan Hatalar

| Hata | Çözüm |
|---|---|
| "Version code already used" | `pubspec.yaml`'da build numarasını artır (ör. `+28`) |
| "APK/AAB is not signed" | `key.properties` yolunu kontrol et |
| "Target SDK too low" | `build.gradle.kts`'de `targetSdk` ≥ 34 olmalı |
| "Missing declarations" | Data safety formunu doldur |
| "Deobfuscation file" | ProGuard mapping dosyasını yükle |

### Yararlı Komutlar

```bash
# Mevcut imzayı kontrol et
keytool -printcert -jarfile build/app/outputs/bundle/release/app-release.aab

# APK boyut analizi
bundletool build-apks --bundle=app-release.aab --output=app.apks
bundletool get-size total --apks=app.apks

# Logcat ile crash izleme
adb logcat *:E | grep "com.apexflow.app"
```

---

> **Not**: Bu rehber Google Play Console'un Ağustos 2026 itibarıyla güncel kurallarına göre hazırlanmıştır.
