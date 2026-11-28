# MİHEN — Eleştirel ürün ve Ar-Ge raporu

**Tarih:** 28 Kasım 2026  
**İncelenen kaynak:** `c27250d` yerel çalışma ağacı, SwiftUI ekranları, planlama/veri modeli ve depodaki ekran görüntüleri.  
**Amaç:** Plan ve rutin oluşturmayı, günlük takibi, güveni, tasarımı ve ticari değeri iyileştirmek için uygulanabilir, sınanabilir kararlar üretmek.

## 1. Yönetici değerlendirmesi

MİHEN'in değerli tarafı, günlük planlama ile kişisel ve manevi takibi kullanıcının denetiminde bir araya getirmesi. Uygulamada hâlihazırda hızlı görev ekleme, haftalık odak, kapasite, hedefi parçalara ayırma, rutin adımları, dönem raporları, namaz vakitleri ve widget, içe/dışa aktarma gibi ciddi bir altyapı var. Kullanıcının son iPhone geri bildiriminde uygulama açılmış; takvimden vakitlere erişim, yeni ikon ve widget'ta altı vaktin okunması doğrulanmış. Bu bildirim bütün akışların, erişilebilirliğin ve cihaz koşullarının sistematik olarak doğrulandığını göstermiyor.

**Temel eleştirim:** Ürün özellik bakımından geniş; fakat kullanıcı açısından ana değer döngüsü daha net olabilir: **bir niyet seç → bugüne uygun küçük adım belirle → kolayca kaydet → haftalık olarak uyarlayıp devam et.** Ekranlarda seçeneklerin ve açıklamaların fazlalığı, bu döngünün algılanmasını zorlaştırabilir. Bu bir ürün hipotezidir; terk oranı veya görev tamamlama süresi ölçülmediği için doğrulanmış kullanım sorunu gibi sunulmamalıdır.

**En önemli güven riski:** Namaz widget'ı ayar bulunmadığında İstanbul'u kullanıyor; widget görünümünde şehir veya tarih açıkça yazılmıyor. Yolculukta veya ayarlar anlaşılmadığında kullanıcı farklı şehir için hesaplanan vakti kendi konumu sanabilir. İstanbul varsayılanı ürün tercihi olarak korunmalı, ancak açıkça gösterilmelidir. Vakitlerin hesap yöntemiyle güvenilir referans arasındaki farkı bu incelemede ölçmedim; doğruluk iddiası yerine kontrollü karşılaştırma gerekir. `MIHENWidget/MIHENWidget.swift:74`, `MIHEN/Features/PrayerTimesScreen.swift:17`.

**Ticari değerlendirme:** Ürünün satın alınabilirliği konusunda gelir, dönüşüm veya bağımsız kullanıcı araştırması bulunmadığından kesin hüküm verilemez. Para ödemeye değer olma hipotezi, modül sayısından çok ilk haftada kolay plan yapma, güvenilir takip ve kaybolmayan veri deneyimiyle sınanmalıdır. Sağlam çekirdek ve sahici bir haftalık fayda ortaya konmadan yeni geniş modüller eklemek, odağı zayıflatabilir.

## 2. Yöntem ve kanıt sınırları

- Kaynak kodda mevcut davranış ile ürün önerisi ayrıştırıldı; mevcut özellikler eksikmiş gibi sayılmadı.
- Gerçek uygulamadan alınmış depo görsellerinden [haftalık plan](evidence/43927332097/MIHEN-WeeklyPlan-TR.png), [rapor](evidence/44304066244/MIHEN-Executive-Report-TR.png) ve [namaz ekranı](evidence/46140160439/MIHEN-Prayer-Calendar-TR.png) görsel olarak incelendi. Bunlar farklı tarihlerde üretilmiş kanıtlardır; sonraki arayüz değişikliklerini temsil etmeyebilir. Güncel davranış için kod esas alındı.
- Kullanıcının iPhone'daki olumlu geri bildirimi değerlendirmeye alındı. Bu çalışma sırasında yeni cihaz testi, bağımsız kullanıcı görüşmesi veya sayısal kullanım ölçümü yapılmadı.
- Bulgular **gözlem** (kod veya görselde görülen), **çıkarım** (muhtemel etki) ve **hipotez** (kullanıcı testi gerektirir) olarak okunmalıdır. Öneriler gerçekleşmiş geliştirme değildir.
- Araştırma bağlantıları 28 Kasım 2026 itibarıyla incelendi. Bilimsel kanıtların çoğu sağlık davranışları ve farklı örneklemlere ilişkindir; MİHEN kullanıcılarında aynı sonuçları garanti etmez.

## 3. Ürün mimarisi ve konumlandırma

Bugün, Plan, Takvim, İlerleme ve Profil üst düzey gezinmesi anlaşılabilir bir başlangıç sunuyor. Ancak kullanıcının zihninde şu kavramların sınırları belirsiz kalabilir: hedef, görev/adım, tekrar eden görev, rutin, rutin oturumu ve haftalık odak. Bunlar ayrı ayrı güçlü olsa da aynı işin birden fazla yerde görünüyor olması çift kayıt veya farklı sayaç endişesi yaratabilir.

