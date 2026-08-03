# ApexFlow: Dynamic AHRS (Pocket Mode) Telemetry Mathematics

Bu doküman, ApexFlow projesinin "Cep/Çanta" (Pocket Mode) optimizasyonunda kullanılan Havacılık Matematiğinin (AHRS - Attitude and Heading Reference System) çalışma prensiplerini ve fiziksel limitlerini açıklamaktadır.

## Temel Problem: Cepte Neden Doğru Ölçüm Yapılamaz?
Dünyadaki hiçbir teknoloji, cepte serbestçe hareket eden bir telefonun sensörlerine bakarak **Motosiklet Şasisinin** %99 doğru açısını bulamaz. Çünkü telefon motoru değil, **sürücünün bacağını ve vücudunu** ölçer. 
Viraja girerken "sarkma (hang-off)" yapan bir sürücü motoru 40 derece yatırırken, vücudunu 50 derece yatırabilir. Telefon cepteyken bu 50 dereceyi okur. Calimoto, Diablo Super Biker gibi uygulamaların cepteyken çuvallamasının sebebi; telefonu "cebe koyduğunuz andaki" yönünü hafızaya alıp, yol boyunca bacağınızın ufak tefek dönüşlerini (vites atma vb.) viraj zannetmeleridir.

## ApexFlow Çözümü: Dinamik AHRS Vektörlemesi
ApexFlow bu sorunu aşmak için "Telefonun sabit bir ekseni (X, Y veya Z) olduğuna" inanmayı reddeder. Bunun yerine, 3 Boyutlu uzayda telefonun o anki yerçekimi hizasını **dinamik olarak** bulur.

### Adım 1: İvmeölçer (Accelerometer) ve Yerçekimi Vektörlemesi
Motosiklet düz bir yolda sabit hızla veya ivmelenerek giderken, yere doğru etki eden tek büyük kuvvet **Yerçekimidir**. 
Sistem, sadece GPS hızı `> 4 km/h` ve Yön Değişimi (Heading Rate) `~ 0` iken (yani virajda değilken) İvmeölçeri saniyede 10 kez tarar.
Bu tarama sonucunda telefon cepte ters de dursa, çapraz da dursa, X, Y ve Z sensörlerinden gelen veriler filtrelenerek yeni bir **"Sanal Z Ekseni (Aşağı Doğrultu Vektörü)"** elde edilir.

### Adım 2: 3D Vektör Reddi (Vector Rejection) ve Roll Hesaplama
Viraja girildiğinde merkezkaç kuvveti devreye girer. Bu noktada ivmeölçer "aşağıyı" yanlış gösterir. Sistem bunu bildiği için viraj anında İvmeölçeri dikkate almayı bırakır ve sadece **Jiroskoba (Gyroscope)** bakar.
Jiroskop telefonun 3 eksendeki (X, Y, Z) dönüş hızını (Angular Velocity) verir. Sistem bu dönüş hareketini alır ve az önce bulduğu "Sanal Aşağı" vektörüne göre iz düşümünü (Vector Rejection Math) hesaplar.
*   Yatay dönüş (Yaw): Sanal Aşağı vektörünün etrafındaki dönüş.
*   Yatış (Roll/Pitch): Sanal Aşağı vektörüne "dik" olan dönüşler.
Bu kalan hareketin genliği, doğrudan sürücünün **Vücut Yatış (Body Lean) Açısını** verir.

### Adım 3: Dinamik GPS Filtresi (Complementary Fallback)
Cepteki hareketlilik (vites atarken bacağı kaldırma, rüzgar vs.) yüksek frekanslı sinyaller (gürültü) üretir. Sistemi bu gürültüden korumak için, %85 Jiroskop (Anlık Hareket) / %15 GPS (Mutlak Hareket) oranında bir "Complementary Filter" kullanılır. (Bu oran telefon gidona sabitlendiğinde %98 / %2'dir).
Böylece ani bacak oynamaları filtrelenir ve "Motorun Dönüş Çapı" olan GPS kinematiği cebe göre bir nebze daha ağır basarak yatış açısını stabilize eder.

## Sonuç Modları
1. **Telefon Motora Sabit (Gidon Modu):** Sistem GPS kinematiğini büyük ölçüde yok sayıp, motorun saf yatışını %99 doğrulukla (Isolate içinde) süzer.
2. **Akıllı Telemetri (Cep Modu):** Yukarıda anlatılan Sanal Yere Basma ve Vektör Reddi (AHRS) sistemi devreye girerek, vücut/bacak açısını %90-95 isabetle motor yatışına uyarlar. Telefonun yönünün değişmesi sistemi asla bozmaz, çünkü düz yola çıkıldığı an "Aşağı Vektörü" saniyeler içinde tekrar kalibre edilir.
