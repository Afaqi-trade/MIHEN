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
