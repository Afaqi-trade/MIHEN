# Yol haritası uygulama ve kabul kaydı

Güncelleme: 20 Kasım 2026. Kaynak kod ile doğrulanmış iOS sonucu ayrıdır. `44304066244` koşusu, sekiz yol haritası alanına yayılan 92 birim/kalıcılık ve 8 gerçek UI akışında 100/0 sonucu verdi; daha geniş tam UI koşusunun sonucu ayrıca kayda alınır.

| Sıra | Uygulanan yazılım | Kabul kanıtı / durum |
|---|---|---|
| 1 · Veri güveni | Açık modül → görev bağlantısı; önceki manuel miktarı koruyan ayırma; kaynak düzenleme/silme uzlaştırması; V1 → V2 ve eski yedek geçişi | Core bağlantı/JSON/CSV/TZ testleri. İlk P0 koşusunda native migration geçti; son V2 şeması ve UI bağlantısı yeniden doğrulanıyor. |
| 2 · Gerçekçi plan | Yedi gün için dakika kapasitesi, görev süre tahmini, tarihsel süre snapshot'ı; kapasiteye göre tam toplamlı dağıtım; süre uzatma/kapsam düzenleme; hedefe bağlı üç haftalık odak | Ayrık birim, kapasite aşımı, bilinmeyen süre ve geçmiş snapshot testleri. UI kapasite/odak ve tam sayı kontrolleri uzak koşuda. |
| 3 · Rutin | Gruba özel günler/duraklama; ortak görevleri arşivlemez; o güne ait sıralı oturum ve kaldığı adımdan devam; İleri başarı üretmez | Core ortak görev/oturum/tekrar testleri. Native çalışma ekranı ve adım ilerlemesinin görevi tamamlamadığı UI kontrolü. |
| 4 · Beslenme | Öğün ve başlık, son kullanılan beş girişten form doldurma, tarihli miktar düzenleme, özelleştirilen hızlı su; planlanan/gerçekleşen ayrı | Düzenleme tek satırı korur, bağlı görevi günceller, plan gerçek tüketim oluşturmaz. Core ve beslenme UI regresyonu. |
| 5 · Rapor | Yönetici özeti, görev/kısmi emek/kapsam kartları, kaynak seçilebilir eğilim ve tablo; sekiz alanın ayrıntısı; eşit takvim günü karşılaştırmaları; 10 yılda ayrı yıl dökümü; yapılandırılmış değerlendirmeler; açık karar ve kapsamlı PDF/CSV | Eksik değer sıfır yapılmaz. Kaynak farkı için iki dönemde de aynı kaynakta en az üç kayıtlı gün gerekir. Dışa aktarımda alan ve kişisel notlar açık seçimdir. Core dönem/DST/mahremiyet testleri; native ekran ve PDF testleri. |
| 6 · İlk kullanım | Seçilen şablonların 7 günlük salt önizlemesi ve açık görev sayısı; sekiz alanda düzenlenebilir hedef + ilk ay aşaması + haftalık destek adımı | Şablonlar açık seçimle ve sabit kimlikle eklenir; geçmiş/başarı üretilmez. Dakika hedef sonucuna dönüştürülmez. Core sekiz alan/idempotence ve UI örnek hafta. |
| 7 · Günlük araçlar | İstanbul varsayılanı; aramalı çevrimdışı şehir/ülke kısa listesi ve elle koordinat; kaydedilmiş/önizleme ayrımı; ezber tekrarını geri alma/geçmişten silme; isteğe bağlı sayaç titreşimi; Sağlık kaydını açık kaynak bağlantısıyla göreve bağlama; widget'tan uygulamada onaylı su formu | Şehir seçimi hesap yöntemini değiştirmez. Widget veriyi doğrudan değiştirmez, kilitliyken form açılmaz. Native derleme/UI ile fiziksel cihaz kabulü ayrı. |
| 8 · Tasarım ve kabul | Sade geometrik motifler, sıcak zemin, semantik yeşil, serif vurgu/yuvarlatılmış sistem metni; selamlama dili; kısa rapor başlıkları, büyük yazıda tek sütun; native 1/3/10 yıllık SwiftData/rapor ölçümü; ilk üç mağaza görseli hikâyesi | 44304066244'te yönetici özeti ve büyük-yazı UI akışları geçti; tam 19-akış koşusu ayrıca sürüyor. Tüm cihazlarda VoiceOver/Voice Control sertifikası veya fiziksel performans iddiası yok. |

## Kullanıcının ek tasarım kararları

- Rapor bir uzun sayı listesi olmaktan çıkarıldı: yönetici özeti → öne çıkanlar → eğilim → alan ayrıntıları → sonraki karar.
- Dekorasyon verinin önüne geçmez. Yerel SwiftUI geometrisi, metinden ayrılmış küçük motifler ve Dynamic Type sistem fontları kullanılır; harici font/SDK eklenmez.
- Açılışta Selamün aleyküm; saate göre Hayırlı sabahlar/günler/akşamlar/geceler. İngilizce karşılıklar aynı kapsamda tutulur.
- Kullanıcıya ait veri veya başarı uydurulmaz. Motive edici dil kısmi emeği gösterir, kişinin değerini puanlamaz.

## Şema ve bağlantı sözleşmesi

V1 model alanları dondurulmuş olarak kalır. Geliştirme aşamasındaki V2, ayrı varlıklar ekler; son sürüm native V1 → V2 geçiş testine tabidir. Bu aradaki geliştirme commit'leri yayımlanmış V2 mağazası sayılmaz. İlk imzalı V2 dağıtımından sonra yeni değişiklikler ayrıca V3 geçişi gerektirir.

Kaynak bağlantısı aynı gün/alan/birim için açık seçimle yapılır ve manuel miktarın **yerine geçer**, ona eklenmez. Kaynağın tarihi/birimi değiştirilecekse önce bağlantı ayrılır. Ayırma veya kaynak silme önceki manuel miktarı geri getirir. Başlık benzerliğiyle otomatik eşleşme yoktur.

## Dış kabul kapıları

Fiziksel iPhone, Apple üyeliği/imzalama/TestFlight, App Group/Family Controls, izinli Sağlık/Takvim/bildirim teslimatı, iOS 18 runtime, VoiceOver/Voice Control/Reduce Motion ve kullanıcı/ödeme isteği araştırması açık kalır. Bunlar kaynak veya simülatör testleriyle tamamlanmış sayılmaz.
