# MİHEN'i kendi iPhone'unuza TestFlight ile kurma

23 Kasım 2026. Apple Developer Program üyeliği, Team ID `PY75Z73294`, üç uygulama kimliği ve `group.com.afaqitrade.mihen` App Group'u ürün sahibi tarafından oluşturuldu. App Group ataması, üç dağıtım profili ve imzalı IPA uzak archive'da doğrulandı. App Store Connect uygulama kaydı açıldı. Güncel paket **1.0.0 (2)**; App Store Connect yüklemesi ve TestFlight kurulumu henüz yapılmadı.

## Sıradaki işlem: dağıtım sertifikası ve provisioning profilleri

1. [Certificates](https://developer.apple.com/account/resources/certificates/list) sayfasında bir **Apple Distribution** sertifikası oluşturun. macOS'ta Keychain Access → Certificate Assistant → Request a Certificate From a Certificate Authority ile CSR oluşturup Apple'a yükleyin; indirilen sertifikayı Keychain'e ekleyin ve **sertifika + private key** ikilisini parola korumalı `.p12` olarak dışa aktarın.
2. [Profiles](https://developer.apple.com/account/resources/profiles/list) sayfasında **App Store Connect** türünde üç ayrı profil oluşturun: `com.afaqitrade.mihen`, `com.afaqitrade.mihen.widget` ve `com.afaqitrade.mihen.monitor`. Her birini aynı Apple Distribution sertifikasıyla ilişkilendirin ve `.mobileprovision` olarak indirin.
3. Profiller oluşturulamazsa veya ana uygulama/monitor profilinde Family Controls görünmüyorsa durun: Apple'ın Family Controls dağıtım onayı henüz profile yansımamıştır. Onay gelmeden bu özelliği çıkararak farklı bir build üretmeyeceğiz.
4. Hiçbir `.p12`, `.mobileprovision`, sertifika parolası, Apple şifresi veya API anahtarını sohbete ya da Git'e eklemeyin. Bunları yalnızca GitHub repository → Settings → Secrets and variables → Actions alanına, bir sonraki başlıktaki adlarla koyacaksınız.

## GitHub Actions sırları: imzalı IPA üretmek için

Sertifika ve üç profil hazır olduğunda kendi Mac'inizde her dosyayı Base64'e çevirip panoya alın; örneğin `base64 -i DOSYA_YOLU | pbcopy`. GitHub repository → **Settings → Secrets and variables → Actions → New repository secret** ile şu beş sır saklanır:

| Secret adı | Değer |
|---|---|
| `MIHEN_DISTRIBUTION_CERTIFICATE_BASE64` | `.p12` dosyasının Base64 içeriği |
| `MIHEN_DISTRIBUTION_CERTIFICATE_PASSWORD` | `.p12` dışa aktarma parolası |
| `MIHEN_APP_PROFILE_BASE64` | Ana uygulama `.mobileprovision` Base64 içeriği |
| `MIHEN_WIDGET_PROFILE_BASE64` | Widget `.mobileprovision` Base64 içeriği |
| `MIHEN_MONITOR_PROFILE_BASE64` | Monitor `.mobileprovision` Base64 içeriği |

Ardından Actions → **TestFlight signed archive (no upload)** workflow'unu manuel çalıştırın. Bu iş yalnızca imzalı IPA üretir, entitlement/profil eşleşmesini doğrular ve 7 gün süreli artifact olarak saklar; App Store Connect'e hiçbir şey yüklemez.

## Üyelikten sonra birlikte tamamlanacak Apple adımları

1. Apple Developer Team ID, yayıncı hesabı ve kimlikler doğrulandı:

| Kullanım | Önerilen kimlik |
|---|---|
| Ana uygulama | `com.afaqitrade.mihen` |
| Widget | `com.afaqitrade.mihen.widget` |
| Ekran Süresi monitor uzantısı | `com.afaqitrade.mihen.monitor` |
| Ortak veri alanı | `group.com.afaqitrade.mihen` |

2. Üç hedefin App Group ataması portalda tamamlandı. Ana uygulamada HealthKit ve Data Protection, ana uygulama + monitor'de Family Controls capability yapılandırılır. Widget için Family Controls talep edilmez.
3. Ana uygulama ve monitor için imzalı dağıtım profillerinde Family Controls entitlement'ı doğrulandı. Apple'ın portal durumunu ve sonraki yenilemelerde entitlement'ın korunduğunu ayrıca kontrol edin.
4. Apple Distribution sertifikası ve üç hedef için App Store Connect provisioning profilleri oluşturuldu. İmzalı IPA workflow'u yalnızca GitHub Secrets içinden geçici olarak kullanır; `.p8`, `.p12`, sertifika parolası veya token sohbete yazılmaz ve Git'e eklenmez.
5. App Store Connect'te iOS uygulama kaydı açıldı: bundle ID ana uygulamanın gerçek ID'si olmalıdır. Ad MİHEN, ana dil Türkçe, SKU örneği `MIHEN-IOS-001`dir.
6. Uzak Xcode 26+ üzerinde gerçek kimliklerle **imzalı Release archive**, imza/entitlement kontrolü ve Apple doğrulaması tamamlandı. **Yalnızca Build 2 IPA'yı** Transporter'a sürükleyip `Deliver` seçin; önceki Build 1 IPA'yı yeniden yüklemeyin. Apple'ın build işlemesini bekleyin. Bu adımlar mevcut simülatör başarısından ayrı kontrol kapılarıdır. Eski Mac'inize Xcode kurmanız bu uzak yol için şart değildir.
7. İlk denemede **Internal Testing / İç Test** grubunu kullanın. Önerilen grup: `Kişisel iPhone Testi`. Kendi App Store Connect hesabınızı test kullanıcısı olarak ekleyip işlenmiş build'i gruba atayın. Dış test kullanıcıları ve herkese açık bağlantı bu ilk kurulumun parçası değildir.
8. iPhone'da Apple'ın **TestFlight** uygulamasını kurun; kendi test davetinizi kabul edin ve MİHEN için Install/Yükle'ye dokunun. MİHEN minimum iOS 18 hedefler. Telefonda bildirim/Face ID/Sağlık/Ekran Süresi izinlerini ilgili özelliği açarken verin.

## Benim hazırladığım teknik kontrol

`.github/workflows/testflight-preparation.yml` manuel çalışır. `Scripts/prepare-testflight.sh` uzak Mac'te gerçek `generic/platform=iOS` **Release archive** üretir; `Scripts/testflight-readiness.py` üç gerçek arm64 çalıştırılabilir dosyayı, gömülü widget/monitor'ü, sürüm uyumunu ve gizlilik manifestlerini kontrol eder. Bu arşiv bilinçli olarak imzasızdır. Üyelik/kimlik/profil/sertifika olmadan kurulabilir IPA veya TestFlight daveti gibi sunulmaz. Rapor alanlarında `testFlightReady=false`, `uploadedToAppStoreConnect=false` ve `installableOnIPhone=false` açıkça korunur.

`45257992808` / `f6bf37f`: Apple Distribution ile gerçek imzalı archive ve IPA export başarıyla doğrulandı. Üç hedefin imzalı entitlement'ları App Group'u içerir; ana uygulama/monitor ayrıca Family Controls, ana uygulama/widget ayrıca Complete Data Protection içerir. IPA Apple'a yüklenmedi; üyelik sözleşmeleri, App Store Connect uygulama kaydı, TestFlight yüklemesi ve fiziksel iPhone kabulü ayrı kapılardır.

`45262542216` / `4d2b4cd`: güncel Build 2 IPA yine imzalı archive/export ile doğrulandı. Ana uygulamanın Health kullanım açıklaması ve widget'ın `MİHEN` görünen adı paketin içinden okundu. Transporter'da görülen önceki iki metadata eksikliği için bu yeni IPA kullanılmalıdır. Nisan 2027'de başlayacağı belirtilen iOS 27 SDK uyarısı, 23 Kasım 2026 itibarıyla ileri tarihli bir yükleme gereksinimidir; bu Build 2'nin güncel metadata reddi değildir.

## Telefonda ilk 15 dakikalık kontrol

- Boş başlangıçtan bir hedef/görev ekleyin, 2/6 kısmi ilerleme girin, kapatıp açın ve kalıcılığı kontrol edin.
- İstanbul namaz vakitlerini ve widget'ın uygulamayla aynı ayarı okuduğunu kontrol edin.
- JSON yedeği dışa aktarın ve deneme verisini geri yükleyin.
- Face ID/parola, yerel bildirim ve isteğe bağlı Sağlık izinlerini kontrol edin.
- Ekran Süresi için önce yalnızca deneme uygulamalarını seçin. Günlük 1 dakikalık ortak sınır → kısıt → doğrulamayı iptal et → kısıt korunsun → 15 dakika geçici aç → MİHEN kapalıyken yeniden kısıtlama. Tam liste `SCREEN_TIME_TR.md` içindedir.

## Resmî kaynaklar

- Üyelik/ücret: https://developer.apple.com/help/account/membership/program-enrollment
- Kayıt türleri/koşullar: https://developer.apple.com/programs/enroll/
- Family Controls: https://developer.apple.com/documentation/familycontrols/requesting-the-family-controls-entitlement
- App Store Connect profilleri: https://developer.apple.com/help/account/provisioning-profiles/create-an-app-store-provisioning-profile
- Build yükleme: https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/
- İç test: https://developer.apple.com/help/app-store-connect/test-a-beta-version/add-internal-testers
