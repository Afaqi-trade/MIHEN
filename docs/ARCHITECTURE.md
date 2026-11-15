# Mimari

UI → `@MainActor @Observable AppStore` → doğrulanmış `BackupDocument` → `Repository` → SwiftData.

Core, Foundation dışında Apple UI veya veri katmanı bağımlılığı taşımaz. Xcode uygulamasında aynı kaynaklar derlenir; SwiftPM kütüphanesi yerel ve uzak macOS testlerini çalıştırır. SwiftUI görünümleri kayıtları kopya form taslaklarında düzenler; Kaydet açık işlemdir. AppStore değişikliği önce aday belgeye uygular, tüm bütünlüğü doğrular, repository kaydı başarıyla tamamlandıktan sonra görünür duruma geçirir. Hata halinde repository rollback yapar; kalıcı veriyi sessizce silip boş store'a geçmez.

Repository her model tablosunu ID ile eşleştirir; değişenleri günceller, yenileri ekler, açıkça çıkarılanları siler. Tüm değişiklikler tek save transaction'ıdır. ID üzerinden mantıksal referanslar Core'da doğrulanır; SwiftData @Relationship/cascade kullanılmaz. Widget kalıcı veriye yazmadığı için tek yazıcı ana uygulamadır. Büyük veri için tüm belge doğrulaması/fetch maliyeti ölçülmeli; henüz performans iddiası yoktur.

Tarihler mutlak Date, gerçekleşme anahtarları oluşturulduğu kullanıcı saat diliminde YYYY-MM-DD'dir. Gün ekleme Calendar üzerinden yapılır. Aylık tekrar orijinal gününü korur; 31 → Şubat sonu → 31. Dinlenme günleri alışkanlıkları etkiler. Mevcut snapshot'lar tercih veya görev değiştiğinde yeniden yazılmaz. Eski kayıtlar 366 güne kadar foreground backfill alır; görev düzenlenirken başlangıçtan bugüne snapshot alınır, işlemde en çok 36.600 takvim günü sınırı vardır.

Bildirimler her başarılı değişiklikte sıraya alınmış, önceki işlemi iptal edip bitmesini bekleyen bir reconciliation ile yenilenir. Yakın 7 gün ve en çok 60 istek; sessiz saatler atlanır. Background push veya sınırsız bildirim garantisi yoktur.

Widget App Group içindeki dosyayı yalnızca okur. Ana uygulama SwiftData kaydı sonrası gerçek veriden güncel özet yazar. App Group erişilemiyorsa yerel ana uygulama kullanılmaya devam eder; ayarda durum açıklanır. Kilit aktifse görev adı aktarılmaz, widget sayıları da göstermez. Özet dosyası NSFileProtectionComplete ile yazılır.

Şema `MihenSchema` 1.0.0, migration plan başlangıç sürümüdür. Sonraki sürüm önce mevcut şemayı dondurmalı, yeni VersionedSchema ve migration testlerini eklemelidir; başlangıç planı gelecekteki her göçü otomatik çözmez.

## Ekran Süresi

`Core/UsageLimitPolicy` eşik, gün ve geçici erişim durum makinesidir; Apple UI/API bağımlılığı yoktur. `ScreenTimeController` bireysel sistem iznini, DeviceActivity günlük/geçici aralıklarını ve LocalAuthentication onayını yönetir. `MIHENActivityMonitor` sistem callback'lerini `UsageLimitRuntime` üzerinden işler. Hem ana uygulama hem uzantı aynı App Group repository'sini kullanır; JSON atomik yazılır, flock ile prosesler arası mutasyon ve ManagedSettings etkisi sıraya konur. Kısıt yalnızca MİHEN'e ait isimli ManagedSettings mağazasına uygulanır. Geçici süre sonu izleme başarıyla kurulmadan shield kaldırılmaz. Opaque uygulama tokenları SwiftData/taşınabilir yedekten ayrıdır; tüm veri silme kendi izleme/kısıtlarını da temizler. Beşinci Xcode hedefi uzantı olarak ana uygulamaya gömülür ve yapısal kontrolde doğrulanır. Ayrıntı SCREEN_TIME_TR.md içinde.
