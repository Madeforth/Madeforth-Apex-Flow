MADEFORTH  /  PRODUCT SYSTEMS


APEX FLOW


Premium Typography & Product Interface System


Antigravity tarafından doğrudan uygulanmak üzere hazırlanmış Flutter entegrasyon, tasarım token’ı, erişilebilirlik, migrasyon ve QA spesifikasyonu


GEIST SANS  +  GEIST MONO   •   OFFLINE-FIRST


V1.0  •  03 AĞUSTOS 2026  •  IMPLEMENTATION READY


Hedef: Apex Flow’un tipografisini, üst düzey bir global teknoloji şirketinin ürün tasarım ekibinden çıkmış kadar tutarlı, sakin, güvenilir ve rafine hâle getirmek.




Belge kontrolü ve uygulama emri


Alan


Tanım


Belge


Apex Flow Premium Typography System — Antigravity Specification V1


Ürün


Apex Flow motosiklet sürüş ve makine ilişkisi uygulaması


Sahip


Madeforth


Hedef platform


Öncelikle Flutter / Android; iOS uyumlu mimari


Karar


Geist Sans ana arayüz; Geist Mono seçili teknik metadata


Dağıtım


Font dosyaları uygulama paketine yerel asset olarak gömülecek


Kapsam dışı


Logo geometrisinin veya ürün işlevlerinin yeniden tasarlanması


Başarı ölçütü


Tutarlı hiyerarşi, çevrimdışı çalışma, 200% yazı ölçeğinde kırılmama





BAĞLAYICI KARAR  Antigravity bu belgeyi öneri listesi olarak değil, uygulanacak ürün tasarım sistemi sözleşmesi olarak ele almalıdır. Görünür marka adı her yerde “Apex Flow” şeklinde ayrı yazılacaktır.


Belge haritası


Yönetici kararı ve hedef deneyim


Font ailesi, lisans ve marka uyumu


Tipografi token’ları ve bileşen kuralları


Flutter asset ve tema entegrasyonu


Erişilebilirlik, lokalizasyon ve telemetri rakamları


Migrasyon planı, QA matrisi ve kabul kriterleri


Antigravity için kopyalanabilir nihai uygulama görevi


1. Yönetici kararı


Apex Flow için önerilen üretim tipografi sistemi Geist Sans + Geist Mono’dur. Geist Sans, tüm ana kullanıcı arayüzünün ve büyük telemetri değerlerinin temelidir. Geist Mono yalnızca teknik kimlikler, kısa durum kodları, zaman/GPS metadata’sı ve hizalı yardımcı değerlerde kullanılacaktır.


Bu kararın amacı uygulamayı bir yarış oyunu veya modifiye motosiklet göstergesi gibi göstermek değil; Meta, Vercel veya üst düzey bir Avrupa ürün tasarım ekibinin üreteceği ölçüde kontrollü, sessiz ve güven veren bir teknoloji ürününe dönüştürmektir.


1.1 Neden önceki Manrope + Barlow önerisi değişti?


Seçim


Güçlü taraf


Apex Flow açısından değerlendirme


Manrope


Temiz, modern ve okunaklı


İyi fakat çok sayıda mobil üründe görüldüğü için marka özgünlüğü sınırlı kalabilir.


Barlow Semi Condensed


Ulaşım ve gösterge karakteri güçlü


Tüm ürüne yayılırsa yarış oyunu veya satış sonrası gösterge hissi oluşturabilir.


Geist Sans


Sade, hassas ve ürün odaklı


Premium teknoloji uygulaması karakterine daha dengeli uyum sağlar.


Geist Mono


Teknik ve hizalı bilgi sunumu


Sınırlı kullanımda telemetri katmanını güçlendirir; aşırı kullanımda terminal hissi yaratır.





1.2 Tek cümlelik yaratıcı yön


CREATIVE NORTH STAR  Sürücünün telefonunda çalışan sakin bir yarış mühendisliği ürünü: yüksek teknik güven, düşük görsel gürültü.


2. Marka ve deneyim hedefi


2.1 Marka karakteri


Premium: Gösterişli değil; hassas boşluk, doğru ağırlık ve kontrollü renk kullanımıyla değerli görünür.


Endüstriyel: Motosiklet teknolojisine referans verir fakat fiziksel gösterge panelini taklit etmez.


Sakin: Neon, agresif italik, aşırı dar font ve sürekli büyük harf kullanımından kaçınır.


