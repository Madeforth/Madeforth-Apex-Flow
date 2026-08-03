MADEFORTH

APEXFLOW

Discord QA, Uygulama İçi Bug Report

ve Çift Yönlü Hata Yaşam Döngüsü Motoru

MASTER SPEC  Antigravity Uygulama Ana Şartnamesi

Bu belge, yerel bilgisayarda Antigravity ile uygulanmak üzere hazırlanmış bağlayıcı teknik mimari, kodlama, güvenlik, test, dağıtım ve operasyon rehberidir.

Belge Alanı

Değer

Belge Kodu

AF-AG-016 / Master Implementation Specification

Sürüm

1.0

Tarih

29 Temmuz 2026

Hedef

ApexFlow Flutter + Firebase + Madeforth Discord

Uygulama Ortamı

Antigravity / Yerel Geliştirme Bilgisayarı

Durum

Uygulamaya Hazır Teknik Şartname

Madeforth Confidential • Internal Engineering Use

Belge Kontrolü ve Bağlayıcı Kararlar

Bu şartname, ApexFlow’un uygulama içi sorun bildirme özelliğini Madeforth Discord QA altyapısıyla birleştiren hedef sistemi tanımlar. Antigravity uygulama sırasında bu kararları değiştirmemeli; zorunlu bir teknik engel bulursa uygulamayı durdurup gerekçeyi raporlamalıdır.

Karar

Bağlayıcı Uygulama Kuralı

Tek gerçek kaynak

Bug kaydının ana ve kalıcı kaynağı Firestore olacaktır.

Discord’un rolü

Discord, QA operasyon ve iletişim yüzeyidir; ana veri tabanı değildir.

Mobil güvenlik

Bot tokenı veya webhook URL’si Flutter uygulamasına, APK’ya ya da repository’ye yazılmayacaktır.

Gizlilik

Uygulama içi ham raporlar varsayılan olarak özel QA forumuna aktarılacaktır.

Kimlik

Her kayıt server tarafından üretilen AFB-YYYY-NNNNNN numarası taşır.

Senkronizasyon

Uygulamadan Discord’a ve Discord’dan Firestore/FCM’e çift yönlü durum akışı kurulacaktır.

Dağıtım

Antigravity hiçbir production deploy işlemini kullanıcı onayı olmadan yapmayacaktır.

Telemetri

Ham rota ve hassas konum Discord’a gönderilmeyecek; yalnızca güvenli özet ve Diagnostic ID kullanılacaktır.

GÜVENLİK  Kırmızı çizgi

Mobil uygulamanın Discord’a doğrudan HTTP çağrısı yapması mimari ihlaldir. Webhook adresini gizlemek için obfuscation kullanmak çözüm değildir; sır yalnızca server tarafında tutulur.

İçindekiler

İçindekiler Word tarafından açıldığında güncellenir.

Not: Microsoft Word belgeyi ilk açtığında içindekiler alanına sağ tıklayıp “Alanı Güncelleştir > Tüm tabloyu güncelleştir” seçeneğini kullanın.

1. Antigravity ile Bu Belge Nasıl Kullanılmalı?

1.1 Çalışma modeli

Antigravity’ye belgenin tamamı verilebilir; ancak uygulama tek seferde büyük bir kod değişikliği olarak yaptırılmamalıdır. Her faz ayrı uygulanmalı, test edilmeli ve commit edilmelidir. Bir fazın kabul kriterleri geçmeden sonraki faza başlanmamalıdır.

Repository üzerinde yeni bir feature branch oluştur.

Mevcut dosyaları ve kullanıcı değişikliklerini incele; üzerine yazma veya geri alma.

Yalnızca aktif fazın kapsamını uygula.

Format, analiz, birim test, emulator testi ve güvenlik kontrolünü çalıştır.

Değiştirilen dosyaları, test sonucunu ve kalan riskleri raporla.

Kullanıcı onayı veya faz kabulü sonrasında bir sonraki faza geç.

1.2 Antigravity için evrensel çalışma komutu

Antigravity master çalışma talimatı

Bu belgeyi bağlayıcı teknik şartname olarak kullan.Önce repository'yi oku ve mevcut mimariyle eşleştir.Kullanıcıya ait mevcut değişiklikleri silme, resetleme veya geri alma.Sadece belirtilen fazı uygula.Secret, token, webhook URL veya kişisel veriyi source code'a yazma.Üretim deploy'u yapma; emulator ve yerel testlerle doğrula.Her değişiklik sonunda:1. Değiştirilen dosyaları listele.2. Çalıştırılan komutları ve sonuçlarını yaz.3. Kabul kriterlerini PASS/FAIL olarak raporla.4. Bilinen riskleri ve manuel kullanıcı adımlarını belirt.Bloker varsa varsayım yapma; uygulamayı durdur ve açıkça raporla.

1.3 Çalışma öncesi güvenli Git kontrolü

git status --shortgit branch --show-currentgit log -1 --onelineflutter --versionflutter doctor -vflutter pub getdart format --output=none --set-exit-if-changed lib testflutter analyzeflutter test

DUR  Stop condition

Repository kirliyse Antigravity değişiklikleri otomatik temizlememeli. Mevcut değişiklikleri sınıflandırmalı, çakışan dosyaları kullanıcıya bildirmeli ve güvenli biçimde aynı değişikliklerin üzerinde çalışmalıdır.

2. Mevcut ApexFlow Kod Tabanına Özgü Ön Bulgular

Bu bölüm, paylaşılan ApexFlow kaynak arşivinin bu modülle doğrudan ilgili bölümlerinin incelenmesiyle hazırlanmıştır. Antigravity uygulamaya başlamadan önce bulguları güncel çalışma kopyasında yeniden doğrulamalıdır.

Öncelik

Mevcut Bulgu

Zorunlu Düzeltme

P0

`main.dart` içinde bütün TLS sertifika hatalarını kabul eden `badCertificateCallback => true` bulunuyor.

Global HttpOverrides kaldırılmalı. Sertifika doğrulaması hiçbir production/beta build’de devre dışı bırakılmamalı.

P0

Firebase seçenekleri `main.dart` içine platforma göre elle yazılmış; Android yolu web yapılandırmasına düşebiliyor.

`flutterfire configure` ile `firebase_options.dart` üretilecek ve `DefaultFirebaseOptions.currentPlatform` kullanılacak.

P1

`pubspec.yaml` içinde Functions, Storage, App Check, Crashlytics, device/package bilgi bağımlılıkları yok.

Bu şartnamede belirtilen paketler uyumlu sürümlerle eklenecek ve lockfile commit edilecek.

P1

`FirebaseService.init()` bazı hataları sessizce yutuyor.

Bug gönderiminde gerçek hata durumu kullanıcıya ve log sistemine kontrollü biçimde aktarılacak.

P1

Cloud Functions yapısı CommonJS `functions/index.js`, Node 20 ve `europe-west1` bölgesini kullanıyor.

Yeni fonksiyonlar mevcut yapıyla uyumlu modüllere ayrılacak; tek dosyalı monolit büyütülmeyecek.

P1

`firebase.json` içinde Firestore ve Storage rules/index konfigürasyonu görünmüyor.

Rules ve indexes dosyaları repository’ye eklenip emulator testine bağlanacak.

P2

Repository arşivinde `.orig` ve `.rej` gibi merge artıkları bulunuyor.

Aktif kaynakla ilişkileri doğrulanıp ayrı temizlik göreviyle kaldırılmalı; bu faz kullanıcı kodunu körlemesine silmemeli.

Avantaj

Firebase Auth, Firestore, FCM, Riverpod, Isar/Hive/ApexKvStore ve mevcut notification yapısı var.

Yeni modül mevcut yetenekleri kullanmalı; ikinci bir state veya notification altyapısı kurmamalı.

2.1 Gerekli Flutter bağımlılıkları

Sürüm numaralarını ezberden yazmak yerine pub tarafından uyumlu güncel sürüm çözdürülür; ardından pubspec.lock sabitlenir.

flutter pub add cloud_functionsflutter pub add firebase_storageflutter pub add firebase_app_checkflutter pub add firebase_crashlyticsflutter pub add package_info_plusflutter pub add device_info_plusflutter pub add connectivity_plusflutter pub add uuidflutter pub add mime

2.2 Firebase başlangıç düzeltmesi

Hedef yaklaşım; tam entegrasyon mevcut bootstrap ve test yapısına göre Antigravity tarafından uyarlanacaktır.

import 'package:firebase_core/firebase_core.dart';import 'package:firebase_app_check/firebase_app_check.dart';import 'package:firebase_crashlytics/firebase_crashlytics.dart';import 'firebase_options.dart';Future<void> bootstrapFirebase() async {  await Firebase.initializeApp(    options: DefaultFirebaseOptions.currentPlatform,  );  await FirebaseAppCheck.instance.activate(    androidProvider: kDebugMode        ? AndroidProvider.debug        : AndroidProvider.playIntegrity,    appleProvider: kDebugMode        ? AppleProvider.debug        : AppleProvider.appAttestWithDeviceCheckFallback,  );  FlutterError.onError =      FirebaseCrashlytics.instance.recordFlutterFatalError;  PlatformDispatcher.instance.onError = (error, stack) {    FirebaseCrashlytics.instance.recordError(      error,      stack,      fatal: true,    );    return true;  };}

P0  Önce güvenlik, sonra özellik

TLS doğrulamasını kapatan global override kaldırılmadan Discord/Firebase bug sistemine production verisi gönderilmemelidir. Bu düzeltme AF-AG-016 uygulamasının ön koşuludur.

3. Hedef Sistem Mimarisi ve Güven Sınırları

Şekil 1 — ApexFlow uygulama içi raporlama, Firestore ana kayıt ve Discord QA operasyon akışı.

3.1 Bileşen sorumlulukları

Bileşen

Sorumluluk

Yapmaması Gereken

ApexFlow istemcisi

Form, güvenli tanılama özeti, yerel outbox, dosya seçimi, kullanıcının kendi raporlarını görüntüleme.

Discord tokenı tutmak, öncelik belirlemek, admin statüsü değiştirmek.

Callable API

Auth/App Check doğrulaması, validasyon, sanitizasyon, idempotency, rate limit, AFB kimliği.

Kullanıcı girdisine güvenmek veya secret döndürmek.

Firestore

Bug ve olay geçmişinin tek gerçek kaynağı.

Discord mesajına bağımlı kalmak.

Storage

Ekran görüntüsü, video ve kontrollü tanılama eklerini saklamak.