**Önerilen kavram modeli:**

| Kavram | Kullanıcıya anlatımı | Örnek |
|---|---|---|
| Hedef | Zaman içinde ulaşmak istediğin sonuç | 12 kitap okumak |
| Adım | Belirli bir günde yapabileceğin eylem | 10 sayfa okumak |
| Rutin | Birlikte yürüttüğün adımlar | Akşam rutini |
| Haftalık odak | Bu hafta özellikle önem verdiğin en fazla üç seçim | Okumaya geri dönmek |
| Kayıt | Gerçekleşen ilerleme | Bugün 6 sayfa |

Bu sözlüğü uzun bir yardım ekranına hapsetmek yerine yalnızca ilgili ekranda kısa, örnekli açıklamalarla ve gerektiğinde daha fazla bilgi bağlantısıyla kullanın. Kullanıcıya tüm modülleri ilk anda anlatmaya çalışmayın. Önerilen konumlandırma: **“Gününü sade planla; senin için önemli alanlarda istikrarlı, esnek adımlar at.”** Manevi yön görünür ve kullanıcı tercihine bağlı kalabilir; diğer yaşam alanlarının kullanımını zorunlu bir kimlik seçimine dönüştürmemek değerlendirilmeli.

## 4. İlk kullanım ve Bugün

### 4.1 İlk kullanım

**Gözlem:** Karşılama, isim ve mahremiyet bilgisi; yaşam alanları; seçilebilir başlangıç şablonları ve haftalık önizleme mevcut. Atla seçeneği de bulunuyor; kodda bu yol tüm alanları etkinleştiriyor ve şablon seçmiyor. `MIHEN/Features/RootView.swift:80`.

**Eleştiri:** Sekiz alanı ve ardından şablonları değerlendirmek, daha gerçek bir fayda görülmeden kullanıcıdan karar isteyebilir. “Atla” sonucunda tüm alanların etkinleşmesi, daha sonra gösterilecek içerik ve karmaşıklık açısından kullanıcı beklentisiyle karşılaştırılmalı. İsim, alan ve şablon seçiminin etkisi açık olmalı.

**Öneri:** Üç giriş yolu prototiplenmeli: “Bugün bir adım ekle”, “Hazır bir rutinle başla” ve “Önce uygulamayı incele”. İsim ve ayrıntılı alan ayarları ertelenebilir. İlk deneyimde tek küçük adımın başlığı, günü ve isteğe bağlı hatırlatıcı yeterli; hedef, alan ve detaylar sonra düzenlenebilmeli. Hiçbir örnek otomatik olarak gerçekleşmiş gibi işaretlenmemeli.

**Kabul senaryosu:** İlk kez gören kullanıcı yardım almadan bir adım oluşturur, Bugün'de bulur, kısmi veya tam ilerleme kaydeder ve yanlış işlemi geri almanın yolunu açıklar. Ölçülecek değer: tamamlayan/girişen sayısı, süre medyanı ve tamamlayamayanların nedeni. Henüz hedef değer atamayın; mevcut durumu ölçtükten sonra belirleyin.

### 4.2 Bugün ve günlük işlem

**Gözlem:** Bugün özet, bekleyen kayıtlar, tamamlananlar, kullanıcının belirlediği odaklar, not, ekleme ve ilerleme kontrolleri içeriyor. Görev satırında değer/hedef, durum ve hedef birden büyükse artı/eksi düğmeleri var. Günlük odak zaten mevcut; sıfırdan yapılacak özellik değil. `MIHEN/Features/TodayView.swift:3`, `:140`.

**Eleştiri:** Kullanıcı çok sayıda madde planladığında özet, farklı kontroller ve uzun liste bir araya gelerek “Şimdi ne yapacağım?” sorusunu zorlaştırabilir. Sayısal görevde artı/eksi iyi bir hızlı yol olsa da her bir artışın neyi değiştirdiği ve yanlışlıkla tamamlama sonrası geri alma görünürlüğü araştırılmalı. Erişilebilirlik boyutlarında özet kartının gizlenmesi bilginin diğer yollarla erişimini ayrıca doğrulamayı gerektirir.

**Öneri:** Birincil alan olarak kullanıcının kendi seçtiği “Şimdi başlayabileceğim adım”ı ve varsa diğer odakları sunun; tüm planı erişilebilir bir bölüm olarak koruyun. Aşırı dolu günde “Birini seç”, “Bugünü hafiflet” ve ertelenenleri açıkça yeniden planla seçenekleri verin. Tamamlama, kısmi ilerleme, atlama ve erteleme farklı anlamlarını korusun; sessiz veri değişikliği yapılmasın. Ekranda görülen geri alma kapsamı ve süresi dürüstçe belirtilsin.