Güvenilir: Telemetri değerleri hizalı, okunaklı ve bilgi hiyerarşisi açısından tartışmasızdır.


Global: Türkçe, İngilizce ve Almanca metinlerde aynı kaliteyi korur.


Offline-first: Font hiçbir zaman ağdan indirilmez; paket içinde teslim edilir.


2.2 Görsel kaliteyi fonttan daha fazla etkileyen kararlar


Bir ekranda en fazla üç belirgin tipografik seviye görünmelidir.


Büyük rakamların çevresinde geniş negatif alan bırakılmalıdır.


Kart başlıkları ile gövde metni arasındaki fark yalnız boyutla değil, ağırlık ve renk kontrastıyla kurulmalıdır.


Birincil cyan yalnız seçili odak, aktif durum ve veri vurgularında kullanılmalıdır.


Turuncu, kritik apex/uyarı/özel vurgu rengidir; başlık rengi olarak yaygınlaştırılmamalıdır.


Köşe yuvarlaklığı, ikon çizgi kalınlığı, boşluk ve tipografi aynı token sisteminden yönetilmelidir.


2.3 Yasaklanan estetik davranışlar


Yasak


Neden


Orbitron, Audiowide, Rajdhani, Oxanium


Sistemi premium ürün yerine oyun/aftermarket gösterge estetiğine taşır.


Tüm başlıkları büyük harf yapmak


Okuma hızını düşürür ve sürekli bağıran bir ton oluşturur.


800–900 ağırlıkları yaygın kullanmak


Karanlık arayüzde kaba bloklar yaratır; görsel hiyerarşiyi öldürür.


Mono fontu bütün telemetride kullanmak


Kullanıcı ürünü yerine geliştirici konsolu hissi üretir.


Her widget içinde ayrı TextStyle yazmak


Ekranlar arasında drift ve bakım maliyeti oluşturur.


Fontu çalışma anında internetten çekmek


Offline-first ilkesini, açılış tutarlılığını ve gizliliği zedeler.





3. Font ailesi ve lisans kararı


3.1 Üretim ailesi: Geist


Geist, Vercel tarafından Basement Studio ve Andrés Briganti ile geliştirilen; okunabilirlik, sadelik, hız ve İsviçre tipografisi ilkelerini temel alan bir font ailesidir. Geist Sans ve Geist Mono aynı tasarım sisteminin parçaları olduğu için arayüz ile teknik veriler arasında doğal bir akrabalık kurar.


LISANS  Geist SIL Open Font License 1.1 ile yayımlanır. Font dosyaları ticari uygulamaya gömülebilir. OFL lisans metni kaynak repoda korunmalı ve uygulamanın açık kaynak lisansları ekranına eklenmelidir.


3.2 Dosya seçimi


Dosya


Projede yeniden adlandırma


Kullanım


Geist[wght].ttf


Geist-Variable.ttf


Ana kullanıcı arayüzü ve büyük telemetri


GeistMono[wght].ttf


GeistMono-Variable.ttf


Teknik metadata ve hizalı yardımcı değer


OFL.txt


OFL.txt


Lisans bildirimi





Dosya adları projede sadeleştirilebilir; ancak fontun iç family adı değiştirilmemeli ve türetilmiş bir font adı oluşturulmamalıdır. Font dosyaları yalnız resmî Vercel veya Google Fonts kaynağından alınmalıdır.


3.3 Gelecekte ücretli yükseltme


GT America, bütçe ve mobil uygulama lisansı ayrıldığında değerlendirilebilecek üst segment alternatiftir. Ancak V1 uygulamasında satın alınmamalı veya deneme fontu üretime gömülmemelidir. V1 için Geist kararı kesindir.


ÜRETIM GÜVENLIĞI  Antigravity, internette bulunan lisanssız GT America dosyalarını indirmeyecek veya projeye eklemeyecektir.


4. Tipografi token sistemi


4.1 Temel ilkeler


Tüm metin stilleri tek bir merkezi sınıftan üretilmelidir.


Widget seviyesinde ham fontFamily, fontSize ve letterSpacing tekrarı bırakılmamalıdır.


Ağırlıklar tasarım token’ı olarak tanımlanmalı; 400, 500, 600 ve seçili yerlerde 650/700 kullanılmalıdır.


Büyük başlıklarda çok hafif negatif letterSpacing; gövde metninde sıfır veya nötr letterSpacing kullanılmalıdır.