Dosyaları herkese açık URL ile yayınlamak.

Dispatch Outbox

Discord kesintisini uygulama gönderiminden ayırmak, retry ve dead-letter sağlamak.

Aynı AFB için kontrolsüz tekrar başlık açmak.

Madeforth QA Bot

Forum başlığı, etiketler, butonlar, role dayalı triage, audit.

Kullanıcı şifresi, ham GPS veya tokenı Discord’a yazmak.

Discord QA

İnceleme, ekip içi iletişim, durum operasyonu.

Ana veri tabanı veya hassas dosya deposu olmak.

FCM ve Raporlarım

Kullanıcıya durum, ek bilgi ve retest bildirimleri.

İç QA notlarını kullanıcıya göstermek.

3.2 Veri akışı

Kullanıcı güvenli şekilde durduktan sonra ApexFlow’da Sorun Bildir ekranını açar.

İstemci formu doğrular, güvenli tanılama özetini hazırlar ve idempotency key üretir.

Backend draft kaydı ve server taraflı AFB numarası oluşturur.

Varsa ekler kullanıcıya özel Storage yoluna yüklenir.

Finalize çağrısı dosyaları, rızayı ve veri bütünlüğünü doğrular; durumu submitted yapar.

Aynı transaction içerisinde Discord dispatch outbox kaydı oluşur.

Worker özel QA forumunda başlık açar ve thread/message kimliklerini Firestore’a yazar.

QA butonları Discord Interaction endpoint’ine gelir; imza ve QA rolü doğrulanır.

Durum değişikliği Firestore event geçmişine yazılır; uygun durumda FCM gönderilir.

Kullanıcı Raporlarım ekranından güncel durumu ve retest talebini görür.

3.3 Hata izolasyonu

Discord kapalıysa bug Firestore’da kalır; kullanıcı gönderimi başarısız sayılmaz.

FCM başarısızsa bug durumu kaybolmaz; uygulama sonraki açılışta Firestore’dan güncel durumu okur.

Dosya yükleme başarısızsa draft korunur ve istemci yalnızca eksik dosyayı yeniden dener.

Aynı gönderim tekrarlandığında idempotency kaydı mevcut AFB numarasını döndürür.

Discord mesajı silinse bile bug ve event geçmişi Firestore’da yaşamaya devam eder.

4. Bug Domain Modeli ve Yaşam Döngüsü

Şekil 2 — ApexFlow bug kayıt durum makinesi.

4.1 Durumlar

Durum

Anlam

Kim değiştirebilir?

draft

Form oluşturuldu; gönderim veya ek yüklemesi tamamlanmadı.

Rapor sahibi / sistem

submitted

Kayıt backend tarafından kabul edildi; Discord kuyruğunda olabilir.

Sistem

new

Discord QA intake kaydı oluşturuldu.

Sistem

needs_info

Rapor sahibinden belirli ek bilgi isteniyor.

QA

confirmed

QA sorunu tekrar üretti veya yeterli kanıtla doğruladı.

QA

in_progress

Geliştirme işi aktif.

QA / Developer

ready_for_retest

Düzeltme beta build’e alındı ve tester doğrulaması bekleniyor.

QA / Developer

fixed

Düzeltme doğrulandı.

QA

closed

Yaşam döngüsü tamamlandı veya kayıt geçersiz/duplicate olarak kapandı.

QA

4.2 Kaynak ve görünürlük

enum BugSource { inApp, discord, crashlytics, internalQa }enum BugVisibility { qaPrivate, betaVisible, publicKnownIssue }enum BugPlatform { android, ios }enum BugPriority { untriaged, p0, p1, p2, p3 }enum BugImpact {  safetyOrSecurity,  dataLoss,  crash,  wrongTelemetry,  featureUnavailable,  performance,  visualOrText,}

4.3 Öncelik matrisi

Seviye

Örnek

Operasyon

P0

Güvenlik açığı, yetkisiz veri erişimi, geri döndürülemez veri kaybı.

Testi durdur; anında izole et; fix öncesi production deploy yok.

P1

Sürekli crash, sürüş kaydının kaybolması, 168° yatış veya gerçek dışı maksimum hız.

Aynı iş günü triage; ilgili build ve telemetri motorunu işaretle.

P2

Özelliğin bazı cihazlarda çalışmaması, ciddi performans/batarya problemi.

Aktif beta sprintine planla.

P3

Metin, hizalama, düşük etkili görsel sorun.

Toplu UI düzeltme planına ekle.

YÖNETİŞİM  Tester öncelik seçmez

Tester yalnızca kullanıcı etkisini seçer. Bot bir öncelik adayı hesaplayabilir; P0–P3 nihai kararını QA rolü verir.

5. Madeforth Discord Sunucusu Kurulumu

5.1 Kanal ve kategori yapısı

MADEFORTH├── START HERE│   ├── #welcome│   ├── #rules│   ├── #announcements│   └── #tester-guide├── APEXFLOW BETA│   ├── #report-a-bug│   ├── #apexflow-beta-builds│   ├── #apexflow-release-notes│   ├── #apexflow-known-issues│   └── Forum: apexflow-bug-reports└── MADEFORTH QA — PRIVATE    ├── Forum: apexflow-qa-inbox    ├── #qa-audit-log    ├── #qa-dead-letter    └── #release-planning

5.2 Roller

Rol

Yetki

Madeforth Owner

Tam sunucu kontrolü; token/secret yine Discord mesajında paylaşılmaz.

Madeforth Admin

Kanal, rol ve bot yönetimi.

Madeforth QA

Özel intake görünümü, triage butonları, ek bilgi ve kapatma.

ApexFlow Developer

Confirmed/In Progress/Ready for Retest işlemleri; admin yetkisi yok.

ApexFlow Beta Tester

Beta kanalları, public bug forumu, known issues, yeni rapor paneli.

Madeforth QA Bot

En düşük gerekli teknik izinler.

5.3 Bot izinleri

View Channels

Send Messages

Send Messages in Threads

Embed Links

Attach Files

Read Message History

Manage Threads

Use Application Commands

LEAST PRIVILEGE  Administrator verilmez

Madeforth QA Bot’a Administrator veya Manage Server verilmemelidir. Manage Webhooks yalnızca gerçekten webhook yönetimi gerekiyorsa ve ayrı değerlendirmeyle açılmalıdır.

5.4 Forum etiketleri — 20 etiket sınırına göre

Grup

Etiketler

Durum (7)

New, Confirmed, Need Info, In Progress, Ready for Retest, Fixed, Closed

Platform (2)

Android, iOS

Kategori (7)

Lean Angle, Speed, Ride/GPS, Account, UI/UX, Performance, Other

Öncelik (4)

P0 Critical, P1 High, P2 Medium, P3 Low

Her forum başlığına dört etiket uygulanır: platform + kategori + durum + öncelik. Build numarası etiket yapılmaz; başlık ve Firestore alanında tutulur.

5.5 Uygulama içi raporların görünürlüğü

Bütün in-app raporlar varsayılan olarak `apexflow-qa-inbox` özel forumuna düşer.

Kullanıcı adı yerine TESTER-XXXX gibi anonim operasyon kodu gösterilir.

QA doğruladığında sanitizasyon uygulanmış bir özet `apexflow-known-issues` kanalına yayınlanabilir.

Ham tanılama paketi Discord’a yüklenmez; yalnızca Diagnostic ID gösterilir.

Forum başlıkları inactivity nedeniyle arşivlenebilir; Firestore kaydı etkilenmez.

6. Discord Developer Application ve Madeforth QA Bot

6.1 Manuel kurulum adımları

Discord Developer Portal’da `Madeforth QA` isimli application oluştur.

Bot kullanıcısını oluştur ve Madeforth görsel kimliğine uygun avatar ekle.

Bot tokenını bir kez üret; chat, Word veya source code içine yapıştırma.

General Information bölümündeki Application ID ve Public Key’i güvenli yapılandırma değerleri olarak kaydet.

OAuth2 URL Generator üzerinden `bot` ve `applications.commands` scope’larını seç.

Yalnızca belirtilen minimum bot izinleriyle Madeforth sunucusuna davet et.

Interactions Endpoint URL’i backend deploy edildikten sonra tanımla.

Discord’un PING ve geçersiz imza testlerinin başarıyla geçtiğini doğrula.

6.2 Secret listesi

Secret / Config

Nerede tutulur?

Repository?

DISCORD_BOT_TOKEN

Google Secret Manager / Firebase Functions secret

Hayır

DISCORD_PUBLIC_KEY

Secret veya doğrulanmış server config

Tercihen hayır

DISCORD_APPLICATION_ID

Server environment config

Evet olabilir; hassas değil

DISCORD_GUILD_ID

Server environment config

Evet olabilir; hassas değil

DISCORD_QA_FORUM_ID

Server environment config

Evet olabilir; erişim yetkisi vermez

DISCORD_QA_ROLE_ID

Server environment config

Evet olabilir

FIREBASE_PROJECT_ID

FlutterFire ve Firebase config

Evet; secret değildir

6.3 HTTP interaction mimarisi

İlk sürümde sürekli açık Gateway bağlantısı kurmaya gerek yoktur. Slash command, buton ve modal etkileşimleri Firebase `onRequest` endpoint’ine gönderilebilir. Endpoint her istekte Ed25519 imzasını doğrular, PING’e PONG döner ve etkileşime üç saniye içinde ilk cevap verir.

const nacl = require("tweetnacl");function verifyDiscordRequest(req, publicKey) {  const signature = req.get("X-Signature-Ed25519");  const timestamp = req.get("X-Signature-Timestamp");  if (!signature || !timestamp) return false;  return nacl.sign.detached.verify(    Buffer.from(timestamp + req.rawBody.toString("utf8")),    Buffer.from(signature, "hex"),    Buffer.from(publicKey, "hex"),  );}

SECURITY  İmza doğrulaması zorunlu

Discord Interaction endpoint’i herkese açık bir HTTP uç noktasıdır. `X-Signature-Ed25519` ve `X-Signature-Timestamp` doğrulanmadan hiçbir buton veya komut işlenmeyecektir.

7. Firebase Proje Hazırlığı

7.1 FlutterFire konfigürasyonu

`flutterfire configure` çalıştırılarak Android ve iOS uygulamaları doğru package/bundle kimlikleriyle bağlanır.

Üretilen `lib/firebase_options.dart` platform seçiminde tek kaynak yapılır.

`main.dart` içindeki elle yazılmış FirebaseOptions blokları kaldırılır.