**Motivasyon dili örnekleri:** “Bugün küçük bir adım yeterli olabilir”; “Bu plan yoğun görünüyor, birlikte sadeleştirelim mi?”; “6 / 10 sayfa kaydettin.” “Başarısız oldun”, “serini kaybettin” ve suçluluk yaratan kırmızı uyarılar varsayılan olmasın.

## 5. Plan, hedef ve rutinler

### 5.1 Haftalık plan

**Gözlem:** Haftalar arasında gezinme, tarih, bilinen süreler, süresi belirtilmeyen adımlar, haftalık odak, kapasite, gün listeleri ve geçmiş işler mevcut. `MIHEN/Features/RoutinesScreen.swift:146`. İncelenen tarihli ekran görüntüsünde sayfanın üstü tarih ve süre bilgilerine ayrılmış; kullanıcı eylemi aşağıda kalıyor. Görselin eski olması nedeniyle güncel düzen cihazda tekrar doğrulanmalı.

**Eleştiri:** Haftalık planın ilk sorusu “0 dakika biliniyor mu?” değil, “Bu hafta neye yer var?” olmalı. Süre belirtilmemiş işlerin ayrıca sayılması doğru; ancak bu rakam kapasitenin tam bilindiği izlenimini vermemeli. Dolu haftada gecikmiş işlerin topluca sunulması baskı yaratabilir.

**Önerilen kısa akış:** (1) En önemli 1–3 odağı seç veya atla; (2) uygun günleri gör; (3) mevcut işler için kapasiteye göre taşı/azalt/olduğu gibi bırak; (4) haftayı önizle ve onayla. Daha ayrıntılı zaman, bilinmeyen süre ve geçmiş iş bilgilerini erişilebilir ikinci katmanda tutun. Hiçbir işlemi kullanıcı görmeden geçmiş kayıtları değiştirecek şekilde uygulamayın. Kapasiteye sığmayan veya süresi bilinmeyen işlerin neden hesaplanamadığını gösterin.

### 5.2 Hedef parçalama

**Gözlem:** Tarih ve gün seçimi, kapasiteye göre dağıtım, ilk 90 gün, aylık/haftalık aşamalar, tahmini dağılım önizlemesi ve uygulama onayı var. Görünüm başlangıç tarihinden itibaren en fazla yaklaşık bir yıllık ilk dağıtımı hazırlıyor. `MIHEN/Features/GoalPlanningScreen.swift:16`.

**Eleştiri:** Kapasite, birim başına dakika, ara hedef, destekleyici görev ve dağıtım önizlemesi aynı sayfada sunulduğunda basit bir hedef için teknik görünebilir. Uzun vadeli hedefte oluşturulan dönem ile hedefin tüm süresi karıştırılabilir.

**Öneri:** Basit modda üç soru: “Ne istiyorsun?”, “Ne zamana kadar?”, “Bu hafta ne kadar ayırabilirsin?”; ardından “Önerilen ilk hafta” ve toplam plan kapsamı gösterilsin. Ayrıntılı mod mevcut kapasite ve aşama seçeneklerini korusun. Örnek: 120 sayfa/4 hafta önerisi, kullanıcının günlerine ve kapasitesine göre oluşturulur; kesin sonuç vaadi verilmez. Geçmiş gerçekleşmeler, gelecekteki plan ve yeniden hesaplamanın değiştireceği kayıtlar ayrı gösterilmeli; önizleme ve onay korunmalı. Hedef birimi ile destekleyici adım birimi uyumsuzsa otomatik toplama yapılmamalı.

### 5.3 Rutin oluşturucu ve yürütme

**Gözlem:** Rutin adı/alanı, günler, var olan veya yeni görev adımları, sıralama, hatırlatıcı, duraklatma ve rutin başlatma bulunuyor. Gün seçimi ile adımın kendi tekrar takvimi aynı şey değil. `MIHEN/Features/RoutinesScreen.swift:65`.

**Eleştiri:** Tek ekranda yedi gün anahtarı, mevcut tüm görevlerin listesi ve adım ayrıntıları, ilk rutini kurmayı yorucu hâle getirebilir. Bir görevin birden fazla rutinde görünmesi veya rutin günü ile adım günü farklıysa ne olacağı yeterince kolay anlaşılmayabilir. Bu, veri hatası olduğu iddiası değil; anlaşılabilirlik ve beklenti uyuşmazlığı riskidir.

**Öneri:** “Sabah”, “Akşam”, “Kendi rutinim” başlangıcı; ardından bir veya iki adım, günler ve isteğe bağlı saat. “Daha sonra ekle” desteklensin. Rutin ekranında “Bugün 3 adımdan 1'i kaydedildi” gibi gerçekten var olan veriye dayalı durum ve tek “Başla” eylemi sunulsun. Adım, mevcut görev olarak başka yerde de kullanılıyorsa düzenlemenin etkisi görünür olsun. Başlamış oturumda ara ver/devam et/bitir, tamamlanmamış adımları tamamlanmış saymadan çalışsın. Yoğun gün için kısa sürüm kullanıcı seçimiyle oluşturulabilir.

