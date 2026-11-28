# Test raporu

## 28 Kasım — iPhone geri bildirimi ve namaz widget'ı

`366a491`: Yerel `swift test` **77 test / 0 hata**; uygulama ve iki uzantının Debug iPhone derlemesi başarılı. Kullanıcının mevcut iPhone kurulumuna aynı bundle/team kimliğiyle yerinde güncelleme yapıldı; kullanıcı uygulamanın açıldığını, Takvim'deki namaz bağlantısını, yeni ikonu ve önceki görevlerini gördüğünü bildirdi. Kullanıcı namaz widget'ında altı vaktin okunabildiğini de bildirdi. Widget boyutu, konum/yöntem değişimi ve farklı saat dilimleri için ayrı fiziksel cihaz matrisi yapılmadı.

Uzak `46140160439` / `366a491`: **93 geçti / 0 hata / 0 atlama**; `prayer` kapsamı tüm uygulama birim/kalıcılık testleri ve Takvim'den namaz ekranı UI testidir, tam UI matrisi değildir. Gerçek `.xcresult` kökü ve 1.572 Data dosyası, JSON özeti ve native namaz ekranı incelendi; kanıtlar `docs/evidence/46140160439` içindedir. Namaz görseli 15 Kasım İstanbul test tarihindeki 06:16 değerini gösterir; güncel resmî takvim karşılaştırması değildir. Yerel simülatör UI koşusu 20 dakikadan fazla sonuç üretmeyince durduruldu ve başarı sayılmadı.

Güncelleme: 2026-11-24 (Europe/Istanbul).

## 24 Kasım — gerçek imzalı IPA doğrulaması

`45192651735` / `b55b40f`: iPhone 17 Pro / iOS 26.4.1 simülatöründe **93 passed / 0 failed / 0 skipped**. Gerçek xcresult kök kaydı ve 1.506 Data öğesi, sonuç JSON'u ve dört native PNG attachment incelendi. Bu dar `daily-guided` kapsamıdır; tam UI matrisi değildir.

`45257992808` / `f6bf37f`: GitHub macOS 26 ARM koşusunda gerçek **ARCHIVE SUCCEEDED** ve **EXPORT SUCCEEDED**. Apple Distribution ile imzalı `MIHEN.ipa` üretildi: 2.185.316 byte, SHA-256 `3dcb2381944d2d64e797ecb4379cfd61d63bc401eb91b6396c106b4308f67bfd`. İmzalı ana uygulama `PY75Z73294.com.afaqitrade.mihen`, widget ve monitor uzantıları ortak `group.com.afaqitrade.mihen` alanını içerir. Ana uygulama/monitor Family Controls; ana uygulama/widget `NSFileProtectionComplete` entitlement'ını içerir. Artifact, imzalı entitlement plistleri ve IPA 7 gün saklanır. **App Store Connect'e yükleme, TestFlight daveti veya fiziksel iPhone kurulumu yapılmadı.**

`45262542216` / `4d2b4cd`: güncel metadata ile Intel macOS 26 fallback koşusunda gerçek **ARCHIVE SUCCEEDED** ve **EXPORT SUCCEEDED**. İmzalı güncel IPA **1.0.0 (2)** sürümündedir; 2.185.607 byte, SHA-256 `6daa7d5fc55657f61e1ce46b17d2ada6f6a1d1eb3d325c2a6cd3dce697074015`. Paket açılarak ana uygulamada `NSHealthUpdateUsageDescription`, widget uzantısında `CFBundleDisplayName = MİHEN` ve her iki hedefte build `2` okundu. Bu, Transporter'ın önceki `90683` ve `90360` doğrulama eksiklerini kapatır. **Yalnızca bu Build 2 IPA yüklenmelidir; App Store Connect'e yükleme, TestFlight daveti veya fiziksel iPhone kurulumu henüz yapılmadı.**

`45279974082` / `5d30424`: Kullanıcı önceki 1.0.0 (2) TestFlight build'ini expire ettiği için aynı marketing version ile yeni imzalı IPA üretildi. Intel macOS 26 koşusunda gerçek **ARCHIVE SUCCEEDED** ve **EXPORT SUCCEEDED**: güncel IPA **1.0.0 (3)**, 2.185.617 byte, SHA-256 `42ee301cc1321d444cf38bb72158f387bf2bb80ff5f0a3a60df63edc5d1ef716`. Paket açılarak ana uygulama/widget build `3`, `NSHealthUpdateUsageDescription` ve `CFBundleDisplayName = MİHEN` doğrulandı. **Yalnızca bu Build 3 IPA yüklenmelidir; Apple'a yükleme veya fiziksel iPhone kurulumu yapılmadı.**