Global TLS `badCertificateCallback` tamamen kaldırılır.

Debug, beta ve production build’lerde kullanılan Firebase projeleri/flavor kararları dokümante edilir.

Future<void> main() async {  WidgetsFlutterBinding.ensureInitialized();  await ApexKvStore.init();  await bootstrapFirebase();  await ApexNotificationService.instance.init();  runApp(const ApexFlowRoot());}

7.2 App Check

Android production için Play Integrity, Apple için App Attest ve gerektiğinde DeviceCheck fallback kullanılmalıdır. Debug provider yalnızca yerel geliştirme ve emulator ortamında etkin olmalıdır.

Önce App Check metrikleri izleme modunda değerlendirilir.

Emulator/debug tokenlar güvenli geliştirme kaydına eklenir; repository’ye yazılmaz.

Meşru beta istemcilerinin engellenmediği doğrulandıktan sonra Functions, Firestore ve Storage enforcement açılır.

App Check tek başına kullanıcı kimliği değildir; Firebase Auth kontrolleri devam eder.

7.3 Firebase dosya yapısı

firebase.json.firebasercfirestore.rulesfirestore.indexes.jsonstorage.rulesfunctions/  index.js  package.json  src/    bugReports/      validators.js      sanitizer.js      ids.js      createDraft.js      finalizeReport.js      listMyReports.js      addReporterInfo.js    discord/      client.js      messageBuilder.js      tagResolver.js      dispatchWorker.js      interactions.js      roleGuard.js    notifications/      bugStatusNotification.js    shared/      errors.js      rateLimit.js      audit.js

7.4 firebase.json hedefi

{  "functions": {    "source": "functions"  },  "firestore": {    "rules": "firestore.rules",    "indexes": "firestore.indexes.json"  },  "storage": {    "rules": "storage.rules"  },  "emulators": {    "auth": { "port": 9099 },    "functions": { "port": 5001 },    "firestore": { "port": 8080 },    "storage": { "port": 9199 },    "ui": { "enabled": true }  }}

TEST  Emulator-first

Functions, Firestore Rules ve Storage Rules production’a gönderilmeden önce Firebase Emulator Suite üzerinde otomatik testten geçmelidir. Antigravity ilk deploy’a kadar gerçek Discord forumuna test kaydı göndermemelidir; ayrı test forumu kullanılmalıdır.

8. Flutter Modül Mimarisi

Yeni özellik mevcut `FirebaseService` sınıfına yüzlerce satır eklenerek uygulanmamalıdır. Bug report bağımsız bir feature modülü olmalı; Riverpod kontrolcüsü domain modeli ile repository arasındaki akışı yönetmelidir.

lib/features/support/bug_report/├── domain/│   ├── bug_report.dart│   ├── bug_report_enums.dart│   ├── diagnostic_summary.dart│   ├── attachment_reference.dart│   └── bug_report_validation.dart├── data/│   ├── bug_report_repository.dart│   ├── firebase_bug_report_repository.dart│   ├── local_bug_outbox.dart│   └── bug_report_mapper.dart├── application/│   ├── bug_report_controller.dart│   ├── my_bug_reports_controller.dart│   └── diagnostic_collector.dart└── presentation/    ├── bug_report_screen.dart    ├── my_bug_reports_screen.dart    ├── bug_report_detail_screen.dart    └── widgets/        ├── bug_category_picker.dart        ├── attachment_picker.dart        ├── diagnostic_consent_card.dart        └── bug_status_timeline.dart

8.1 Domain modeli

@immutableclass BugReportDraft {  const BugReportDraft({    required this.idempotencyKey,    required this.title,    required this.category,    required this.impact,    required this.actualResult,    required this.expectedResult,    required this.reproductionSteps,    required this.repeatability,    required this.diagnosticConsent,    this.rideSessionId,    this.phonePlacement,    this.attachments = const [],    this.diagnostics,  });  final String idempotencyKey;  final String title;  final BugCategory category;  final BugImpact impact;  final String actualResult;  final String expectedResult;  final List<String> reproductionSteps;  final BugRepeatability repeatability;  final bool diagnosticConsent;  final String? rideSessionId;  final PhonePlacement? phonePlacement;  final List<LocalBugAttachment> attachments;  final DiagnosticSummary? diagnostics;}

8.2 Repository kontratı

abstract interface class BugReportRepository {  Future<BugDraftReceipt> createDraft(BugReportDraft draft);  Future<List<UploadedAttachment>> uploadAttachments(    BugDraftReceipt receipt,    List<LocalBugAttachment> attachments,  );  Future<BugSubmissionReceipt> finalizeReport(    BugDraftReceipt receipt,    List<UploadedAttachment> attachments,  );  Stream<List<BugReportSummary>> watchMyReports();  Future<void> addReporterInformation(    String bugId,    String response,  );}

8.3 Riverpod durumları

UI Durumu

Kullanıcıya Gösterilecek

idle

Form doldurulabilir.

validating

Alan hataları kontrol ediliyor.

creatingDraft

Rapor hazırlanıyor.

uploading

Ekler yükleniyor: yüzde ve dosya adı.

finalizing

Rapor gönderiliyor.

queuedOffline

İnternet geldiğinde gönderilecek.

submitted

AFB numarası ve Raporlarım bağlantısı.

failure

Tekrar dene; form ve ekler kaybolmaz.

8.4 Mevcut uygulamaya giriş noktaları

Ayarlar / Destek / Sorun Bildir: genel bug raporu.

Ayarlar / Destek / Raporlarım: kullanıcının kendi rapor geçmişi.

Sürüş özetinde `Bu ölçüm yanlış görünüyor`: Ride ID, kategori ve telemetri alanlarını otomatik doldurur.

Crash sonrası bir sonraki açılışta isteğe bağlı `Çökme hakkında bilgi gönder`: Crashlytics correlation ID’yi forma bağlar.

Bildirim tıklaması: ilgili Bug Report Detail ekranını açar.

9. Bug Report UI/UX ve Sürüş Güvenliği

9.1 Form alanları

Alan

Zorunlu

Kural

Kategori

Evet

Enum; serbest metin değil.

Başlık

Evet

10–120 karakter; kişisel veri uyarısı.

Gerçekleşen sonuç

Evet

20–2000 karakter.

Beklenen sonuç

Evet

10–1000 karakter.

Tekrar adımları

Evet

En az bir adım; toplam en fazla 3000 karakter.

Tekrarlanma

Evet

Bir kez / Bazen / Her zaman.

Kullanıcı etkisi

Evet

Priority değil, etki seçilir.

İlgili sürüş

Hayır

Kullanıcıya ait yerel Ride ID.

Telefon konumu

Telemetride evet

Cep/Gidon/Çanta/Diğer/Bilinmiyor.

Ekler

Hayır

En fazla 3 dosya; boyut ve MIME kontrolü.

Tanılama rızası

Evet/Hayır seçimi

Varsayılan kapalı; açıklama açık ve anlaşılır.

9.2 Sürüş sırasında etkileşim

SÜRÜŞ GÜVENLİĞİ  Motosiklet hareket hâlindeyken form açılmaz

Aktif sürüş veya hareket tespit edildiğinde ayrıntılı rapor formu açılmamalıdır. Uygulama yalnızca güvenli şekilde durulduktan sonra rapor tamamlanabileceğini gösterir. Telemetri anomalisinin zamanı arka planda işaretlenebilir; kullanıcıdan hareket hâlindeyken işlem istenmez.

9.3 Sürüş özeti hızlı raporu

Max yatış açısı veya maksimum hız kartında `Bu ölçüm yanlış görünüyor` eylemi bulunmalıdır. Bu eylem formu aşağıdaki alanlarla önceden doldurur:

Kategori: Lean Angle veya Speed

Ride ID

Hesaplanan değer

Motor/algoritma sürümü

Güven skoru ve invalidReason

Telefon yerleşimi mevcutsa

Raporlanan olayın timestamp’i

9.4 Başarı ekranı

Raporunuz alındıAFB-2026-000123QA ekibimiz raporu inceleyecek. Durum değişiklikleriniRaporlarım bölümünden takip edebilirsiniz.[Raporu Görüntüle]   [Kapat]

9.5 Erişilebilirlik ve yerelleştirme

Bütün metinler `AppStrings`/mevcut i18n yapısına eklenir; UI içinde sabit Türkçe metin bırakılmaz.

Buton ve durum ikonlarına semantik etiket eklenir.

Renk tek anlam taşıyıcısı değildir; durum adı metin olarak gösterilir.

Hata mesajı ilgili alanın yanında ve ekran okuyucuya okunabilir biçimde gösterilir.

Dosya yükleme ilerlemesi yüzde, dosya adı ve iptal seçeneği içerir.

10. Güvenli Tanılama Paketi

Tanılama verisi `allowlist` yaklaşımıyla üretilmelidir. Uygulamadaki bütün state’in JSON’a çevrilip gönderilmesi yasaktır. Yalnızca bu belgede izin verilen alanlar toplanır.

10.1 Genel allowlist

Grup

İzin Verilen Alanlar

Build

appVersion, buildNumber, flavor, environment

Cihaz

manufacturer, model, OS/API version, locale, timezone

Uygulama

currentRoute, themeMode, featureFlags, correlationId

Bağlantı

networkType özeti; SSID/IP yok

İzinler

location/backgroundLocation/notification izin durumları

Kimlik

Server tarafından anonimleştirilmiş reporter code; e-posta/telefon yok

Crash

Crashlytics correlation ID, son non-PII breadcrumb’lar

10.2 Telemetri allowlist

Alan

Açıklama

rideSessionId

Kullanıcının seçtiği sürüş kimliği.

phonePlacement

Cep, gidon, çanta, bilinmiyor.

speedEngineVersion

Hız motorunun semantic version bilgisi.

leanEngineVersion

Yatış motorunun semantic version bilgisi.

reportedMaxSpeedKmh

Kullanıcıya gösterilen sonuç.

reportedMaxLeanAngleDeg

Kullanıcıya gösterilen sonuç.

confidence

Motorun kendi güven skoru.

invalidReason

Kalite kapısı reddetme nedeni.

accepted/rejected samples

Özet sayaçlar.

accuracySummary

Min/median/p95/max; ham koordinat yok.

speedSourceSummary

Doppler/math/fused kaynak dağılımı.

samplingSummary

İstenen ve gerçekleşen örnekleme frekansı özeti.

10.3 Kesinlikle gönderilmeyecek alanlar

Ham GPS koordinat dizisi veya tam rota

