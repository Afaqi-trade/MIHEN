# iPhone entegrasyon planı ve kabul ölçütleri

15 Kasım 2026. Çalışan kodla dış yetkiye bağlı adımların ayrımı.

| Entegrasyon | Mevcut kaynak | Sonraki doğrulama |
|---|---|---|
| Apple Takvim | Sistem editöründe tek etkinlik kopyası | Gerçek cihazda kaydet/iptal; tekrar ve çift yönlü senkronizasyon ayrı kapsam |
| Apple Sağlık | İsteğe bağlı adım/aktif enerji toplamı okuma | HealthKit capability provisioning, izin reddi/veri yokluğu, gün/saat dilimi ve gerçek kayıt testi |
| Namaz vakitleri | Çevrimdışı Adhan/Türkiye yaklaşık hesabı + ayrı namaz widget | Gerçek App Group, şehir referansları ve widget yenileme |
| Ekran Süresi | Kodlanan günlük sınır ve doğrulamalı geçici erişim | Family Controls, DeviceActivity ve ManagedSettings uzantıları, cihaz yetkisi, dağıtım entitlement onayı |

Ekran Süresi uygulama tasarımı:

1. Kullanıcı yalnızca bu özelliği açınca `.individual` yetkisi istenir.
2. Sistem FamilyActivityPicker ile uygulamaları seçer. Seçimler opak token olarak cihaz/App Group'ta kalır; sosyal medya içeriği, mesaj veya şifre okunmaz.
3. Kullanıcı günlük dakika sınırı, günler ve geçici erişim süresini seçer. DeviceActivity günlük takvimi seçilen saat dilimine göre başlatılır.
4. DeviceActivityMonitor uzantısı sınır aşılınca yalnızca seçili uygulamalara ManagedSettings shield uygular.
5. Geçici erişim için uygulama içindeki yerel doğrulama sonrasında belirlenen süre açılır, ardından tekrar sınır uygulanır. Kullanıcı bireysel yetkiyi sistemden kaldırabilir; kaldırılamaz ebeveyn kilidi vaadi verilmez.
6. Özelliği kapatma, seçim değiştirme ve tüm veri silme işlemleri monitor ve shield'ı temizler. Gün değişimi, DST, uygulamayı kapatma, yeniden başlatma, yetki iptali test edilir.
7. Apple Developer yetkisi ve uygulama/uzantı dağıtım izinleri tamamlanmadan TestFlight'ta çalıştığı iddia edilmez.

Sosyal medya içeriğine genel okuma erişimi yoktur. İçerik gerektiren gelecekteki entegrasyonlar her platformun resmî kapsamı ve kullanıcının ayrı izniyle değerlendirilir. İlk hedef süre yönetimidir.

Kaynaklar:
- https://developer.apple.com/documentation/familycontrols/requesting-the-family-controls-entitlement
- https://developer.apple.com/documentation/healthkit/authorizing-access-to-health-data
- https://developer.apple.com/documentation/eventkit/accessing-calendar-using-eventkit-and-eventkitui

15 Kasım Ekran Süresi geliştirmesi: `MIHENActivityMonitor` hedefi, FamilyActivityPicker, ortak günlük bütçe, ManagedSettings kısıtı ve cihaz doğrulamalı 15/30/60 dakika geçici erişim kodlandı. Güncel davranış, test kapsamı ve cihaz kabul listesi SCREEN_TIME_TR.md içindedir. Bu liste fiziksel cihaz başarısı veya dağıtım entitlement onayı anlamına gelmez.
