# Uygulama süre sınırı

15 Kasım 2026 — işlev ve doğrulama sınırları.

Profil → Uygulama süre sınırı. Ekrana girmek izin istemez; “Ekran Süresi izni ver” işlemi Apple'ın bireysel yetkilendirmesini açar. İzin verilmeden seçim ve etkinleştirme kapalıdır.

1. Apple seçim ekranından uygulama, kategori veya web sitesi seçin. Seçimler opak token olarak cihazın ortak uygulama alanında tutulur. İçerik, mesaj, parola veya gezinti geçmişi okunmaz.
2. 1–720 dakika arasında **ortak günlük bütçe** belirleyin. Örneğin seçilen iki uygulama birlikte 60 dakikayı doldurunca ikisi de kısıtlanır. Bu sürüm her uygulamaya ayrı farklı bütçe sunmaz.
3. Etkinleştirildiğinde yerel takvim gününün 00:00–23:59:59 aralığı için DeviceActivity izleme kurulur. `includesPastActivity` ile sistemin o gün için erişilebilir geçmiş kullanımını da hesaba katması istenir. Ham kullanım dakikası uygulama içinde uydurulup gösterilmez.
4. Eşik bildirimi `MIHENActivityMonitor` uzantısına gelir. Uzantı MİHEN'e ait ManagedSettings mağazasında seçimi kısıtlar; uygulamanın açık kalması gerekmez.
5. Limit dolduğunda MİHEN'e dönün. 15, 30 veya 60 dakika seçip “Doğrula ve geçici aç” deyin. Onaydan sonra Face ID/Touch ID veya cihaz parolası istenir. Başarısız/iptal doğrulama kısıtı kaldırmaz.
6. Geçici süre sonu için ayrı bir DeviceActivity aralığı başarıyla kurulmadan kısıt kaldırılmaz. Günlük bütçe sıfırlanmaz. Süre sonu callback'i ve ön plana dönüş denetimi kısıtı yeniden uygular. iOS callback zamanlaması gerçek cihazda kontrol edilmelidir; kesin saniye garantisi verilmez.
7. Ayar değiştirmek için önce cihaz doğrulamasıyla sınırı kapatın. Tüm verileri silme işlemi de MİHEN'in monitor ve kısıtlarını temizler. Başka uygulamaların ManagedSettings mağazalarına dokunulmaz.

Geçici erişim için MİHEN uygulamasına dönülür; sistemin standart kısıt ekranındaki bir düğmeden biyometrik doğrulama açıldığı iddia edilmez. Bu sürüm özel Shield UI/Shield Action uzantısı kullanmaz.

## Saklama ve hata davranışı

Günlük durum, seçimin kendisi ve geçici erişim bitişi App Group içindeki `UsageLimits/state.json` dosyasında tutulur. Atomik yazma ve prosesler arası dosya kilidi uygulama/uzantı güncellemelerini sıraya koyar. Dosya koruması ilk cihaz kilidi açıldıktan sonra arka plan uzantısının çalışmasına uygundur. Cihaz yeniden başlatıldıktan sonraki ilk kilit açılmadan veri erişimi garanti edilmez.

Bozuk dosya sessizce yeni bütçeye çevrilmez. Mevcut kısıt korunur; kullanıcı cihaz doğrulamasıyla sınırı kapatıp yeniden kurabilir. Kayıt yazılamazsa geçici erişim verilmez. Önceki sürüm veya önceki geçici aralık callback'i güncel izni erken sona erdiremez. Tokenlar başka cihaz/uygulama kimliğinde geçerli olmayabileceği için JSON/CSV kullanıcı yedeğine alınmaz.

## Cihaz ve dağıtım gereksinimleri

- Ana uygulama ve `MIHENActivityMonitor` için Family Controls capability gerekir. Her iki hedef aynı App Group'u kullanır.
- Örnek kimlikler `com.example.mihen`, `com.example.mihen.monitor`, `group.com.example.mihen` yayıncı tarafından gerçek kimliklere ve provisioning profillerine bağlanmalıdır.
- TestFlight/App Store dağıtımı için Apple'ın Family Controls dağıtım yetkisi ana uygulama ve uzantı için ayrıca istenir. Bu başvuru/sözleşme kullanıcı hesabı gerektirir; bu çalışma başvuru yapmaz veya onay varmış gibi göstermez.
- Bireysel yetkilendirme cihaz sahibinin ayarlardan kaldırabileceği bir izindir. Kaldırılamaz ebeveyn kilidi vaadi yoktur. İzin iptalinde tokenlar geçersizleşir; uygulama ön plana geldiğinde kendi monitor/kısıtlarını temizler.
- Saat dilimi değişiminde iOS devam eden günün kullanımını yeni aralığa göre taşıyabilir. Seyahat ve DST kabul testleri gereklidir.

## Gerçek iPhone kabul senaryoları

1. İzni reddet: seçim/etkinleştirme kapalı; sahte etkin durum yok.
2. İzin ver, iki test uygulaması seç, 1 dakika ortak sınır kur. Kullanım sonrasında seçilen iki uygulamanın kısıt ekranı gösterdiğini kontrol et.
3. MİHEN'i kapatıp aynı denemeyi yap; uzantı kısıt uygulamalı.
4. Geçici açmada doğrulamayı iptal et: kısıt korunmalı. Doğrula: 15 dakika açılmalı.
5. MİHEN kapalıyken süreyi doldur. Cihaz kullanımında kısıt geri gelmeli; gecikme ölçülmeli.
6. Uygulamayı yeniden aç: geçici bitiş ve günlük eşik korunmalı. Yeni gün: bütçe yenilenmeli; önceki günün kısıtı kalmamalı.
7. Geçici erişim gece yarısını geçsin; yeni gün eşik dolunca erişim süresi bitene kadar açık kalmalı, sonra kısıtlanmalı.
8. İzni Ayarlar'dan kaldır; kendi kısıtları ve monitorlar temizlenmeli. Yeniden yetkilendirmede seçim yeniden yapılmalı.
9. Sınırı kapat ve tüm veriyi sil: mevcut ve eski callback'ler yeniden kısıt uygulamamalı.
10. Ana uygulama/uzantı imzalarını ve App Group provisioning'i gerçek archive içinde kontrol et.

Simülatör testleri politika mantığı, dosya işlemleri ve kurulum arayüzünü doğrular. Gerçek başka uygulamada süre tüketimi, OS kısıt ekranı, biyometri ve süre sonu teslimatı fiziksel cihaz kabulü olmadan tamamlanmış sayılmaz.

Kaynaklar:
- https://developer.apple.com/documentation/familycontrols/requesting-the-family-controls-entitlement
- https://developer.apple.com/documentation/deviceactivity/deviceactivitycenter/monitoringerror/intervaltooshort
- https://developer.apple.com/documentation/deviceactivity/deviceactivitycenter/startmonitoring(_:during:events:)
- https://developer.apple.com/documentation/deviceactivity/deviceactivitymonitor/intervaldidend(for:)
- https://developer.apple.com/forums/thread/819904