Line-height değerleri kullanıcı metin ölçeği büyüdüğünde kırpılmayacak kadar açık tutulmalıdır.


Renk, tipografi sınıfının içine sabitlenmemeli; tema veya parametre üzerinden aktarılmalıdır.


4.2 Üretim ölçeği


Token


Font


Boyut


Ağırlık


Satır


Harf aralığı


Kullanım


displayHero


Geist Sans


56 sp


650


0.96


−1.1


Birincil telemetri kahraman değeri


displayLarge


Geist Sans


44 sp


650


1.00


−0.8


İkincil büyük veri


headlineLarge


Geist Sans


30 sp


650


1.10


−0.5


Ana ekran başlığı


headlineMedium


Geist Sans


24 sp


600


1.17


−0.3


Sayfa başlığı


titleLarge


Geist Sans


20 sp


600


1.20


−0.2


Büyük kart/section


titleMedium


Geist Sans


17 sp


600


1.29


−0.1


Kart başlığı


bodyLarge


Geist Sans


16 sp


400


1.50


0


Uzun açıklama


bodyMedium


Geist Sans


14 sp


400


1.43


0


Standart arayüz metni


labelLarge


Geist Sans


15 sp


600


1.33


+0.1


Birincil buton


labelMedium


Geist Sans


12 sp


500


1.33


+0.3


Kısa veri etiketi


caption


Geist Sans


11 sp


500


1.36


+0.2


Yardımcı bilgi


technical


Geist Mono


12 sp


500


1.33


0


ID, GPS ve kısa teknik değer





4.3 Renk bağlama kuralları


Rol


Renk


Kullanım


Primary text


#E8EDF2


Ana başlıklar ve kritik değerler


Secondary text


#E8EDF2 / %68–72 opaklık


Açıklama ve ikincil bilgi


Muted text


#E8EDF2 / %48–56 opaklık


Zaman damgası ve düşük öncelik


Interactive accent


#11B8DD


Aktif durum, odak, seçili navigasyon


Secondary accent


#48D4E8


Grafik/telemetri ikincil vurgusu


Apex / caution


#F47A24


Apex noktası, önemli uyarı ve seçili ödül


Background


#08131F


Ana koyu yüzey





5. Bileşen bazlı kullanım


5.1 Telemetri kartı


Katman


Stil


Örnek


Etiket


labelMedium / titanium %68


DOĞRULANMIŞ MAKS. HIZ


Değer


displayHero / tabular figures


187


Birim


caption veya technical


km/sa


Güven/metadata


technical / cyan


GNSS • doğrulandı





KURAL  Büyük telemetri değeri Geist Mono değil Geist Sans kullanır. Sayıların sabit genişlikte hizalanması FontFeature.tabularFigures() ile sağlanır. Birim değerin görsel rakibi olmamalıdır.


5.2 Dashboard ve sürüş özeti


Ekran başlığı headlineMedium; bölüm başlıkları titleMedium kullanılmalıdır.


Bir kartta en fazla bir display stili bulunmalıdır.


Maksimum hız, ortalama hız, mesafe ve aktif süre aynı basamak çizgisinde hizalanmalıdır.


Değer değişirken yatay genişlik oynamamalıdır; tabular figures zorunludur.


Sıfır durumlarında ‘—’ veya ‘0’ kullanım kararı veri modeline göre tekleştirilmelidir.


5.3 Achievement ve rozet ekranı


Achievement adı titleMedium, ilerleme metni bodyMedium, sayaç labelMedium kullanmalıdır.


Rozet görseli başlıktan daha baskın olabilir; tipografi yarışan bir dekorasyona dönüşmemelidir.


Kilitli achievement için yalnız opaklık düşürülmemeli; kilit ikonu ve metinsel durum birlikte gösterilmelidir.


Premium süre ödülü gibi kritik kazanımlar turuncu vurguyu yalnız küçük bir işaret veya etiket olarak kullanmalıdır.


Uzun Almanca başlıklarda iki satıra izin verilmeli; sabit kart yüksekliği kullanılmamalıdır.


5.4 Butonlar, sekmeler ve navigasyon


Bileşen


Stil


Yasak


Primary button


labelLarge 600


Tamamı büyük harf


Secondary button


labelLarge 600


Primary ile aynı renk ağırlığı


Bottom navigation


caption 500


