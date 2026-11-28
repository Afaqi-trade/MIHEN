# Ar-Ge ilk aşama: iPhone kabul denemesi

Bu kontrol listesi simülatör testlerinin tamamlayıcısıdır. Kullanıcının kişisel verilerini silmez; uygulamayı kaldırmayı, ayarları sıfırlamayı veya mevcut yedeğin üzerine yazmayı gerektirmez. Denemeler ancak yeni sürüm telefona kurulduktan sonra o sürüm için geçerlidir. Her testin cihaz, iOS sürümü, uygulama derlemesi, tarih ve sonucu kaydedilmelidir.

## Başlamadan önce

Profil → veriler bölümünden JSON yedeğini kullanıcının seçtiği güvenli bir konuma dışa aktarın ve Dosyalar uygulamasında gerçekten bulunduğunu kontrol edin. Yedek hassas veri içerir ve uygulamanın dışa aktardığı dosya ayrıca şifrelenmez. Dosyanın varlığı, henüz geri yüklemenin denendiği anlamına gelmez.

## Namaz vakitleri widget'ı

1. Takvim → Namaz vakitleri ekranında kaydedilmiş şehir ve yöntemi kontrol edin. İstanbul varsayılan olarak tanımlanmıştır; gerçek cihaz konumunu otomatik belirleme iddiası yoktur.
2. Küçük ve orta widget ekleyin; altı vakti, şehir ve tarihi ayrı ayrı okuyun. Gösterilen saatler aynı ayarlarla uygulamadaki günle uyuşmalı.
3. İsteğe bağlı olarak başka bir şehir seçip **Kaydet**'e basın. Widget'ın hangi ayarı gösterdiğini ve değişimin ne zaman yansıdığını kaydedin; deneme sonunda önceki ayarı tekrar seçin ve kaydedin.
4. Gece yarısını ve bir vakit geçişini gözlemleyin; tarih, saat ve vurgunun değişimini not edin. iOS widget'ları istenen anda güncelleme garantisi vermez. Yanlış şehir ya da eski tarih görülürse vakitleri uygulamada ve yerel güvendiğiniz takvimde ayrıca kontrol edin.

## Yedek ve geri yükleme

Gerçek verileri içeren mevcut kuruluma deneme amaçlı yedek geri yüklemeyin. Ayrı bir test cihazı veya kişisel veri içermeyen güvenli test ortamında örnek görev, kısmi ilerleme, hedef ve rutin oluşturun; yedek alıp dışarı aktarın. Yedek önizlemesinde kapsamı inceleyin, iptalin hiçbir şeyi değiştirmediğini kontrol edin; yalnızca test ortamında onaylayıp ilişkilerin ve namaz ayarının korunduğunu inceleyin. Bozuk dosyaya verilen hata ve işlem iptalinde mevcut test verisinin değişmediği ayrıca doğrulanmalı.

## Ekran süresi

Yalnızca kullanıcının açıkça seçtiği ve geçici olarak erişilememesi sorun yaratmayacak bir test uygulaması kullanın. Kurulumda seçimin tek ortak günlük bütçe olduğunu doğrulayın. Sistemin yetki durumunu kontrol ettikten sonra kısa bir sınırla eşik, kısıtlama ekranı, cihaz sahibi onayıyla geçici açma ve sürenin sonunda yeniden kısıtlamayı ayrı ayrı kaydedin. İzin reddi, kapatma ve ertesi gün davranışı da test edilmeli. Koruma gecikir veya çalışmazsa, ekran süresinin güvenilir biçimde uygulandığı varsayılmamalı; önce ayarları ve Apple'ın uygulama/uzantı yetkilerini kontrol edin. Test bittiğinde kullanıcı eski ayarlarını geri seçebilir.

## İlk adım ve haftalık plan

İlk kullanımın gerçek boş kurulum akışı için ayrı test ortamı kullanın; mevcut iPhone uygulamasını sırf bu deneme için silmeyin. Bir adım oluşturup kaydedin, kısmi ilerleme ekleyin, uygulamayı kapatıp açarak kaydın korunduğunu kontrol edin. Haftalık planda süre tahmini olan bir adımın toplam süreye girdiğini; rutin günlerinde hafta içi ve her gün kısayollarının seçimi değiştirdiğini, istenmeyen tamamlanmış kayıt oluşturmadığını kontrol edin.