Ev/iş adresi ve harita ekran görüntüsündeki hassas adres

Firebase ID token, refresh token, bot token, webhook URL

Şifre, e-posta, telefon, plaka, acil durum kişisi

Kişinin fotoğraf galerisi veya seçmediği dosyalar

Bütün Firestore kullanıcı dokümanı

Sınırsız log veya network request body

10.4 Tanılama özeti modeli

class DiagnosticSummary {  const DiagnosticSummary({    required this.schemaVersion,    required this.appVersion,    required this.buildNumber,    required this.deviceModel,    required this.osVersion,    required this.currentRoute,    required this.permissionStates,    required this.correlationId,    this.telemetry,  });  final int schemaVersion;  final String appVersion;  final int buildNumber;  final String deviceModel;  final String osVersion;  final String currentRoute;  final Map<String, String> permissionStates;  final String correlationId;  final SafeTelemetrySummary? telemetry;}

PRIVACY  Diagnostic ID, ham veri değil

Discord’a `AFD-72P6K9` gibi bir Diagnostic ID gönderilir. Ayrıntılı paket yalnızca yetkili backend/QA erişiminde ve sınırlı saklama süresiyle tutulur.

11. Draft, Ek Yükleme ve Finalize Protokolü

11.1 Neden iki aşamalı?

Büyük ekran kaydı veya zayıf bağlantı tek bir Callable isteğine bağlanmamalıdır. Önce server draft oluşturur; istemci kontrollü Storage yollarına dosyaları yükler; finalize fonksiyonu dosyaları doğrulayarak kaydı submitted yapar.

`createBugReportDraft`: Validasyon, idempotency ve AFB üretimi.

`uploadAttachments`: Her dosyayı izin verilen kullanıcı/bug yoluna yükleme.

`finalizeBugReport`: Dosya varlığı, sahiplik, MIME, boyut ve rıza doğrulaması.

Firestore transaction: status=submitted ve dispatch_outbox=pending.

Kullanıcıya AFB receipt dönülmesi.

11.2 Draft durumları

local_pending  -> creating_server_draft  -> uploading_attachments  -> finalizing  -> submittedHer ağ hatasında:  -> queued_offline  -> retrying

11.3 Dosya politikası

Tür

MIME

Önerilen Limit

Discord’a Kopya

Ekran görüntüsü

image/jpeg, image/png, image/webp

5 MB / dosya

Yalnız açık rıza ve sanitizasyonla

Ekran kaydı

video/mp4, video/quicktime

25 MB / dosya

Hayır; Diagnostic ID üzerinden

Tanılama JSON

application/json

1 MB

Hayır

Metin log

text/plain

1 MB

Hayır

11.4 Storage yolu

bugReports/{uid}/{internalBugId}/├── screenshots/{attachmentId}.png├── recordings/{attachmentId}.mp4└── diagnostics/{diagnosticBundleId}.json

11.5 Storage Rules iskeleti

İskelet kuraldır. Antigravity folder/MIME fonksiyonlarını ve emulator testlerini tamamlamadan deploy etmemelidir.

rules_version = '2';service firebase.storage {  match /b/{bucket}/o {    match /bugReports/{uid}/{bugId}/{folder}/{fileName} {      allow read: if request.auth != null                  && request.auth.uid == uid;      allow create: if request.auth != null                    && request.auth.uid == uid                    && request.resource.size < 25 * 1024 * 1024                    && isAllowedType(folder, request.resource.contentType);      allow update, delete: if false;    }  }}

DEFENSE IN DEPTH  Rules yeterli değildir

Finalize fonksiyonu Admin SDK ile dosya metadata’sını yeniden doğrulamalıdır. İstemci ve Storage Rules kontrolü savunmanın ilk katmanıdır; server doğrulaması ikinci katmandır.

12. Callable API Kontratları

12.1 createBugReportDraft

REQUEST{  "idempotencyKey": "uuid-v4",  "title": "Yatış açısı 168 derece gösterildi",  "category": "lean_angle",  "impact": "wrong_telemetry",  "actualResult": "...",  "expectedResult": "...",  "reproductionSteps": ["...", "..."],  "repeatability": "once",  "rideSessionId": "ride_a842f",  "phonePlacement": "pocket",  "diagnosticConsent": true,  "diagnostics": { "schemaVersion": 1, "...": "safe values" },  "attachmentManifest": [    { "clientId": "a1", "kind": "screenshot", "mime": "image/png", "size": 481223 }  ]}RESPONSE{  "internalBugId": "auto-firestore-id",  "bugId": "AFB-2026-000123",  "status": "draft",  "uploadPaths": {    "a1": "bugReports/{uid}/{internalBugId}/screenshots/a1.png"  },  "expiresAt": "server timestamp"}

12.2 finalizeBugReport

REQUEST{  "internalBugId": "auto-firestore-id",  "idempotencyKey": "uuid-v4",  "uploadedAttachments": [    { "clientId": "a1", "storagePath": "...", "sha256": "..." }  ]}RESPONSE{  "bugId": "AFB-2026-000123",  "status": "submitted",  "discordSyncStatus": "pending"}

12.3 Kullanıcı API’leri

Fonksiyon

Amaç

Kritik kontrol

listMyBugReports

Kullanıcının kendi rapor özetleri.

request.auth.uid eşleşmesi; sayfalama.

getMyBugReport

Tek rapor, kullanıcıya açık event’ler.

Internal QA notları filtrelenir.

addReporterInformation

Need Info talebine cevap.

Durum needs_info olmalı; uzunluk/rate limit.

requestReportDeletion

Gizlilik talebi.

Audit ve yasal saklama politikasıyla işlenir.

cancelDraft

Gönderilmemiş draft ve ekleri temizleme.

Yalnız draft sahibi.

12.4 Standart hata kodları

Kod

Kullanıcı mesajı

İstemci davranışı

unauthenticated

Oturumunuzu yenileyip tekrar deneyin.

Login yönlendirme.

failed-precondition

Rapor bu işlem için uygun durumda değil.

Sunucudan güncel kaydı çek.

invalid-argument

Bazı alanları kontrol edin.

Alan bazlı hata göster.

resource-exhausted

Kısa sürede çok fazla rapor gönderildi.

Retry-after göster.

unavailable

Bağlantı kurulamadı; rapor sıraya alındı.

Local outbox.

permission-denied

Bu işlem için yetkiniz yok.

Tekrar deneme; güvenlik logu.

internal

Rapor gönderilemedi; verileriniz saklandı.

Correlation ID ve güvenli retry.

13. Firestore Veri Modeli, İndeksler ve Kurallar

13.1 Koleksiyonlar

bug_reports/{internalBugId}bug_reports/{internalBugId}/events/{eventId}bug_reports/{internalBugId}/reporter_messages/{messageId}bug_reports/{internalBugId}/affected_testers/{discordOrUserHash}bug_report_idempotency/{uidHash_keyHash}bug_dispatch_outbox/{internalBugId}bug_dispatch_dead_letters/{internalBugId}bug_counters/{year}public_known_issues/{publicIssueId}

13.2 Ana bug dokümanı

{  "bugId": "AFB-2026-000123",  "source": "in_app",  "visibility": "qa_private",  "reporterUid": "firebase-uid",  "reporterPublicCode": "TESTER-4F9A",  "title": "...",  "category": "lean_angle",  "impact": "wrong_telemetry",  "priority": "untriaged",  "status": "submitted",  "platform": "android",  "appVersion": "1.0.0",  "buildNumber": 1,  "device": { "model": "...", "osVersion": "..." },  "rideSessionId": "ride_a842f",  "diagnosticBundleId": "AFD-72P6K9",  "attachmentCount": 1,  "duplicateOf": null,  "fixedInBuild": null,  "discord": {    "syncStatus": "pending",    "threadId": null,    "messageId": null,    "lastErrorCode": null  },  "createdAt": "serverTimestamp",  "updatedAt": "serverTimestamp"}

13.3 Event dokümanı

{  "type": "status_changed",  "fromStatus": "confirmed",  "toStatus": "in_progress",  "actorType": "discord_qa",  "actorIdHash": "sha256...",  "publicMessage": "Düzeltme üzerinde çalışılıyor.",  "internalNote": "Reproduced on build 126.",  "discordInteractionId": "...",  "createdAt": "serverTimestamp"}

13.4 Public ve internal alan ayrımı

Kullanıcıya gösterilecek event’lerde yalnızca `publicMessage` bulunur.

`internalNote`, Discord ID, raw error ve secret benzeri alanlar istemci query’sine dönmez.

Firestore rules tek başına alan filtrelemesi için yeterli görülmez; callable DTO açıkça güvenli alanları map eder.

İstemci doğrudan `bug_reports` koleksiyonuna yazmaz; create/finalize yalnızca Callable API üzerinden yapılır.

13.5 Önerilen indeksler

{  "indexes": [    {      "collectionGroup": "bug_reports",      "queryScope": "COLLECTION",      "fields": [        { "fieldPath": "reporterUid", "order": "ASCENDING" },        { "fieldPath": "createdAt", "order": "DESCENDING" }      ]    },    {      "collectionGroup": "bug_reports",      "queryScope": "COLLECTION",      "fields": [        { "fieldPath": "status", "order": "ASCENDING" },        { "fieldPath": "priority", "order": "ASCENDING" },        { "fieldPath": "updatedAt", "order": "DESCENDING" }      ]    },    {      "collectionGroup": "bug_dispatch_outbox",      "queryScope": "COLLECTION",      "fields": [        { "fieldPath": "state", "order": "ASCENDING" },        { "fieldPath": "nextAttemptAt", "order": "ASCENDING" }      ]    }  ],  "fieldOverrides": []}

13.6 Firestore Rules yaklaşımı

Üretim kuralı doğrudan kopyalanmamalı; mevcut koleksiyonlar ve kullanıcı erişim modeliyle emulator testinde birleştirilmelidir.

rules_version = '2';service cloud.firestore {  match /databases/{database}/documents {    function signedIn() {      return request.auth != null;    }    match /bug_reports/{bugId} {      allow create, update, delete: if false;      allow read: if signedIn()                  && resource.data.reporterUid == request.auth.uid;      match /events/{eventId} {        allow write: if false;        allow read: if signedIn()                    && get(/databases/$(database)/documents/bug_reports/$(bugId))                       .data.reporterUid == request.auth.uid                    && resource.data.publicMessage != null;      }    }    match /bug_dispatch_outbox/{document=**} {      allow read, write: if false;    }  }}