11 sp altı metin


Tab


labelMedium 600 seçili / 500 pasif


Renk + ağırlık + alt çizgi üçlüsünü aynı anda aşırı kullanmak


Chip


caption 500


Uzun açıklamayı chip içine sıkıştırmak





6. Telemetri ve sayısal tipografi


6.1 Tabular figures


Telemetri değerlerinde rakamların genişliği sabit olmalıdır. Flutter’ın FontFeature.tabularFigures() özelliği OpenType tnum davranışını açar. Bu sayede 1, 8 veya 0 farklı genişlikte olsa bile sayaç ve kart hizası değişmez.


DART


const telemetryFeatures = <FontFeature>[  FontFeature.tabularFigures(),];


6.2 Birim ve değer ayrımı


Değer


Format


Örnek


Hız


0 veya 1 ondalık; ürün kararına göre sabit


187 km/sa veya 86,4 km/sa


Mesafe


Yerel ondalık ayırıcı


124,6 km


Aktif süre


HH:MM veya açık metin


01:42


Ortalama hız


1 ondalık


64,8 km/sa


Bug Report ID


Mono, seçilebilir ve kopyalanabilir


AFX-BUG-7F2K9





6.3 Yerelleştirme


Sayı biçimlendirmesi UI içinde string birleştirmeyle değil locale-aware formatter ile yapılmalıdır.


Türkçe görünür metinde ‘km/sa’; İngilizce ürün kararına göre ‘km/h’; Almanca ‘km/h’ kullanılabilir.


Ondalık ayırıcı locale’e göre değişmelidir; ham nokta karakteri zorlanmamalıdır.


Aynı veri kartında değer ile birim ayrı TextSpan veya ayrı widget olmalıdır.


Birimler çeviri dosyalarına alınmalı ve kod içine gömülmemelidir.


7. Flutter dosya ve asset mimarisi


7.1 Önerilen klasör yapısı


PROJECT TREE


assets/  fonts/    geist/      Geist-Variable.ttf      GeistMono-Variable.ttf      OFL.txtlib/  core/    design_system/      apex_colors.dart      apex_spacing.dart      apex_typography.dart      apex_theme.darttest/  design_system/    typography_glyph_test.dart    typography_scale_test.dart


7.2 pubspec.yaml


YAML


flutter:  uses-material-design: true  fonts:    - family: Geist      fonts:        - asset: assets/fonts/geist/Geist-Variable.ttf    - family: GeistMono      fonts:        - asset: assets/fonts/geist/GeistMono-Variable.ttf  assets:    - assets/fonts/geist/OFL.txt


ÖNEMLI  google_fonts paketi üzerinden çalışma anında font indirilmemelidir. Fontlar Flutter asset bundle içine girmeli ve uçak modunda ilk açılışta dahi aynı şekilde render edilmelidir.


7.3 Asset doğrulaması


Dosya yolu ile pubspec girintisi birebir doğrulanmalıdır.


flutter clean yalnız gerçekten gerekli olduğunda; ardından flutter pub get çalıştırılmalıdır.


Release AAB/APK içinde font assetlerinin bulunduğu doğrulanmalıdır.


Font yüklenemediğinde sessiz sistem fontu fallback’i kabul edilmemeli; test aşamasında görünür hata üretilmelidir.


Lisans dosyasının sürüm kontrolüne girdiği doğrulanmalıdır.


8. Flutter uygulama kodu


Bu bölümdeki kod, mevcut Apex Flow mimarisine uyarlanacak referans uygulamadır. Antigravity önce projedeki Flutter sürümünü, mevcut tema katmanını ve kullanılan state/navigation yapısını incelemeli; örnekleri körlemesine kopyalamamalıdır.


8.0 Uygulama sözleşmesi


ApexTypography yalnız tipografi token’larını ve stil üreticilerini barındırmalıdır.


ApexTheme renk sistemi ile tipografiyi birleştirmeli; iş mantığı içermemelidir.


Yeni sınıflar mevcut tema giriş noktasına tek merkezden bağlanmalıdır.


Kod örnekleri mevcut Flutter SDK API’leriyle derlenebilir hâle uyarlanmalıdır.


Her fazdan sonra analyze, widget testi ve en az bir fiziksel cihaz önizlemesi yapılmalıdır.


Uygulama çevrimdışıyken font görünümü ilk açılışla sonraki açılışlarda aynı kalmalıdır.


