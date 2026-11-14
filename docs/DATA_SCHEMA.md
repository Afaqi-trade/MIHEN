# Veri şeması V1

Tüm modellerin benzersiz String ID'si vardır; SwiftData `.unique` ve içe aktarma doğrulaması uygulanır. Schema/model/DTO kaynağı `Scripts/generate_models.py` içindeki S tanımıdır. `Core/Records.swift` Codable taşıma modeli; `PersistenceModels.swift` SwiftData tablolarıdır.

| Model | Temel bağ / sorumluluk |
|---|---|
| UserPreferences | Tek kayıt; dil, tema, saat dilimi, kilit, bildirim, dinlenme ve Hicri tercihleri |
| LifeDomain | Sabit 8 anahtar, görünürlük, sıra, vizyon |
| Subcategory | domainID |
| Goal | domainIDs, parentID, subcategoryID; dönem, target, unit, start/end |
| GoalMilestone / GoalProgressEntry | goalID; aşama/tarih ve miktarlı ilerleme geçmişi |
| PlannedTask | domainID, goalID; tekrar şablonu, başlangıç/bitiş, öncelik, alışkanlık |
| TaskOccurrence | taskID+day benzersiz; bağımsız başlık/birim/hedef/domain/goal snapshot, value/status, originalDay |
| Routine / RoutineItem | Alan ve taskID'lerden sıralı rutin tanımı (UI görev şablonlarını kullanır) |
| Project | Alan, isteğe bağlı goalID, açıklama, arşiv |
| QuranKhatm / QuranReadingLog | Hatim hedefi ve khatmID ile sayfa günlüğü |
| MemorizationItem / MemorizationReview | Ayet aralığı, öğrenilen ayetler, zorluk, değiştirilebilir tekrar aralığı ve tarihsel tekrarlar |
| DhikrCounter | Başlık+gün benzersiz; hedef ve gerçek sayaç |
| FastingPlan | Kişisel plan; planned/completed/cancelled/postponed ayrı durumları |
| CalendarEvent | Tarih, bitiş, tekrar; içerik kullanıcı tarafından girilir |
| JournalEntry | Alan opsiyonel; note/weekly/monthly |
| DomainActivity | Alan, tarih, miktar, birim; egzersiz/uyku/gelir/gider/bütçe/bağış vb. manuel faaliyet |
| NotificationPreference | Tür, izin tercihi ve saat |

Görev silme yerine arşivlenir; geçmiş saklanır. Hedef silmek bağlı görev/proje/gerçekleşme referanslarını boşaltır; yalnızca hedefin kendi ilerleme ve aşama kayıtları silinir. Hatim ve ezber silme kendi bağlı günlüklerini de açık işlemle siler. Tüm veriyi silmek fresh şemaya dönüştürür; tüm tablolar tek transaction'da uzlaştırılır.

Durumlar: planned(value=0), partial(0<value<target), completed(value=target), skipped/cancelled/moved. Taşıma kaynak kaydı korur, yeni tarihli kopyaya ilerlemeyi bir kez aktarır. Yeniden dağıtım en çok 90 gün için eşit kalan miktar önerir; ilk güne mevcut ilerlemeyi taşır. Çakışma otomatik birleştirilmez. Onaydan önce işlem uygulanmaz.

JSON sürüm 1; tarihler ISO-8601 (saniye hassasiyeti). En çok 10 MB. Mükerrer kimlik/gün, geçersiz ilişki, hedef döngüsü, negatif/sonsuz miktar, bozuk tarih ve bilinmeyen sürüm reddedilir. Hedef/faaliyet miktar sınırı 1e12. Yedek CSV `entity,id,payload` ile tam kayıttır. Plan CSV eklemelidir; sütunları `type,id,title,domain,target,unit,start,end,recurrence` olup domain alanı sabit anahtar veya TR/EN alan başlığı olabilir. Plan CSV alt hedef/çok alan ilişkisinin tümünü taşımaz; kayıpsız yedek için JSON veya yedek CSV kullanılır.