BACKEND AUTHZ  Admin SDK Rules’u bypass eder

Cloud Functions içindeki Admin SDK yazımları Firestore Security Rules’a tabi değildir. Bu nedenle callable içinde auth, ownership, enum, uzunluk, state transition ve role kontrolleri mutlaka tekrar yapılır.

14. Backend Uygulaması: Validasyon, ID ve Idempotency

14.1 createBugReportDraft Callable

const {onCall, HttpsError} = require("firebase-functions/v2/https");const {getFirestore, FieldValue} = require("firebase-admin/firestore");const crypto = require("crypto");exports.createBugReportDraft = onCall(  {    region: "europe-west1",    enforceAppCheck: true,  },  async (request) => {    if (!request.auth) {      throw new HttpsError("unauthenticated", "Authentication required");    }    const uid = request.auth.uid;    const input = validateBugDraft(request.data);    const keyHash = sha256(`${uid}:${input.idempotencyKey}`);    const db = getFirestore();    return db.runTransaction(async (tx) => {      const idempotencyRef =        db.collection("bug_report_idempotency").doc(keyHash);      const existing = await tx.get(idempotencyRef);      if (existing.exists) {        return existing.data().receipt;      }      await enforceRateLimitInTransaction(tx, uid);      const bugId = await allocateHumanBugId(tx, db);      const bugRef = db.collection("bug_reports").doc();      const receipt = buildDraftReceipt(bugRef.id, bugId, uid, input);      tx.create(bugRef, buildDraftDocument(uid, bugId, input));      tx.create(idempotencyRef, {        uidHash: sha256(uid),        receipt,        createdAt: FieldValue.serverTimestamp(),        expiresAt: plusDays(7),      });      return receipt;    });  },);

14.2 İnsan tarafından okunabilir AFB numarası

Firestore document ID rastgele kalmalıdır. `AFB-2026-000123` yalnızca operasyon ve kullanıcı iletişim numarasıdır. Düşük/orta beta hacminde yıllık sayaç transaction ile güvenli şekilde artırılabilir.

async function allocateHumanBugId(tx, db) {  const year = new Date().getUTCFullYear();  const counterRef = db.collection("bug_counters").doc(String(year));  const counterSnap = await tx.get(counterRef);  const lastNumber = counterSnap.exists    ? Number(counterSnap.data().lastNumber || 0)    : 0;  const next = lastNumber + 1;  tx.set(counterRef, {    lastNumber: next,    updatedAt: FieldValue.serverTimestamp(),  }, {merge: true});  return `AFB-${year}-${String(next).padStart(6, "0")}`;}

14.3 Validasyon kuralları

Kontrol

Server davranışı

Enum allowlist

Bilinmeyen category/impact/status değeri reddedilir.

Uzunluk

Başlık ve açıklamalar alt/üst sınırla doğrulanır.

Nesting

Beklenmeyen alanlar DTO’dan atılır; Firestore’a kör spread yapılmaz.

Ride sahipliği

Ride ID verilmişse kullanıcıya ait olduğu doğrulanır veya yalnız anonim referans olarak kabul edilir.

Attachment manifest

Tür, boyut, sayı ve clientId benzersizliği kontrol edilir.

Diagnostic consent

Rıza yoksa diagnostics payload tamamen silinir.

PII sanitizer

Token/secret patternları ve aşırı hassas alanlar reddedilir veya maskelenir.

Rate limit

UID, App Check ve gerekirse IP hash temelinde uygulanır.

14.4 Sanitizasyon

function sanitizeUserText(value, maxLength) {  const normalized = String(value ?? "")    .normalize("NFKC")    .replace(/\u0000/g, "")    .trim()    .slice(0, maxLength);  return normalized    .replace(/@everyone/gi, "@ everyone")    .replace(/@here/gi, "@ here")    .replace(/<@&?\d+>/g, "[mention removed]")    .replace(/https:\/\/discord(?:app)?\.com\/api\/webhooks\/[^\s]+/gi,             "[webhook removed]");}

INPUT SAFETY  Kullanıcı metni embed’e doğrudan verilmez

Sanitize işlemi yapılmalı ve Discord payload’ında `allowed_mentions: {parse: []}` kullanılmalıdır. Bu, mention saldırısını ve istem dışı rol bildirimlerini engeller.

15. Outbox, Discord Dispatcher ve Duplicate Koruması

15.1 Transactional outbox

Finalize işlemi bug kaydını ve Discord outbox dokümanını aynı Firestore transaction içinde oluşturmalıdır. Böylece bug submitted olduğu hâlde hiç kuyruğa girmeme veya kuyruğa girip bugın oluşmaması durumları önlenir.

await db.runTransaction(async (tx) => {  const bugSnap = await tx.get(bugRef);  assertOwnedDraft(bugSnap, uid);  await validateUploadedAttachments(bugSnap.data(), uid);  tx.update(bugRef, {    status: "submitted",    updatedAt: FieldValue.serverTimestamp(),    "discord.syncStatus": "pending",  });  tx.create(db.collection("bug_dispatch_outbox").doc(bugRef.id), {    bugRef: bugRef.path,    bugId: bugSnap.data().bugId,    state: "pending",    attemptCount: 0,    nextAttemptAt: FieldValue.serverTimestamp(),    createdAt: FieldValue.serverTimestamp(),  });});

15.2 Worker durumları

pending  -> leased  -> deliveredHata:leased -> pending (retryable)leased -> dead_letter (kalıcı / max attempt)

15.3 Retry politikası

Deneme

Bekleme

Not

1

Anında

İlk Discord gönderimi.

2

30 saniye

Geçici network/5xx.

3

2 dakika

Rate limit header dikkate alınır.

4

10 dakika

Aynı AFB başlığı kontrol edilir.

5

1 saat

Son otomatik deneme.

Sonrası

Dead letter

QA audit uyarısı ve manuel replay.

15.4 Discord forum başlığı oluşturma

async function createDiscordBugThread(report, tagIds, botToken, forumId) {  const response = await fetch(    `https://discord.com/api/v10/channels/${forumId}/threads`,    {      method: "POST",      headers: {        "Authorization": `Bot ${botToken}`,        "Content-Type": "application/json",      },      body: JSON.stringify({        name: buildThreadName(report),        applied_tags: tagIds,        message: {          embeds: [buildBugEmbed(report)],          components: buildQaButtons(report),          allowed_mentions: {parse: []},        },      }),    },  );  if (!response.ok) {    throw await mapDiscordError(response);  }  return response.json();}

15.5 Duplicate gönderim koruması

Worker başlamadan `discord.threadId` alanını kontrol eder.

Lease transaction ile tek worker’ın kaydı sahiplenmesi sağlanır.

Thread adı her zaman benzersiz AFB numarası taşır.

Belirsiz timeout sonrası retry öncesinde aktif ve arşivlenmiş thread’lerde AFB numarası aranır.

Bulunan thread yeniden kullanılmalı; ikinci başlık açılmamalıdır.

Discord response alındıktan hemen sonra threadId/messageId ve delivered state transaction ile yazılır.

RELIABILITY  At-least-once gerçeği

Dış API çağrısı ve Firestore update tek atomik işlem değildir. Bu nedenle dispatcher tam olarak bir kez garantisi iddia etmemeli; idempotent ve duplicate-aware tasarlanmalıdır.

16. Discord Mesaj Şablonu, Etiketler ve Butonlar

16.1 Thread başlığı

[AFB-2026-000123] [IN-APP] [Android] Yatış açısı 168° gösterildi

16.2 Embed içeriği

Alan

Discord’a yazılacak değer

Bug ID

AFB-2026-000123

Kaynak

ApexFlow In-App / Discord / Crashlytics

Anonim kullanıcı

TESTER-4F9A

Build

1.0.0+1 / beta

Platform

Android 16

Cihaz

Samsung Galaxy S23

Kategori

Lean Angle

Etki

Wrong telemetry

Ride ID

Kısaltılmış veya izinli referans

Diagnostic ID

AFD-72P6K9

Açıklama

Sanitize edilmiş actual/expected/steps

Ekler

Sayı ve private storage bilgisi; hassas URL yok

16.3 Buton kimlikleri

bug:confirm:{internalBugId}bug:need_info:{internalBugId}bug:in_progress:{internalBugId}bug:ready_retest:{internalBugId}bug:fixed:{internalBugId}bug:duplicate:{internalBugId}bug:close:{internalBugId}bug:affected:{internalBugId}

`custom_id` içine kullanıcı girdisi, token veya uzun JSON konulmamalıdır. Internal bug ID kısa ve doğrulanabilir biçimde kullanılmalıdır.

16.4 Tag resolver

function resolveAppliedTags(report, config) {  return [    config.platformTags[report.platform],    config.categoryTags[report.category] ?? config.categoryTags.other,    config.statusTags[report.status],    config.priorityTags[report.priority ?? "p3"],  ].filter(Boolean);}

16.5 Discord limitleri için davranış

Thread adı 100 karakteri geçmeden anlamlı şekilde kısaltılır; AFB numarası asla kesilmez.

Uzun açıklamalar embed field’larına kör biçimde konmaz; kontrollü özet üretilir.

Discord’a gönderilemeyen ayrıntı Firestore’da kalır.

Gönderi başına en fazla dört forum etiketi kullanılır.

Hassas dosyaların Discord CDN’e kopyalanması varsayılan olarak kapalıdır.

17. Discord Interaction Endpoint ve Yetkilendirme

17.1 İstek işleme sırası

Raw body, timestamp ve Ed25519 imzasını doğrula.

PING ise gecikmeden PONG döndür.

Guild ID’nin Madeforth sunucusuna ait olduğunu doğrula.

Interaction ID’nin daha önce işlenmediğini kontrol et.

Butonun internal bug ID ve izin verilen action formatını doğrula.

Member role listesinde Madeforth QA veya izinli Developer rolünü doğrula.

Üç saniye içinde ephemeral deferred/ack response döndür.

Firestore transaction ile geçerli state transition uygula.

Event ve audit kaydı oluştur.

Discord mesajını/tag’leri güncelle ve kullanıcı bildirimi kuyruğa ekle.

17.2 Rol kontrolü

function assertQaRole(interaction, allowedRoleIds) {  const memberRoles = new Set(interaction.member?.roles ?? []);  const allowed = allowedRoleIds.some((roleId) => memberRoles.has(roleId));  if (!allowed) {    const error = new Error("Missing QA role");    error.code = "DISCORD_FORBIDDEN";    throw error;  }}

17.3 State transition allowlist

