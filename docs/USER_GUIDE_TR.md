# MİHEN kullanım kılavuzu

İlk açılışta adını ve öncelikli alanları seç. Şablon istemiyorsan boş başlayabilir veya onboarding'i atlayabilirsin. Şablonlar gerçek geçmişin olarak eklenmez.

Plan → yaşam alanı → Hedef ekle ile miktar, birim, dönem ve tarihleri belirle. Bir hedefi birden fazla alana veya bir üst hedefe bağlayabilirsin. Görevler ve alışkanlıklar bölümünde hedefe bağlı tekrar eden bir görev oluştur. Mevcut gerçekleşmelerin bilgileri, görev şablonunu düzenlediğinde değişmez. Sayısal klavyeyi Bitti düğmesiyle kapatabilirsin.

Bugün ekranında daire tamamlar/geri alır; + ve − birer birim ekler/çıkarır. Görev başlığına dokunarak tam miktar girebilir, başka güne taşıyabilir, yeniden dağıtım önerisi isteyebilir, atlayabilir veya iptal edebilirsin. Taşıma/dağıtım onay ister. Hedef günü zaten doluysa otomatik üzerine yazılmaz. Sayfa, dakika ve kitap gibi farklı birimler birbirine eklenmez.

Plan → Manevi takip: hatim oluştur, toplam sayfayı kendi baskına göre ayarla, okunan sayfaları ekle. Mealli okuma üç yıllık hatmin içindedir; tefsir ayrı plandır. Ezber ayet aralığını ve öğrenilen miktarı düzenle; tekrar kaydı sonraki tekrar önerisini oluşturur. Zikir sayacı tarih bazlıdır. Oruç yalnızca tamamlandı seçildiğinde tutulmuş sayılır; ertelendi durumundan sonra yeni tarihi ayrı planlayabilirsin.

Takvim'de gün, hafta veya ay seç; etkinlik ekle ve ilgili günün görevlerini gör. Profil'de saat dilimi ve isteğe bağlı Hicri tarih düzeltmesi ayarlanır. Algoritmik Hicri tarihler yerel resmî takvimle farklı olabilir.

İlerleme gerçek tamamlanmış görev oranını gösterir. Kısmi kayıt ayrı saklanır. Görev bulunmayan alanlarda başarı yüzdesi üretilmez. Haftalık/aylık değerlendirmelerde kendi cevaplarını kaydedebilirsin.

Profil → JSON yedeğini dışa aktar ile düzenli yedek al. Geri yükleme mevcut verinin tamamını değiştirir; önizlemeyi okuyup onayla. Plan CSV ise hedef ve görev ekler; bir satır bile hatalıysa hiçbir satır alınmaz. Excel'den UTF-8 CSV kaydet; XLSX dosyası desteklenmez. Dışa aktarılan dosyalar şifrelenmez.

Bildirim izni yalnızca etkinleştirdiğinde istenir. Face ID/cihaz parolası kilidi isteğe bağlıdır. iCloud senkronizasyonu yoktur. Widget için yayın sahibinin App Group yapılandırmasını tamamlaması gerekir.

## Yeni planlama ve kayıt ekranları

Plan ekranının altındaki kısayollardan Haftalık planlama, Rutinler, Beslenme ve hareket ve Kaza namazı takibine ulaşılır.

Hedef detayında “Hedefi günlere böl”: başlangıç/bitiş ve haftanın günlerini seçin, günlük öneriyi inceleyin, onaylayın. Mevcut aktif bağlı görev varsa ikinci plan açılmaz. Aynı ölçü birimi korunur.

Rutinler: var olan görevleri seçip bir grup oluşturun. Günün gerçekleşmesi varsa aynı gerçek kaydı tamamlayabilirsiniz; grubun silinmesi görevleri silmez.

İlerleme → Dönem raporları: seçilen tarihin hafta, ay veya yılı; 10 yıl seçeneğinde seçilen yılın sonuna kadar son 10 takvim yılı raporlanır. Boş geçmiş üretilmez. Hedef satırları güncel durumu gösterir.

Beslenme ve hareket: tarihi, alınan/egzersizde harcanan enerjiyi veya suyu seçin. Enerji kcal, su ml birimiyle kaydedilir. Apple Sağlık ekranı izin verildiğinde seçilen günün adım ve aktif enerjisini ayrı gösterir; elle girilen kaloriye eklemez. Veri gelmemesi izin reddi ile veri yokluğunu ayırt etmeyebilir.

Kaza namazı: önce ilgili vakit için takip edilecek miktarı ekleyin, ardından kılınan miktarı kaydedin. Uygulama size kendiliğinden borç hesaplamaz. Vitir ayrı ve isteğe bağlıdır.

Profil → Kişisel hatırlatmalar: su, hareket ve değerlendirme için saat ekleyin; genel bildirim iznini Profil'den etkinleştirin. Sessiz saatler geçerlidir. İşletim sisteminin bildirim sunum tercihleri uygulamanın üstündedir.

İçe aktarmadan önce son mevcut belge cihazda bir kurtarma dosyasına alınır. Profil'deki kurtarma önizlemesiyle inceleyip geri yükleyebilirsiniz. Bu, dışa aktarılan kişisel yedeğinizin yerine geçmez. Tüm verileri silme işlemi kurtarma dosyasını da kaldırır.

## Namaz vakitleri ve widget

Plan → Manevi takip → Namaz vakitleri ekranında enlem, boylam ve saat dilimini seçin. Türkiye yaklaşık yöntemi başlangıç seçeneğidir. İkindi hesabı için Hanefî seçimi ayrıca yapılır; uluslararası hesaplama yöntemleri ayrı listelenir. Yüksek enlem kuralı ayrıca ayarlanır. İlk konum İstanbul merkezidir (41.0082, 28.9784), saat dilimi Europe/Istanbul ve yöntem Türkiye yaklaşık hesabıdır. Kendi konumunuza göre değiştirebilir veya İstanbul düğmesiyle başlangıca dönebilirsiniz.

Kaydet ile tercihler cihazda ve kullanılabiliyorsa App Group içinde tutulur. iPhone ana ekranında widget eklerken MİHEN Namaz / Prayer seçilir. Sonraki vakit gösterilir. App Group yapılandırması eksikse widget ayarı alamaz; bu durum cihaz kurulumu sırasında doğrulanmalıdır. Namaz hesabı internet kullanmaz; konum izni istemez. Koordinat değiştiğinde yeniden kaydedin. Bu ayarlar JSON yedeğinde yer almaz; başka cihaza geçerken tekrar girin.

Türkiye hesabı resmî canlı takvim değildir; yerel takvimle küçük farklar olabilir. Resmî takvimi ekran içindeki bağlantıyla karşılaştırabilirsiniz. Hesaplanamayan kutup koşullarında uygulama ikame bir vakit üretmez.
