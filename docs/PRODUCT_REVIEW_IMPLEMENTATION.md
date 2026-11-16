# Ürün incelemesinden uygulamaya

16 Kasım 2026. Kaynak geliştirmesi rapordaki sırayla yapıldı. Bu tablo kaynakta bulunan değişiklikleri belirtir; nihai iOS derleme/test ve görsel kabulü TEST_REPORT.md içindeki commit ve kapsam belirler. Tamamlanmamış dış kabul kapıları aşağıdadır.

| Öncelik | Uygulanan değişiklik | Temel kontrol |
|---|---|---|
| P0 hesap/birim | ProductPlanning içinde tek önizleme/kayıt algoritması; tam adet/kitap/sayfa, para ve süre için 0,01 hassasiyet; yeniden dağıtım da aynı kuralı kullanır | Seyrek kitap, tam sayfa, para toplamı, uygun gün, hassasiyet ve ikinci plan reddi testleri |
| P0 katkı kaynağı | Görev ve bağımsız manuel katkı ayrı; manuel ikinci onay ve sıfırlanan giriş; geçmiş katkı varken hedef birimi kilitli | Moved kaydı ikinci kez sayılmaz; dönemler yarı açık; kaynak toplamları testi |
| P0 Sağlık kaynağı | Aynı gün için idempotent adım/aktif enerji snapshot'ı; manuel enerji korunur fakat ayrıca toplanmaz | Güncelleme, çift saymama, kaynak silinince manuel toplamın geri gelmesi, hatalı girişte değişmeme |
| P0 yedek | Sürümlü JSON zarfı namaz ayarını kapsar; eski V1 JSON/CSV kabul edilir; geçersiz ayar kurtarma kopyasının üstüne yazmaz | Core uyumluluk/sürüm testleri; gerçek dosyada kurtarma ve repository yeniden açma testleri |
| P0 gizlilik | Pencere seviyesinde örtü açık sheet'leri de kapsar; kilitlenince kaydedilmemiş formlar kapanır; açılmayan store boş veriyle değiştirilmez | Kod ve iOS derlemesi; fiziksel app switcher/Face ID testi ayrı kapı |
| P1 Bugün | Kısmi emek ana özette; tam oran ayrı; tamamlananlar ayrı bölüm; son miktara geri alma; açık seçilen günlük en çok üç odak | 2/6 ekranı ve tam etiket eşitliği; hızlı giriş/geri alma UI akışı |
| P1 ilk kullanım | Kısa üç aşama, isteğe bağlı ad, alan odağı ve tek tek seçilen şablonlar; ilk boş ekran yönlendirmesi | Açık tek şablon seçimi, başka şablon eklenmediği ve sıfır geçmiş kontrolü |
| P1 gezinme | Araçlar Plan'ın üstünde; odak ve diğer alanlar ayrı; tüm sekiz alan korunur; aramalı saat dilimi ve ayrı bağlantılar | Mevcut sekme/dil/tema ve modül UI akışları |
| P1 hedef yol haritası | İlk 90 gün toplamı, aylık/haftalık dağılım, açık seçimle aylık milestone, günlük kayıt onayı; gelecek planı arşivleme | Yol haritası toplamları günlük toplamla aynı; geçmiş snapshot ve katkı korunur |
| P1 hafta | Bilinen süre ve süresiz iş ayrı; hafta ileri/geri; haftalık niyet/not; seçili kayda onaylı toplu taşıma/atlama | Core taşıma/çakışma ve UI haftalık akış; aday belge hata halinde commit edilmez |
| P1 rutin | Ekran içinde adım oluşturma, mevcut görev seçme, sıra/düzenleme, saatli hatırlatma; yönetim menüsü ve onaylı duraklat/sürdür | Duraklama aralığında sonradan görev üretilmez; geçmiş korunur; yeni başlangıç yarındır; süresi dolan adım açık hata verir |
| P1 rapor | Görev durumları, kaynakları ayrı hedef katkısı, sayfa/tekrar/zikir/oruç/kaza/beslenme/faaliyet/not; veri kapsamı ve sonraki karar | 10−2=8 kaza hareketi; yarı açık dönem; birimler ve boş gün; 10.959 sentetik kayıt |
| P2 rapor paylaşma | Alanlar açıkça seçilmeden dışa aktarılmaz; notlar ayrıca seçilir; gerçek native PDF veya güvenli hücrelerle CSV | Çok sayfalı PDFKit okuma ve Türkçe içerik testi; UI seçim ön koşulu |
| P2 günlük modüller | Önce vakit, sonra konum/yöntem; kaza +1/geri al; hızlı su/geri al; hatimde okunan miktar açıklaması; zikirde mevcut kayıt önce | Namaz, kaza, su, hatim, ezber, zikir, oruç regresyonları |
| P2 erişilebilirlik | Semantik tema renkleri, 44 pt minimum eylem alanları, açıklanabilir bakiyeler, aylık yıllık grafik ve ısı haritası açıklaması | İlk kullanım ve Bugün için açıklama audit’i; XS/en büyük yazıda gerçek metin/eylem boyutu ölçümü; küçük ekranda boş/dolu Bugün görüntüsü |
| P2 yardım/widget | Kullanım rehberi/SSS, kişisel kayıt içermeyen isteğe bağlı sürüm paylaşımı; widget'tan hızlı giriş bağlantısı; kilitli derin bağlantı güvenliği | Kaynak/iOS derlemesi; widget ve izinli entegrasyonların cihaz kabulü ayrıca |
| P3 ticari hazırlık | App Store taslağı faydaya göre yeniden yazıldı; gerçek ekran hikâyesi; ücretsiz/hesapsız çekirdek korundu | Yayımlanmadı, fiyat/gelir iddiası yok, ödeme/analitik SDK eklenmedi |

