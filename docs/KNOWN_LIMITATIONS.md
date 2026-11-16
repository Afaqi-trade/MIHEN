# Bilinen sınırlar

Güncelleme: 16 Kasım 2026. Ürün incelemesi sonrası güncel davranış aşağıdadır; uzak doğrulama TEST_REPORT.md içindeki commit ve kapsamla birlikte okunmalıdır. Önceki sınırların tarihsel dökümü history/KNOWN_LIMITATIONS_20261115.md içindedir; güncel özellik listesi olarak kullanılmaz.

| Konu | Kaynaktaki güncel davranış | Açık kabul sınırı |
|---|---|---|
| Yerel veri | SwiftData V1, offline-first; başarısız kayıt aday belgeyi commit etmez | Fiziksel cihaz dosya koruması, cihaz kaybı ve dosya sağlayıcısı testi |
| JSON yedek | Sürümlü mihen.archive zarfı; mevcut V1 kayıtları ve namaz ayarları; eski düz V1 JSON kabul edilir | Harici dosyanın kalıcı saklandığı ancak cihazda doğrulanabilir; dışa aktarma senkronizasyon değildir |
| CSV | Tam kayıt CSV'si veya düzenlenebilir hedef/görev plan tablosu; namaz ayarı taşımaz | XLSX yok; plan tablosu tüm ilişkileri taşımaz |
| İçe aktarma | Önizleme ve onay; önce geçerli kurtarma dosyası; eski JSON/CSV mevcut namaz ayarını korur | Son tek kurtarma kopyası cihaz dışı yedek değildir; birden çok dosyada süreç kesintisi için kurtarma gerekebilir |
| Hedef dağıtımı | En çok 366 takvim günü; ayrık birimde tam sayılar; diğer birimlerde 0,01 hassasiyet; aynı önizleme/kayıt algoritması | 1 milyardan büyük toplamlar ve desteklenmeyen hassasiyetler reddedilir; birimler otomatik dönüştürülmez |
| Hedef aşamaları | İlk 90 gün toplamı, aylık/haftalık önizleme; onayla aylık milestone ve günlük görevler | Ayrı alt hedef hiyerarşisini kendiliğinden üretmez; milestone ikinci katkı kaynağı değildir |
| Katkı kaynakları | Bağlı görev / bağımsız manuel katkı ayrı; manuel giriş açık ikinci onay ister | Aynı gerçek olayı kullanıcı iki bağımsız kayıtta bildirirse sistem bunu anlamsal olarak tespit edemez |
| Geçmiş | Görev snapshot'ları korunur; taşıma ve yeniden dağıtım onaylı; gelecek hedef planı arşivlenebilir | Geçmişteki hedef metadata durumunu yeniden kuran sürümlü tarihçe yok; güncel durum ayrı etiketli |
| Bugün | Kısmi emek görünür; tamamlama oranı ayrı; günün en çok üç odağı; hızlı giriş; son miktar değişimini geri alma | Genel yaşam kalitesi veya manevi değer puanı üretilmez |
| Rutin | Ekran içinde yeni günlük adım, mevcut görev seçimi, sıra/düzenleme, saatli hatırlatma | Duraklatma tüm üye görev şablonlarını etkiler; ortak görev diğer rutinlerde de etkilenir; bugün/geçmiş değişmez; sürdürme yarından yeni başlangıçla başlar, duraklama aralığı sonradan doldurulmaz; bitişi geçmiş adım önce düzenlenir |
| Haftalık plan | Bilinen dakika / süresiz adım sayısı, haftalık not, günler, onaylı toplu taşıma/atlama | Süresi olmayan görevlerin süresi tahmin edilmez; çakışan görev otomatik birleştirilmez; geçmiş bekleyenler seçili haftadan önceki 30 günle sınırlı görünür |
| Rapor | Görev durumları, kaynakları ayrı hedef katkısı, sayfa/tekrar/oruç/kaza/beslenme/faaliyet ve notlar; gerçek kayıt kapsamı | Yaşam dengesi puanı yok; planlanmamış gün başarısızlık sayılmaz; 10 yıllık geçmiş üretilmez; kaza bakiyesi kaydın tarihine bağlıdır |
| Rapor dışa aktarma | Kullanıcının seçtiği alanlarla PDF/CSV; kişisel alan notları ayrıca seçilir | Ham veri yedeği değildir; genel/alan bağlanmamış notlar seçili alan dışa aktarımına girmez |
| Namaz | İstanbul merkez başlangıç; çevrimdışı Adhan hesabı; yöntem ve ikindi tercihi ayrı; vakitler önce, ayarlar ikinci katmanda | Resmî canlı Diyanet verisi değildir; koordinat elle; GPS yok; kutup ikamesi yok; kurum takvimiyle fark olabilir |
| Namaz widget | Sonraki vakit; kaydedilmiş konum/yöntem | Gerçek App Group provisioning ve fiziksel cihaz doğrulaması açık |
| Beslenme | Tarihli manuel enerji/su kaydı, hızlı su ve geri alma | Besin veritabanı, yemek fotoğrafı, otomatik kalori açığı veya tıbbi/diyet önerisi yok |
| Apple Sağlık | Açık izinle günün adım/aktif enerjisi; isteğe bağlı tek günlük idempotent kayıt | Gerçek cihaz/izin/veri kabulü açık; yokluk ile reddedilmiş okuma izni ayrıştırılamaz; Sağlık'a yazılmaz |
| Enerji kaynağı | Sağlık günlük toplamı varsa manuel egzersiz subtotalı ayrıca toplanmaz; manuel satırlar korunur | Sağlık satırı silinince manuel subtotal geri görünür; bu toplam tüm günlük harcama değildir |
| Apple Takvim | Sistem editöründe tek etkinlik kopyası | Çift yönlü eşitleme veya tekrar kuralı aktarımı yok; cihaz kabulü açık |
| Ekran Süresi | Seçili gruba ortak günlük bütçe; cihaz sahibi onayıyla geçici açma | Uygulama başına farklı bütçe yok; içerik/mesaj okuma yok; Family Controls, App Group, gerçek shield/callback/biyometri cihaz kabulü açık |
| Bildirim | Kullanıcı saati, sessiz saatler, rutin bazlı hatırlatma; açık genel izin | Yakın 7 gün/en çok 60 istek; sistem teslimatı garanti değildir; bildirim ayarını açmak veri üretmez |
| Widget etkileşim | Günlük özet ve uygulamada hızlı görev açan bağlantı | Widget üstünden doğrudan kayıt tamamlama yok; kilitliyken içerik/giriş gizli; eski günlük snapshot güncel başarı gibi gösterilmez |
| Güvenlik | İsteğe bağlı cihaz doğrulaması; pencere seviyesinde geçici gizlilik örtüsü | Fiziksel app switcher/Face ID/bildirim/Files senaryoları henüz kabul edilmiş değildir; dışa aktarılan dosyalar şifrelenmez |
| Erişilebilirlik | Semantik açık/koyu eylem renkleri, büyük dokunma alanları, açıklamalar, Dynamic Type tabanlı metin | Açıklama audit’i ve gerçek XS/en büyük yazı boyutu ölçümleri yalnızca test edilen ekranları kapsar; SwiftUI Dynamic Type heuristiği tam uygunluk kanıtı sayılmaz; VoiceOver/Voice Control/Reduce Motion ve iOS 18 runtime matrisi ayrıca gerekir |
| Performans | 10.959 sentetik kayıtta çekirdek rapor doğruluğu/zamanı ölçülür | Gerçek SwiftUI/SwiftData açılış, kaydırma, pil ve fiziksel cihaz performansı değildir |
| Ticari kapsam | Ücretsiz, hesapsız çekirdek; reklam/abonelik/harici analitik eklenmedi | Gerçek kullanılabilirlik, devam kullanımı ve ödeme isteği araştırması katılımcı gerektirir; fiyat/gelir doğrulanmadı |

Apple Developer üyeliği ürün sahibinin bildirimine göre etkinleştirilme sürecindedir. İmzalı dağıtım, App Store Connect yüklemesi, TestFlight daveti ve Family Controls dağıtım onayı yapılmış kabul edilmez. Kaynak ve simülatör testleri bu hesap işlemlerinin yerine geçmez.
