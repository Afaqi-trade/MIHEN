# Test raporu

Tarih: 2026-11-14 (Europe/Istanbul).

**Son doğrulanmış koşu:** [43619860236](https://github.com/Afaqi-trade/MIHEN/actions/runs/43619860236), kaynak commit `1aeadbd980e303e7567a1fc8b431cb3e2ea58dd8`. macos-26 GitHub runner, Xcode 26.6, iOS 26.5 Simulator SDK; iPhone 17 Pro / iOS 26.4.1 simülatörü. Gerçek BUILD SUCCEEDED ve TEST SUCCEEDED logları doğrulandı. Sonuç: **46 passed, 0 failed**.

| Kontrol | Gerçek sonuç |
|---|---|
| Uzak uygulama + widget derlemesi | PASS, Swift 6 / Xcode 26.6 |
| Uzak `swift test` | PASS: 35 çekirdek XCTest, 0 hata |
| iOS XCTest | PASS: 40 test (35 çekirdek + 4 SwiftData + 1 yerelleştirme), 0 hata |
| iOS XCUITest | PASS: 6 akış, 0 hata |
| Sonuç paketi ve screenshot dışa aktarma | PASS; xcresult, özet JSON ve attachment'lar saklandı |
| Yerel `swift build -Xswiftc -strict-concurrency=complete -Xswiftc -warn-concurrency` | PASS, Swift 5.10 CLT ile çekirdek derlemesi |
| Yerel `python3 Scripts/test-core.py` | PASS: 35 senaryo, 94 assertion, 0 hata |
| Yerel `python3 Scripts/verify-project.py` | PASS: kaynak referansları, plist/XML/asset, 275 TR/EN anahtarı, Swift sözdizimi |
| Yerel `swift test` / `xcodebuild` | BLOKE: XCTest ve tam Xcode yerelde yok; uzak test bunu ayrı ortamda tamamladı |
| Gerçek iPhone / TestFlight / imzalı archive | Yapılmadı; yayın kapısı açık |

## Arayüzde gerçekten çalıştırılan akışlar

1. Onboarding atlama → hedef oluşturma → görevi hedefe bağlama → 2/6 kısmi kayıt → tamamla → uygulamayı kapat/aç → kalıcılığı doğrula.
2. Türkçe → İngilizce dil değişimi → koyu ve açık tema → ana ekran; gerçek screenshot attachment'ları.
3. Günlük görevi oluştur/tamamla → hatim oluştur → 6/604 sayfa kaydet → takvimde görevi gör → gerçek ilerleme özetini doğrula; Plan/Takvim/İlerleme ekranları.
4. Oruç planı oluştur → planlandı/tamamlandı sayılarını ayrı doğrula → durumu tamamlandı yap.
5. Ezber ayet aralığı ve öğrenilen miktar → tekrar kaydı → sonraki tekrar tarihi.
6. Zikir sayacı oluştur → artır/azalt → gerçek değeri doğrula.

SwiftData: diskteki store'u kapat/aç, 2/6 kısmi kayıt ve Türkçe metin; geçersiz save mevcut veriyi değiştirmez; tüm tablolardaki veriyi sıfırla; JSON yedeğini repository'ye geri yükle.

Çekirdek: sekiz sabit alan; tüm tekrar türleri; artık yıl/31 Ocak/Şubat; DST ve saat dilimi; idempotent gerçekleşme; tarihsel snapshot; dinlenme/istikrar; onaylı taşıma/90 güne kadar yeniden dağıtım; birim uyumlu hedef katkısı; boş veride yüzde yok; hatim miktarı; ezber takvimi; oruç durum ayrımı; dönem paydaları; JSON disk roundtrip; bozuk/bilinmeyen yedek; ID/gün mükerrerliği; döngü/referans bütünlüğü; CSV tırnak/virgül/satır sonu/Türkçe/önizleme; spreadsheet formül hücrelerini koruma ve apostrof roundtrip; aşırı sayfa sayısıyla overflow reddi.

## Kanıtlar

Özel depo: [Afaqi-trade/MIHEN](https://github.com/Afaqi-trade/MIHEN). Uzak koşudaki `MIHEN-test-results` artifact'i 7 gün saklanır. İndirilen paket `.build-results/remote-43619860236/` altındadır: workflow/derleme logları, toolchain, device listesi, xcresult, test-summary.json ve gerçek ekran attachment'ları. Üretim verisi kullanılmadı; UI testleri memory store veya DEBUG UUID'li ayrı test store'u kullanır.

## Düzeltme geçmişi

| Koşu | Sonuç / giderilen neden |
|---|---|
| 43615202286 / 9275b02 | Çekirdek 33/33 geçti; iOS derlemesi `.self` metatype ve notification Sendable nedeniyle başarısız. Job pipeline hatayı gizlediğinden yeşil görünüyordu; iOS başarısı sayılmadı. |
| 43615423079 / 6a7f9bb | Önceki hatalar ve pipeline/hidden artifact saklama düzeltildi. Plan View type-check ifadesi nedeniyle build başarısız. |
| 43615660200 / 880663a | Plan bileşenleri ayrıldı; Xcode 16.4 ile build, 37 birim + 2 UI testi geçti. İlk gerçek iOS başarı kanıtı. |
| 43616153504 / 02a94a1 | Xcode 26.6 build ve 38 birim geçti; 6 UI testinden 4'ü geçti. Formun ekran dışında kalan hedef alanı ve açık klavyenin sekmeleri engellemesi düzeltildi. |
| 43617005334 / 262be98 | Xcode 26.6 build + 38 birim + 6 UI testi geçti. Klavye Bitti/focus, test kaydırma ve başlık otomatik düzeltme düzeltmeleri doğrulandı. |

## Açık test kapıları

Master prompttaki tüm UI akışları henüz otomatik kapsanmıyor: Files sağlayıcısında gerçek dışa aktarma/içe aktarma/geri yükleme, tüm silme/bozuk dosya hata ekranları, geniş erişilebilirlik ve büyük veri performansı için ek doğrulama gerekiyor. Fiziksel cihazda Face ID/cihaz parolası, kilit ekranı dosya koruması, App Group/widget, bildirim teslimatı ve TestFlight henüz test edilmedi. XCTest JSON/CSV ve repository restore başarısı, Files UI/cihaz doğrulamasının yerine geçmez. App Store'a hazır olarak işaretlenmedi.

## Son kaynak değişiklikleri

`59946a5` / `638f776`: sayı alanı doldurulurken tüm eski değeri seç, tam yeni değeri assert et, 2/6 görünümünü assert et; yüzde ve sayıları seçilen dile göre biçimlendir; Chart eksenini takvim dönemine sabitle; ezber tarihini seçilen dil/saat diliminde göster. [43618218866](https://github.com/Afaqi-trade/MIHEN/actions/runs/43618218866) 44/44 geçti.

`dd020f0`: ezber satırında borderless düğmelerle sadece basılan eylem çalışır; review sonrası edit sheet açılmaması kontrolü; başlangıç şablonları sabit ID ile idempotent, not alanı kullanıcıya ait; ad/not değişse bile tekrar yüklemede mükerrer oluşmaz. Kişisel başlıklar çeviri anahtarı gibi yorumlanmaz; çeviri/literal başlık testi gerçek uygulama bundle'ında doğrulandı. Yerel çekirdek 35 senaryo / 94 assertion geçti; uygulama testine çeviri/literal başlık kontrolü eklendi.

`1aeadbd`: dolu sayısal alanlarda sayfa, ilk/son ayet, öğrenilen ayet ve sayaç hedefi etiketleri kalıcı görünür.

## Son görsel ve veri QA

`43617005334` yeşil olsa da görsel QA miktar alanına 6 yerine 61 girildiğini ortaya çıkardı; o koşu 2/6 kanıtı sayılmadı. `638f776` sürümünde eski sayı tümüyle seçilerek silinir ve yeni değerin tam eşitliği assert edilir; 2/6 ekranda ayrıca assert edilir. Yüzde/sayı biçimleri TR/EN seçimine bağlandı, haftalık Chart saat yerine gün eksenine sabitlendi.

Ezber review düğmesinin aynı List satırındaki edit düğmesini de tetiklemesi `dd020f0` ile düzeltildi; edit sheet açılmaması assertion'ı ve bağımsız düğme stili son koşuda geçti. Şablon kimliği not alanından ayrıldı; ad/not düzenlemesi sonrası tekrar yüklemenin çoğaltmaması ve kişisel başlıkların literal kalması test edildi. `1aeadbd` ile sayfa/ayet/sayaç alanlarında değer doluyken de açıklayıcı etiketler korunur.

12 özgün native PNG, `docs/screenshots/` altında; kaynak run/commit ve byte SHA256 bilgileri `provenance.json` içinde. Test özeti ve toolchain bilgisi `docs/evidence/43619860236/` altında ayrıca korunur. Sonraki yalnızca belge/görsel commit'i test edilen uygulama kaynağını değiştirmez.

Son görsel incelemede 2/6 kaydı, gün ekseni, TR sayı/tarih biçimi, İngilizce açık/koyu tema, sayaç etiketi ve review sonrası edit sheet açılmayan ezber listesi kontrol edildi. Son pakette 46/46 test geçti, 0 skip var; 12 native PNG hash'leri kaynak artifact ile byte düzeyinde aynı.

## Devam eden genişletme doğrulaması

`3675a26` için başlatılan `43639196427` ve `87a21c6` için `43639560615` daha yeni koşularla değiştirildi; iptal edildiler ve başarı sayılmazlar. `56f9671` kaynak koşusu `43639647216` takip ediliyor. Bundan sonraki `b80d645` ayrıca test edilmelidir.

Yerel çekirdek: yeni tekrar eden etkinlik ve beslenme/kaza yedek testleri dahil 37 senaryo, 100 assertion, 0 hata. JSON saniye hassasiyetine uygun sabit test tarihi kullanıldı. Yeni recovery testi iOS XCTest içinde; yerel CLT koşusu bunu kapsamaz. Yeni rapor UI testi de yalnızca uzak simülatörde doğrulanabilir.

`43639647216` / `56f9671`: gerçek sonuç JSON'u 48 passed, 0 failed, 0 skipped; rapor ekranının native screenshot'u incelendi. Kanıtlar docs/evidence/43639647216 içinde. Sonraki kaynak için bu sonuç genellenmez.

`43640375765`: AppleCalendarEditor delegate protokolünün Swift 6 actor izolasyonu nedeniyle derleme başarısız. `0bce546` callback'i nonisolated girişten MainActor'a taşıdı. `43640550462` bu düzeltme ve son Apple Sağlık/kalıcılık testlerini doğrulamak üzere çalışıyor.

15 Kasım: `43640550462` gerçek derlemeyi geçti, ancak beslenme kalıcılığı UI testi 450 yerine 4.500 girildiğini yakaladı. Başarılı kabul edilmedi. `42da9f5` sayısal alanı yazarken metni sabit tutar, odak bitince biçimlendirir. Sonraki kaynak namaz hesabı/widget ve düzeltmeler içerir; yeni uzak doğrulama gerekir.

Yerel strict concurrency Core derlemesi geçti. Ankara referans saatleri (Adhan upstream 2019 fixture, 2 dakika tolerans), Hanefî ikindi farkı ve geçersiz enlem testi eklendi: 38 senaryo, 109 assertion, 0 hata. Bu referans testi güncel resmî Diyanet verisiyle doğrulama değildir.

## 15 Kasım son doğrulanmış uzak koşu

`43695353187` / `e7c654c`: gerçek logda BUILD SUCCEEDED ve TEST SUCCEEDED. Xcode macOS runner uygulama ve iki widget'ı derledi. Sonuç: **53 passed, 0 failed** (44 birim/kalıcılık, 9 UI). Son kaynak beslenme sayı girişini, yeniden açılınca kalıcılığı ve namaz koordinat ayarı/kaydetme/ekran görüntüsünü de içerir. Yerel Core: 38 senaryo, 109 assertion, 0 hata. Önceki `43640550462` sayı girişi hatası son koşuda kapandı.

Koşu: https://github.com/Afaqi-trade/MIHEN/actions/runs/43695353187 . Bu sonuç fiziksel cihazda HealthKit, bildirim teslimatı veya App Group provisioning kanıtı değildir. Otomatik sosyal medya süre kısıtlaması henüz uygulanmadı; docs/INTEGRATION_PLAN_TR.md açık akışı ve dış yetki adımlarını içerir.

53/53 geçen `43695353187` görsel QA sırasında namaz saatlerinin SwiftUI ortamından UTC görüntülendiği saptandı. Bu koşu namaz saat dilimi kabul kanıtı sayılmaz. `b7e3649` uygulama/widget saat metnini seçilen bölgeyle DateFormatter üzerinden oluşturur; `3661ce3` UI testini 15 Kasım 2026 tarihine sabitler ve Ankara sabah `06:00` kontrolünü ekler. Test fixture yalnızca DEBUG --ui-testing bayraklarıyla çalışır. Modern İstanbul +03 kontrolü eklendi; 1970 tarihinin +02 olması doğru tarihsel davranıştır. Son yerel sonuç: 38 senaryo / 110 assertion / 0 hata.

`43696376397`: namaz saat dilimi ve İstanbul 06:16 kontrolü geçti; koordinatları yeniden yazma testinde kısmi metin seçimi nedeniyle UI test hatası oluştu. `43697198163`: İstanbul hazır konum ve saat testi geçti; beslenmede sayı temizleme testi 4500 girildiğini yakaladı. `556ebd2`: sıfır değer odak alınca boş açılır; UI helper sistemin Tümünü Seç menüsünü kullanır ve tam değer eşitliğini korur. Yeni uzak koşu sonucu ayrıca doğrulanmalıdır.

## Son doğrulanmış sürüm — 15 Kasım 2026

**43698033651 / 556ebd2**: gerçek BUILD SUCCEEDED, TEST SUCCEEDED; **53 passed / 0 failed**, 44 birim-kalıcılık + 9 UI. İstanbul hazır konum düğmesi, tam koordinat eşitliği ve 15 Kasım 2026 sabah **06:16** görünümü geçti. Beslenmede **450 kcal** tam değer ve uygulamayı kapatıp açınca kalıcılık geçti. Sayı alanı yazım sırasında yeniden biçimlenmez; sıfır değer düzenlemeye boş başlar. UI testleri metni sistemin Tümünü Seç işlemiyle değiştirir. Önceki başarısız koşular son başarı olarak sunulmaz.

Koşu: https://github.com/Afaqi-trade/MIHEN/actions/runs/43698033651 . Namaz hesaplama, yöntem/ikindi seçimi ve ayrı namaz widget'ı kaynakta ve gerçek iOS derlemesinde mevcut. Widget'ın fiziksel iPhone'da App Group verisini alması, HealthKit gerçek veri/izin ve bildirim teslimatı hâlâ cihaz kabul kapılarıdır. Ekran Süresi kısıtlaması tasarım aşamasındadır.

Sonuç paketi indirildi: `.build-results/remote-43698033651/` altında gerçek xcresult, loglar ve PNG attachment'ları var. JSON: **53 passed, 0 failed, 0 skipped**. Kanıt özeti ve özgün namaz/beslenme PNG'leri `docs/evidence/43698033651/` içinde; kaynak SHA256 ve test kimlikleri provenance.json ile saklanır. Son görsel kontrol İstanbul sabah 06:16, Türkiye saat dilimi ve 450 kcal kaydını doğruladı.