const ALLOWED_TRANSITIONS = {  submitted: ["new", "closed"],  new: ["needs_info", "confirmed", "closed"],  needs_info: ["new", "confirmed", "closed"],  confirmed: ["in_progress", "needs_info", "closed"],  in_progress: ["ready_for_retest", "needs_info", "closed"],  ready_for_retest: ["fixed", "in_progress", "needs_info"],  fixed: ["closed", "in_progress"],  closed: [],};

17.4 Need More Info modalı

QA butona basınca kullanıcıya sorulacak tek, açık ve spesifik soru girilir.

Soru `publicMessage` olarak kaydedilir; internal not ayrı alanda tutulur.

Kullanıcıya FCM gönderilir ve Raporlarım kartı Needs Info olur.

Kullanıcının yanıtı Firestore’a ve aynı Discord thread’ine bot mesajı olarak eklenir.

Yanıt geldikten sonra durum otomatik olarak New yapılmaz; QA yeniden değerlendirir.

17.5 Duplicate işlemi

QA asıl AFB numarasını modal içine girer.

Backend asıl kaydın varlığını ve aynı ürün ortamında olduğunu doğrular.

Mevcut bug `duplicateOf` alanıyla asıl kayda bağlanır.

Etkilenen kullanıcı/tester bilgisi asıl kayda idempotent biçimde eklenir.

Duplicate kayıt Closed yapılır; kullanıcıya asıl AFB numarası gösterilir.

AUTHZ  Görünmeyen buton güvenlik değildir

QA butonlarını yalnız yetkili kişilere göstermek faydalıdır; ancak gerçek yetkilendirme interaction payload içindeki rol kimliklerinin backend’de doğrulanmasıyla yapılır.

18. Çift Yönlü Senkronizasyon ve Kullanıcı Bildirimleri

18.1 Senkronizasyon kuralları

Kaynak olay

Firestore

Discord

ApexFlow

In-app submit

Bug + outbox

Özel thread

AFB receipt

Discord Confirm

Status + event

Tag/embed güncelle

Durum timeline

Discord Need Info

Request event

QA sorusu

FCM + cevap alanı

Kullanıcı cevap

Reporter message

Thread’e bot mesajı

Gönderildi durumu

Ready for Retest

fixedInBuild

Retest etiketi

FCM + build bilgisi

Tester doğruladı

Verification event

Thread’e sonuç

Teşekkür ekranı

Closed

Final event

Thread lock/archive

Kapanış durumu

18.2 FCM payload

{  "notification": {    "title": "ApexFlow raporunuz güncellendi",    "body": "AFB-2026-000123 için ek bilgi gerekiyor."  },  "data": {    "type": "bug_report_status",    "bugId": "AFB-2026-000123",    "internalBugId": "...",    "status": "needs_info",    "route": "/support/bug-report/..."  }}

18.3 Bildirim gizliliği

Kilit ekranı bildiriminde hassas açıklama veya sürüş detayı gösterilmez.

FCM data payload’da yalnız yönlendirme için gerekli kimlikler bulunur.

Internal QA notu hiçbir zaman push payload’a eklenmez.

FCM token loglarda düz metin tutulmaz; hata loglarında maskelenir.

18.4 Raporlarım ekranı

Kart alanı

Gösterim

AFB numarası

Monospace veya belirgin operasyon etiketi.

Başlık

Kullanıcının verdiği kısa başlık.

Durum

Metin + ikon + renk; yalnız renge bağımlı değil.

Son güncelleme

Yerel saat diliminde.

Aksiyon

Need Info ise cevapla; Retest ise tekrar test et.

Build

Düzeltildiği sürüm varsa göster.

18.5 Discord hesabı zorunlu değildir

ApexFlow içinden rapor gönderen kullanıcının Discord hesabı olmak zorunda değildir. Discord, Madeforth ekibinin operasyon yüzeyidir. İleride isteğe bağlı Discord hesap bağlantısı eklenebilir; ilk sürümün kabul kriteri değildir.

19. Crashlytics Korelasyonu

19.1 Amaç

Manuel kullanıcı anlatımı ile otomatik crash/non-fatal teknik olayı aynı AFB numarası veya correlation ID üzerinden eşleştirmek gerekir. Crashlytics bug takip veri tabanı değildir; stack trace ve hata kümelendirme kaynağıdır.

final crashlytics = FirebaseCrashlytics.instance;await crashlytics.setCustomKey("bug_report_id", bugId);await crashlytics.setCustomKey("ride_session_hash", safeRideHash);await crashlytics.setCustomKey("lean_engine_version", leanEngineVersion);await crashlytics.setCustomKey("speed_engine_version", speedEngineVersion);await crashlytics.setCustomKey("phone_placement", phonePlacement.name);crashlytics.log("User submitted an in-app bug report");

19.2 PII yasağı

Crashlytics user identifier anonim/hash operasyon kimliği olmalıdır.

E-posta, telefon, plaka, tam Ride ID veya koordinat custom key yapılmaz.

Custom loglara request body veya Firebase token yazılmaz.

Custom key sayısı ve boyutu kontrollü tutulur; yüksek kardinalite sınırlanır.

19.3 Non-fatal kullanım alanları

Olay

Fatal?

Kayıt

UI/build exception

Hayır

recordError + currentRoute

Bug submit backend 5xx

Hayır

error code + correlation ID

Discord sync hatası

İstemci değil

Cloud Logging/outbox; Crashlytics’e yazılmaz

Telemetry invariant ihlali

Hayır

Non-fatal + motor sürümü + güvenli özet

Unhandled Flutter exception

Evet

Flutter fatal handler

Unhandled platform async error

Evet

PlatformDispatcher handler

TELEMETRY  Yanlış telemetriyi crash gibi ele alma

168° gibi fiziksel olarak geçersiz sonuç uygulamayı çökertmek yerine quality/invariant olayı olarak kaydedilmeli, kullanıcıya güvenilmez ölçüm bilgisi verilmeli ve güvenli tanılama özeti oluşturulmalıdır.

20. Offline Outbox, Retry ve Dayanıklılık

20.1 Yerel outbox

ApexFlow offline-first yaklaşımına uygun olarak form ve seçilmiş ek referansları yerelde kuyruklanmalıdır. Bu kayıt ayrı bir Isar/Hive/ApexKvStore modeliyle tutulmalı; kullanıcı uygulamayı kapatsa bile kaybolmamalıdır.

class PendingBugSubmission {  final String localId;  final String idempotencyKey;  final BugReportDraft draft;  final List<String> localAttachmentPaths;  final int attemptCount;  final DateTime nextAttemptAt;  final PendingBugState state;  final String? serverBugId;  final String? lastSafeErrorCode;}

20.2 Retry algoritması

Connectivity durumu yalnız ipucu kabul edilir; gerçek upload/callable her zaman try/catch ile denenir.

Exponential backoff + jitter kullanılır.

4xx validation/auth hataları otomatik sonsuz retry yapılmaz.

5xx, timeout ve unavailable hataları retry edilir.

Uygulama açılışında, login sonrasında ve bağlantı geri geldiğinde outbox işlenir.

Aynı idempotencyKey her retry’da korunur.

Kullanıcı queued raporu iptal ederse yerel ekler güvenli biçimde temizlenir.

20.3 İstemci durum tablosu

Durum

Tekrar?

Kullanıcı mesajı

Network timeout

Evet

Rapor sıraya alındı; bağlantı geldiğinde gönderilecek.

Functions unavailable

Evet

Sunucuya ulaşılamadı; verileriniz korunuyor.

Unauthenticated

Login sonrası

Oturumunuzu yenileyin.

Invalid argument

Kullanıcı düzeltince

İşaretli alanları kontrol edin.

Attachment rejected

Dosya değişince

Dosya türü veya boyutu desteklenmiyor.

App Check rejected

Hayır / yapılandırma

Güvenli bağlantı doğrulanamadı.

20.4 Discord outage senaryosu

Finalize başarılı olur ve kullanıcı AFB numarasını alır.

Outbox pending/retry durumunda kalır.

QA audit ekranında Discord sync pending sayısı görülebilir.

Discord geri geldiğinde worker aynı AFB kaydını teslim eder.

Maksimum deneme sonrası dead-letter oluşturulur; bug kaydı asla silinmez.

21. Güvenlik, Gizlilik ve Kötüye Kullanım Koruması

21.1 Tehdit modeli

Tehdit

Kontrol

APK’dan webhook/token çıkarılması

Mobilde secret yok; bütün Discord çağrıları backend.

Sahte istemciden spam

Firebase Auth + App Check + server rate limit.

Mention saldırısı

Sanitize + `allowed_mentions.parse=[]`.

Dosya bombası / zararlı tür

Boyut, MIME, sayı, metadata ve server doğrulaması.

Başkasının raporuna erişim

Owner UID kontrolü; callable DTO; rules testleri.

Sahte Discord buton çağrısı

Ed25519 imza + guild + role + interaction idempotency.

Yetkisiz durum geçişi

Backend transition allowlist + audit.

Secret log sızıntısı

Structured logging redaction; payload dump yasak.

Duplicate Discord thread

Lease + AFB araması + stored threadId.

Hassas rota ifşası

Allowlist diagnostics; raw route Discord’a gönderilmez.

21.2 Rate limit önerisi

İşlem

Başlangıç limiti

Davranış

Draft create

5 / 10 dakika / UID

Aşımda resource-exhausted.

Finalize

10 / 10 dakika / UID

İdempotent retry hariç.

Reporter response

10 / saat / bug

Spam/tekrar kontrolü.

Discord affected

1 / kullanıcı / bug

Toggle; sayı tekil.

QA status action

30 / dakika / QA

Audit + duplicate interaction koruması.

21.3 Veri saklama

Veri

Önerilen saklama

Temizlik

Draft

24 saat

TTL/planlı cleanup.

Ekran görüntüsü/video

Bug kapandıktan sonra 90 gün

Storage lifecycle veya scheduled function.

Tanılama paketi

Bug kapandıktan sonra 30–90 gün

Risk seviyesine göre.

Bug metadata

Ürün QA geçmişi süresince

PII minimize edilmiş.

Audit event

En az release yaşam döngüsü

Silinmez/değişmez kayıt.

Idempotency

7 gün

TTL.

Dead letter

Çözümden sonra 30 gün

Manuel replay sonrası arşiv.

Saklama süreleri beta öncesi Gizlilik Politikası ve kullanıcı ülkesindeki yükümlülüklerle birlikte yeniden değerlendirilmelidir. Bu belge hukuki görüş yerine mühendislik minimizasyon prensibi sunar.

