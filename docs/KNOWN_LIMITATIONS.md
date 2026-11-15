# Bilinen sınırlar

Tarih: 2026-11-14. Durum: Uzak Xcode 26.6 derlemesi ve 46 iOS testi geçmiş geliştirme sürümü; yayın hazır değildir.

- Yerel ortam yalnızca Swift 5.10 CLT içeriyor. XCTest ve iOS SDK/simülatör yok. Swift 6 hedef ayarları, SwiftData makroları ve SwiftUI API tip uyumluluğu uzak Xcode 26.6 derlemesinde doğrulandı.
- Simülatörde 40 birim/kalıcılık ve 6 UI testi geçti. Dil/tema, hatim, ezber, zikir, oruç, hedef bağlantısı/kısmi tamamlama ve yeniden açılınca kalıcılık UI akışlarında doğrulandı. Ekran görüntüleri gerçek test uygulamasından alındı. Fiziksel cihaz/TestFlight ve App Store görsel seti onayı tamamlanmadı.
- Widget salt okunur günlük snapshot kullanır; App Intents ile görev tamamlama henüz uygulanmadı. Gece yarısından sonra ana uygulama açılana kadar eski veriyi güncel başarı gibi göstermez. App Group kimlikleri örnektir; provisioning doğrulaması gerekir.
- CloudKit/iCloud senkronizasyonu ve XLSX yok. JSON/tam yedek CSV ile geri yükleme ve düzenlenebilir hedef/görev CSV'si kodlandı; cihaz dosya sağlayıcılarıyla test edilmedi. Plan CSV çok alan/üst hedef/proje bağlarını tam taşımaz; JSON kayıpsız ana yedek biçimidir.
- Orucun ertelendi durumu saklanır; yeni tarih manuel planlanır. Recep/Şaban 15 gün ve Hicri 13–15 hedefleri manuel oluşturulur. Resmî dini gün veri kaynağı bağlanmadı. Hicri takvim Foundation Umm al-Qura algoritmasıdır; yerel takvimden farklı olabilir.
- Rutin ve rutin item tabloları var; UI başlangıç rutinlerini görev/alışkanlık şablonu olarak sunar. Ayrı rutin gruplama/editör deneyimi genişletilmelidir. Alt kategori ve proje düzenleme deneyimi temel seviyededir.
- Hedef bölme kalan günlük miktarı gösterir; kullanıcı onaylı 90 güne kadar eşit yeniden dağıtım vardır. Kitap adedinden dakika gibi farklı birime dönüşüm çıkarılmaz. Alışkanlık izinleri haftanın dinlenme günleriyle sınırlı; özel tarih aralıklı izin takvimi yok.
- Sayısal grafikte görev gerçekleşmesi ölçülür. Nitel yaşam kalitesi skoru veya otomatik AI değerlendirmesi üretilmez. Alışkanlık istikrarı görev listesinde gösterilir; gelişmiş yıllık alışkanlık karşılaştırmaları yok.
- Bildirimler uygulama açılışı/değişikliğinde yakın 7 gün ve en çok 60 istekle yenilenir. Akşam/haftalık değerlendirme saati 20:00, görev/sabah saati ayarlanabilir. Sessiz saatler atlanır; sınırsız veya garantili teslimat yoktur.
- Core CSV/JSON kontrollere rağmen geniş fuzz/performance ölçümü henüz yok. Store güncellemesi tüm belgeyi doğrular; büyük veri için fetch/validation maliyeti ölçülmelidir. Geçmiş backfill foreground'da 366 günle sınırlıdır.
- İlk sürüm migration planı V1'i tanımlar; gelecekteki şema geçişi için ayrı migration ve gerçek store yükseltme testi şarttır. UUID referanslarının bütünlüğü uygulama katmanında denetlenir, SwiftData @Relationship/cascade kullanılmaz.
- İmzalı fiziksel cihaz dağıtımı, App Store isim uygunluğu, hukuki değerlendirme, yayıncı iletişimi ve politika/destek URL'leri tamamlanmadı. Yerelde uyumlu Xcode 16.2 App Store'un güncel Xcode 26+ yükleme şartını sağlamaz.

Son tam UI koşusu iPhone 17 Pro / iOS 26.4.1 üzerinde çalıştı. Minimum iOS 18 deployment compiler tarafından kontrol edilir; son kaynak için iOS 18 cihaz/runtime ve küçük ekran/Dynamic Type matrisi ayrıca doğrulanmalıdır.

## 14 Kasım genişletme çalışması — doğrulama sürüyor

Yeni kod: aktarma öncesi tek yerel kurtarma yedeği; hafta/ay/yıl/10 yıl kayıt raporu; günlük hedef dağılımı; haftalık gündem; görev gruplarından rutin; tarihli beslenme/su/egzersiz ve kaza namazı kayıtları; saat seçilebilir su/hareket/değerlendirme hatırlatmaları; Apple Takvim sistem editöründe tek etkinlik kopyası.

