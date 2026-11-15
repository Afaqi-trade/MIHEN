# MİHEN'i kendi iPhone'unuza TestFlight ile kurma

15 Kasım 2026. Ürün sahibi aktif Apple Developer Program üyeliği olmadığını bildirdi. Bu nedenle şu anda imzalı TestFlight yüklemesi başlatılamaz. Teknik hazırlık çalışması ve hesap sahibinin adımları aşağıdadır.

## Şimdi sizin yapacağınız işlem: Apple üyeliği

1. iPhone'da Apple'ın **Apple Developer** uygulamasını kurun: https://apps.apple.com/app/apple-developer/id640199958 . Alternatif kayıt sayfası bilgisayarda açıldı: https://developer.apple.com/programs/enroll/ .
2. Hesap / Account bölümünde kendi Apple hesabınızla giriş yapın. İki faktörlü doğrulama açık olmalı. Şifre, doğrulama kodu, kimlik belgesi ve ödeme bilgilerini yalnızca Apple'ın kendi ekranına girin; sohbete göndermeyin.
3. Kayıt / Enroll akışını başlatın. Kendi adınıza ürün çıkaracaksanız Individual; tüzel şirket adına çıkaracaksanız Organization yolunu seçin. Bireysel üyelikte satıcı adı yasal kişisel adınızdır. Kurumsal üyelikte tüzel kişilik ve D-U-N-S doğrulaması gibi ek koşullar vardır. Şirket adı veya kimlik bilgisi sizin yerinize varsayılmaz.
4. Apple'ın kimlik doğrulama, sözleşme ve ödeme adımlarını kendiniz tamamlayın. Apple'ın listelediği ücret yıllık **99 USD**; yerel tutar kayıt sırasında gösterilir. Ödeme veya hukuki kabul sizin adınıza yapılmadı.
5. Kayıt talebinin gönderilmiş olması üyeliğin etkinleştiği anlamına gelmez. Apple Developer hesabında üyelik **Active** görünmesini ve App Store Connect'e erişimi bekleyin. Onay süresi garanti edilmez.
6. Üyelik etkinleştiğinde bu sohbete yalnızca **“Üyelik aktif”** yazın. Sonraki hesap kurulumuna o noktadan devam edilebilir; şifrenize veya doğrulama kodunuza ihtiyacımız yok.

## Üyelikten sonra birlikte tamamlanacak Apple adımları

1. Apple Developer Team ID'yi ve yayıncı hesabını doğrulayın. Benzersiz kimlikleri Apple portalında kaydedin. Aşağıdakiler yalnızca öneridir; henüz kaydedilmedi:

| Kullanım | Önerilen kimlik |
|---|---|
| Ana uygulama | `com.afaqitrade.mihen` |
| Widget | `com.afaqitrade.mihen.widget` |
| Ekran Süresi monitor uzantısı | `com.afaqitrade.mihen.monitor` |
| Ortak veri alanı | `group.com.afaqitrade.mihen` |

2. Üç hedefi aynı Team ve App Group'a bağlayın. Ana uygulamada HealthKit ve Data Protection, ana uygulama + monitor'de Family Controls capability yapılandırılır. Widget için Family Controls talep edilmez.
3. **Family Controls dağıtım yetkisini hem ana uygulama hem monitor için talep edin.** Form: https://developer.apple.com/contact/request/family-controls-distribution . Başvuruya hazır ürün açıklaması `APPLE_FAMILY_CONTROLS_REQUEST.md` içindedir. Apple onayı henüz alınmadı; Ekran Süresi içeren TestFlight sürümü için bu yetki gereklidir.
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
