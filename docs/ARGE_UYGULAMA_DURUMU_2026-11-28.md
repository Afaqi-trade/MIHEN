# 28 Kasım Ar-Ge yol haritası — uygulama durumu

Bu belge `ARGE_URUN_INCELEMESI_2026-11-28.md` içindeki önceliklerin durumunu izler. “Uygulandı” cihaz ve kullanıcı araştırması kabulünün tamamlandığı anlamına gelmez.

| Öncelik | Durum | Yapılanlar ve açık kalanlar |
|---|---|---|
| P0 · Vakit widget güveni | Kısmen uygulandı | Şehir/özel konum, tarih ve İstanbul varsayılanı; yerel gece yarısı/vakit geçişleri. Küçük ve orta widget'ın yeni düzeni ile gerçek iPhone gün değişimi ve iOS yenilemesi ayrıca test edilmeli. |
| P0 · Vakit referansları | Başlandı | İstanbul için yaz/sonbahar, İzmir için sonbahar ve önceki Ankara örneği; kaynaklar ve dakika farkları `PRAYER_REFERENCE_CHECK_2026-11-28.md` içinde. Yetkili kaynaklarla daha çok tarih/şehir, yüksek enlem ve yöntem matrisi açık. |
| P0 · Yedek güveni | Kısmen uygulandı | Dışa aktarmanın otomatik yedek olmadığı ve konumun uygulama tarafından doğrulanamadığı belirtiliyor; ilişkili kayıtları kapsayan ek kalıcılık testi eklendi. Dosyalar sağlayıcısı ve gerçek cihaz geri yükleme kabulü açık. |
| P0 · Ekran süresi | Açık | Gerçek shield, limit, geçici açma ve süre sonu; App Review ve imzalı yetkilerin güncel durumu cihaz/Apple tarafında ayrı doğrulanmalı. |
| P1 · İlk kullanım/Bugün | Kısmen uygulandı | İsteğe bağlı tek adımla başlangıç ve odakları öne alma. İlk adım ile mevcut rehberli akış uzak UI testinde geçti; bağımsız kullanılabilirlik çalışması açık. |
| P1 · Haftalık plan | Kısmen uygulandı | Odaklar süre ayrıntılarından önce; süre özeti kaydedilmiş tahminleri günlük kapasiteyle aynı şekilde kullanır. Önerilen uçtan uca sadeleştirilmiş planlama akışı ve kullanıcı araştırması açık. |
| P1 · Rutin ve hedef parçalama | Kısmen uygulandı | Gün seçiminde her gün/hafta içi/hafta sonu kısayolları eklendi. Daha geniş basit kurulum ve hedefin ilk hafta odaklı önizlemesi açık. |
| P2 · Raporlar, erişilebilirlik, beslenme, bildirimler | Açık | Ar-Ge raporundaki ölçüm tanımları, karar desteği, kapsamlı erişilebilirlik/cihaz ve giriş kolaylığı iyileştirmeleri henüz tamamlanmadı. |
| P3 · Entegrasyon ve ticari araştırma | Açık | İzin ve platform sınırları, katılımcılı test ve fiyatlandırma araştırması yapılmadı. |

Birleşik uzak doğrulama `46166901804`: 101 başarılı, 0 başarısız, 0 atlanan; kapsam ve fiziksel cihaz sınırları için `TEST_REPORT.md` okunmalıdır.