Bu liste tamamlanmış kabul kriteri değildir. Son kaynak için uzak iOS testi doğrulanmadan yeni özelliklerin cihazda çalıştığı ileri sürülmez.

- Kurtarma yedeği yalnızca son içe aktarma öncesini saklar; cihaz dışı yedek değildir. Tüm verileri silme işleminde kaldırılır. Files sağlayıcısı ile uçtan uca UI doğrulaması hâlâ açık.
- Günlük hedef dağıtımı aynı birimi korur, 366 günle sınırlıdır; aktif bağlı görevi olan hedefte ikinci plan oluşturulmaz. Yıllık/90 günlük/aylık hiyerarşiyi otomatik oluşturan tam sihirbaz henüz yok.
- Haftalık ekran günleri ve geciken kayıtları gösterir; taşıma mevcut tekil onaylı işlem üzerinden yapılır. Toplu karar verme henüz yok.
- Rutinler mevcut görevleri gruplar; grup kaldırıldığında görev/geçmiş korunur. Sürükleyerek sıralama, grup düzenleme ve grup duraklatma henüz yok.
- Raporlar mevcut gerçekleşme kayıtlarını sayar; 10 yıllık geçmiş üretmez. İlgili hedefler güncel durumlarıyla etiketlenir; geçmiş tarihteki hedef durumunu yeniden kurmaz. PDF/CSV dönem raporu dışa aktarımı henüz yok.
- Beslenme ve egzersiz kalorileri elle girilir. Besin veritabanı, yemek fotoğrafından kalori, otomatik enerji açığı, HealthKit okuması veya diyet önerisi yok.
- Kaza namazı başlangıç miktarını kullanıcı girer. Beş vakit ve isteğe bağlı vitir ayrı tutulur; yapılan miktar borcu aşamaz. Kayıt düzeltme/geri alma akışı henüz geliştirilmelidir.
- Apple Takvim aktarımı tek kopyadır, tekrar kuralı aktarmaz ve çift yönlü senkronizasyon değildir. Sistem editörünün kaydet/iptal akışı fiziksel cihazda doğrulanmalıdır.
- Namaz vakitleri ve namaz widget'ı henüz uygulanmadı. Resmî Diyanet Awqat Salah servisi kullanıcı başvurusu ve kimlik doğrulama ister: https://awqatsalah.diyanet.gov.tr/index.html . Bu başvuru yapılmadı; hiçbir anahtar kaynak koda eklenmedi. Yerel astronomik yöntem ile resmî Diyanet verisi aynı kaynakmış gibi gösterilmemelidir. İkindi mezhep tercihi hesaplama kuruluşundan ayrı ayar olmalıdır.
- Sağlık/adım için seçili günün toplamlarını okuyan isteğe bağlı HealthKit ekranı kodlandı; gerçek cihaz izni/verisi ve provisioning doğrulanmadı. Sosyal medya süre sınırı henüz uygulanmadı. HealthKit veri türü bazında izin; Screen Time için Family Controls ve uygun uzantılar gerekir. Sosyal medya içeriklerini genel olarak okumak bu izinlerden çıkmaz. Dağıtım yetkisi Apple tarafından ayrıca onaylanır: https://developer.apple.com/documentation/familycontrols/requesting-the-family-controls-entitlement .

## 15 Kasım namaz vakitleri güncellemesi

Ürün sahibi resmî Diyanet servisi gerektirmediğini netleştirdi. Çevrimdışı Adhan Swift hesaplamaları (MIT, sabit kaynak commit ve lisans Design/Licenses içinde) uygulama ve ayrı namaz widget'ına eklendi. Türkiye yaklaşık hesap yöntemi varsayılan; diğer uluslararası yöntem, Hanefî ikindi ve yüksek enlem kuralı seçilebilir. Bu yöntemler ilgili kurumun canlı resmî verisi olduğu iddiasını taşımaz. Koordinat/saat dilimi elle seçilir; başlangıç koordinatları İstanbul merkezidir; GPS konumu değildir. Ayarlar cihaz/App Group tercihlerinde saklanır; JSON yedeğine henüz dahil değildir. Tüm veri silme ayarları da temizler. App Group cihaz provisioning ve widget görünümü fiziksel cihazda doğrulanmalıdır. Kutup ikamesi kapalı; hesaplanamayan vakit için boş/hata durumu gösterilir.

Kaza kaydında onaylı silme/düzeltme eklendi; borçtan fazla gerçekleşme doğuracak silme repository doğrulamasında reddedilir. Manevi takipte Rutinler artık rutin grup ekranına gider.
