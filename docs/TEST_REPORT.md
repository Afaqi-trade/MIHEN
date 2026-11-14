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