8.1 apex_typography.dart


DART


import 'dart:ui' show FontFeature, FontVariation;import 'package:flutter/material.dart';abstract final class ApexTypography {  static const String sans = 'Geist';  static const String mono = 'GeistMono';  static const List<FontFeature> tabular = <FontFeature>[    FontFeature.tabularFigures(),  ];  static TextStyle _sans({    required double size,    required double weight,    required double height,    required double tracking,    required Color color,    List<FontFeature>? features,  }) {    return TextStyle(      fontFamily: sans,      fontSize: size,      height: height,      letterSpacing: tracking,      color: color,      fontWeight: _semanticWeight(weight),      fontVariations: <FontVariation>[        FontVariation('wght', weight),      ],      fontFeatures: features,    );  }  static FontWeight _semanticWeight(double weight) {    if (weight >= 650) return FontWeight.w700;    if (weight >= 600) return FontWeight.w600;    if (weight >= 500) return FontWeight.w500;    return FontWeight.w400;  }  static TextStyle telemetryHero(Color color) => _sans(    size: 56,    weight: 650,    height: .96,    tracking: -1.1,    color: color,    features: tabular,  );  static TextStyle technical(Color color) => TextStyle(    fontFamily: mono,    fontSize: 12,    height: 1.33,    fontWeight: FontWeight.w500,    fontVariations: const <FontVariation>[      FontVariation('wght', 500),    ],    fontFeatures: tabular,    color: color,  );}


Not: Antigravity, kullanılan Flutter sürümünde variable font davranışını fiziksel cihazda doğrulamalıdır. FontVariation desteklenmiyorsa veya tutarsızsa resmî statik 400/500/600/700 dosyalarına geçilmeli; yapay bold üretimine güvenilmemelidir.


8.2 TextTheme üretimi


DART — APEXTYPOGRAPHY SINIFINA EKLENECEK


static TextTheme textTheme({  required Color primary,  required Color secondary,}) {  return TextTheme(    headlineLarge: _sans(      size: 30, weight: 650, height: 1.10,      tracking: -.5, color: primary,    ),    headlineMedium: _sans(      size: 24, weight: 600, height: 1.17,      tracking: -.3, color: primary,    ),    titleLarge: _sans(      size: 20, weight: 600, height: 1.20,      tracking: -.2, color: primary,    ),    titleMedium: _sans(      size: 17, weight: 600, height: 1.29,      tracking: -.1, color: primary,    ),    bodyLarge: _sans(      size: 16, weight: 400, height: 1.50,      tracking: 0, color: primary,    ),    bodyMedium: _sans(      size: 14, weight: 400, height: 1.43,      tracking: 0, color: secondary,    ),    labelLarge: _sans(      size: 15, weight: 600, height: 1.33,      tracking: .1, color: primary,    ),    labelMedium: _sans(      size: 12, weight: 500, height: 1.33,      tracking: .3, color: secondary,    ),    bodySmall: _sans(      size: 11, weight: 500, height: 1.36,      tracking: .2, color: secondary,    ),  );}


8.3 apex_theme.dart


DART


import 'package:flutter/material.dart';import 'apex_typography.dart';abstract final class ApexTheme {  static const Color navy = Color(0xFF08131F);  static const Color cyan = Color(0xFF11B8DD);  static const Color orange = Color(0xFFF47A24);  static const Color titanium = Color(0xFFE8EDF2);  static ThemeData dark() {    final secondary = titanium.withValues(alpha: .70);    return ThemeData(      useMaterial3: true,      brightness: Brightness.dark,      scaffoldBackgroundColor: navy,      fontFamily: ApexTypography.sans,      colorScheme: const ColorScheme.dark(        primary: cyan,        secondary: Color(0xFF48D4E8),        tertiary: orange,        surface: navy,        onSurface: titanium,      ),      textTheme: ApexTypography.textTheme(        primary: titanium,        secondary: secondary,      ),    );  }}


UYUMLULUK  withValues(alpha:) mevcut Flutter sürümünde yoksa aynı davranış withOpacity() ile uygulanabilir. Antigravity sürüm uyumluluğunu analiz etmeden toplu API değişikliği yapmamalıdır.


8.4 Bileşen örneği


DART