21.4 Secret yönetimi

Discord bot tokenı yalnız Secret Manager/Firebase Functions secret olarak tanımlanır.

Token console çıktısına, `.env.example` değerine veya Antigravity prompt’una yazılmaz.

Token sızdığından şüphelenilirse Discord Portal’dan derhal regenerate edilir.

Bot tokenı ile user token karıştırılmaz; self-bot kullanılmaz.

Test ve production Discord sunucusu/forum kimlikleri ayrı config olarak tutulur.

BLOCKER  Mevcut TLS override P0 blokerdir

Tüm sertifikaları kabul eden HttpOverrides kaldırılmadan App Check, Auth veya webhook güvenli kabul edilemez. Antigravity bu bulguyu ilk güvenlik fazında kapatmalıdır.

22. Gözlemlenebilirlik, Audit ve Operasyon Metrikleri

22.1 Structured log alanları

{  "event": "discord_dispatch_failed",  "bugId": "AFB-2026-000123",  "internalBugIdHash": "...",  "attempt": 3,  "discordStatus": 429,  "retryAfterMs": 1500,  "correlationId": "...",  "environment": "beta"}

Logda title, actualResult, kullanıcı adı, token veya attachment URL bulunmaz.

Bug ID ve correlation ID operasyon eşleştirmesi için tutulur.

Hata nesnesi serialize edilmeden önce secret/URL redaction uygulanır.

Her status değişikliği append-only event ve audit log üretir.

22.2 İzlenecek metrikler

Metrik

Amaç

bug_submit_success_rate

Uygulama içi gönderim güvenilirliği.

bug_submit_latency_p50/p95

Backend kullanıcı deneyimi.

attachment_upload_failure_rate

Dosya politikasındaki veya networkteki sorun.

discord_dispatch_pending_count

Kuyruk sağlığı.

discord_dispatch_dead_letter_count

Operasyon müdahalesi.

time_to_first_triage

QA reaksiyon süresi.

needs_info_rate

Form kalitesi ve eksik alanlar.

duplicate_rate

Known issues görünürlüğü ve arama kalitesi.

retest_pass_rate

Düzeltmelerin doğruluk kalitesi.

reports_by_build/device/category

Regresyon kümeleri.

22.3 Alarm koşulları

P0 etkili yeni bug oluşturuldu.

Discord dead-letter sayısı sıfırın üzerine çıktı.

Son 15 dakikada submit success rate belirgin şekilde düştü.

App Check rejection oranı beta build değişimi sonrası yükseldi.

Aynı build/device üzerinde crash veya wrong telemetry kümesi oluştu.

Storage rejected upload sayısı anormal arttı.

23. Test Stratejisi ve QA Matrisi

23.1 Test katmanları

Katman

Kapsam

Dart unit

Validasyon, DTO map, sanitizer, outbox retry, status mapping.

Flutter widget

Form validation, güvenlik kilidi, success/error/queued durumları.

Repository integration

Callable mock, Storage upload, idempotency receipt.

Functions unit

Validator, human ID, state transitions, tag resolver.

Firebase Emulator

Auth, App Check test modu, Firestore/Storage Rules, triggers.

Discord contract

Payload snapshot, signature, role, 3-second response, rate limit.

End-to-end beta

Gerçek test Discord sunucusu + beta Firebase projesi.

Security

Secret scan, unauthorized reads, malformed input, mention injection.

23.2 Kritik test vakaları

ID

Senaryo

Beklenen

QA-001

Geçerli genel rapor

AFB üretilir; private Discord thread oluşur.

QA-002

168° yatış hızlı raporu

Ride ID ve lean diagnostics prefill edilir.

QA-003

Gerçek dışı max hız raporu

Speed motor sürümü ve confidence gider.

QA-004

Aynı submit iki kere

Tek AFB; tek Discord thread.

QA-005

Gönderirken internet kesilir

Local outbox; form kaybolmaz.

QA-006

Discord 500

AFB receipt başarılı; outbox retry.

QA-007

Discord 429

Retry-After uygulanır.

QA-008

Worker timeout sonrası retry

AFB araması duplicate thread’i engeller.

QA-009

Yetkisiz Discord rolü Confirm

Ephemeral denied; Firestore değişmez.

QA-010

Geçersiz Discord imzası

HTTP 401; audit güvenlik kaydı.

QA-011

@everyone içeren başlık

Mention sanitize; bildirim tetiklenmez.

QA-012

25 MB üstü dosya

Upload reddedilir; form korunur.

QA-013

Yasak MIME

İstemci ve rules/backend reddeder.

QA-014

Başkasının bugını okuma

Permission denied.

QA-015

Need Info

FCM + in-app cevap alanı.

QA-016

Kullanıcı ek bilgi gönderir

Thread’e bot mesajı; audit event.

QA-017

Duplicate işlemi

duplicateOf bağlanır; asıl affected sayısı artar.

QA-018

Ready for Retest

Build bilgisi ve FCM gider.

QA-019

Closed bug

Thread lock/archive; metadata korunur.

QA-020

Tanılama rızası kapalı

Diagnostics payload saklanmaz.

QA-021

Aktif sürüşte form açma

Güvenlik kilidi; form sürüş sonrasına yönlendirir.

QA-022

Firebase init başarısız

Sessiz başarı yok; kontrollü unavailable.

QA-023

App Check enforcement

Sahte istemci reddedilir; beta istemci geçer.

QA-024

Crash correlation

AFB custom key ve correlation eşleşir.

QA-025

Secret scan

APK/repo/log içinde Discord tokenı bulunmaz.

23.3 Emulator komutları

firebase emulators:startnpm --prefix functions testflutter testflutter analyzedart format --output=none --set-exit-if-changed lib testfirebase emulators:exec "npm --prefix functions test"

23.4 Test verisi politikası

Emulator testlerinde gerçek e-posta, telefon, rota veya Discord tokenı kullanılmaz.

Discord contract testleri HTTP client mock/fixture ile yapılır.

Gerçek test sunucusunda yalnız sentetik Ride ID ve diagnostic verisi kullanılır.

Golden payload’larda secret placeholder dahi gerçek formatta tutulmaz.

24. Antigravity Uygulama Fazları

Aşağıdaki fazlar önerilen çalışma sırasıdır. Her faz sonunda Antigravity değişiklik özeti, test çıktısı, kabul kriterleri ve kalan riskleri vermelidir.

Faz

Ad

Kapsam

Çıkış Kapısı

F0

Read-only audit

Repository, Firebase, auth, rules, notification ve test altyapısını doğrula.

Kod değişikliği yok; güncel durum raporu.

F1

P0 güvenlik

TLS override kaldır; FlutterFire platform config düzelt; init hata modelini iyileştir.

Analyze/test geçer; sertifika bypass yok.

F2

Dependencies & bootstrap

Functions, Storage, App Check, Crashlytics ve device/package paketlerini ekle.

Debug/beta bootstrap testleri.

F3

Domain & local outbox

Bug modelleri, enumlar, repository kontratı, Isar/Hive outbox.

Unit testler ve idempotency key kalıcılığı.

F4

UI/UX

Sorun Bildir, Raporlarım, detay/timeline ve sürüş güvenlik kilidi.

Widget/a11y/i18n testleri.

F5

Diagnostics

Allowlist collector, telemetry özetleri, rıza ve redaction.

PII denylist testleri.

F6

Firebase API

Draft/finalize/list/add info; human ID; validator; rate limit.

Emulator integration.

F7

Storage

Upload manager, rules, metadata doğrulama, cleanup.

Unauthorized/MIME/size testleri.

F8

Discord dispatcher

Outbox worker, thread/embed/tag, retry/dead-letter.

Mock Discord contract testleri.

F9

Discord interactions

Signature, role guard, buttons, state transitions, audit.

Invalid signature/role/state testleri.

F10

Bidirectional sync

FCM, Need Info, retest, Raporlarım güncellemesi.

E2E emulator + test server.

F11

Crashlytics

Fatal/non-fatal, AFB correlation, PII-safe keys.

Crash test build.

F12

Hardening

App Check enforcement plan, secret scan, privacy/retention, metrics.

Security checklist PASS.

F13

Beta release

Test Discord/Firebase’den beta ortamına kontrollü geçiş.

Manual approval + rollback plan.

24.1 Faz başına Antigravity prompt kalıbı

AF-AG-016 / FAZ: <FAZ KODU VE ADI>Bu DOCX'i bağlayıcı şartname kabul et.Önce bu fazla ilgili mevcut dosyaları oku ve bulguları özetle.Kullanıcının mevcut değişikliklerini koru.Yalnız bu fazı uygula; sonraki fazları uygulama.Zorunlu:- Secret veya gerçek kullanıcı verisi yazma.- Production deploy yapma.- Mevcut Riverpod/Firebase/notification yapısını yeniden kullan.- Yeni public API'leri tipli ve test edilebilir tasarla.- Hata yutma; güvenli error code ve correlation ID kullan.Tamamlandığında:1. Değiştirilen/yeni dosyalar2. Mimari kararlar3. Çalıştırılan komutlar4. Test sonuçları5. Kabul kriterleri PASS/FAIL6. Manuel kullanıcı adımları7. Kalan risklerraporunu ver.

24.2 Antigravity stop koşulları

Firebase project/package eşleşmesi belirsizse.

Repository’de çakışan kullanıcı değişikliği varsa.

Discord token/public key/forum/role ID kullanıcı tarafından henüz tanımlanmadıysa.

App Check beta istemcilerini engelliyorsa.

Firestore/Storage Rules emulator testleri geçmiyorsa.

Production deploy veya secret rotasyonu gerekiyorsa.

Migration mevcut kullanıcı verisini geri döndürülemez biçimde etkiliyorsa.

25. Dağıtım ve Ortam Runbook’u

25.1 Ortamlar

Ortam

Firebase

Discord

Amaç

Local

Emulator Suite

Mock HTTP

Unit/integration geliştirme.

Development

Dev project

Private dev forum

Antigravity ve geliştirici testi.

Beta

Beta/prod ayrımı karara bağlı

Madeforth private QA

12+ tester kapalı test.

Production

Production project

Madeforth production QA

Onay sonrası gerçek kullanıcı.

25.2 Manual kurulum değerleri

Değer

Kullanıcı işlemi

Antigravity’nin işlemi

Discord Application

Portal’da oluşturur.

Kodda config şemasını ve doğrulamayı kurar.

Bot token

Secret olarak tanımlar.

