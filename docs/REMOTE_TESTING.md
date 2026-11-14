# Uzaktan iOS derleme ve test

Yerel Mac: macOS 14.6.1; tam Xcode yok. Uzaktaki GitHub-hosted macos-26 runner, kendi Xcode SDK ve iPhone simülatörünü kullanır. Yerel Mac'in güncellenmesi veya simülatör testleri için Apple Developer üyeliği gerekmez. İmzalı gerçek cihaz/TestFlight dağıtımı ayrı aşamadır.

## Hazır akış

`.github/workflows/ios.yml` yalnızca manuel `workflow_dispatch` ile başlar. Push/PR otomatik koşusu yoktur. Depo içeriğine salt okuma izni kullanır; ödeme, yayın veya signing sırrı içermez. Aynı branch için önceki koşuyu iptal eder; 35 dakikalık zaman sınırı vardır. Test çıktıları 7 gün tutulur.

Sıra: toolchain bilgisini kaydet → `swift test` ile gerçek XCTest → proje yapısını doğrula → uygulama/widget simülatör derlemesi → SwiftData/birim/XCUITest → `.xcresult`, log ve cihaz listesini artifact olarak sakla. Kurulan özel depoda gerçek koşular yapıldı; son doğrulanmış sonuç TEST_REPORT.md içinde. CI dosyasının tek başına var olması başarı kanıtı değildir.

## Başlatma

1. GitHub bağlantısını tamamlayın. Var olan özel bir depo seçin veya yeni özel MIHEN deposu oluşturun. Kaynağı halka açık hale getirmeyin.
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

Kurulan özel depo: https://github.com/Afaqi-trade/MIHEN . Son doğrulanmış simülatör başarısı: run 43619860236, Xcode 26.6, 46/46 iOS test. Yerel CLI /Users/iz/.local/bin/gh altında kurulu; terminalde `export PATH="$HOME/.local/bin:$PATH"` ile erişilebilir. `OWNER` ve `RUN_ID` gerçek değerlerle değiştirilir. Token/şifreyi belgeye, chate veya Git'e koymayın. GitHub bağlantısı henüz doğrulanmamışsa uzak koşu başlatılamaz.

## Sınırlar

Simülatör: Face ID'nin donanım davranışı, kilit ekranında dosya koruması, bildirim teslimatı, gerçek App Group entitlement ve cihaz dosya sağlayıcısından geri yükleme için cihaz testlerinin yerine geçmez. Bu workflow App Store'a yükleme veya TestFlight dağıtımı yapmaz. Güncel SDK ile archive/signing ve Apple hesabı sonraki yayın kapısıdır.

Kaynaklar: [GitHub hosted runners](https://docs.github.com/en/actions/reference/runners/github-hosted-runners), [Manuel workflow çalıştırma](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/manually-run-a-workflow), [Apple SDK yükleme şartı](https://developer.apple.com/news/upcoming-requirements/?id=04282026a).