Text.rich(  TextSpan(    children: <InlineSpan>[      TextSpan(        text: maxSpeed.toStringAsFixed(0),        style: ApexTypography.telemetryHero(          ApexTheme.titanium,        ),      ),      TextSpan(        text: ' ${l10n.kilometersPerHour}',        style: Theme.of(context).textTheme.bodySmall,      ),    ],  ),  maxLines: 1,  overflow: TextOverflow.fade,)


9. Erişilebilirlik ve adaptif davranış


9.1 Yazı ölçeği


Android 14 doğrusal olmayan font scaling yaklaşımı 200% seviyesine kadar kullanıcı ayarını etkileyebilir. Apex Flow kullanıcı yazı ölçeğini kapatmamalı, TextScaler.noScaling kullanmamalı ve küçük ekranlarda sabit yükseklikli metin kutularından kaçınmalıdır.


Test seviyeleri: 100%, 130%, 160% ve 200%.


Test genişlikleri: 320 dp, 360 dp, 412 dp ve tablet 600 dp.


Kart yüksekliği içerikten türemeli; fixed height yalnız kanıtlanmış özel bileşenlerde kullanılmalıdır.


Uzun metinler kırpılmamalı; başlıklar gerekli olduğunda iki satıra çıkabilmelidir.


Kritik CTA yalnız ikonla verilmemeli; erişilebilir metin etiketi bulunmalıdır.


Renk, durum bilgisinin tek taşıyıcısı olmamalıdır.


9.2 Kontrast ve karanlık arayüz


Normal gövde metni için kontrast en az WCAG AA düzeyinde tutulmalıdır.


Muted metin opaklığı görsel olarak güzel görünse bile okunabilirlik testinden geçmiyorsa yükseltilmelidir.


Cyan metin uzun paragraf rengi olarak kullanılmamalıdır; vurgu ve durum rengi olmalıdır.


Turuncu küçük metinde yalnız yeterli kontrast sağlayan yüzeyde kullanılmalıdır.


Dinamik güneş ışığı koşulları nedeniyle gerçek motosiklet sürüşünde dış mekân okunabilirliği ayrıca test edilmelidir.


9.3 Dil ve glyph doğrulama metni


QA SAMPLE


TR: ÇĞİÖŞÜ çğıöşü — Sürüş özeti, doğrulanmış maksimum hızEN: Ride summary, verified maximum speedDE: Höchstgeschwindigkeit, Straße, Größe, ÜberprüfungNUM: 0 1 2 3 4 5 6 7 8 9  •  00:00  •  188,8 km/sa


10. Migrasyon planı


10.1 Antigravity uygulama sırası


Envanter çıkar: Projede kullanılan ThemeData, TextTheme, TextStyle, GoogleFonts ve doğrudan fontFamily çağrılarını bul.


Mevcut davranışı koru: Önce ekran görüntüsü/golden referansları al; özellik veya layout mantığını değiştirme.


Assetleri ekle: Yalnız resmî Geist fontlarını ve OFL lisansını yerel assetlere yerleştir.


Token katmanını kur: ApexTypography ve ApexTheme sınıflarını ekle; mevcut renk sistemine kontrollü bağla.


Kritik ekran pilotu: Dashboard, sürüş özeti ve telemetri kartlarında yeni sistemi uygula.


Bileşen migrasyonu: Buton, kart, rozet, achievement, profil ve ayarlar ekranlarını sırayla taşı.


Hardcoded stilleri temizle: Eşdeğer token bulunan tüm dağınık TextStyle tanımlarını kaldır.


Lokalizasyon testi: TR/EN/DE glyph, satır kırılımı ve sayı formatlarını doğrula.


Erişilebilirlik testi: 200% text scaling ve küçük ekran testlerini çalıştır.


Release doğrulaması: Offline açılış, release AAB/APK asseti, performans ve görsel regresyonu doğrula.


10.2 Güvenli migrasyon kuralları


Toplu search/replace ile bütün fontSize değerlerini körlemesine değiştirme.


Mevcut ekranın iş mantığını, state yönetimini veya veri modellerini tipografi görevi kapsamında değiştirme.


Kullanıcının mevcut erişilebilirlik ayarlarını override etme.


ThemeData güncellemesinden sonra modal, dialog, snackbar ve sistem sayfalarını ayrıca kontrol et.


Mevcut kullanıcı değişikliklerini ve alakasız dosyaları geri alma.


Her faz sonunda flutter analyze ve ilgili testleri çalıştır.


11. QA matrisi


Test alanı


Senaryo


Beklenen sonuç


