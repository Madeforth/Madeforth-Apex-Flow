# ApexFlow Documentation Index

Bu klasör ApexFlow projesinin ürün niyetini, geliştirme durumunu ve sonraki adımlarını korur. Başka bir geliştirici veya yapay zeka projeyi devraldığında önce **`memory-bank/`** (repo kökünde) okunmalıdır — güncel proje durumu, mimari ve aktif bağlam artık orada tutulur. Bu klasördeki dosyalar tamamlayıcı referans niteliğindedir.

## Okuma Sırası

1. `../memory-bank/activeContext.md` ve `../memory-bank/progress.md`
   - En hızlı, güncel bağlam. Mevcut görev, doğrulanmış/doğrulanmamış durum, bilinen risk alanları.

2. `COMPANY_PROFILE.md`
   - Şirketin kimliği, misyonu, vizyonu, iş modeli, hedef kitlesi ve ürün felsefesi. Yapay zeka araçlarına bağlam sağlamak için kullanın.

3. `APEXFLOW_ULTIMATE_PRODUCT_ARCHITECTURE.txt`
   - Orijinal ana mimari ve ürün vizyonu belgesidir. Product bible olarak kabul edilir.

4. `RIDER_CARD_SPECS.md`
   - Rider Card bileşeninin tasarım spesifikasyonu (boyutlar, temalar, rozetler, destekçi efektleri).

5. [MARKETING_DESIGNS.md](MARKETING_DESIGNS.md)
   - Uygulama mağazası, reklam tasarımları ve tanıtım görselleri için hazırlanmış yapay zeka prompt rehberi.

6. `google_closed_testing.md`
   - Google Play Kapalı Test (Closed Testing) kurulum rehberi.

## Not

`HANDOFF_FOR_AI.md`, `MISSION_VISION.md`, `DEVELOPER_GOALS.md`, `DEVELOPER_REQUESTS.md`, `DEVLOG.md` ve `ROADMAP_PHASES.md` dosyaları 2026-08-04'te kaldırıldı; içerikleri güncel haliyle `memory-bank/projectbrief.md`, `memory-bank/productContext.md` ve `memory-bank/progress.md` içinde tutuluyor (bazı içerikleri eski faz/test sayılarıyla çelişiyordu). Aktif faz bilgisi için `../PHASE_LOCK.md` kullanılır.

## Güncelleme Kuralı

Ürün yönü, mimari karar veya milestone değiştiğinde `memory-bank/activeContext.md` ve `memory-bank/progress.md` güncellenmelidir (bkz. kök `CLAUDE.md`).
