# MİHEN'i kendi iPhone'unuza TestFlight ile kurma

23 Kasım 2026. Apple Developer Program üyeliği, Team ID `PY75Z73294`, üç uygulama kimliği ve `group.com.afaqitrade.mihen` App Group'u ürün sahibi tarafından oluşturuldu. İmzalı archive ve TestFlight yüklemesi henüz yapılmadı; önce portal ataması ve provisioning gerekir.

## Şimdi sizin yapacağınız işlem: App Group'u hedeflere atamak

1. https://developer.apple.com/account/resources/identifiers/list adresinde **Certificates, Identifiers & Profiles → Identifiers** sayfasını açın.
2. Sırayla `com.afaqitrade.mihen`, `com.afaqitrade.mihen.widget` ve `com.afaqitrade.mihen.monitor` kimliklerini arayıp açın.
3. Her kimlikte **App Groups** capability'sini etkinleştirin. Görünen **Configure** düğmesine basın, `group.com.afaqitrade.mihen` satırını seçin, **Continue → Assign → Done → Save** sırasını tamamlayın.
4. Ana uygulama ve monitor için Family Controls capability'sinin etkin kaldığını kontrol edin; widget için Family Controls gerekmez. Ana uygulamada HealthKit ve Data Protection da korunmalıdır.
5. Apple, bir kimliğin capability'si değişince eski provisioning profillerini geçersiz kılar. Atama biter bitmez bu üç hedef için App Store dağıtım profillerini yeniden üreteceğiz; henüz sertifika veya anahtar paylaşmayın.

## Üyelikten sonra birlikte tamamlanacak Apple adımları

1. Apple Developer Team ID, yayıncı hesabı ve kimlikler doğrulandı:

| Kullanım | Önerilen kimlik |
|---|---|
| Ana uygulama | `com.afaqitrade.mihen` |
| Widget | `com.afaqitrade.mihen.widget` |
| Ekran Süresi monitor uzantısı | `com.afaqitrade.mihen.monitor` |
| Ortak veri alanı | `group.com.afaqitrade.mihen` |

2. Üç hedefin App Group atamasını portalda tamamlayın. Ana uygulamada HealthKit ve Data Protection, ana uygulama + monitor'de Family Controls capability yapılandırılır. Widget için Family Controls talep edilmez.
3. **Family Controls dağıtım yetkisi ana uygulama ve monitor için talep edildi.** Apple onayı gelene kadar Ekran Süresi içeren TestFlight sürümü dağıtılabilir sayılmaz.
4. Apple Distribution sertifikası ve üç hedef için App Store Connect provisioning profillerini oluşturun. Hesap/cert/profil işlemleri hesap sahibinin kontrolündedir. Gerekirse uzak Mac imzalama akışını kurarız; `.p8`, `.p12`, sertifika parolası veya token sohbete yazılmaz ve Git'e eklenmez. Bu çalışma henüz bir API anahtarı veya sertifika oluşturmadı.
5. App Store Connect'te yeni iOS uygulama kaydı açın. Ad: MİHEN (Apple'da uygunluğu kontrol edilir); ana dil Türkçe; bundle ID ana uygulamanın gerçek ID'si; önerilen SKU `MIHEN-IOS-001`. Apple uygulama kimliği henüz yok.
6. Uzak Xcode 26+ üzerinde gerçek kimliklerle **imzalı Release archive**, imza/entitlement kontrolü ve Apple doğrulaması yapın. Ardından App Store Connect'e yükleyin ve Apple'ın build işlemesini bekleyin. Bu adımlar mevcut simülatör başarısından ayrı kontrol kapılarıdır. Eski Mac'inize Xcode kurmanız bu uzak yol için şart değildir.
7. İlk denemede **Internal Testing / İç Test** grubunu kullanın. Önerilen grup: `Kişisel iPhone Testi`. Kendi App Store Connect hesabınızı test kullanıcısı olarak ekleyip işlenmiş build'i gruba atayın. Dış test kullanıcıları ve herkese açık bağlantı bu ilk kurulumun parçası değildir.
8. iPhone'da Apple'ın **TestFlight** uygulamasını kurun; kendi test davetinizi kabul edin ve MİHEN için Install/Yükle'ye dokunun. MİHEN minimum iOS 18 hedefler. Telefonda bildirim/Face ID/Sağlık/Ekran Süresi izinlerini ilgili özelliği açarken verin.

## Benim hazırladığım teknik kontrol

`.github/workflows/testflight-preparation.yml` manuel çalışır. `Scripts/prepare-testflight.sh` uzak Mac'te gerçek `generic/platform=iOS` **Release archive** üretir; `Scripts/testflight-readiness.py` üç gerçek arm64 çalıştırılabilir dosyayı, gömülü widget/monitor'ü, sürüm uyumunu ve gizlilik manifestlerini kontrol eder. Bu arşiv bilinçli olarak imzasızdır. Üyelik/kimlik/profil/sertifika olmadan kurulabilir IPA veya TestFlight daveti gibi sunulmaz. Rapor alanlarında `testFlightReady=false`, `uploadedToAppStoreConnect=false` ve `installableOnIPhone=false` açıkça korunur.

İmzalı arşiv ve yükleme akışı hesap/sertifika bilgileri doğrulanınca tamamlanır. Üyelik satın alınması, Apple sözleşmelerinin kabulü, yetki onayı veya TestFlight yüklemesi şu an gerçekleşmiş değildir.

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
