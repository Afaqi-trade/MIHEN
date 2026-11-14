# MİHEN

**Dengeli • Planlı • Anlamlı Yaşam** — iPhone için yerel yaşam planlama uygulaması.

SwiftUI / SwiftData / Swift Charts; minimum iOS 18, Swift 6. `MIHEN.xcodeproj` uygulama, WidgetKit uzantısı, XCTest ve XCUITest hedeflerini içerir. Harici paket veya sunucu bağımlılığı yoktur.

**Durum:** Geliştirme sürümü. Swift çekirdeği yerelde derlendi ve 33 senaryo / 82 assertion geçti. iOS derleme ve simülatör sonuçları `docs/TEST_REPORT.md` içinde ayrı raporlanır. Tamamlanmış, cihazda doğrulanmış veya App Store'a hazır ürün iddiası yoktur.

## Çalıştırma

Tam Xcode ile projeyi açın, MIHEN scheme ve bir iPhone simülatörü seçin. Yerel macOS 14.6.1 için Xcode 16.2 uyumludur. App Store'a güncel yükleme için Xcode 26+ ve uygun macOS gerekir. Uygulama hesapsız ve boş başlangıçla açılır. Şablonlar isteğe bağlıdır.

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
- `MIHENWidget/`: gerçek günlük özet okuyan salt okunur widget.
- `MIHENTests/`, `MIHENUITests/`, `Tests/MIHENCoreTests/`: cihaz/simülatör ve taşınabilir testler.
- `Scripts/`: bağımlılıksız proje/model/metin/ikon üretimi ve doğrulama.
- `Design/MihenLogo.svg`: düzenlenebilir dağ/yol/hedef logosu. PNG'ler gerçek asset catalog içindedir.

Model üretimi: `python3 Scripts/generate_codec.py`; çeviri: `python3 Scripts/localize.py`; ikon: `swift Scripts/render-brand.swift`; proje: `python3 Scripts/generate_project.py`. Yayımlanan bir veri şemasını değiştirmeden önce migration ekleyin.

## Belge sırası

[Ürün kapsamı](docs/PRODUCT_REQUIREMENTS.md), [mimari](docs/ARCHITECTURE.md), [veri şeması](docs/DATA_SCHEMA.md), [kullanım](docs/USER_GUIDE_TR.md), [test raporu](docs/TEST_REPORT.md), [sınırlar](docs/KNOWN_LIMITATIONS.md), [yayın kontrolü](docs/RELEASE_CHECKLIST.md).
