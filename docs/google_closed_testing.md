# ApexFlow — Google Play Kapalı Test (Closed Testing) Rehberi

> **Uygulama**: ApexFlow
> **Paket Adı**: `com.apexflow.app`
> **Versiyon**: 1.0.0+34
> **Güncelleme**: 2026-08-09

---

## 1. Ön Koşullar

| Gereksinim | Durum |
|---|---|
| Google Play Console hesabı (25$ ücret ödendi) | ☐ |
| Uygulama Google Play Console'da oluşturuldu | ☐ |
| Signing key (upload key) hazır (`key.properties`) | ☐ |
| Privacy Policy URL: `https://apex-flow-privacy-7baea.web.app/` | ☐ |
| Hesap silme URL: `https://apex-flow-privacy-7baea.web.app/delete-account/` | ☐ |
| Yeni kişisel hesaplarda en az 12 kapalı test kullanıcısı | ☐ |

---

## 2. Release AAB Oluşturma

```bash
# Temiz build
flutter clean
flutter pub get

# AAB (Android App Bundle) oluştur
flutter build appbundle --release --build-number=34 --build-name=1.0.0

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
4. 13 Kasım 2023 sonrasında açılmış kişisel geliştirici hesaplarında en az
   **12 test kullanıcısı 14 gün kesintisiz opt-in** kalmalıdır. Play Console'da
   hesabınız için gösterilen şart esastır.

**Seçenek B — Google Groups ile:**
1. Bir Google Group oluştur (ör. `apexflow-testers@googlegroups.com`)
2. Test kullanıcılarını gruba ekle
3. Play Console'da grup bağlantısını gir

### 3.3 AAB Yükleme

1. **Releases** sekmesi → **"Create new release"**
2. **App signing by Google Play** → kabul et (ilk seferde)
3. `app-release.aab` dosyasını sürükle-bırak ile yükle
4. **Release name**: `1.0.0 (34) — Internal Test` (kapalı teste taşırken aynı artifact kullanılabilir)
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

### 5.2 Data Safety — Kodla Doğrulanmış Beyan

Genel cevaplar:

| Soru | Cevap |
|---|---|
| Uygulama gerekli veri türlerinden birini topluyor veya paylaşıyor mu? | **Evet** |
| Toplanan kullanıcı verileri aktarım sırasında şifreleniyor mu? | **Evet** |
| Kullanıcı hesap silme talep edebilir mi? | **Evet** — uygulama içi + harici URL |
| Bağımsız güvenlik incelemesi yapıldı mı? | **Hayır** (sertifika yoksa Evet işaretleme) |
| Veriler satılıyor veya reklam için kullanılıyor mu? | **Hayır** |

`Paylaşım` sorusu için **Hayır** seçilir: Firebase, RevenueCat ve özel QA
altyapısı uygulama adına hizmet sağlayıcı olarak işler; arkadaş/grup görünürlüğü
kullanıcının açıkça başlattığı uygulama işlevleridir. Bu durum değişirse form ve
gizlilik politikası birlikte güncellenmelidir.

Telefon, kan grubu, acil durum telefonu ve plaka varsayılan olarak kapalıdır.
Kullanıcı her alanı ayrı ayrı "arkadaşlara aç" yaptığında veri yalnızca
Firestore'da doğrulanmış Apex Flow arkadaşlarına gösterilir; e-posta hiçbir
sosyal profil görünümüne eklenmez.

Play Console'da aşağıdaki veri türlerini ekle:

| Kategori / Veri türü | Toplanıyor | Zorunlu mu? | Amaç |
|---|---:|---|---|
| Konum → Kesin konum | Evet | İsteğe bağlı | Uygulama işlevselliği (sürüş, buluşma noktası) |
| Kişisel bilgiler → Ad | Evet | Hesap profili için zorunlu | Uygulama işlevselliği, hesap yönetimi |
| Kişisel bilgiler → E-posta adresi | Evet | E-posta hesabında zorunlu | Hesap yönetimi, kimlik doğrulama |
| Kişisel bilgiler → Kullanıcı kimlikleri | Evet | Zorunlu | Uygulama işlevselliği, hesap yönetimi, güvenlik |
| Kişisel bilgiler → Telefon numarası | Evet | İsteğe bağlı | Uygulama işlevselliği |
| Kişisel bilgiler → Diğer bilgiler | Evet | İsteğe bağlı | Rider Tag, şehir, sosyal profil, motosiklet/profil özeti |
| Sağlık ve fitness → Sağlık bilgileri | Evet | İsteğe bağlı | Acil durum kartı / uygulama işlevselliği |
| Finansal bilgiler → Satın alma geçmişi | Evet | İsteğe bağlı | Premium hakkı, hesap yönetimi, dolandırıcılığı önleme |
| Fotoğraflar ve videolar → Fotoğraflar | Evet | İsteğe bağlı | Profil fotoğrafı |
| Mesajlar → Diğer uygulama içi mesajlar | Evet | İsteğe bağlı | Park QR yanıtları ve destek iletişimi |
| Uygulama etkinliği → Diğer kullanıcı tarafından oluşturulan içerik | Evet | İsteğe bağlı | Profil alanları, grup lobisi, hata raporları |
| Uygulama bilgileri ve performansı → Teşhis | Evet | İsteğe bağlı | Kullanıcının gönderdiği hata raporunu inceleme |
| Cihaz veya diğer kimlikler | Evet | Bildirimlerde isteğe bağlı | FCM bildirimi, güvenlik, dolandırıcılığı önleme |

Şunları **işaretleme** (mevcut üretim kodunda cihaz dışına toplanmıyor): kişiler,
SMS/MMS, ses, takvim, web tarama geçmişi, reklam kimliği, crash logları ve tam
ödeme kartı bilgisi. Şifreli belge görselleri ve ayrıntılı sürüş rota örnekleri
cihazda kalır; bu nedenle yalnızca yerel işlenen veri olarak Data Safety
`toplanan` listesine eklenmez.

### 5.3 Konum ve Foreground Service Beyanı

- Manifestte `ACCESS_FINE_LOCATION` ve `ACCESS_COARSE_LOCATION` bulunur.
- `ACCESS_BACKGROUND_LOCATION` **bulunmaz**; Play Console'da bu izin için
  `Hayır / kullanılmıyor` beyanı verilir.
- `FOREGROUND_SERVICE_LOCATION` kullanılır. Foreground service türü:
  **Location**.
- Konum yalnızca kullanıcı uygulama içinden bir sürüş başlattıktan sonra alınır.
- Ekran kilitli/uygulama küçültülmüşken görünür `Sürüş Devam Ediyor` bildirimi
  gösterilir ve kullanıcı sürüşü bitirdiğinde servis durur.

Play Console açıklama metni:

> Apex Flow records motorcycle ride location only after the user taps Begin
> Ride. A persistent Ride in Progress notification remains visible while the
> screen is locked or the app is minimized. GPS is used to calculate the
> user-requested ride's distance, speed and telemetry. Tracking stops
> immediately when the user ends or cancels the ride. Without this foreground
> service, recording would be interrupted when the screen locks and the ride
> result would be incomplete.

İnceleme videosu tek kesintisiz kayıtta şunları göstermeli:

1. Sürüşler ekranını aç.
2. `Sürüşü Başlat` → belirgin konum açıklaması → `Devam Et` → Android izin penceresi.
3. Sürüş aktifken kalıcı bildirimi göster.
4. Ana ekrana geç / ekranı kilitle; bildirimin devam ettiğini göster.
5. Uygulamaya dön, sürüşü bitir; bildirimin kaybolduğunu göster.

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
| 2 | Hesap için gerekiyorsa minimum 12 tester 14 gün kesintisiz kaldı | ☐ |
| 3 | Kritik crash oranı < %2 | ☐ |
| 4 | ANR oranı < %0.5 | ☐ |
| 5 | Kullanıcı geri bildirimleri değerlendirildi | ☐ |
| 6 | Store listing tamamlandı | ☐ |
| 7 | Content rating onaylandı | ☐ |
| 8 | Data safety formu dolduruldu | ☐ |
| 9 | Tüm ekran görüntüleri yüklendi | ☐ |
| 10 | Privacy policy ve hesap silme URL'leri girildi | ☐ |

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