## 6. Raporlama: özetten karar desteğine

**Gözlem:** Hafta, ay, yıl ve 10 yıl seçimi; tarih çıpası; dönem kartı; tamamlanmış/kısmi kayıtlar; kayıt bulunan gün/alan; eğilimler, alan ayrıntıları, sonraki eylemler, hesaplama açıklaması ve dışa aktarma zaten mevcut. `MIHEN/Features/ReportsScreen.swift:4`. İncelenen ekran örneğinde büyük bir üst kart, ilk görünümün çoğunu kaplıyor.

**Eleştiri:** “Yönetici özeti” görünümü var; fakat ilk ekranda çok sayıda sayı kullanıcının hangi kararı alacağını kendiliğinden açıklamaz. “2 / 8 alan” bilgisi tüm alanlarda kayıt yapmayı hedef gibi algılatabilir; gerçekten seçilen alanlarla ilişkisi ve anlamı açıklanmalı. Boş gün, kaydedilmemiş gün ve başarısız gün eşit değildir. On yıllık görünümde yeni kullanıcıya sahte karşılaştırma veya çok küçük veriden kesin eğilim sunulmamalı.

**Önerilen dört katman:**

1. **Anlamlı özet:** Seçili dönem, veri kapsamı, tamamlanan ve kısmi adımlar; sade ve kısa.
2. **Değişim ve bağlam:** Ancak karşılaştırılabilir önceki dönem varsa değişim; yoksa “Karşılaştırma için yeterli kayıt yok.” Pay/payda, takvim ve filtre görünür.
3. **Yaşam alanı ayrıntısı:** Etkin alanlar ve isteğe bağlı diğerleri; tek bir toplam “hayat başarısı puanı” olmadan. İbadet, kalori ve görevler anlamsızca aynı yüzdeye dönüştürülmesin.
4. **Bir sonraki karar:** Veri destekliyse kullanıcının seçebileceği, açıklanabilir öneriler: “Süresi bilinmeyen 3 adımı gözden geçir” veya “Bu hafta bir odağı yeniden planla.” Hiçbir öneri otomatik plan değişikliği yapmasın.

Bir metrik kataloğu oluşturun: tanım, pay/payda, tarih aralığı, kaynak, kayıt eksikliği, zaman dilimi ve hesap değişimlerinin geçmiş rapora etkisi. Örnek: “Tamamlanma = tamamlandı durumundaki uygun görev oluşumları / aynı dönemde planlanan uygun oluşumlar”; taşınmış/iptal/atlananların dahil edilme kuralı gerçek motorla doğrulanmadan üründe kesin formül olarak yayımlanmamalı. Bu ifadeyi uygulama formülünün mevcut tanımı olarak değil, netleştirilmesi gereken örnek olarak okuyun.

## 7. Maneviyat, namaz ve kaza takibi

**Namaz vakitleri:** Takvimden doğrudan erişim olumlu; ayrı vakit ekranında şehir, tarih, hesap ayarları ve kaynak açıklaması bulunuyor. Widget küçük ve orta boyda altı vakti gösteriyor. Kullanıcı altı vaktin okunabildiğini bildirdi; bu tek cihaz ve koşuldaki nitel geri bildirimdir.