`45263372679` / `4d2b4cd`: iPhone 17 Pro / iOS 26.4.1 Intel simülatöründe güncel kaynak için **93 passed / 0 failed / 0 skipped**. Gerçek `.xcresult` kök kaydı (format 3.58) ve **1.400 Data öğesi**, sonuç JSON'u, dört native PNG ve PDF/performans ekleri indirildi ve incelendi. PNG'ler rehberli ilk kullanım seçenekleri, ilk kullanım, şablon haftası ve Türkçe Bugün ekranını içerir; başarısız test ekleri yoktur. Bu `daily-guided` kapsamıdır, tam UI matrisi değildir.

Önceki `45255224909` yeşil iş kabul edilmedi: çalıştırma izni olmayan betik hatası `tee` borusuyla gizlenmiş, IPA oluşmamıştı. `4677679`, `1b27b9d` ve `f6bf37f` workflow'u hata kodunu koruyup Apple Distribution kimliğini açıkça seçerek bu yanlış-pozitifi kapattı.

## Güncel sonuç — ürün incelemesi sonrası

| Koşu | Kaynak | Kapsam | Sonuç |
|---|---|---|---|
| [43927332097](https://github.com/Afaqi-trade/MIHEN/actions/runs/43927332097) | `441886f` | Tam; 70 uygulama birim/kalıcılık + 14 UI | **84 passed / 0 failed / 0 skipped** |
| [43930797517](https://github.com/Afaqi-trade/MIHEN/actions/runs/43930797517) | `1906be8` | SE 3; 70 uygulama birim/kalıcılık + 1 UI | **71 passed / 0 failed / 0 skipped** |

Her iki koşuda gerçek BUILD SUCCEEDED ve TEST SUCCEEDED doğrulandı. Xcode 26.6 / 17F113; iOS Simulator 26.4.1. SwiftPM çekirdek ayrıca 57/57 geçti. Yerel CLT fallback 57 senaryo / 189 assertion geçti. Koşuların ortak testleri iki ayrı doğrulamadır; benzersiz test sayısı olarak toplanmaz. Sonraki tarihsel bölümler güncel sonuç yerine kullanılmaz.

Uygulama/Core/widget/monitor kaynakları iki commit arasında aynıdır; fark yalnızca UI-test kart sorgusudur. Küçük ekran sonucunu tam UI matrisi gibi sunmayın. Fiziksel iPhone, iOS 18 runtime, tüm ekranlarda VoiceOver/Voice Control/Reduce Motion, Files sağlayıcısı, izinli entegrasyonlar ve TestFlight ayrı kabul kapılarıdır. Sonraki kaynak değişiklikleri bu sonuçla doğrulanmış sayılmaz.


**14 Kasım tarihsel koşusu:** [43619860236](https://github.com/Afaqi-trade/MIHEN/actions/runs/43619860236), kaynak commit `1aeadbd980e303e7567a1fc8b431cb3e2ea58dd8`. macos-26 GitHub runner, Xcode 26.6, iOS 26.5 Simulator SDK; iPhone 17 Pro / iOS 26.4.1 simülatörü. Gerçek BUILD SUCCEEDED ve TEST SUCCEEDED logları doğrulandı. Sonuç: **46 passed, 0 failed**.

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

Depo: [Afaqi-trade/MIHEN](https://github.com/Afaqi-trade/MIHEN). Uzak koşudaki `MIHEN-test-results` artifact'i 7 gün saklanır. İndirilen paket `.build-results/remote-43619860236/` altındadır: workflow/derleme logları, toolchain, device listesi, xcresult, test-summary.json ve gerçek ekran attachment'ları. Üretim verisi kullanılmadı; UI testleri memory store veya DEBUG UUID'li ayrı test store'u kullanır.

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

## Ekran Süresi geliştirmesi — 15 Kasım

`43700231433` / `7f785cd`: uygulama, widget ve yeni DeviceActivity monitor uzantısı gerçek Xcode derlemesinden geçti. 60 test geçti, 1 UI testi başarısız: kurulum ekranında ekran dışındaki etkinleştirme düğmesine kaydırmadan erişim. Policy ve gerçek dosya repository testleri geçti. Bu koşu tam başarı sayılmaz.

`b275e67`: gecikmiş geçici erişim callback'i, eşzamanlı uygulama/uzantı yazımları, bozuk dosyayı doğrulamalı sıfırlama ve kaybolmuş sistem monitorü için ek kontroller. `155d461`: kurulum UI testinde etkinleştirme düğmesine kaydırma. Son uzak koşu `43701076134` sürüyor. Yerel strict concurrency Core derlemesi ve 44 senaryo / 132 assertion geçti; platform entegrasyonunun derleme/test sonucu ayrıca doğrulanır.

Test sınırı: politika ve monitor callback adaptörü testleri gerçek OS ekranına shield uygulandığını kanıtlamaz. Uygulamalar arası gerçek kullanım süresi, shield ekranı, bireysel izin ve biyometri, süre sonu callback teslimatı gerçek iPhone'da; Family Controls dağıtım yetkileri de yayıncı hesabında doğrulanmalıdır. SCREEN_TIME_TR.md cihaz kabul listesini içerir. UI testinde yetki/başarılı kısıtlama taklit edilmez.

`43701076134` / `155d461` tam koşusu doğrulandı: gerçek BUILD SUCCEEDED, TEST SUCCEEDED, **64 passed, 0 failed, 0 skipped** (54 birim/kalıcılık + 10 UI). Gerçek xcresult ve attachment'lar indirildi; izin/ortak depolama yokken devre dışı kalan kurulum ekranı görsel olarak incelendi. Kanıtlar `docs/evidence/43701076134/` içinde.

Son `075c2d1` değişikliği geçici aralığın bitişini UTC DateComponents ile kurar; tekrarlanan yerel saat sırasında süre uzayıp/kısalmaz. Yerel sonuç 45 senaryo / 137 assertion / 0 hata. Bu son değişiklik `43702054711` / `0ad6148` odaklı koşusunda tüm uygulama birim/kalıcılık testleri ve Ekran Süresi kurulum UI testiyle doğrulanıyor. `43701994378` daha yeni ve tam UI test kimliği düzeltilmiş koşuyla değiştirildi; başarı kanıtı olarak kullanılmaz. Dar koşu tam UI koşusu olarak sayılmaz.

**Son odaklı doğrulama: 43702054711 / 0ad6148157085a58afd6e65c172a7c9eb3e9b94f.** Xcode 26.6 / build 17F113; uygulama, widget ve monitor uzantısı gerçek derlemeden geçti. `Test scope: screen-time`. **56 passed, 0 failed, 0 skipped:** tüm 55 uygulama birim/kalıcılık testi + 1 gerçek Ekran Süresi UI testi. Tam UI koşusu değildir. SwiftPM çekirdek 45/45; yerel fallback 45 senaryo / 137 assertion geçti. Runtime callback adaptörü, kilitli eşzamanlı disk güncellemeleri, bozuk dosya reseti, reddedilen işlemin commit/etki üretmemesi ve UTC/DST süre sonu testleri geçti. Sonuç JSON, toolchain, native kurulum ekranı ve SHA256/test kaynağı `docs/evidence/43702054711/` içinde. Gerçek xcresult `.build-results/remote-43702054711/` altında. İlk başarısız kurulum testinin kaydırma hatası kapandı.

Koşular: https://github.com/Afaqi-trade/MIHEN/actions/runs/43701076134 (tam), https://github.com/Afaqi-trade/MIHEN/actions/runs/43702054711 (son kaynak, odaklı). Family Controls dağıtım izni, fiziksel uygulama kullanımı/shield, biyometrik onay ve gerçek süre sonu callback kabulü tamamlanmış iddiası yoktur.


## TestFlight teknik hazırlığı — 15 Kasım

`43704463900` / `5af9ce3`: uzak Xcode ile gerçek `generic/platform=iOS`, **Release archive** adımı başarıyla çalıştı. Uygulama + widget + DeviceActivity monitor arm64 binary'leri, gömülü uzantılar, sürüm/build uyumu ve privacy manifestleri arşiv içinden kontrol edildi. Rapor `docs/evidence/43704463900/testflight-readiness.json` içinde. Bu adım yeni bir simülatör test koşusu veya imzalı dağıtım değildir.

Hesap sahibi aktif Apple Developer Program üyeliği olmadığını bildirdi. Apple hesabında giriş/yetki, gerçek bundle/App Group kayıtları, Family Controls dağıtım onayı, imzalama sertifikası/profilleri ve App Store Connect uygulama kaydı henüz tamamlanmadı. **İmzalı arşiv doğrulanmadı, App Store Connect'e yükleme yapılmadı, TestFlight daveti oluşturulmadı.** İmzasız teknik arşiv iPhone'a kurulabilir paket olarak sunulmaz. Kullanıcının adımları TESTFLIGHT_OWNER_STEPS_TR.md; Family Controls taslağı APPLE_FAMILY_CONTROLS_REQUEST.md içindedir.

Koşu: https://github.com/Afaqi-trade/MIHEN/actions/runs/43704463900 . Workflow varsayılan otomatik yayına bağlı değildir; yalnızca manuel teknik hazırlık yapar.

## Yeni modül galerisi — 16 Kasım 2026

`43859546404` / `1d88ae7`: gerçek derleme ve birim testleri geçti; yeni galeri UI testi rutin seçim anahtarının etiketine dokunulduğunda açık duruma geçmediğini ve kaza miktarının eksik silindiğini yakaladı. Başarı veya galeri kaynağı sayılmadı. `43860953949` sonraki koşuyla değiştirildi; iptal edildi.

`43861206079` / `ca96676`: rutin seçimi/kaydı ve üç mevcut UI regresyon testi geçti; yeni galeri testi kaza sayısında 10 yerine 101, 2 yerine 2101 değerini yakaladı. Bu koşu da galeriye alınmadı. IntegerInput düzenleme sırasında metin state'ini korur; metin değiştirme helper'ı geniş alanın boş ortası yerine metnin sağ ucundan seçim/silme yapacak şekilde düzeltildi. Tam değer ve kalan 8 assertion'ları korunur. Sonraki koşunun sonucu ayrıca doğrulanmalıdır.

`43863080599` / `39c17b9`: 58 passed / 1 failed / 0 skipped. İkinci sayı değişimi 2 olarak geçti; ilk tek haneli 1 değeri 101 kaldığı için sonuç kabul edilmedi. Native test videosu uzun basış sonrası imlecin dar 1 rakamının önünde olduğunu gösterdi. `c38ea9a` helper dokunuşunu alanın son yüzde 0,1'ine taşır; tam eşitlik ve kalan miktar kontrolleri değiştirilmez. Bu başarısız koşunun PNG'leri galeriye alınmadı.

**Son doğrulanmış koşu: [43864948660](https://github.com/Afaqi-trade/MIHEN/actions/runs/43864948660) / c38ea9a44f4f975c2ee06a5f68865023b56e2931.** Gerçek BUILD SUCCEEDED ve TEST SUCCEEDED; sonuç JSON'u **59 passed / 0 failed / 0 skipped** (55 uygulama birim/kalıcılık + 4 UI). SwiftPM çekirdek ayrıca 45/45 geçti. Xcode 26.6 / 17F113, iPhone 17 Pro / iOS Simulator 26.4.1. `module-gallery` kapsamıdır; tam UI matrisi değildir.

Yeni galeri testi gerçek arayüz üzerinden haftalık görev, kaydedilmiş Sabah rutini ve kaza kaydı oluşturdu. Tam sayı 10, ardından 2 girişi ve Sabah kalan **8** assertion'ları geçti. Hedefin 365 miktarı tam eşitlikle girildi; tarih/gün seçimi ve 366 gün için günlük 1 Adet önerisi çekildi. Hedef dağıtım onayı verilmedi; görüntü öneri aşamasıdır. Ortak sayı alanını kullanan hatim, ezber/tekrar ve zikir UI regresyonları da geçti.

Beş özgün PNG görsel olarak incelendi ve `docs/evidence/43864948660/` içinde sonuç JSON'u, toolchain, kaynak/test/çekim zamanı/SHA256 ile korundu. Gerçek xcresult `.build-results/remote-43864948660/` içindedir. Önceki 16 ekranla birleşik galeri **21 ekran** içerir; HTML içindeki 21 PNG hash'i, dosya hash'leri ve ZIP CRC/hash'leri doğrulandı. Başarısız koşuların görselleri galeriye alınmadı. Örnek kayıtlar bağımsız UI-test bellek deposundadır; kullanıcının kişisel geçmişi değildir.

## Ürün incelemesi uygulaması — 16 Kasım, doğrulama sürüyor

`43874697968` / `b1ae313`: çekirdek testleri ve proje yapısı geçti; gerçek iOS derlemesi iki kaynak hatasıyla durdu (GoalPlanningScreen uzun tip çıkarımı ve PDF başlığında MainActor çağrısı). Başarılı sayılmadı. `5803366` bunları düzeltti; `43875429816` tam koşusu başlatıldı. Sonraki yardım/gizlilik/audit/rapor renderer değişiklikleri bu koşunun kapsamı değildir ve ayrıca test edilmelidir.

Yerel son çekirdek: `swift build` geçti. CLT fallback 56 senaryo / 184 assertion / 0 hata. 10.959 sentetik gerçekleşmede 10 yıllık Core raporu doğruluğu kontrol edildi; yerel zaman çıktısı product-core.log içinde. Bu, iOS arayüz veya fiziksel cihaz performansı değildir. Tam Xcode tip kontrolü ve UI kanıtı uzak son commit sonucu gelmeden başarılı kabul edilmez.


## Ürün incelemesi — yeniden başlatılan uzak doğrulama

`43875429816` / `5803366`: gerçek uygulama/uzantı derlemesi geçti; sonuç **77 passed / 2 failed / 0 skipped**. Kaza raporunda birleşik satırın erişilebilirlik sorgusu ve boş miktar alanını placeholder metniyle karıştıran UI giriş helper'ı başarısız oldu. Tam sayı eşitliği kontrolleri korunarak erişilebilirlik değeri ve boş alan kontrolü düzeltildi. Başarısız koşunun görselleri güncel galeriye alınmadı.

`43878131480` / `19c4b6d`: GitHub hesap ödeme/kota engeli yüzünden job başlamadı. Derleme veya test başarısı değildir. Ürün sahibi 16 Kasım'da depoyu public yaptı. Ardından `43915316233` / `0913be7a38f33375c25a2d26b865ce96f8449ec8` tam koşusu gerçekten başladı; önceki engel bu koşuda oluşmadı. Sonuç henüz doğrulanıyor.

Yerel güncel kontrol: `swift build` başarılı; CLT fallback **57 senaryo / 189 assertion / 0 hata**. Bu sonuç iOS derlemesi veya SwiftData/UI testi olarak sayılmaz. Yeni rutin sürdürme testi, duraklama aralığının sonradan doldurulmadığını ve geçmişin korunduğunu kontrol eder. İnceleme önerilerinin uygulama haritası `PRODUCT_REVIEW_IMPLEMENTATION.md` içindedir.


`43915316233` / `0913be7`: gerçek BUILD SUCCEEDED; xcresult sonuç JSON'u **80 passed / 4 failed / 0 skipped** (70 uygulama birim/kalıcılık testi başarılı, 10 UI başarılı, 4 UI başarısız). İlk kullanımda üç Dynamic Type bulgusu, klavye açılırken yer değiştiren sayı alanına koordinatla yeniden dokunma, ekran dışındaki boylam alanı ve 6 yerine 61 girişi yakalandı. Koşu galeri kaynağı sayılmadı. Sayı bileşenleri odakta tüm değeri seçer; test aynı odağı koruyarak tam değer eşitliğini doğrular. İlk kullanımda kritik açıklama ve eylem metni açıkça body boyutunu kullanır ve sarılabilir; Atla erişilebilir etiketli simgedir. Boylam doğrulaması alana kaydırır. `43919696953` eski kaynak, `43920797525` ve `43920797712` son yazı düzeltmesiyle değiştirilen koşulardır; iptaller başarı sayılmaz.


`43921587110` / `0983bec`: gerçek derleme ve 70 birim/kalıcılık testi geçti; tam UI koşusu ilk kullanımda iki SwiftUI Dynamic Type heuristik bulgusu ve oruç menüsüne geçişte başarısız oldu. Sayı değiştirme (tam 10, 2, 365 ve 6), 2/6, raporda 8 Sabah, beslenme kalıcılığı ve namaz koordinat kontrolleri geçti. Başarısız koşu galeriye alınmadı. `43921587177` aynı kaynak için SE 3 / iOS 26.4.1 odaklı koşuda **71 passed / 0 failed / 0 skipped**; ancak görünür denetim alanı dışında kalan metinler için genellenmez.

Gerçek SE görüntüsü, en büyük yazıda özetin ilk eylemi aşağı ittiğini gösterdi. `b63a446` büyük yazı yerleşiminde ilk eylem/görevleri öne alır; boş/dolu görünümü ayrı çeker. Sonraki test düzeltmesi heuristik bulguları görmezden gelen bir handler eklemez: gerçek SwiftUI ağacını yalnızca DEBUG ve açık UI-test bayrağıyla XS ve accessibility5 ortamlarında açar, ilk kullanım gizlilik metni ve Devam eyleminin yükseklik büyümesini ayrı ayrı assert eder, ölçüm JSON'u ve native PNG'leri saklar. Sistem tercihi/Release davranışı değiştirilmez. Açıklama audit’i korunur. Tüm ara boyutların veya tüm ekranların sertifikası değildir. Manevi modül geçişinde typed button sorgusu ve Plan başlığını bekleme, genel kaydırmada iki yönlü arama ve gerçek hittable ön koşulu kullanılır. Tam koşu süresi yeni ölçümleri kapsamak için 45 dakikaya çıkarıldı.


## Son arayüz doğrulaması ve galeri

`43921587110` sonuç JSON’u 82 passed / 2 failed / 0 skipped olarak doğrulandı. `43927332055` / `441886f` odaklı koşusunda 70 passed / 1 failed: XS/en büyük yazı ölçümleri ve açıklama audit’i geçti; görev içindeki StaticText için tek yönlü kaydırma/hittable kontrolü başarısız oldu. Gerçek ekran, kartın geçilerek sayfa altına kaydırıldığını gösterdi. `6a59955` ve `1906be8` yalnızca UI testini düzeltti: kartın metin çocuğunu içeren gerçek Button iki yönlü bulunur, görüntü alınır, dokunularak Görev ayrıntısı açılması assert edilir. `43930596900` eski sorguyla başlatılan ve yenisiyle değiştirilen iptal koşusudur; başarı sayılmaz.

Son SE koşusu 71/71 geçti. Ölçüm JSON’u: gizlilik metni yüksekliği XS 66 → accessibility5 589,5; Devam eylemi 61 → 107,5. Bunlar metnin satırlara yayılmasını da içerir; fontun dokuz kat büyüdüğü iddiası değildir. DEBUG test boyutu SwiftUI ortamını açıkça seçer; varsayılan küçük ekran akışı ayrıca sistemin en büyük içerik ayarında çalışır. Açıklama audit’i ilk kullanım ve boş Bugün’ü kapsar. SwiftUI Dynamic Type heuristiğiyle tüm ara boyutların uyumluluğu ilan edilmez.

Tam koşuda ilk kullanımda yalnızca seçilen şablon, hızlı görev/geri alma, 2/6 ve yeniden açma kalıcılığı, tam sayı 10/2/365/6, raporda 8 Sabah, İstanbul koordinatı ve 06:16 fixture vakti, beslenme 450 kcal kalıcılığı, hızlı su/geri alma, rutin/hafta/hedef önerisi, hatim/ezber/zikir/oruç, dil/tema ve rapor paylaşım alanı seçimi doğrulandı. PDFKit üretim renderer’ının Türkçe içerikli çok sayfalı çıktısını okudu.


Güncel galeri **35 özgün PNG** içerir: 31 görsel tam koşudan, 4 görsel son SE koşusundan. Güncel kaynak listesi `screenshots/CURRENT.md` ve byte SHA256 kayıtları `screenshots/current-provenance.json` içindedir. Tam koşunun 33 capture’ı ve SE koşusunun 4 capture’ı kendi evidence klasörlerinde ayrıca korunur; ortak ilk kullanım ölçüm görüntülerinde galeri son SE çekimini kullanır. Başarısız koşuların PNG’leri güncel galeriye alınmadı. Büyük yazılı görevli ekran kaydırma sonrası özeti gösterir; görev kartına dokunup ayrıntı açıldığı UI assertion’ıyla ayrıca doğrulandı.

Gerçek xcresult bundle’ları ve dışa aktarılmış summary/attachment manifestleri `.build-results/remote-43927332097/` ve `.build-results/remote-43930797517/` altında incelendi. Her iki bundle’ın Info.plist/root kaydı vardır; sonuç JSON’ları 84/0/0 ve 71/0/0 ile loglara uyar. Native PNG byte’ları, HTML gömülü resimleri ve ZIP CRC/hash’leri doğrulandı. `docs/evidence/review-source-equivalence.json`, Core/uygulama/widget/monitor/paylaşılan politika/proje Git tree’lerinin iki kaynakta aynı olduğunu kaydeder. Bu son yalnızca belge/galeri metni/kanıt değişikliği uygulama kaynağını değiştirmez.

## 17 Kasım — kalan yol haritası ve tasarım doğrulaması sürüyor

Son kaynakta yerel `swift build` ve yapı/sözdizimi kontrolü geçti. CLT fallback **77 senaryo / 345 assertion / 0 hata**. Bu sonuç SwiftData veya iOS UI testi değildir. Native test hedefi üretiminde kaynak/senaryo eşitliği kontrolü eklendi; eski üretilmiş test dosyası artık doğrulamayı geçemez.

- `43946452464` / `98410ff`: uygulama derlemesi ve birim/kalıcılık testleri geçti; kaynak bağlama UI testi, SwiftUI onay düğmesinin iç/dış erişilebilirlik düğümleri aynı kimliği taşıdığı için başarısız. Gerçek eşleşen onay kontrolü seçildi; 1/6 ve ayırınca 2/6 kontrolleri korunur.
- `43948814376` / `aa5fe7e`: beslenme ekranında uzun SwiftUI tip çıkarımı nedeniyle derleme başarısız. Metin biçimleme ayrı fonksiyonlara taşındı.
- `43969463089` / `c6c1602`: uygulama derlemesi geçti; iOS test hedefindeki eski üretilmiş test kaynağı parametre sıralaması nedeniyle derlenmedi. Üretici yeniden çalıştırıldı ve stale test kontrolü eklendi.
- `43971158813` / `ed6170e`: widget satırındaki sözdizimi düzeltmesiyle değiştirilen, iptal koşusu; başarı sayılmaz.
- Sonraki tam koşular GitHub Mac kuyruğuna gönderildi. Kesin sonuç, JSON/xcresult ve gerçek screenshot incelemesinden sonra bu bölüme yazılacak. Eski 35 ekran henüz yeni tasarım kanıtı değildir.

Kapsam: kaynak bağlantısı/V1 migration; kapasite/rutin/beslenme; kaynak bazında dönem karşılaştırması, yapılandırılmış cevaplar ve paylaşım; şablon örnek haftası; şehir seçimi/tekrar geri alma; yönetici özeti ve selamlama/tasarım dili. Native performans testi 1/3/10 yıllık **sentetik ve ayrı test mağazasında** save/reopen-load/rapor süresini JSON attachment'a yazar. Fiziksel cihaz, pil veya kullanıcı verisi performansı olarak sunulmaz.

`43971590638` / `638e394`: gerçek BUILD SUCCEEDED; xcresult + sonuç JSON'u **101 passed / 8 failed / 0 skipped**. 91 birim/kalıcılık geçti, 18 UI testinin sekizi başarısız. `43972382277` / `ccf7cfb`: SE 3, **93 passed / 1 failed / 0 skipped**; 92 birim/kalıcılık ve ilk kullanım erişilebilirlik testi geçti, yeni raporun büyük yazıda alan ayrıntısı testinde ekran dışındaki bağlantı bulunamadı. İki bundle'ın Info.plist/Data içeriği ve sonuç JSON'ları incelendi. Bu koşuların ekranları galeriye alınmadı.

Düzeltmeler: kaynak onayı ayrı sunum state'i ve sabit modal ile tutulur; kaynak miktarı ana ayrıntıda canlı ve salt okunur. Hızlı su ayarı odakta tüm metni seçer. UI testi, kayan sekme çubuğunun altında kalan kontrolü `isHittable` tek başına yeterli sayarak dokunmaz; güvenli görünür alana kaydırır. Uzun formdaki özetler ve rutin görev seçimi ayrıca görünür hale getirilir. Plan sekmesinin önceki alt ekranını koruması testte doğru geri gezinmeyle ele alınır. Rapor alanında ana bağlantı öne, uzun kaynak açıklaması açılır ayrıntıya taşınır.

SE koşusunda başarılı native performans testi: 1 yıl (1.098 gerçekleşme + 366 faaliyet): save 0,205 s, reopen/load 0,067 s, yönetici özeti 0,031 s; 3 yıl (3.291 + 1.097): 0,636 / 0,127 / 0,090 s; 10 yıl (10.959 + 3.653): 2,360 / 0,416 / 0,390 s. Tek ölçüm, Debug simülatör ve sentetik veri; UI akıcılığı, pil veya fiziksel iPhone ölçümü değildir. Son başarılı koşunun ölçümleri ayrıca korunacaktır.


`44057110827` / `c964ace`: JSON **104 passed / 7 failed / 0 skipped** (92 birim/kalıcılık, 19 UI). Kaynak bağlantısı için sistem onay penceresi görünmedi; plan miktarı alanı alttaki formun alanıyla aynı kimliği taşıdı. İki davranış düzeltildi: kaynak değişimi açık miktar önizlemesinden onaylanır; beslenme planı/düzenleme/widget miktarları ayrı kimlik taşır. UI kaydırma yardımcısı, gezinme çubuğundaki düğmeleri içerikle karıştırıyor ve büyük kaydırmada kontrolü aşıyordu; araç çubuğu ayrımı ve kısa kontrollü kaydırma eklendi. Bir sayaç testi simülatörün önceki uygulamayı sonlandıramamasıyla durdu; sonraki gerçek koşuda yeniden sınanacak. Başarısız koşunun PNG'leri galeriye alınmadı.

`77c4270`: gerçek görüntüde İngilizce kalan grafik ay etiketleri uygulamanın dil/takvim/saat dilimine bağlandı. Tam `44103597753` ve SE 3 `44103603089` koşuları gönderildi; sonuç bekleniyor. `44103443194` ve `44103450398` önceki kaynak için iptal edilen koşulardır ve başarı sayılmaz.


`44103603089` / `77c4270`: **94 passed / 0 failed / 0 skipped**, gerçek BUILD SUCCEEDED ve TEST SUCCEEDED. SE 3 / iOS 26.4.1; 92 birim-kalıcılık ve 2 UI. xcresult Info.plist ve 1.572 Data dosyası, JSON, beş PNG, Dynamic Type ve native performans attachment'ları incelendi. Kanıtlar `evidence/44103603089/` içinde. Sonraki kaynak ayrıca sınanır.

`44103597753` / `77c4270`: **109 passed / 2 failed / 0 skipped**. Beslenme, rutin/kapasite, kaza, hedef, selamlama ve diğer akışlar geçti. Şehir araması gerçekleşti fakat test yardımcısı sistem arama alanını içerik sınırına zorladığı için hata verdi. Kaynak seçiminde gerçek simülatör videosu ve sentezlenmiş dokunma kaydı incelendi: düğmenin erişilebilirlik merkezi `(201, 555)` satırın boş kısmındaydı; dar VStack etiketinin dışına dokunulduğunda seçim oluşmadı. Sonraki arama kaydırmaları modali kapattı. `1fa33da` etiketin dokunma alanını tüm satıra genişletir; onay, `1 / 6` ve ayırınca `2 / 6` kontrolleri korunur. Önceki onay sunumu değişiklikleri tek başına sorunu çözmemişti. Başarısız koşunun görselleri güncel galeriye alınmadı.

`44304066244` / `9cad731`: gerçek **BUILD SUCCEEDED** ve **TEST SUCCEEDED**; sonuç JSON'u **100 passed / 0 failed / 0 skipped**. Bu koşu 92 birim/kalıcılık testine ek olarak kaynak bağlantısı, kapasite-rutin-beslenme, yönetici özeti/şehir, büyük yazı, yeni modül galerisi, rapor gezintisi ve yedek/hızlı su akışlarını kapsayan 8 gerçek UI testi çalıştırdı. xcresult kök kaydı ve 1.830 Data öğesi, dışa aktarılan test özeti, toolchain kaydı ve 24 özgün native PNG incelendi. Kanıtlar `docs/evidence/44304066244/` içindedir; bu ekranlar 20 Kasım güncel galerisine alındı. Eksik elemanın türü sorgulanmadan önce varlık kontrolü yapan `9cad731` UI test yardımcısı düzeltmesinin ardından bu kritik akışlarda önceki yedi yanlış-negatif tekrar etmedi.

Tam 19 UI akışını kapsayan `44746949560` / `091bd62` koşusu, paylaşımlı macOS çalıştırıcısında genişletilmiş 90 dakikalık sınırla ayrıca yürütülmektedir. Sonuç JSON'u, xcresult ve gerçek görüntüler incelenmeden bu tam koşu başarılı sayılmaz.
# 28 Kasım — Ar-Ge önerilerinin ilk uygulamaları

`9e41306` için [46142515899](https://github.com/Afaqi-trade/MIHEN/actions/runs/46142515899) namaz odaklı uzak iOS koşusu: Xcode 26.6, iPhone 17 Pro / iOS 26.4.1, **95 başarılı, 0 başarısız, 0 atlanan**. Bu kapsam birim/kalıcılık testleri ve tek namaz ekranı UI akışıdır; bütün UI matrisi veya gerçek widget yerleşimi olarak yorumlanmaz. Özet, araç zinciri ve namaz ekranı görüntüsü `evidence/46142515899/` içindedir. Widget şehir/tarih ve yerel gece yarısı zaman çizelgesi eklendi; fiziksel iPhone'da güncel widget görünümü ve zamanında yenilenmesi ayrıca doğrulanmalıdır.

`cb1c34e` için [46142915530](https://github.com/Afaqi-trade/MIHEN/actions/runs/46142915530) derlemesi ve taşınabilir testleri geçti; iOS test aşaması iptal edildi. Kesintiye uğrayan xcresult tamamlanamadığından dışa aktarma da başarısızdı; bu koşu iOS test başarısı sayılmaz. Yerel iOS 27.2 simülatör testinde arayüz hiyerarşisi sorgusu zaman aşımına uğradı; bu koşu da başarılı sayılmaz.

`463a7f3` için daha geniş iOS kontrolü [46163417685](https://github.com/Afaqi-trade/MIHEN/actions/runs/46163417685) ile yeniden başlatıldı. Namaz referans kapsamı ve sınırları `PRAYER_REFERENCE_CHECK_2026-11-28.md` içindedir.

`46163417685` tamamlandı: **99 geçti, 1 başarısız**. Yedekte hedef–görev–rutin–geçmiş ilişkilerinin yeniden açılması ve haftalık kapasite/rutin/beslenme UI testi geçti. Yeni tek adımla başlangıç testi, görev formu açılırken uygulamanın kapanmasını yakaladı. Gerçek `.ips` kaydında `SwiftUI EnvironmentValues` assertion'ı görüldü; kökten açılan görev, namaz ve su pencerelerine ortak `AppStore` ortamı eklenerek düzeltildi (`33c4e94`). Bu düzeltme yerel derlemeden sonra [46165625033](https://github.com/Afaqi-trade/MIHEN/actions/runs/46165625033) hedefli uzak koşusuna gönderildi; sonuç incelenmeden bu sorun kapanmış sayılmamalıdır. `f4646e5` içindeki gün seçim kısayollarını da içeren [46163789349](https://github.com/Afaqi-trade/MIHEN/actions/runs/46163789349) ayrı geniş koşudur ve eski pencere hatasını içermektedir.

`46163789349` x86_64 / iOS 26.4.1 sonucu **99 geçti, 1 başarısız**: tek başarısızlık aynı eski başlangıç çökmesidir. Haftalık tahmini 20 dakikanın özette gösterilmesi, süre bilinmeyen adım sayısı ve rutin hafta içi/günlük seçimleri dâhil haftalık kapasite/rutin/beslenme UI testi geçti. Bu koşu `33c4e94` düzeltmesini içermez; düzeltilmiş başlangıç için kanıt sayılamaz. Sonuç JSON ve toolchain `evidence/46163789349/` içindedir.
