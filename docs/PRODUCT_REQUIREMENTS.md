# Ürün kapsamı ve kararlar

Kaynak: ürün sahibinin geliştirme talimatı olarak onayladığı MİHEN master promptu. Görsel referans HTML prototipindeki kart hiyerarşisi, lacivert özet, yeşil aksiyonlar ve beş sekmedir. Master prompttaki dağ/yol/hedef logosu, krem #F7F5EF ve “Dengeli • Planlı • Anlamlı Yaşam” sloganı eski prototip metinlerinin önündedir.

Tam olarak sekiz ana alan korunur: Kulluk ve Manevî Hayat; Kur'an, İlim ve Fikrî Gelişim; Ahlâk, Nefs Terbiyesi ve İç Disiplin; Aile, Akraba, Dostluk ve Sosyal Hayat; Sağlık, Beden ve Yaşam Düzeni; Meslek, Yetkinlik, Üretim ve Kariyer; Mali Hayat, Helal Kazanç, İnfak ve Hac Hazırlığı; Hizmet, Toplumsal Fayda ve Miras.

## Kodlanan akışlar (iOS doğrulaması ayrı kapıdır)

| Alan | Kaynak kod kapsamı |
|---|---|
| Onboarding | Atlanabilir; ad/öncelik seçimi, yalnızca onayla tamamlanmamış şablonlar |
| Bugün | Gerçekleşme listesi, 2/6 gibi kısmi kayıt, tamamla/geri al, üç öncelik, not ve manevi kısayol |
| Plan | Sekiz alan, vizyon, alt kategori, çok alanlı ve üst/alt hedef, dönem, tarih, öncelik, arşiv/sil; proje ve faaliyet kayıtları |
| Görev/alışkanlık | Hedef bağlantısı, sayısal/süre/sayfa/para/özel birim, tekrar, dinlenme günü, istikrar |
| Takvim | Gün/hafta/ay, Miladi/Hicri tekrar, görev/etkinlik/hedef bitişi/oruç |
| İlerleme | Gerçek tamamlama oranı, dönem ve alan özeti, grafik, 28 gün ısı haritası, önceki eşit uzunlukta dönem |
| Manevi takip | Hatim ve sayfa günlüğü, mealli dahil 3 hatim + ayrı tefsir şablonu, ezber/tekrar, zikir sayacı, oruç durumları |
| Değerlendirme | Haftalık/aylık gerçek görev özeti ve serbest kullanıcı cevapları |
| Profil | TR/EN, tema, saat dilimi, Hicri düzeltme, kilit, bildirim, JSON/CSV önizleme/aktar/geri yükle/sil |
| Widget | Paylaşılan gerçek günlük özet; kilitliyken içerik gizli; eski gün için uygulamayı aç mesajı |

## Açık sınırlar

Widget üzerinden App Intents ile tamamlama yok. iCloud ve XLSX desteği yok. Dini günler için resmî kaynak entegrasyonu yok; oruç günleri manuel, Hicri hesap algoritmiktir. Tüm master prompt kabul kriterleri kapanmış değildir. Kaynak kodunun mevcut olması cihazda çalışmasının kanıtı değildir. Detay: KNOWN_LIMITATIONS.md ve TEST_REPORT.md.

## Varsayımlar

- Alışkanlıklar ayrı bir görevin `isHabit` türüyle; günlük tamamlanma ve kısmi değer `TaskOccurrence` ile temsil edilir. Haftalık/aylık değerlendirmeler `JournalEntry.kind` ile saklanır. Ayrı isimli fakat aynı sorumluluğu tekrar eden tablolar üretilmez.
- Başarı, görev gerçekleşmesini ölçer; kişinin yaşam kalitesi/manevi değeri için sayısal sonuç üretilmez.
- Sayısal hedefe otomatik katkı yalnızca aynı birimli bağlı görevlerden gelir. Sayfa ve dakika kitap adedine çevrilmez.
- Kişisel cihaz sürümü local-first'tür. Hesap, abonelik, reklam, üçüncü taraf analitik ve ağ erişimi eklenmez.

## Ekran Süresi kapsamı — ürün sahibinin 15 Kasım isteği

Profil altında Apple sistem seçicisiyle seçilen uygulama/kategori/web siteleri için tek ortak günlük dakika bütçesi uygulanır. Eşik DeviceActivity uzantısında ManagedSettings shield üretir. Kullanıcı MİHEN'e dönüp cihaz doğrulamasıyla 15/30/60 dakika geçici erişim verebilir; süre sonunda kısıtlama geri gelir. Günlük bütçe bu işlemle sıfırlanmaz. Kısıt veya uygulama kullanımı yaşam alanlarına sahte tamamlanma kaydı eklemez. Bireysel izin kullanıcı tarafından sistemden kaldırılabilir. Ana uygulama/uzantı Family Controls ve App Group yetkileri ile fiziksel cihaz testi ayrı kabul koşuludur. Detay SCREEN_TIME_TR.md içinde.
