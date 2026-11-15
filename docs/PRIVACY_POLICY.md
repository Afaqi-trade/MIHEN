# Gizlilik politikası — yayın öncesi taslak

MİHEN hedefler, görevler, tercihler ve isteğe bağlı manevi, sağlık, mali ve kişisel not kayıtlarını cihazda SwiftData ile saklar. Kullanıcı hesabı, reklam, analitik SDK, geliştiriciye telemetri veya uygulama kaynaklı uzak veri toplama bulunmaz. Banka veya üçüncü taraf AI bağlantısı kurulmaz. İsteğe bağlı Apple Sağlık ekranı, kullanıcı HealthKit izni verdiğinde seçilen günün adım ve aktif enerji toplamlarını yalnızca görüntüler; Sağlık verisine yazmaz, bu toplamları MİHEN yedeğine eklemez veya geliştiriciye göndermez. Apple Takvim aktarımı kullanıcının sistem editöründe kaydettiği ayrı etkinlik kopyasıdır; mevcut takvim kayıtları okunmaz.

Bildirimler cihazda planlanır ve kullanıcı iznine bağlıdır. Biyometrik doğrulamayı iOS LocalAuthentication yapar; biyometrik veri uygulamaya verilmez. Cihaz parolası yedek doğrulama yoludur. App Group yapılandırıldıysa widget günlük özeti cihazda okur; kilit etkinse içerik gösterilmez. Dosya korumasının gerçek cihazdaki davranışı yayın öncesi test edilmelidir; özel veritabanı şifreleme algoritması vaadi yoktur.

Kullanıcının dışa aktardığı JSON/CSV dosyası kişisel kayıtları açık biçimde içerebilir; paylaşım hedefini kullanıcı seçer. İçe aktarma yalnızca seçilen dosyaya sistemin izin verdiği erişimi kullanır. iOS cihaz yedekleri ve kullanıcının iCloud ayarları işletim sistemine bağlıdır; uygulama CloudKit senkronizasyonu sunmaz.

İçe aktarma öncesinde mevcut kaydın tek yerel kurtarma dosyası oluşturulur. Profil'deki tüm verileri sil işlemi uygulama içindeki kayıtları ve bu kurtarma dosyasını kaldırır. Daha önce dışa aktarılmış dosyalar veya sistem yedekleri kullanıcının ilgili konumda ayrıca yönetmesini gerektirir.

Yayın sahibinin tamamlayacağı bilgiler: tüzel/gerçek kişi adı, destek e-postası, politika URL'si, geçerli tarih, sunulan bölgeler ve talep yönetim yöntemi. Bunlar tamamlanmadan yayımlanmaz. KVKK ve sunulan diğer bölgeler için veri akışı, amaç, saklama, kullanıcı hakları ve geliştiricinin herhangi bir veriye erişip erişmediği hukuk uzmanıyla değerlendirilmelidir. Bu taslak hukuki uyumluluk veya App Store kabul garantisi değildir.

Namaz vakitleri elle seçilen koordinat, saat dilimi ve hesaplama yöntemiyle cihazda hesaplanır. Konum izni istenmez ve koordinatlar bir ağ servisine gönderilmez. Namaz tercihleri widget paylaşımı için cihaz/App Group tercihlerinde tutulur; tüm verileri sil işleminde kaldırılır.
