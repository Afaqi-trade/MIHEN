# İlk iPhone denemesi ve kullanılabilirlik kabulü

Bu belge deneme protokolüdür; tamamlanmış araştırma veya satın alma isteği kanıtı değildir. Teknik test sonuçları TEST_REPORT.md içindedir. İlk denemede gerçek kişisel geçmiş yerine ayrı deneme verisi kullan; yedek/geri yükleme adımında önce korunacak verinin cihaz dışında kopyasını tut.

## 20 dakikalık ilk oturum

Katılımcıya aşağıdaki amacı söyle, düğmenin yerini tarif etme. Her adımda bağımsız tamamlandı mı, yardım gerekti mi, geçen süre ve katılımcının kendi ifadesini kaydet. Hata, kişinin başarısızlığı olarak değerlendirilmez.

| Amaç | Gözlenecek davranış | Kabul işareti |
|---|---|---|
| Bugün kısa bir yürüyüş planla | İlk kullanımda alan ve şablon seçimini anlama; hızlı görev oluşturma | İstemediği şablon eklenmez; yeni görev tamamlanmamış görünür |
| Altı birimlik işin ikisini kaydet, sonra düzelt | 2/6 kısmi kaydı ve Geri al eylemini bulma | Üst özeti “hiç emek yok” diye yorumlamaz; geri alma doğru miktarı döndürür |
| Bir hedefi uygun günlere dağıt | Toplam, birim, aylık/haftalık önizleme ve kayıt onayını anlama | Günlük miktarın hedef toplamıyla ilişkisini kendi sözleriyle anlatır; önizleme başarı sanılmaz |
| Sabah rutini ve haftalık odak oluştur | Rutin içine yeni adım ekleme, sıralama ve hafta notu | Aynı görevin rutinde ikinci kez tamamlanmadığını anlar; süresiz iş dakika gibi sayılmaz |
| Son dönemi incele ve paylaş | Kayıt kapsamı, farklı birimler, alan ve not seçimi | Boş günleri otomatik başarısızlık sanmaz; paylaşılacak alanı bilinçli seçer |
| Yedek oluştur ve geri yükle | Dosyayı bulma, kapsamı açıklama, önizleme ve onay | Dosya gerçekten harici konumda bulunur; deneme verisi doğru geri gelir; izinlerin yeniden kurulacağını bilir |

Oturum sonunda: “En çok nerede tereddüt ettin?”, “Hangi bilgiyi nerede bekliyordun?”, “Yarın hangi iş için açardın?” diye sor. Yanıtı yönlendiren memnuniyet veya satın alma sorularıyla başlama. Fotoğraf, ses veya ekran kaydı için ayrıca açık katılımcı izni al; kişisel içerikleri depoya ekleme.

## İki haftalık devam denemesi

İlk küçük tur için farklı deneyimlerden 5–8 gönüllüyle dene. Açılış günü ve 7/14. gün kısa görüşmeler yap. Uygulama içi izleme SDK'sı ekleme; paylaşmayı seçtikleri günlük notlar ve görev sonuçlarıyla ilerle. Hangi gün hangi somut amaç için kullandıklarını, terk edilen akışları ve güvensizlik yaratan hesap/ifade hatalarını kaydet. Kullanılmayan günün nedenini varsayma.

Satın alma etkisini kullanım değerinden sonra değerlendir: hangi mevcut yöntemin yerini aldı, ne kadar zaman kazandırdı, hangi eksik tekrar kullanmayı engelledi? Ücretli ürün seçeneği araştırılacaksa aynı kapsamı tüm katılımcılara açıkla ve beyan edilen ödeme isteğini gerçek satın alma olarak raporlama. Henüz fiyat veya dönüşüm oranı doğrulanmış değildir.

## Teknik cihaz kabulü

TESTFLIGHT_OWNER_STEPS_TR.md ve SCREEN_TIME_TR.md adımlarını kullan. Files dosya sağlayıcısı, gerçek Face ID/cihaz parolası, açık formdayken uygulama değiştirici, bildirim teslimatı, widget App Group, Apple Sağlık ve Takvim fiziksel iPhone'da ayrıca doğrulanır. Ekran Süresi için gerçek süre tüketimi → shield → doğrulanmış geçici erişim → süre sonunda yeniden shield zincirini gözle. Bu denemeler simülatör screenshot'larıyla kapatılmaz.

VoiceOver okuma sırası ve etiketleri, Voice Control ile eylem seçimi, Reduce Motion, en büyük yazı, Türkçe/İngilizce, açık/koyu tema ve minimum iOS 18 ayrıca denenir. Otomatik erişilebilirlik audit'i yalnızca test edilen ekran ve audit türleri için kanıttır.

## Bulgu kaydı

Her bulguda ekran/sürüm, amaç, beklenen davranış, görülen davranış, tekrar adımı ve etkisini yaz. Önce veri kaybı/yanlış hesap/gizlilik, sonra temel görevi bitirememe, sonra kafa karışıklığı ve görsel ayrıntıları düzelt. Başarı yüzdesini yalnızca gerçekten gözlenen oturum sayısıyla birlikte bildir; küçük örneklemi genel pazar sonucu olarak sunma.
