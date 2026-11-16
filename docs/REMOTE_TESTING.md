# Uzaktan iOS derleme ve test

Yerel Mac: macOS 14.6.1; tam Xcode yok. Uzaktaki GitHub-hosted macos-26 runner, kendi Xcode SDK ve iPhone simülatörünü kullanır. Yerel Mac'in güncellenmesi veya simülatör testleri için Apple Developer üyeliği gerekmez. İmzalı gerçek cihaz/TestFlight dağıtımı ayrı aşamadır.

## Hazır akış

`.github/workflows/ios.yml` yalnızca manuel `workflow_dispatch` ile başlar. Push/PR otomatik koşusu yoktur. Depo içeriğine salt okuma izni kullanır; ödeme, yayın veya signing sırrı içermez. Aynı branch için önceki koşuyu iptal eder; 45 dakikalık zaman sınırı vardır. Test çıktıları 7 gün tutulur.

Sıra: toolchain bilgisini kaydet → `swift test` ile gerçek XCTest → proje yapısını doğrula → uygulama/widget simülatör derlemesi → SwiftData/birim/XCUITest → `.xcresult`, log ve cihaz listesini artifact olarak sakla. Depoda gerçek koşular yapıldı; son doğrulanmış sonuç TEST_REPORT.md içinde. CI dosyasının tek başına var olması başarı kanıtı değildir.

## Başlatma

1. GitHub bağlantısını tamamlayın ve ürün sahibinin seçtiği depoyu kullanın. Afaqi-trade/MIHEN, ürün sahibi tarafından 16 Kasım 2026’da Actions engelini aşmak için public yapıldı; özgün master prompt ve referans ZIP Git dışında tutulur.
2. GitHub hesabında Actions'ın etkinliğini ve dahil olan kullanım kotasını doğrulayın. Ücretsiz kullanım garantisi yoktur; kota aşımında ücretli kullanım devreye girmemelidir. Bütçe ayarını hesap sahibi kontrol eder. Ücretli kapasite satın alınmaz.
3. Kodu push edin. GitHub → Actions → iOS validation → Run workflow.
4. Başarısız aşamanın logunu okuyun, hatayı düzeltip yeni commit ile tekrar çalıştırın. Sadece workflow yeşil olunca gerçek iOS testlerinin geçtiğini raporlayın.
5. MIHEN-test-results artifact'ini indirin. XCTest attachment ekran görüntülerini Xcode Results üzerinden inceleyin. Mağaza görsellerini ancak doğrulanmış çalışan uygulamadan üretin.

Kimliği doğrulanmış CLI alternatifi:

```sh
gh workflow run ios.yml --repo OWNER/MIHEN --ref main
gh run list --repo OWNER/MIHEN --workflow ios.yml --limit 1
gh run watch RUN_ID --repo OWNER/MIHEN --exit-status
gh run download RUN_ID --repo OWNER/MIHEN --name MIHEN-test-results --dir .build-results/remote-RUN_ID
```

Kullanılan depo: https://github.com/Afaqi-trade/MIHEN . Doğrulanmış koşuların kapsamı ve sonuçları docs/TEST_REPORT.md içinde kayıtlıdır. Yerel CLI /Users/iz/.local/bin/gh altında kurulu; terminalde `export PATH="$HOME/.local/bin:$PATH"` ile erişilebilir. `OWNER` ve `RUN_ID` gerçek değerlerle değiştirilir. Token/şifreyi belgeye, chate veya Git'e koymayın. GitHub bağlantısı henüz doğrulanmamışsa uzak koşu başlatılamaz.

## Sınırlar

Simülatör: Face ID'nin donanım davranışı, kilit ekranında dosya koruması, bildirim teslimatı, gerçek App Group entitlement ve cihaz dosya sağlayıcısından geri yükleme için cihaz testlerinin yerine geçmez. Bu workflow App Store'a yükleme veya TestFlight dağıtımı yapmaz. Güncel SDK ile archive/signing ve Apple hesabı sonraki yayın kapısıdır.