**P0 önerisi:** Widget'a en azından şehir/manuel konum ve gün bilgisini sığdıran bir düzen, ilk açılışta “Varsayılan: İstanbul” açıklaması ve uygulamaya konum ayarına kolay erişim ekleyin. Konum/method değişince widget'ın yeni veriyi ne zaman göstereceğini test edin; yüksek enlemde hesap yoksa saati uydurmak yerine bilgi verin. Tarih değişimi, saat dilimi, yaz saati, seyahat, gecikmiş widget yenilemesi ve yatsı sonrası sonraki gün senaryolarını test edin. Apple, widget güncellemelerinin sürekli veya dakika dakika garanti olmadığını belirtiyor; uygun zaman çizelgesi hazırlansa da sistem davranışı cihazda doğrulanmalı. [Apple widget rehberi](https://developer.apple.com/design/human-interface-guidelines/widgets).

**Vakit doğrulama Ar-Ge'si:** Türkiye yöntemi için seçilen gün ve şehirlerde, ayrıca yüksek enlemler ve farklı ikindi yöntemleri için açıkça tanımlanmış referanslarla dakika farklarını kaydedin. Kaynak, şehir koordinatı, tarih, yöntem ve toleransı önceden belirleyin; İstanbul, Ankara ve diğer şehirleri mevsimlere yayın. Yerel hesaplamayı resmî veriymiş gibi etiketlemeyin; bir uyum iddiası ancak bu karşılaştırma sonrası yapılabilir.

**Kaza takibi:** Her vakit için başlangıç miktarı, tahmin/kesin ayrımı, kullanıcı kaydı, geri alma ve kalan hesabı açık olmalı. Kişisel dini yorumlarda tek doğruyu dayatan dil kullanılmamalı. Kayıp/yanlış girişe karşı başlangıç değerinin ne zaman ve nasıl düzeltildiği görülebilmeli; ibadet kayıtları widget, dışa aktarma ve paylaşımda varsayılan mahremiyetle korunmalı.

## 8. Sağlık, beslenme, ekran süresi ve entegrasyonlar

### Sağlık ve beslenme

Manuel günlük öğün, kalori ve aktivite kaydının yükü değerlendirilmelidir: sık kullanılan girdiler, yakın geçmişten tekrar ekleme ve tarih düzeltme hipotezleri test edilmeli. Kaynak etiketleri (elle/Health), okunma zamanı, izin durumu ve mükerrer kayıtların nasıl ele alındığı görünür olmalı; dışarıdan okumak için açık kullanıcı izni istenmeli. “Alınan − kaydedilen egzersiz” gibi bir değer, toplam günlük enerji harcaması veya tıbbi sonuç olarak sunulmamalı. Yetersiz veriyle kesin kalori açığı, hastalık, kilo kaybı veya güvenli hedef çıkarılmamalı. Geçmiş kayıt düzenlenince özetin güncellenmesi test edilmeli. `MIHEN/Features/NutritionScreen.swift`, `MIHEN/Features/HealthSummaryScreen.swift`.

### Ekran süresi

**Gözlem:** Kullanıcı uygulama/kategori/site seçer, bir günlük dakika sınırı girer, yetki verir ve süre bittiğinde 15/30/60 dakikalık geçici açılış talep eder; kapatma/geçici açılışta onay akışı bulunur. `MIHEN/Features/ScreenTimeScreen.swift:14`.

**Eleştiri:** Seçilenler için tek ortak sınırın uygulama başına bağımsız kota sanılması önlenmeli. “Onay”ın hangi cihaz doğrulaması olduğunu, izin iptalini, yeniden başlatmayı, gün dönümünü ve boş seçimleri anlaşılır biçimde açıklayın. Kullanıcının daha önce paylaştığı App Review Family Controls uyarısı, dağıtım yetkisinin ve imzalı her ilgili hedefin yeniden doğrulanmasını gerektirir; entitlement'ın hesapta atanmış olması tek başına bu incelemede yayın onayı alındığını kanıtlamaz. [Apple yetki rehberi](https://developer.apple.com/documentation/familycontrols/requesting-the-family-controls-entitlement).

**P0 cihaz matrisi:** gerçek cihazda limite ulaşma, seçilen ve seçilmeyen uygulamalar, 15 dakikalık açma ve yeniden kapanma, sistem saati/gün değişimi, telefon yeniden açılması, yetki kaldırma, uygulama sonlandırılması ve kullanıcıya anlaşılır hata. Bunlar yürütülmeden “kesintisiz engelleme” vaadi verilmemeli. Her uygulamaya ayrı limit talebi ürün kapsamıysa bunun platform ve yetki sınırları araştırılıp ayrıca tasarlanmalı; şu anki ortak bütçe ile aynı sayılmamalı.

### Takvim ve diğer bağlantılar

Takvim entegrasyonunda okumak/yazmak ayrı yetkiler, önizleme ve kaynak etiketi ile tasarlansın; takvim etkinliği otomatik yapılmış görev sayılmasın. Sağlık ve sosyal uygulama verilerinde kullanılabilir veriler iOS izinleri ve ilgili servislerin arayüzleriyle sınırlıdır; doğrudan tüm sosyal medya verilerinin okunabileceği söylenmemeli. Öncelik: kullanıcının tekrar tekrar elle girdiği ve izinle gerçekten erişilebilen veri. Her entegrasyon için kapat, veriyi sil, kaynak ve son eşitleme durumlarını göster.

## 9. Veri güveni, yedek ve kurtarma

**Gözlem:** Ayarlarda dışa aktarma tarihi, kapsam açıklaması, yedek içe aktarma önizlemesi ve yerel kurtarma akışı bulunuyor. `MIHEN/Features/SettingsScreen.swift:85`. Bunların varlığı, belirli bir kullanıcı yedeğinin her zaman güvenle geri yüklendiğinin kanıtı değildir.

**Öneri:** Ayarlarda üç açık cevap: “Veriler nerede?”, “Son yedeği ne zaman ve nereye aldım?” ve “Nasıl geri yüklerim?” Yerel dosya ve dışarı aktarılan dosyanın korunması arasındaki fark anlatılsın; cihaz değiştirme, uygulama silme ve işletim sistemi yedekleri için garanti verilmeyip desteklenen akış doğrulansın. Birleştirme ile tüm veriyi değiştirme seçeneklerinin etkisi, kayıt sayısı ve önizlemesi anlaşılır olmalı. İsteğe bağlı, rahatsız etmeyen yedek hatırlatması ve geri yüklemeyi risksiz doğrulama akışı araştırılmalı. Hassas sağlık/ibadet verileri içeren dosyalar hakkında paylaşmadan önce açıklama gösterilmeli.

**Doğrulama:** Gerçek cihazda veri oluştur → dosyaya aktar → ayrı test ortamına geri yükle → görev, rutin, ilerleme, vakit ayarları ve tarihler eşleşsin; bozuk/yanlış sürümlü dosya ve işlem iptali hiçbir mevcut veriyi bozmamalı. Yedek dosyalarının tam kapsamı testten önce kodla belirlenmeli.

## 10. Tasarım sistemi, erişilebilirlik ve metin

**Güçlü yönler:** Lacivert/yeşil kimlik, beyaz alan, az miktarda geometrik/etnik motif ve sakin dil güçlü bir yön oluşturuyor. Kullanıcının son iPhone deneyiminde yeni ikonun göründüğü doğrulandı; estetik beğeni ve küçük boyut tanınırlığı için bağımsız test yapılmadı.

**Eleştirel gözlem:** İncelenen eski haftalık plan ekranında uzun dikey formlar ve seyrek bilgi yoğunluğu, raporda büyük bir üst kart var. Bu, ekran başına kullanıcı kararını geciktirebilir; ancak güncel görüntüyle tekrar kontrol edilmeli. Küçük widget'ta altı vakit tek ekranda olduğundan yazı boyutu ve kontrast farklı cihazlarda ayrıca değerlendirilmeli.

**Tasarım ilkeleri:**

- Her ekranda bir açık birincil eylem; önem sırasına göre artan ayrıntı.
- Tipografi: okunabilir sistem stilleri ve tutarlı hiyerarşi; karakterli serif vurgu yalnızca kısa başlıklarda. Motifler bilgi ve dokunma alanlarının önüne geçmesin.
- Renk yalnız başına durum taşımamalı; metin, ikon ve kontrastla desteklenmeli. Başarı yeşili kullanıcının manevi değerini ya da sağlığını puanlamamalı.
- Erişilebilirlik testi: VoiceOver sıralaması/etiketleri, büyük yazı ve en büyük erişilebilirlik boyutları, yatay-dikey taşma, azaltılmış hareket, koyu/açık mod, 44 pt hedef alanları, renk kontrastı, küçük iPhone, Türkçe uzun başlıklar. Kodda bazı erişilebilirlik etiketleri ve boyut uyarlamaları mevcut; bunlar uçtan uca uyum kanıtı değildir.
- İkon ve marka değerlendirmesi: ana ekranda küçük/büyük, açık/koyu ve benzer ikonlarla yan yana 5 saniyelik tanıma testi; kullanıcıların kendi ifadeleri kaydedilsin. Yeni ikonu onay almadan yeniden değiştirmek yerine test edin.
- Metinler: Kullanıcının tercih ettiği “Selamün aleyküm”, “Hayırlı sabahlar/akşamlar” üslubu korunabilir; selamlaşmanın saat dilimi ve farklı kullanıcı tercihlerine uyumu sınansın. Manevi, sağlık ve ekran süresi ekranlarında suçlayıcı veya kesin sonuç vaat eden sözcüklerden kaçının.

## 11. Dış araştırma ve örneklerden çıkarımlar

| Kaynak | Gözlenen yaklaşım | MİHEN için sınanacak fikir | Sınır |
|---|---|---|---|
| [Open Habit](https://github.com/zamai/open-habit) | SwiftUI/iOS, taşınabilir JSON, widget, Kestirmeler ve isteğe bağlı iCloud; MIT lisansı | Verinin taşınabilirliğini ve widget/otomasyon keşfini kullanıcı dilinde anlatmak | Depo iddiaları bağımsız ürün testi değildir; kopyalama öncesi lisans/bağımlılık incelemesi gerekir. |
| [Loop Habit Tracker](https://github.com/iSoron/uhabits) | Alışkanlık takibi ve geçmiş görselleştirmesi; Android odağı, GPL | Birkaç kaçırılan günün tüm emeği silmediği geri bildirim tasarımı | iOS ile davranışları birebir karşılaştırılamaz; GPL kodu ve varlıkları lisans değerlendirmeden projeye taşınmamalı. |
| [FreeHabits](https://github.com/jonasgunklach/FreeHabits) | iOS'ta liste/ızgara, esnek zamanlama ve basit geçmiş | “Bugün ve geçmiş” arasında hızlı geçiş prototipi | Depo README'si kişisel kullanım ifadesi içeriyor; ticari kullanım izni varsayılmamalı, yeniden kullanım öncesi haklar netleştirilmeli. Özellikler MİHEN için kanıtlanmış etki değildir. |
| [Kadō](https://github.com/scastiel/kado) | Gizlilik odaklı iOS alışkanlık takibi, MIT | Kapsamı dar tutma ve mahremiyeti somutlaştırma | Depo kapsamı ve bakım durumu zamanla değişebilir. |
| [Apple widget rehberi](https://developer.apple.com/design/human-interface-guidelines/widgets) | Bir bakışta okunurluk, anlamlı güncellik, uygun boyut ve ilgili ekrana bağlantı | Vakit widget'ında şehir/tarih ve küçük boyut testi | iOS güncellemelerinin zamanlaması sistem kontrolündedir. |

**Davranış bilimi:** [Alışkanlık oluşumu sistematik derlemesi](https://pmc.ncbi.nlm.nih.gov/articles/PMC11641623/) kişiden kişiye ve davranışa göre önemli değişkenlik bildirir; “21 günde alışkanlık” veya herkese sabit süre vaadi desteklenmez. [Mobil sağlık uygulamalarında davranış değişimi ve etkileşim derlemesi](https://pmc.ncbi.nlm.nih.gov/articles/PMC10545861/) hedef belirleme, öz izleme ve geri bildirim gibi tekniklerle etkileşim arasında olası ilişkiler bulur; bunlar MİHEN'de nedensel etki ya da satın alma garantisi değildir. Buradan çıkan tasarım hipotezi: kullanıcının belirlediği küçük adım, anlaşılır ilerleme ve baskısız gözden geçirme birlikte test edilmeli.

**Farklılaşma fırsatı:** Yerel mahremiyet, Türkçe ve kültürel olarak sıcak dil, sade haftalık plan ve tercih edilebilir manevi araçların birlikte çalışması. Pazar boşluğu veya benzersizlik kanıtlanmış değildir; rakip mağaza deneyimleri, kullanıcı görüşmeleri ve fiyat testleri ayrıca yapılmalıdır.

## 12. Önceliklendirilmiş yol haritası

S/M/L yalnızca göreli mühendislik/tasarım karmaşıklığı tahminidir; takvim veya maliyet taahhüdü değildir. P0 güven ve dağıtım, P1 çekirdek günlük değer, P2 karar desteği ve ölçeklenme, P3 araştırma/farklılaşma anlamına gelir.

| Sıra | Öncelik | İş | Kanıt / kabul | Tahmini boyut |
|---:|---|---|---|---|
| 1 | P0 | Widget'ta konum/tarih ve varsayılan İstanbul'u anlaşılır göster | Yerel kodda şehir yok; küçük/orta boy, seyahat, gün değişimi ve yenileme cihazda doğrulanır | M |
| 2 | P0 | Vakit hesapları için referans karşılaştırma matrisi | Şehir, yöntem, tarih ve dakika farkı kayıtlı; açıklanmayan büyük farklar çözülür | M |
| 3 | P0 | Yedek/geri yükleme ve hassas veri açıklığı | Dışa aktar–geri yükle, bozuk dosya ve iptal senaryoları geçer | M |
| 4 | P0 | Screen Time gerçek cihaz ve dağıtım yetkisi doğrulama | İmzalı hedefler, onay durumu ve limit/geçici açma matrisi kanıtlanır | L |
| 5 | P1 | İlk kullanımda tek adım/rutin odaklı akış | Mevcut akışla kullanıcı testinde görev tamamlama ve zorlanma karşılaştırılır | M |
| 6 | P1 | Bugün'de öncelik, yoğun gün ve geri alma | Odak seçimi mevcut veriye dayanır; kullanıcı her işlemin etkisini anlar | M |
| 7 | P1 | Haftalık planı karar sırasına göre sadeleştir | Odak–kapasite–önizleme; mevcut veriler korunur | L |
| 8 | P1 | Rutin kurma ve oturumun basit yolu | Yeni kullanıcı bir rutin kurar, yarıda bırakıp devam eder; yinelenen görev mantığını anlar | L |
| 9 | P1 | Hedef parçalamada basit/ayrıntılı yol | İlk hafta önizlemesi, kapsam ve etkiler anlaşılır; onay olmadan değişiklik yok | M/L |
| 10 | P2 | Raporlarda kapsam, okunur içgörü ve karar | Formüller kanıtlı, eksik veri açık, eylemler açıklanabilir | L |
| 11 | P2 | Büyük yazı, VoiceOver ve küçük ekran düzeltmeleri | Cihaz ve ekran matrisi; kritik işlemler erişilebilir | M/L |
| 12 | P2 | Beslenmede hızlı giriş ve kaynak şeffaflığı | Manuel/Health ayrımı ve tekrar giriş senaryoları doğrulanır | M |
| 13 | P2 | Bildirim yönetimi ve izin durumları | Kullanıcı sıklığı/sessiz saatleri seçer; kapalı izin anlaşılır; aşırı bildirim yok | M |
| 14 | P3 | Kestirmeler ve seçici entegrasyon araştırması | İzin kapsamı ve kullanıcı değeri kanıtlanmadan geniş entegrasyon yapılmaz | M/L |
| 15 | P3 | Fiyatlandırma ve marka testleri | Gerçek fiyat teklifleri, alternatifler ve kullanıcı gerekçeleri etik biçimde karşılaştırılır | M |

Bağımlılık sırası: önce veri/kritik vakit/izin güveni; sonra günlük değer akışı; daha sonra rapor ve entegrasyon. P0 maddeleri yayın öncesi güven kapısıdır; risk kabulü ve kalan cihaz testleri görünür olmadan “tamamlandı” denmemelidir.

## 13. Araştırma ve deney planı

### A. Yönetilen kullanılabilirlik testi

8–12 farklı katılımcıyla keşif niteliğinde, mümkünse başlangıç ve geri dönen kullanıcıları ayrı gözlemleyin; bu sayı istatistiksel pazar temsili sağlamaz. Gizlilik ve izinler açıklanarak oturumlar yürütülsün. Görevler: tek adım oluştur ve yarım ilerleme kaydet; haftada üç gün iki adımlı rutin kur ve başlat; dört haftalık hedefi önizle; yoğun günü yeniden planla; widget şehrini doğrula; son haftanın raporunda bir sonraki kararı açıkla; yedek almanın yerini bul.

Her görev için girişen/tamamlayan, ipucu alan, kritik hata, süre ve katılımcının kendi sözleri kaydedilsin. Kolaylık puanına ek olarak özellikle terk nedenleri ve yanlış güven yaratan durumlar incelensin. Tek kişinin tekrar eden testleri bağımsız katılımcı gibi sayılmasın. Önce mevcut sürüm, sonra aynı görevlerle iyileştirilmiş prototip; küçük örneklemde sonucu yön gösterici kabul edin.

### B. 7/14/28 günlük günlük kullanım pilotu

Katılımcılar açık rıza ve kolay ayrılma hakkıyla alınsın. Ölçüm tercihen cihaz üzerinde ve isteğe bağlı; isim, sağlık, ibadet içeriği veya seçilmiş uygulama listesi merkezi analitiğe varsayılan gönderilmesin. Rıza verilmezse çekirdek kullanım engellenmesin.

Önerilen metrik tanımları: **ilk değer** = ilk yedi gün içinde en az bir kullanıcı tarafından oluşturulmuş adımın ilerlemesinin kaydedilmesi; **haftalık planlama** = pilotta o hafta uygulamayı açanlardan haftalık planını bilinçli kaydeden/uygulayanların oranı; **geri dönüş** = başlangıç kohortundan 7/14/28. günlerde uygulamayı en az bir kez açan kişi oranı; **haftalık sürdürülebilirlik** = ilgili haftada planlanan günlerden en az birinde kayıt yapanların oranı. Otomatik örnekler ve araştırmacı testleri hariç tutulsun; pay, payda, tarih ve eksik ölçüm raporlansın. Bunlar davranış ve alışkanlık oluşumunun birebir ölçüsü değildir. Sayısal başarı hedefleri temel ölçü alındıktan sonra önceden yazılmalı.

### C. Ticari doğrulama

Önce farklı kullanıcıların gerçekten tekrar döndüğü çekirdek değer bulunmalı. Sonra ücretli/ücretsiz sınırı ve fiyat için görüşme ve gerçekçi teklif deneyleri tasarlanabilir; sonuçları bölgesel satın alma gücü ve örneklem yanlılığıyla birlikte değerlendirin. İbadet, kişisel sağlık verilerine erişim veya veri dışa aktarma üzerinden korku yaratarak ücretlendirme önerilmez. Mevcut ücret, gelir, indirme veya dönüşüm verisi bu incelemede bulunmadığından rakam üretilmemiştir.

## 14. Açık kararlar ve sonraki ölçümler

1. İlk kullanımda tek adım mı, hazır rutin mi daha anlaşılır? Mevcut ekran ve iki prototip karşılaştırılsın.
2. Kullanıcı “rutin adımı” ile “tekrarlayan görev” ilişkisini yardımsız anlatabiliyor mu?
3. Vakitlerde şehir, yöntem ve gün bilgisi hangi widget boyutunda okunabilir kalıyor? Referans saatlerle fark nedir?
4. Haftalık ve on yıllık raporda eksik veri, karşılaştırma ve bir sonraki karar anlaşılabiliyor mu?
5. Gerçek cihazda ortak ekran süresi bütçesi ve geçici açma sınırları kullanıcı beklentisiyle örtüşüyor mu? Apple dağıtım incelemesinin güncel sonucu nedir?
6. Kullanıcı cihaz değişiminde kendi verisini güvenle taşıyabildiğini somut olarak gösterebiliyor mu?
7. Hangi tekrarlı sağlık/plan girdileri gerçek kullanıcı yükü yaratıyor ve gerçekten izinli entegrasyonla azaltılabilir?

Bu rapor bir Ar-Ge ve ürün değerlendirmesidir. Bulgular uygulanmış geliştirme, tamamlanmış iPhone test matrisi, Apple yayın onayı veya kanıtlanmış ticari başarı anlamına gelmez.
