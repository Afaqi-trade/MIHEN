# MİHEN çalışma kuralları

- Ürün kapsamı: docs/MASTER_PROMPT_TR.md ve docs/PRODUCT_REQUIREMENTS.md. Prototip Design/Reference altında görsel referanstır; oradaki eski pusula logosu/slogan yerine master prompttaki dağ-yol-hedef ve Dengeli • Planlı • Anlamlı Yaşam kullanılır.
- Önce README.md, docs/TEST_REPORT.md, docs/KNOWN_LIMITATIONS.md okuyun. Çalıştırılmayan test veya iOS derlemesini başarılı saymayın.
- Offline/local-first; iOS 18+, Swift 6, SwiftUI, SwiftData. Harici SDK, ağ servisi, AI API veya CloudKit'i kendiliğinizden eklemeyin.
- Sekiz ana alanın sayısını ve anlamını değiştirmeyin. Şablonlar yalnızca açık kullanıcı seçimiyle yüklenir; geçmiş veya başarı üretilmez.
- Core Apple UI bağımlılığı içermez. Tekrarlar Calendar gün hesabını kullanır; 24 saat ekleyerek tarih ilerletmeyin.
- Gerçekleşme, görev şablonundan bağımsız tarihsel snapshot'tır. Şablon değişikliği geçmişi yeniden yazamaz. Taşıma/dağıtım yalnızca kullanıcı onayıyla uygulanır.
- Model alanlarını Scripts/generate_models.py içindeki S şemasından üretin: python3 Scripts/generate_codec.py. Repository mantığını değiştirdiyseniz üretici içindeki şablonu da güncelleyin. Her şema değişikliğinde BackupCodec doğrulama ve sürümlü migration gereksinimini değerlendirin. Yayımlanmış şemayı doğrudan değiştirmeyin.
- Türkçe/İngilizce metinler Scripts/localize.py üzerinden Localizable.xcstrings'e üretilir. Sonra python3 Scripts/generate_project.py çalıştırın.
- Xcode projesi Python standart kitaplığı ile deterministik üretilir. Yeni kaynakları bu üreticiye ekleyin; harici proje üreticisi gerekmez.
- Kontroller: swift build; swift test (XCTest varsa); python3 Scripts/test-core.py (CLT fallback); python3 Scripts/verify-project.py; Scripts/validate-ios.sh (tam Xcode ve iPhone runtime gerekir).
- .build-results çalışma çıktısıdır. Doğrulanmış özetleri docs/TEST_REPORT.md içine yazın. Üretim verisini ekran görüntüsü fixture'ı olarak kullanmayın.
- Apple hesabı, sözleşme, ödeme, sertifika ve yayın işlemleri ürün sahibinindir. Kaynaklara sır koymayın, App Store'a açık izin olmadan göndermeyin.