Kaynaklar: [GitHub hosted runners](https://docs.github.com/en/actions/reference/runners/github-hosted-runners), [Manuel workflow çalıştırma](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/manually-run-a-workflow), [Apple SDK yükleme şartı](https://developer.apple.com/news/upcoming-requirements/?id=04282026a).

## Ekran Süresi odaklı koşu

Manuel workflow'un `suite` seçeneği varsayılan olarak `full` değerindedir. `screen-time` seçeneği tüm uygulama/uzantıları derler, tüm uygulama birim/kalıcılık testlerini ve `testScreenTimeSetupDoesNotRequestPermissionOnEntry` UI testini çalıştırır. SwiftPM çekirdek testleri her iki seçenekte de çalışır. Dar koşunun sonucu tam UI matrisi olarak sunulmaz.

```sh
/Users/iz/.local/bin/gh workflow run ios.yml --ref main -f suite=screen-time
```

Ekran Süresi gerçek uygulama kullanımı/shield ve biyometri doğrulaması için SCREEN_TIME_TR.md fiziksel cihaz kabul listesini kullanın. CI yetki verilmiş veya gerçek başka uygulamalar kısıtlanmış gibi davranan bir sahte başarı ekranı kullanmaz.

## Yeni modül ekran galerisi

`suite=module-gallery` tüm uygulama birim/kalıcılık testlerini ve dört UI testini çalıştırır: yeni modül galerisi, ezber/tekrar, zikir sayacı ve hatim/takvim akışı. Uygulama ve uzantılar gerçek simülatör için derlenir; SwiftPM çekirdek testleri ayrıca çalışır. Tam UI matrisi değildir.

```sh
/Users/iz/.local/bin/gh workflow run ios.yml --ref main -f suite=module-gallery
```

`testNewModuleScreensGallery` ayrı bellek deposunda arayüz üzerinden görev, rutin, kaza kaydı ve hedef oluşturur. Haftalık plan, kaydedilmiş rutin, 10 eklenip 2 kılınan kaza miktarında kalan 8 ve hedefin onay öncesi dağıtım önerisi native PNG olarak alınır. Sayı girişleri tam eşitlikle doğrulanır. Üretim verisi kullanılmaz.

Artifact indirildikten sonra `Scripts/build-screenshot-gallery.py` başarılı sonuç JSON'unu ve beş yeni modül attachment'ının varlığını kontrol eder; orijinal PNG byte'larını koruyarak önceki galeriyle birleştirir. Kaynak koşu, commit, test kimliği, çekim zamanı ve SHA256 her görselin provenance kaydında saklanır.

## Küçük ekran erişilebilirlik koşusu

`suite=accessibility`, mevcut iOS runtime üzerinde iPhone SE (3. nesil) simülatörü oluşturur, içerik boyutunu accessibility-extra-extra-extra-large yapar ve tüm uygulama birim/kalıcılık testleriyle ilk kullanım/Bugün açıklama audit’ini ve gerçek XS/accessibility5 metin/eylem büyüme ölçümünü çalıştırır. Boyut geçişi yalnızca DEBUG UI-test bayrağıyla gerçek SwiftUI ağacına uygulanır; ölçüm JSON’u ve native PNG’ler attachment olarak saklanır. Küçük ekranda boş Bugün ve arayüzden eklenen görev ayrıca çekilir. SwiftUI Dynamic Type heuristiğindeki kısmi destek bulguları görmezden gelinerek başarılı sayılmaz; bu heuristik tam uygunluk kanıtı olarak kullanılmaz. Runtime/cihaz profili yoksa adım başarısız olur; başka cihaz testi gibi sunulmaz. Bu kapsam tüm ekranların erişilebilirlik sertifikası değildir; VoiceOver ve fiziksel cihaz matrisi ayrıca doğrulanır. Minimum iOS 18 desteği compiler kontrolünden ayrı runtime kabulü gerektirir.

```sh
/Users/iz/.local/bin/gh workflow run ios.yml --ref main -f suite=accessibility
```