Asset


Uçak modunda ilk açılış


Geist fontu fallback olmadan yüklenir.


Türkçe


ÇĞİÖŞÜ çğıöşü


Eksik glyph veya sistem fontuna geçiş yoktur.


Almanca


Höchstgeschwindigkeit


Kart kırpılmaz; uygun şekilde sarar.


Telemetri


1→8→100 değeri değişimi


Kart genişliği ve baseline oynamaz.


Yazı ölçeği


200% sistem fontu


Kritik içerik kaybolmaz; CTA erişilebilir kalır.


Küçük ekran


320 dp genişlik


Taşma, sarı overflow şeridi veya kesik metin yoktur.


Güneş ışığı


Yüksek ekran parlaklığı / dış ortam


Ana veri ve CTA rahat okunur.


Tema


Dark theme tüm modal ve sheet’ler


Fallback beyaz/siyah veya yanlış font görünmez.


Release


Release AAB/APK


Font dosyaları paket içinde ve lisans bildirimi görünürdür.


Performans


Cold start ve ekran geçişi


Font yüzünden ağ isteği veya belirgin jank oluşmaz.


Snapshot


Kritik ekran golden testi


Onaylı referans dışında beklenmeyen fark yoktur.


Semantics


TalkBack gezinmesi


Metin rolleri ve buton etiketleri anlamlıdır.





11.1 Telemetri sayı test seti


VISUAL REGRESSION INPUT


0  •  1  •  7  •  8  •  9  •  10  •  88  •  100  •  1880,0  •  9,9  •  88,8  •  100,0  •  999,900:00  •  01:09  •  11:11  •  23:59AFX-BUG-7F2K9  •  GPS  •  GNSS  •  OFFLINE


11.2 Otomatik kontrol beklentileri


flutter analyze sıfır hata ile tamamlanmalıdır.


Mevcut unit/widget testleri başarısız olmamalıdır.


En az bir typography glyph widget testi eklenmelidir.


En az dashboard ve sürüş özeti için görsel regresyon/golden testi bulunmalıdır.


Kod tabanında google_fonts üzerinden ağ yükleme veya eski fontFamily kalıntısı raporlanmalıdır.


Aynı tipografik rol için birden fazla farklı TextStyle oluşmadığı statik taramayla kontrol edilmelidir.


12. Kabul kriterleri


12.1 Zorunlu kabul maddeleri


☐ Görünür marka adı bütün yeni/etkilenen metinlerde ‘Apex Flow’ şeklinde ayrı yazılmıştır.


☐ Geist Sans ve Geist Mono resmî kaynaktan alınmış ve projeye yerel olarak gömülmüştür.


☐ OFL lisansı projede ve uygulamanın lisans bildirimlerinde yer alır.


☐ Ana font Geist Sans’tır; Geist Mono yalnız tanımlanmış teknik rollerde kullanılır.


☐ Telemetri değerlerinde tabular figures aktif ve görsel olarak doğrulanmıştır.


☐ Tüm kritik metin stilleri merkezi token katmanından gelir.


☐ TR/EN/DE örnekleri fallback veya clipping olmadan görüntülenir.


☐ 200% text scaling testinde kritik görev akışları tamamlanabilir.


☐ Uçak modunda ilk açılışta font aynı görünür; ağ isteği yapılmaz.


☐ flutter analyze ve mevcut testler geçer.


☐ Dashboard, sürüş özeti, achievement ve ayarlar ekranları görsel QA’dan geçer.


☐ Tipografi değişikliği nedeniyle uygulama işlevi veya veri modeli değişmemiştir.


12.2 Başarısız sayılacak durumlar


Fontun runtime’da internetten indirilmesi


Türkçe karakterlerde sistem fontuna fallback


Büyük telemetri değerlerinin Geist Mono ile terminal görünümüne dönüşmesi


Kartların 200% yazı ölçeğinde kırpılması


Aynı rol için ekrandan ekrana farklı ağırlık ve letterSpacing kullanılması


Sırf sığdırmak için kullanıcı font ölçeğinin kapatılması


GT America deneme veya lisanssız dosyasının üretime eklenmesi


Görünür metinde ‘ApexFlow’ birleşik yazımının yeni alanlarda sürdürülmesi


13. Antigravity için nihai uygulama görevi