## Kabul için dış katılım gerekenler

- Gerçek kullanıcılarla kullanılabilirlik ve iki haftalık kullanım/ödeme isteği araştırması: önceki ürün incelemesi bölüm 15 ve [somut deneme protokolü](USABILITY_ACCEPTANCE_TR.md). Katılımcı yokken sonuç veya satın alma talebi üretilmez.
- Fiziksel iPhone: Face ID, uygulama değiştiricide açık form, Files sağlayıcısından yedek/geri yükleme, gerçek Sağlık verisi, bildirim teslimatı, Takvim sistem editörü ve App Group widget.
- Ekran Süresi: Family Controls dağıtım izni, gerçek uygulama kullanımı, OS shield, geçici erişim ve sürede yeniden kısıtlama. Bu izinler mağazaya yükleme yetkisi değildir.
- Minimum iOS 18 runtime, VoiceOver/Voice Control/Reduce Motion matrisi. Uzak runner'da mevcut runtime ve kullanılan cihaz raporda açıkça belirtilir.
- Apple üyeliği, imzalama, destek/gizlilik URL'leri ve TestFlight/yayın ürün sahibinin hesap işlemleridir. Bu geliştirme mağazaya gönderim yapmaz.

## Yedekleme ve şema kararı

SwiftData V1 alanları değiştirilmedi. Yeni arşiv biçiminin kendi sürümü ve eski belge okuma yolu vardır. Kayıt türü olarak `steps`, mevcut String alanının ek kabul edilen değeridir. Sözleşme DATA_SCHEMA.md içinde; ileride model alanı değişirse sürümlü store migration ve gerçek yükseltme testi gerekir. Tüm geçmişi veya başarıyı otomatik üretmek, birimleri çevirmek veya kullanıcı onayı olmadan taşımak bu geliştirmede yapılmaz.


Son doğrulama: tam iOS **84/84** (`43927332097`), SE 3 odaklı **71/71** (`43930797517`); iki koşunun uygulama kaynakları aynıdır. [35 güncel ekran ve provenance](screenshots/CURRENT.md). TEST_REPORT.md sonuçları ve açık cihaz/araştırma kapılarını birbirinden ayırır.