Tokenı görmez/yazmaz; secret referansını kullanır.

Public key

Portal’dan alır.

Signature verifier config’ine bağlar.

Forum/Role IDs

Developer Mode ile kopyalar.

Environment config ve startup validation.

Firebase App Check

Console provider/enforcement.

SDK init ve debug/beta testi.

Cloud Functions deploy

Son onayı verir.

Önce dry-run/emulator ve deploy komut listesini hazırlar.

25.3 Secret tanımlama örneği

# Gerçek değer bu belgeye veya source code'a yazılmaz.firebase functions:secrets:set DISCORD_BOT_TOKENfirebase functions:secrets:set DISCORD_PUBLIC_KEY

25.4 Deployment sırası

Bütün unit/widget/emulator testlerini çalıştır.

Secret scan ve dependency audit yap.

Firestore indexes ve rules değişikliklerini gözden geçir.

Storage rules testlerini çalıştır.

Functions’ı development ortamına deploy et.

Discord Interactions URL’i development endpoint’e bağla ve PING doğrula.

Sentetik bir in-app rapor ile tam E2E akışı test et.

Rollback ve dead-letter replay’i test et.

Kullanıcı onayıyla beta ortamına geç.

App Check enforcement’i metrikler doğrulandıktan sonra kademeli aç.

25.5 Rollback

Yeni UI feature flag ile kapatılabilir.

Callable yeni API version path’iyle yayınlanır; önceki istemciyi kırmaz.

Discord dispatcher kapatılsa bile Firestore bug kayıtları korunur.

Outbox replay daha sonra yapılabilir.

Rules rollback, önceki güvenli kurala dönmelidir; asla geniş `allow read, write: if true` kullanılmaz.

Bot token sızıntısında token rotate edilir ve eski token derhal geçersiz olur.

26. QA Operasyon Playbook’u

26.1 Yeni rapor triage adımları

AFB numarası, build, platform ve kategori alanlarını kontrol et.

Raporun kişisel/hassas veri içerip içermediğini kontrol et; gerekiyorsa eki karantinaya al.

Known issues ve açık buglarda duplicate ara.

Tekrar üretim adımlarını çalıştır; mümkün değilse Need Info kullan.

Impact ve kanıta göre P0–P3 önceliğini belirle.

Confirmed ise Antigravity/GitHub geliştirme kaydını aç.

Düzeltildiği build’i gir ve Ready for Retest yap.

En az ilgili tester veya QA cihazında doğrulama sonrası Fixed/Closed yap.

26.2 Önerilen hedef süreler

Öncelik

İlk triage

İletişim

P0

Derhal

Test durdurma ve owner bildirimi.

P1

Aynı iş günü

Tester’a alındı/doğrulandı bilgisi.

P2

2 iş günü

Planlanan build/sprint bilgisi.

P3

Beta sprint planında

Toplu UI düzeltme notu.

26.3 Known issue yayınlama

Yalnız doğrulanmış ve sanitize edilmiş sorun yayınlanır.

Kullanıcı adı, cihaz seri bilgisi, Ride ID ve diagnostic ID public içerikte bulunmaz.

Etkilenen build’ler ve geçici çözüm varsa açıkça yazılır.

Fixed olduğunda düzeltildiği build ve retest sonucu eklenir.

26.4 Bug kapanış kontrolü

Kod değişikliği ilgili testleri içeriyor.

Düzeltme beta build’e girdi.

Orijinal senaryo tekrar test edildi.

Regresyon testi yapıldı.

Kullanıcıya açık kapanış mesajı yazıldı.

Hassas ekler için retention takvimi işaretlendi.

Discord thread kapatıldı; Firestore event tamamlandı.

27. Nihai Kabul Kriterleri ve Definition of Done

27.1 Fonksiyonel kabul

ApexFlow’dan genel ve sürüşe bağlı bug raporu gönderilebiliyor.

Her gönderim server taraflı benzersiz AFB numarası üretiyor.

Aynı idempotency key tekrarında ikinci kayıt oluşmuyor.

Ham in-app rapor özel Discord QA forumuna otomatik düşüyor.

Discord forum başlığı doğru dört etiketi taşıyor.

QA butonları Firestore statüsünü güncelliyor.

Need Info kullanıcının uygulamasına ulaşıyor ve cevap thread’e dönüyor.

Ready for Retest build bilgisiyle kullanıcıya bildiriliyor.

Raporlarım ekranı yalnız kullanıcının kendi güvenli verisini gösteriyor.

Discord erişilemezken rapor kaybolmuyor ve daha sonra teslim ediliyor.

27.2 Güvenlik kabul

Bot tokenı, webhook URL’si veya secret APK/repository/log içinde yok.

Global TLS certificate bypass kaldırılmış.

Firebase platform ayarları FlutterFire ile doğru çözülüyor.

App Check debug ve beta/production sağlayıcıları ayrılmış.

Firestore ve Storage rules emulator testleri yetkisiz erişimi reddediyor.

Discord Interaction imzası, guild ve QA rolü doğrulanıyor.

`allowed_mentions` kapalı ve kullanıcı metni sanitize ediliyor.

Ham GPS, PII ve tokenlar diagnostic/Discord payload’ına girmiyor.

Dosya türü, boyutu ve sahipliği server tarafından doğrulanıyor.

27.3 Kalite kabul

`flutter analyze` hatasız.

`flutter test` ve Functions testleri başarılı.

Firebase Emulator entegrasyon testleri başarılı.

En az QA-001–QA-025 kritik senaryoları PASS.

Crashlytics correlation doğrulandı.

Retry/dead-letter ve duplicate thread senaryosu test edildi.

Türkçe/İngilizce metinler i18n sisteminde.

Aktif sürüş güvenlik kilidi test edildi.

Kullanıcı değişiklikleri korunmuş ve yeni modül dokümante edilmiş.

NO-GO  Release gate

Yukarıdaki maddelerden herhangi biri FAIL ise Madeforth QA Bot ve in-app Bug Report sistemi production-ready sayılmaz. Özellikle secret, TLS, Rules, imza ve idempotency maddeleri ertelenemez.

Ek A — Örnek Discord Bug Embed Payload

{  "name": "[AFB-2026-000123] [IN-APP] [Android] Yatış açısı 168°",  "applied_tags": ["ANDROID", "LEAN_ANGLE", "NEW", "P1"],  "message": {    "embeds": [{      "title": "AFB-2026-000123",      "color": 1161437,      "fields": [        {"name": "Kaynak", "value": "ApexFlow In-App", "inline": true},        {"name": "Build", "value": "1.0.0+1", "inline": true},        {"name": "Tester", "value": "TESTER-4F9A", "inline": true},        {"name": "Kategori", "value": "Lean Angle", "inline": true},        {"name": "Diagnostic", "value": "AFD-72P6K9", "inline": true},        {"name": "Gerçekleşen", "value": "Maksimum yatış 168° gösterildi."},        {"name": "Beklenen", "value": "Güvenilir ölçüm veya geçersiz sonuç uyarısı."}      ],      "footer": {"text": "Madeforth QA • Firestore source of truth"}    }],    "allowed_mentions": {"parse": []}  }}

Ek B — Discord QA Panel Metni

APEXFLOW BETA FEEDBACKMotosiklet hareket hâlindeyken rapor oluşturmayın.Güvenli şekilde durduktan sonra devam edin.Bug bildirirken:• Ne yaptığınızı• Ne beklediğinizi• Gerçekte ne olduğunu• Telefon modelini ve build sürümünübelirtin.[BUG REPORT OLUŞTUR][BUGLARIM][BİLİNEN SORUNLAR]

Ek C — Kullanıcıya Açık Durum Mesajları

Durum

Mesaj

Submitted

Raporunuz alındı ve QA sırasına eklendi.

New

Madeforth QA ekibi raporunuzu incelemeye başladı.

Needs Info

Raporunuz için ek bilgi gerekiyor.

Confirmed

Sorun doğrulandı.

In Progress

Düzeltme üzerinde çalışılıyor.

Ready for Retest

Yeni beta sürümünde tekrar test etmenizi bekliyoruz.

Fixed

Sorun düzeltildi ve doğrulandı.

Closed

Rapor kapatıldı.

Duplicate

Raporunuz mevcut bir sorunla birleştirildi.

Ek D — Antigravity Son Kontrol Prompt’u

AF-AG-016 kapsamındaki tüm fazları yalnızca incele; yeni özellik ekleme.1. DOCX kabul kriterlerini kodla karşılaştır.2. APK/repository/loglarda Discord tokenı veya webhook URL’si ara.3. TLS certificate bypass bulunmadığını doğrula.4. FlutterFire platform config’ini doğrula.5. Firestore/Storage Rules emulator testlerini çalıştır.6. Idempotency ve duplicate Discord dispatch testlerini çalıştır.7. Discord signature/role/state transition testlerini çalıştır.8. Offline outbox ve FCM senaryolarını doğrula.9. PII/ham GPS denylist testlerini çalıştır.10. QA-001–QA-025 sonuçlarını PASS/FAIL tablosu olarak raporla.FAIL olan maddeleri düzeltme; önce neden, dosya, risk ve önerilen fix’i raporla.Kullanıcı onayı olmadan production deploy yapma.

Ek E — Resmî Teknik Kaynaklar

Discord Components Reference

Discord Interactions Overview

Discord Receiving and Responding

Discord Channel / Forum API

Discord Webhook API

Discord Forum Channels FAQ

Firebase Callable Functions

Firebase App Check for Flutter

Firebase Crashlytics for Flutter

Firebase Storage Security Rules

Firestore Security Rules

Uygulama Handoff Özeti

OUTCOME  Nihai hedef

ApexFlow veya Discord üzerinden gelen bütün raporlar tek AFB yaşam döngüsünde birleşecek; Firestore gerçeği saklayacak, Madeforth QA Bot Discord operasyonunu yönetecek, kullanıcı Raporlarım ve FCM üzerinden süreci takip edecektir.

Motor

Nihai sorumluluk

ApexFlow Bug Report Engine

Güvenli form, tanılama, ekler, offline outbox.

Firebase Bug Lifecycle Engine

Auth, App Check, kimlik, state, audit ve kalıcılık.

Madeforth Discord QA Bot

Forum, etiket, buton, rol ve operasyon.

Bidirectional Sync Engine

Discord ↔ Firestore ↔ FCM ↔ ApexFlow.

QA Governance

Triage, duplicate, retest, kapanış ve metrikler.

END OF IMPLEMENTATION SPECIFICATION