KULLANIM  Aşağıdaki görev metni bu Word belgesiyle birlikte Antigravity’ye verilebilir. Antigravity önce projeyi analiz etmeli, sonra değişiklikleri fazlar hâlinde uygulamalı ve sonunda kanıt raporu üretmelidir.


ANTIGRAVITY MASTER TASK


ROLApex Flow projesinde çalışan kıdemli Flutter Design Systems Engineer,Mobile UI Engineer ve QA Engineer olarak hareket et.AMAÇBu Word belgesindeki Apex Flow Premium Typography System V1'i mevcutuygulamaya güvenli biçimde uygula. Sonuç sakin, endüstriyel, premium veüst düzey global teknoloji ürünü kalitesinde olmalıdır.BAĞLAYICI KARARLAR1. Görünür marka adı her yerde 'Apex Flow' şeklinde ayrı yazılacak.2. Ana UI fontu Geist Sans olacak.3. Geist Mono yalnız teknik metadata, kısa ID ve seçili yardımcı   değerlerde kullanılacak. Büyük telemetri Geist Sans kullanacak.4. Fontlar runtime'da indirilmeyecek; uygulama assetlerine gömülecek.5. Telemetri değerlerinde FontFeature.tabularFigures() kullanılacak.6. Kullanıcı text scaling ayarı kapatılmayacak.7. GT America veya başka ücretli/lisanssız font üretime eklenmeyecek.8. Tipografi görevi kapsamında iş mantığı ve veri modelleri değişmeyecek.ÇALIŞMA SIRASIA. Mevcut ThemeData/TextTheme/TextStyle/fontFamily envanterini çıkar.B. Değişecek dosyaları ve riskleri raporla.C. Resmî Geist assetlerini ve OFL lisansını ekle.D. apex_typography.dart ve apex_theme.dart merkezi katmanını oluştur.E. Önce dashboard, sürüş özeti ve telemetri kartlarında pilot uygula.F. Sonra rozet, achievement, profil, ayarlar, dialog ve sheet'leri taşı.G. Hardcoded eşdeğer TextStyle tanımlarını kontrollü olarak temizle.H. TR/EN/DE, 320 dp ve 200% text scaling testlerini çalıştır.I. flutter analyze, mevcut testler ve görsel regresyon testlerini çalıştır.J. Yapılan dosyaları, test sonuçlarını ve kalan riskleri raporla.KALİTE KAPISIBelgedeki tüm zorunlu kabul maddeleri sağlanmadan görevi tamamlandı sayma.Bir API veya mevcut proje mimarisi belge örneğinden farklıysa körlemesinekopyalama; aynı tasarım sonucunu mevcut sürüme uyarlayıp değişikliği açıkla.Alakasız kullanıcı değişikliklerini geri alma. Her fazda derlenebilir durumu koru.


14. Kaynaklar ve teknik dayanak


Bu spesifikasyondaki font lisansı, asset entegrasyonu, tabular figures ve erişilebilirlik kararları aşağıdaki birincil kaynaklarla doğrulanmıştır. Antigravity uygulama sırasında mevcut Flutter sürümünü ayrıca kontrol etmelidir.


• Vercel — Geist resmî font sayfası: https://vercel.com/font


• Vercel — Geist font kaynak deposu ve OFL lisansı: https://github.com/vercel/geist-font


• Google Fonts — Geist Sans dosyaları: https://github.com/google/fonts/tree/main/ofl/geist


• Google Fonts — Geist Mono dosyaları: https://github.com/google/fonts/tree/main/ofl/geistmono


• Flutter — Özel font kullanımı: https://docs.flutter.dev/cookbook/design/fonts


• Flutter API — FontFeature.tabularFigures: https://api.flutter.dev/flutter/dart-ui/FontFeature/FontFeature.tabularFigures.html


• Flutter — Android 14 doğrusal olmayan font scaling: https://docs.flutter.dev/release/breaking-changes/android-14-nonlinear-text-scaling-migration


• Grilli Type — GT America resmî bilgi ve deneme kaynağı: https://cdn.grillitype.com/typeface/gt-america


14.1 Son ürün kararı


FINAL  Apex Flow V1 üretim tipografi sistemi: Geist Sans + Geist Mono. Bu seçim ücretsiz olmakla birlikte ‘ücretsiz font’ gibi görünmemeli; kalite, merkezi token sistemi, doğru ağırlık, boşluk, erişilebilirlik ve disiplinli bileşen uygulamasıyla üretilecektir.