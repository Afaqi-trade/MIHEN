# Test raporu

Tarih: 2026-11-14 (Europe/Istanbul). Son doğrulanmış durum aşağıdadır; CI sonucu geldikçe güncellenir.

| Kontrol | Gerçek sonuç |
|---|---|
| `swift build` | PASS; Foundation tabanlı MIHENCore derlendi, Swift 5.10 / macOS 14.6.1 |
| `swift test` | BLOKE: XCTest not available; CLT SDK'sında PlatformPath/XCTest yok |
| `python3 Scripts/test-core.py` | PASS: aynı XCTest test gövdelerinden 33 senaryo, 82 assertion, 0 hata; bağımsız Swift assertion yürütücüsü |
| `python3 Scripts/verify-project.py` | PASS: tüm hedef kaynak referansları, plist/XML, asset dosyaları, 274 TR/EN anahtarı ve Swift sözdizimi |
| `xcodebuild -list -project MIHEN.xcodeproj` | BLOKE: aktif developer directory CommandLineTools; tam Xcode yok |
| iOS uygulama/widget derlemesi | Henüz doğrulanmadı |
| SwiftData XCTest / XCUITest | Yazıldı; henüz çalıştırılmadı |
| Uzak GitHub Actions | Hazırlanıyor; gerçek run ID/sonuç oluşmadan başarılı sayılmaz |
| Gerçek iPhone / TestFlight | Yapılmadı |
| App Store ekran görüntüleri | Üretilmedi |

Çekirdek kapsamı: sabit sekiz alan; günlük/haftalık/aylık/yıllık/Hicri tekrar; 31 Ocak/Şubat ve artık yıl; DST 23 saatlik gün ve saat dilimi; idempotent gerçekleşme; 2/6 kısmi/tamamlama; geçmiş snapshot; arşiv/silme; onaylı taşıma/yeniden dağıtım; boş veride yüzde yok; dinlenme/istikrar; hedefe aynı birimde katkı; hatim günlük miktarı; ezber tekrar aralıkları; planlanan/tutulan oruç ayrımı; haftalık/aylık payda; JSON disk roundtrip; bozuk/bilinmeyen yedek; mükerrer kimlik/gün; döngü/dangling referans; CSV tırnak/virgül/satır sonu/Türkçe; CSV önizleme/alan eşleştirme; aşırı sayfa sayısıyla overflow reddi.

Başlangıç test hataları düzeltildi: fallback assertion yürütücüsünde throwing autoclosure işleme; farklı birim toplamı engellendikten sonra eski test fixture'ının birimi pages olarak düzeltildi. Son çekirdek koşusu 0 hatadır.

Kaynakta yazılmış cihaz testleri: SwiftData store'u kapat/aç/kısmi Türkçe kayıt; başarısız save veriyi korur; tüm tabloları sıfırla; JSON repository restore. XCUITest başlangıç akışı hedef/görev oluşturma, tamamlama, yeniden açma ve screenshot attachment; dil/tema kontrolleri. Master prompttaki tüm 14 UI akışının otomatik kapsamı henüz tamamlanmadı.

Fallback, SwiftUI derleme veya iOS çalışma kanıtı değildir. Tamamlanma/yayın kapıları açık kalır.
