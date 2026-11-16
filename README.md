# MİHEN

**Dengeli • Planlı • Anlamlı Yaşam** — iPhone için yerel yaşam planlama uygulaması.

SwiftUI / SwiftData / Swift Charts; minimum iOS 18, Swift 6. `MIHEN.xcodeproj` uygulama, WidgetKit ve DeviceActivity monitor uzantıları, XCTest ve XCUITest hedeflerini içerir. Harici paket veya sunucu bağımlılığı yoktur.

**Durum:** Geliştirme sürümü. Xcode 26.6 ile uygulama ve uzantılar derlendi. Son tam uzak iOS koşusu **84/84** (70 birim/kalıcılık + 14 UI), SE 3 / en büyük yazı koşusu ayrıca **71/71** geçti; hata ve atlama yok. İki koşunun uygulama kaynakları aynıdır; son değişiklik küçük ekran testinin kart sorgusudur. [Commit, kapsam ve kanıtlar](docs/TEST_REPORT.md). Fiziksel iPhone, imzalama ve TestFlight kabulü henüz tamamlanmadı.

## Çalıştırma

Ana doğrulama yolu GitHub Actions üzerindeki uzak Mac’tir; yerel macOS 14.6.1 / CLT ortamı çekirdeği çalıştırır. Tam Xcode bulunan bir Mac’te projeyi açıp MIHEN scheme ve iPhone simülatörünü seçebilirsiniz. Uygulama hesapsız ve boş başlangıçla açılır; şablonlar tek tek açık seçimle eklenir.

```sh
swift build
swift test
python3 Scripts/test-core.py
python3 Scripts/verify-project.py
Scripts/validate-ios.sh
```

`swift test` tam XCTest gerektirir. CLT ortamında `test-core.py` aynı test gövdelerini gerçek assertion'larla çalıştırır; SwiftData, SwiftUI, XCTest veya simülatör testi değildir. Son komut tam Xcode ve kurulu iPhone runtime gerektirir.

Uzaktan test: [REMOTE_TESTING.md](docs/REMOTE_TESTING.md). CI otomatik yayına veya imzalamaya bağlı değildir.

## Kaynak düzeni

- `Core/`: Codable kayıtlar, tekrar/planlama motoru, JSON/CSV doğrulama ve aktarım.
- `MIHEN/Models/`: sürümlü SwiftData şeması ve kalıcı satırlar.
- `MIHEN/Services/`: atomik repository, uygulama durumu, yerel bildirim, kilit ve widget özeti.
- `MIHEN/Features/`: onboarding, beş sekme, hedef/görev/alanlar, manevi takip, not/değerlendirme ve ayarlar.
- `MIHENWidget/`: gerçek günlük özet ve uygulamada hızlı giriş bağlantısı; ayrı namaz widget’ı.
- `MIHENTests/`, `MIHENUITests/`, `Tests/MIHENCoreTests/`: cihaz/simülatör ve taşınabilir testler.
- `Scripts/`: bağımlılıksız proje/model/metin/ikon üretimi ve doğrulama.
- `Design/MihenLogo.svg`: düzenlenebilir dağ/yol/hedef logosu. PNG'ler gerçek asset catalog içindedir.

Model üretimi: `python3 Scripts/generate_codec.py`; çeviri: `python3 Scripts/localize.py`; ikon: `swift Scripts/render-brand.swift`; proje: `python3 Scripts/generate_project.py`. Yayımlanan bir veri şemasını değiştirmeden önce migration ekleyin.

## Belge sırası

[Ürün kapsamı](docs/PRODUCT_REQUIREMENTS.md), [mimari](docs/ARCHITECTURE.md), [veri şeması](docs/DATA_SCHEMA.md), [kullanım](docs/USER_GUIDE_TR.md), [test raporu](docs/TEST_REPORT.md), [sınırlar](docs/KNOWN_LIMITATIONS.md), [yayın kontrolü](docs/RELEASE_CHECKLIST.md).

15 Kasım genişletmeleri: İstanbul varsayılanlı çevrimdışı namaz hesabı ve ayrı namaz widget, kaza kayıtları, manuel kalori/su/egzersiz, isteğe bağlı Apple Sağlık okuma, Apple Takvim tek kopya aktarımı, dönem raporları, hedef dağılımı, haftalık gündem, rutin grupları ve aktarma öncesi kurtarma yedeği. Ayrıntılı kabul sınırları KNOWN_LIMITATIONS ve INTEGRATION_PLAN_TR içinde. Adhan Swift MIT kaynakları Core/Adhan_* altında sabit sürümle bulunur; lisans/provenance Design/Licenses içinde.

Ekran Süresi: Profil → Uygulama süre sınırı. Seçili uygulama/kategori/web sitelerine ortak günlük bütçe; eşikte sistem kısıtı; Face ID/cihaz parolasıyla 15/30/60 dakika geçici erişim ve bitişte yeniden kısıtlama. Uygulama ve monitor için Family Controls + ortak App Group provisioning gerekir. Gerçek iPhone kabulü ve yayıncı yetkileri henüz tamamlanmadı. [Kullanım ve cihaz kabul adımları](docs/SCREEN_TIME_TR.md).

TestFlight başlangıcı: [Hesap sahibinin adımları](docs/TESTFLIGHT_OWNER_STEPS_TR.md). İmzasız iPhone Release archive teknik kontrolü geçti; Apple Developer üyeliği/imzalama ve TestFlight yüklemesi henüz tamamlanmadı. [Family Controls başvuru taslağı](docs/APPLE_FAMILY_CONTROLS_REQUEST.md).

16 Kasım ürün incelemesi: birim tutarlı hedef dağılımı ve aşamalar; geçmişi koruyan rutin duraklatma; kaynakları ayrı hedef/Sağlık katkıları; namaz ayarını kapsayan sürümlü yedek; kısmi emeği gösteren Bugün ve geri alma; üç aşamalı açık şablon seçimi; haftalık kararlar; kapsamı seçilen PDF/CSV raporları; yardım ve büyük yazıya uyarlanan yerleşim. [Önceliklere göre uygulama haritası](docs/PRODUCT_REVIEW_IMPLEMENTATION.md), [ilk iPhone/kullanıcı deneme protokolü](docs/USABILITY_ACCEPTANCE_TR.md). Mevcut sekiz alan, local-first yapı ve SwiftData V1 korunur.

[Güncel 35 gerçek uygulama ekranı](docs/screenshots/CURRENT.md). Taşınabilir HTML/ZIP galeri yerel `.build-results/MIHEN_Current_Screens_20261116.*` çıktılarındadır.
