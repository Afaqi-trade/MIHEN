from pathlib import Path
import json,re
rows='''source.replacement|Görev miktarı değişikliği|Task amount change
source.amount.readonly|Bu miktar bağlı kaynaktan güncellenir. Bağımsız giriş için önce kayıt bağlantısını ayır.|This amount follows the linked source. Disconnect the source before entering an independent amount.
example.navtitle|Başlangıç örneği|Starting example
report.capacity.setup|Haftanın kapasitesini belirle|Set your weekly capacity
water.widget.stale|Widget farklı bir güne aitti. Kayıt, burada gösterilen bugünün tarihine eklenecek.|The widget belonged to a different day. The entry will use today's date shown here.
water.widget.help|Widget bu formu açar. İçtiğiniz miktarı kontrol edip Kaydet'e dokununca yalnızca bir kayıt eklenir.|The widget opens this form. Check the amount you drank, then tap Save to add one record.
water.widget|Su kaydet|Record water
report.duration.unknown|Tahmini süresi olmayan adım|Steps without an estimated duration
report.metric.coverage|Bu kaynak için kayıtlı gün · bu / önceki dönem|Recorded days for this source · current / previous
design.progress.body|Dönem özetini, değişimleri ve sekiz alanın ayrıntılarını birlikte gör.|See your executive summary, changes and details across all eight areas.
design.plan.body|Önce bir alan seç. Hedefini küçük adımlara ayır, haftana yerleştir, kendi ritmini kur.|Choose an area. Break your goal into small steps, fit them into your week and find your rhythm.
design.plan.title|Niyetinden ilk adıma|From intention to your first step
report.thisWeek.capacity|Bu hafta kapasitesi aşılmış gün|Days over capacity this week
report.openArea|Alanı ve planımı aç|Open area and plan
report.completedSteps|tamamlanan adım|completed steps
report.trend.table|Grafiğin sayısal ayrıntıları|Chart data table
report.attention.help|Kalan adımları gözden geçir; gerekirse haftana yeniden yer aç.|Review the remaining steps and make room in your week when needed.
report.goals.review|Dönemde yer alan, süresi dolmuş açık hedefler|Open goals in this period whose deadline has passed
report.attention|Gözden geçirilecekler|Worth reviewing
report.compare.insufficient|İki dönemi karşılaştırmak için henüz yeterli kayıt yok.|There are not enough records yet to compare both periods.
report.steps.change|tamamlanan adım farkı|change in completed steps
report.highlights|Öne çıkanlar|Highlights
report.areas.help|Bir alana dokunarak kaynakları, hedef katkılarını ve notlarını incele. Boş alanlar başarısızlık değildir.|Tap an area to inspect sources, goal contributions and notes. Empty areas are not failures.
report.areas.overview|Sekiz alana genel bakış|Eight areas at a glance
report.areas.recorded|Kayıt bulunan alan|Areas with records
report.anchorDate|İncelenecek tarih|Review date
report.loading|Rapor hazırlanıyor|Preparing report
report.executive.help|Kayıtlarını değerlendir, bir sonraki adımını seç.|Review your records and choose your next step.
report.executive.empty|Yeni bir başlangıç|A fresh start
report.executive.title|Emeğinin görünümü|Your effort, in view
report.executive|DÖNEM ÖZETİ|PERIOD BRIEF
greeting.salaam|Selamün aleyküm|Peace be upon you
greeting.night|Hayırlı geceler|Have a blessed night
dhikr.haptics|Sayaçta hafif titreşim|Light haptic feedback on counter
review.remove|Tekrarı sil|Delete review
prayer.location.preview|Önizleme · widget için aşağıdaki ayarları kaydedin.|Preview · save the settings below to update the widget.
prayer.location.saved|Kaydedilmiş konum · widget bu ayarı kullanır.|Saved location · the widget uses this setting.
prayer.city.manual|Özel koordinat|Custom coordinates
prayer.city.help|Çevrimdışı kısa liste, yaklaşık şehir merkezlerini kullanır. Diğer konumlar için koordinat girebilirsiniz. Şehir seçimi hesaplama yönteminizi değiştirmez.|This offline shortlist uses approximate city centres. Enter coordinates for other locations. Choosing a city does not change your calculation method.
prayer.city.search|Şehir veya ülke|City or country
prayer.city.choose|Şehir seç|Choose a city
example.spiritual.task|Seçtiğim manevi pratiğe zaman ayır|Make time for my chosen spiritual practice
example.spiritual.goal|Kendime uygun manevi rutinimi oluştur|Create a spiritual routine that suits me
example.character.task|Kısa kişisel değerlendirme|Short personal reflection
example.character.goal|Geliştirmek istediğim bir davranışı seç ve değerlendir|Choose and review a behaviour to develop
example.finance.task|Gelir ve giderlerimi gözden geçir|Review my income and expenses
example.finance.goal|Kişisel bütçe planımı oluştur|Create my personal budget plan
example.health.task|Rahat tempoda hareket|Move at a comfortable pace
example.health.goal|Sürdürebileceğim bir hareket düzeni kur|Establish a sustainable movement routine
example.service.task|Gönüllülük hazırlığı ve katkı|Prepare and contribute to volunteering
example.service.goal|Bir gönüllülük çalışmasına katıl|Take part in a volunteering activity
example.family.task|Aileyle planlama ve sohbet|Family planning and conversation
example.family.goal|Birlikte bir aile etkinliği planla|Plan a family activity together
example.career.task|Sertifika çalışması|Certificate study
example.career.goal|Seçtiğim sertifika için hazırlan|Prepare for my chosen certificate
example.learning.task|Program üzerinde çalış|Study the programme
example.learning.goal|Seçtiğim öğrenme programını tamamla|Complete my chosen learning programme
example.applied|Bu örnek daha önce eklendi. Mevcut planınızı düzenleyebilirsiniz.|This example has already been added. You can edit your existing plan.
example.confirm|Önizlemedeki hedef, aşama ve görevi ekle?|Add the previewed goal, milestone and task?
example.apply|Bu planı ekle|Add this plan
example.support.help|Dakika kaydı hedef sonucunu otomatik tamamlamaz. Günleri ve miktarı ekledikten sonra görev ayrıntısından düzenleyebilirsiniz.|Minutes do not automatically complete the goal outcome. Edit days and amount in task details after adding.
example.support|Haftalık destekleyici adım|Weekly supporting step
example.milestone.help|Başlangıçtan 30. gün; otomatik tamamlanmaz.|Day 30 from the start; never completed automatically.
example.milestone|İlk ayı değerlendir, kapsamı düzenle|Review the first month and adjust the scope
example.horizon|90 günlük hedef · sonucu siz kaydedersiniz.|90-day goal · you record the outcome.
example.help|Bir başlangıç örneği. Başlıkları kendinize göre değiştirin; onayladığınızda 1 hedef, 1 aşama ve haftalık 1 görev şablonu eklenir. Bunlar tamamlanmış kayıt değildir.|An editable starting example. Confirming adds 1 goal, 1 milestone and 1 weekly task template. These are plans, not completed records.
example.title|Bu alanda nasıl başlayabilirim?|How can I start in this area?
template.preview.empty|Yeni şablon seçilmedi.|No new template selected.
template.preview.entries|planlanan adım; miktarlar ayrı birimlerle gösterilir.|planned steps; amounts retain their own units.
template.preview.help|Bugünden başlayan 7 gün. Buradaki liste yalnızca önizlemedir; seçimlerinizi uygulayana kadar plan veya geçmiş oluşturmaz.|Seven days starting today. This preview creates no plan or history until you apply your selection.
template.preview|Örnek haftayı gör|Preview the week
report.share.title|Raporu paylaş|Share report
report.export.comparison|Önceki dönem ve alt aralıkları da ekle|Include previous period and subperiods
decadal|On yıllık değerlendirme|Decade reflection
report.lighten|Miktar veya tarihi gözden geçir|Review quantity or dates
report.decide.help|Bir planı hafifletmek için miktar veya tarihi düzenleyebilirsin. Gelecek günlük işleri arşivlemek açık onay ister. Bu kararlar geçmiş kayıtları yeniden yazmaz; kendiliğinden taşıma yapılmaz.|Edit amount or dates to lighten a plan. Archiving future daily tasks requires explicit confirmation. Decisions do not rewrite history or move tasks automatically.
report.decide|Sonraki dönem kararım|My next-period decision
report.metric|Ölçüm|Metric
report.trend.help|Grafik yalnızca seçili ölçümü ve birimini gösterir. Boş aralıkta kayıt yoktur; başarısızlık veya sıfır faaliyet sonucu çıkarılmaz.|The chart shows only the selected metric and unit. Empty intervals have no records; they do not mean failure or zero activity.
report.trend|Zaman içindeki değişim|Change over time
report.difference|Kayıtlardaki fark|Difference in recorded amounts
report.current|Bu dönem|This period
report.compare.help|Önceki aralık aynı sayıda takvim günüdür. Kayıt olmayan ölçüm sıfır sayılmaz. Farklar yalnızca iki dönemde de en az üç kayıtlı gün ve aynı birim varsa gösterilir; bu bir anlamlılık veya yaşam kalitesi değerlendirmesi değildir.|The previous range has the same number of calendar days. Missing metrics are not zero. Differences appear only with at least three recorded days in both periods and matching units; this is not a significance or quality-of-life assessment.
report.compare|Önceki dönemle karşılaştırma|Compare with the previous period
report.cutoff.help|İçinde bulunduğumuz dönem bugünün sonuna kadar hesaplanır; gelecek günler geçmiş sonuç gibi gösterilmez.|The current period is calculated through today; future days are not shown as historical results.
report.lastRecord|Son kayıt günü|Last recorded day
report.firstRecord|İlk kayıt günü|First recorded day
report.coverage.title|Kayıt kapsamı|Record coverage
report.analysis|Karşılaştırma ve eğilim|Comparison and trends
nutrition.actual|Gerçekleşen|Actual
nutrition.planned|Planlanan|Planned
nutrition.plan.help|Plan bir niyettir; gerçekleşme üretmez. kcal ve ml ayrı karşılaştırılır. Egzersizde yakılan enerji toplam günlük harcama değildir; fark kalori açığı olarak yorumlanmaz.|A plan is an intention and creates no actual entry. kcal and ml are compared separately. Exercise energy is not total daily expenditure; the difference is not a calorie deficit.
nutrition.plan.add|Bu güne plan ekle|Add a plan for this day
nutrition.plan|Beslenme ve hareket planı|Nutrition and activity plan
nutrition.recent.help|Bir girişe dokunmak formu doldurur; Kaydet'e basmadan yeni kayıt oluşmaz.|Tapping an entry fills the form; no new record is created until you save.
nutrition.recent|Son kullandığım girişler|Recent entries
meal.other|Diğer|Other
meal.snack|Ara öğün|Snack
meal.dinner|Akşam|Dinner
meal.lunch|Öğle|Lunch
meal.breakfast|Kahvaltı|Breakfast
nutrition.name|Yiyecek veya plan adı (isteğe bağlı)|Food or plan name (optional)
nutrition.meal|Öğün|Meal
nutrition.shortcuts.help|10–2000 ml arasında en çok dört farklı miktarı virgülle ayırarak yaz. Örnek: 200,350,500. Bunlar yalnızca senin hızlı kayıt düğmelerindir.|Enter up to four different amounts from 10 to 2000 ml, separated by commas. Example: 200,350,500. These are only your quick-entry buttons.
nutrition.shortcuts|Hızlı su miktarlarını ayarla|Configure quick water amounts
nutrition.health.readOnly|Sağlık kaydı bu ekrandan değiştirilemez; Sağlık bağlantısından yeniden alabilirsin.|A Health record cannot be edited here; import it again through the Health connection.
routine.step.missing|Bu adım artık bulunamıyor. Eski oturum sırası değiştirilmedi; sonraki adıma geçebilirsin.|This step is no longer available. The saved session order is unchanged; you can move to the next step.
routine.unavailable|Bu rutin bugün için uygun adım içermiyor veya duraklatılmış. Arşivli adımların tekrarını görev düzenleyicisinden ayrıca değiştirebilirsin.|This routine has no eligible steps today or is paused. Archived task repeats can be changed separately in the task editor.
routine.end|Sıranın sonuna geldin. Gerçekleşmeler görev kartlarındaki kayıtlarına göre korunur.|You reached the end. Progress remains as recorded on the task cards.
routine.next|Sonraki adıma geç|Go to next step
routine.run.help|Bugünkü adımları sırayla gözden geçir. İlerleme aynı görev kaydına yazılır; bu sıra ikinci bir başarı üretmez. Sonrakine geçmek görevi tamamlamaz.|Review today's steps in order. Progress uses the same task record; the session adds no second achievement. Moving to the next step does not complete a task.
routine.group.help|Rutin takvimi grup görünümünü ve hatırlatmasını yönetir. Mevcut görevlerin tekrarları korunur; ortak bir görevi duraklatmaz. Yeni adımlar seçili günlerle başlar. Adımı kaydetmek görev listesine de ekler; gruptan çıkmak görevi silmez.|The routine schedule controls the group and its reminder. Existing tasks keep their repeats; shared tasks are not paused. New steps start on selected days. Saving a step also adds it to the task list; leaving the group does not delete it.
routine.days|Rutinin günleri|Routine days
routine.start|Rutini başlat / sürdür|Start / resume routine
planning.support.help|Dakika veya sayfa alışkanlığı kitap hedefini otomatik tamamlamaz. Bağlantı, destek ilişkisini gösterir; farklı birimler toplanmaz.|A minute or page habit does not automatically complete a book goal. The connection shows support; different units are not summed.
planning.support|Bağımsız destek alışkanlığı oluştur|Create a separate supporting habit
week.focus.empty|Bu hafta için henüz odak seçmedin.|No priorities selected for this week.
week.focus.select|Haftanın üç odağını seç|Choose this week's three priorities
capacity.future.confirm|Onay, yeni günlük görevleri ve seçili bitiş tarihini kaydeder. Geçmiş kayıtlar değişmez.|Confirmation saves new daily tasks and the selected end date. Historical records stay unchanged.
capacity.editGoal|Hedef miktarını düzenle|Edit goal amount
capacity.extend|Bitişi 30 gün uzat|Extend end by 30 days
capacity.excess|Kapasiteyi aşan süre|Time above capacity
capacity.free|Kapasite|Capacity
capacity.perUnit|Bir birim için dakika|Minutes per unit
capacity.use|Zaman kapasiteme göre dağıt|Distribute by my time capacity
capacity.insufficient|Bu miktar seçili günlerdeki boş zamanına sığmıyor. Tarihi uzatabilir, uygun günleri artırabilir veya hedef miktarını düzenleyebilirsin.|This amount does not fit the free time on selected days. Extend the dates, add available days or edit the goal amount.
capacity.unknown|Seçili günlerde süresi belirsiz işler var. Önce haftalık planda bu işlerin tahmini süresini belirle veya farklı günler seç.|Some selected days contain tasks without estimated duration. Set their estimates in the weekly plan or choose different days.
capacity.invalid|Tahmini süre 0'dan büyük ve en çok 1440 dakika olmalı.|Estimated duration must be greater than zero and at most 1440 minutes.
capacity.required|Önce haftalık zaman kapasiteni ve birim başına süreyi belirle.|Set weekly time capacity and time per unit first.
capacity.estimate.help|Süre, miktardan ayrıdır. Tahmini dakika bugünün açık planı ve sonraki tekrarlar içindir; geçmişe çalışma süresi eklemez.|Time is separate from quantity. Estimated minutes apply to today's open plan and future repeats; they do not add working time to history.
capacity.estimate|Bu adımın tahmini süresi|Estimated time for this task
capacity.minutes|Süre (dakika)|Duration (minutes)
capacity.help|Her gün planlı işlerin için ayırabileceğin dakikayı gir. 0, o gün yeni iş için zaman ayırmadığın anlamına gelir. Bu bir plan kapasitesidir; gerçekleşen çalışma süresi değildir.|Enter minutes available for planned tasks each day. Zero means no time for new tasks that day. This is planning capacity, not actual working time.
capacity.title|Ayırabileceğim süre|My available time
source.kind.activity|Faaliyet kaydı|Activity record
source.kind.fast|Oruç|Fasting
source.kind.dhikr|Zikir sayacı|Dhikr counter
source.kind.review|Ezber tekrarı|Memorization review
source.kind.reading|Okuma|Reading
source.disconnectFirst|Bu adım bir modül kaydına bağlı. Miktarı kaynakta değiştirin; tarih, birim, durum veya bağımsız miktar için önce bağlantıyı ayırın.|This task is connected to a module record. Edit its amount at the source; disconnect before changing day, unit, status or independent progress.
source.incompatible|Kayıt aynı gün, alan ve birimde olmalı; her kayıt yalnızca bir adıma bağlanabilir.|The day, area and unit must match. Each record can connect to only one task.
source.connect|Kaydı bağla|Connect record
source.confirmation|Bu kaydın miktarı mevcut manuel miktarın yerine geçsin mi? Kaynak daha sonra değişirse bu adım da güncellenir.|Replace the manual amount with this record? Later source changes will update this task too.
source.empty|Bu gün, alan ve birimde bağlanabilecek kayıt yok. Önce ilgili modülde kayıt oluşturabilirsin.|No compatible record for this day, area and unit. Create a record in the relevant module first.
source.available|Uygun kayıtlar|Compatible records
source.restore|Ayırınca bağlantıdan önceki manuel miktar geri gelir. Kaynak kayıt silinmez. Bağlı kaydı düzenlemek miktarı günceller; silmek bağlantıyı kaldırır.|Disconnecting restores the previous manual amount without deleting the source. Editing the source updates the amount; deleting it disconnects the record.
source.disconnect|Bağlantıyı ayır|Disconnect
source.open|Kaynak modülü aç|Open source module
source.connected|Bağlı kayıt|Connected record
source.explanation|Aynı gün, yaşam alanı ve birimdeki bir modül kaydını bu adıma bağlayabilirsin. Bağlı miktar mevcut elle girilen miktarın yerine geçer; ikisi toplanmaz. Hedefi aşan kısım bu adıma eklenmez.|Connect a module record with the same day, area and unit. Its amount replaces the manual amount; they are not added together. Amount beyond the task target is not applied.
source.title|Kayıt bağlantısı|Record connection
routine.manage|Rutin seçenekleri|Routine options
backup.details|Yedek içeriği ve gizlilik|Backup contents and privacy
danger.zone|Verileri silme|Delete data
report.qada.added|Dönemde eklenen kaza|Qada quantity added in this period
report.qada.done|Dönemde kılınan kaza|Qada prayers completed in this period
report.skipped|Atlanan|Skipped
report.cancelled|İptal edilen|Cancelled
report.moved|Taşınan|Moved
routine.expired|Bir adımın bitiş tarihi geçmiş. Rutin düzenleyicide o adıma dokunup bitişini değiştirin; ardından yeniden sürdürün.|A step has expired. Open it in the routine editor and change its end date before resuming.
heatmap.legend|Açık ton: az tamamlanan görev; koyu ton: yüksek tamamlama oranı. Kayıt olmayan günler boş kabul edilir; başarısızlık değildir.|Lighter shades: fewer completed tasks; darker shades: higher completion rate. Unrecorded days are empty, not failures.
startup.safe|Kayıtlar şu anda açılamıyor. Güvenlik için boş veriyle değiştirilmedi. Tekrar deneyin; sürerse teknik ayrıntıyla destek alın.|Records cannot be opened right now. They have not been replaced with empty data. Retry, or use technical details for support if it continues.
startup.retry|Tekrar dene|Retry
startup.details|Destek için teknik ayrıntı|Technical details for support
help.basics.title|Hedef, görev ve rutin arasındaki fark nedir?|What is the difference between goals, tasks and routines?
help.basics.body|Hedef ulaşmak istediğin sonuçtur. Görev bugün veya seçtiğin gün yapacağın eylemdir. Rutin aynı görevleri düzenli bir sırayla bir araya getirir; ikinci bir ilerleme kaydı üretmez.|A goal is an outcome. A task is an action for today or a chosen date. A routine groups the same tasks in a regular order without generating a second progress record.
help.partial.title|Kısmi ilerlemem nasıl görünür?|How does partial progress appear?
help.partial.body|2/6 gibi bir kayıt emek olarak görünür ve saklanır. Tamamlama oranı yalnızca tamamen biten görevleri sayar; kısmi kaydın silinmez. Bu oran hayatının veya manevi değerinin puanı değildir.|A 2/6 entry is shown and saved as progress. Completion rate counts only fully finished tasks; partial records are retained. This rate is not a score of your life or spiritual worth.
help.week.title|Haftam ağır geliyorsa ne yapabilirim?|What if my week feels too full?
help.week.body|Plan'dan Haftalık planlama'yı aç. Süresi bilinen işleri ve süresi belirtilmeyenleri ayrı gör. Kalanları düzenle bölümünde açık kayıtları seçip taşımayı veya bu kez atlamayı onayla. Plan kendiliğinden değişmez.|Open Weekly planning from Plan. Review known duration separately from actions without duration. Select open entries in Review unfinished actions and approve moving or skipping them. Plans never change automatically.
help.backup.title|Yedek, senkronizasyon anlamına gelir mi?|Is backup the same as sync?
help.backup.body|Hayır. JSON yedeği dışa aktardığın andaki kayıtları ve namaz ayarlarını içerir. Dosyayı cihaz dışında güvenli yerde tut. CSV kayıt aktarımı namaz ayarlarını içermez. Ekran Süresi izinleri yeni cihazda yeniden kurulur.|No. A JSON backup contains records and prayer settings at export time. Keep the file somewhere safe outside this device. CSV record exports exclude prayer settings. Screen Time permissions must be set up on a new device.
help.permissions.title|İzin vermeden uygulamayı kullanabilir miyim?|Can I use the app without permissions?
help.permissions.body|Temel planlama çevrimdışı ve hesapsız çalışır. Sağlık okuması, bildirim ve uygulama sınırı kendi iznini gerektirir. Bu izinleri vermemek diğer kayıtlarını kullanmanı engellemez.|Core planning works offline without an account. Health reading, notifications and app limits need their own permissions. Declining these does not prevent using your other records.
help.limits.title|Dijital sınır ve geçici açma nasıl çalışır?|How do app limits and temporary access work?
help.limits.body|Seçilen uygulamaların toplamına ortak günlük bütçe uygulanır. Geçici erişimi aynı cihaz sahibi Face ID veya parolayla onaylar; dışarıdan bir onaylayan yoktur. Bireysel sistem izni kaldırılabilir. Sosyal medya mesajları veya içerikleri okunmaz.|One shared daily budget applies to the selected apps. The same device owner approves temporary access with Face ID or passcode; there is no outside approver. Individual system permission can be revoked. Social media content or messages are not read.
help.support|Yardım ve sorun bildirimi|Help and issue reporting
help.support.body|Sorunun oluştuğu adımları not et. Paylaş düğmesi yalnızca sürüm bilgilerini hazırlar; kişisel kayıt, sağlık veya manevi veri eklemez. Dosyayı kime göndereceğini sen seçersin.|Note the steps leading to the problem. Sharing prepares version information only, excluding personal, health and spiritual records. You choose whom to send it to.
help.diagnostics.safe|Bu metinde kişisel kayıt yoktur.|No personal records are included in this text.
help.diagnostics.share|Sürüm bilgilerini paylaş|Share version information
planning.unit.locked|Kaydedilmiş katkıların anlamını korumak için bu hedefin birimi değiştirilemez. Farklı birim için yeni hedef oluştur.|This goal's unit is locked to preserve the meaning of recorded contributions. Create a new goal for a different unit.
planning.roadmap|Yıldan haftaya yol haritası|Roadmap from year to week
planning.months|Aylık dağılım|Monthly breakdown
planning.weeks|Haftalık dağılım|Weekly breakdown
planning.saveMilestones|Aylık ara sonuçları da kaydet|Also save monthly milestones
planning.milestones.help|Ara sonuçlar ayrıca ilerleme üretmez. Hedef katkısı yalnızca gerçek görev ve bağımsız katkı kayıtlarından hesaplanır.|Milestones do not generate extra progress. Goal contribution comes only from actual tasks and independent contribution entries.
connections|Bağlantılar ve hatırlatmalar|Connections and reminders
timezone.common|Sık kullanılan bölgeler|Common time zones
timezone.search|Şehir veya bölge ara|Search city or region
reading.quantity.help|Bu kayıtta okuduğun sayfa miktarını gir; ulaştığın sayfa numarasını değil.|Enter the number of pages read in this entry, not the page number you reached.
fasting.upcoming|Planlı kayıtlar|Planned entries
fasting.recorded|Tutulan oruç kayıtları|Completed fast entries
qada.witr.optional|Vitir kaydını da göster|Also show Witr records
back|Geri|Back
undo|Geri al|Undo
planning.availableDays|Uygun günleri seç|Choose available days
planning.actions|planlanan adım|planned actions
planning.archive|Gelecek planını arşivle|Archive future plan
planning.archive.confirm|Bugünden itibaren bu hedefin açık görevleri kapatılıp şablonları arşivlenecek. Kaydedilmiş miktarlar ve geçmiş korunur. Ardından yeni planı ayrıca onaylayabilirsiniz.|Open tasks from today onward will close and their templates will be archived. Recorded quantities and history are preserved. You can then approve a new plan separately.
plan.tools|Planlama araçların|Your planning tools
focus.areas|Odaklandığın yaşam alanları|Your focus areas
other.areas|Diğer yaşam alanları|Other life areas
goals.none|Henüz hedef yok · Hedef ekle|No goals yet · Add a goal
goals.count|hedef|goals
task.quick.explanation|Başlığı yazıp bugün için kaydedebilirsin. Miktar, tekrar ve hedef bağlantısı ayrıntılarda.|Enter a title to save an action for today. Quantity, repetition and goal links are in details.
task.details|Miktar, tekrar ve diğer ayrıntılar|Quantity, repetition and other details
starter.explanation|Yalnızca seçtiğin günlük adımlar eklenir. Tamamlanmış geçmiş oluşturulmaz. Her adımı sonradan düzenleyebilirsin.|Only selected daily actions are added. No completed history is created. You can edit each action later.
starter.selected|günlük adım eklenecek|daily actions will be added
starter.apply|Seçtiğim adımları ekle|Add selected actions
welcome.title|MİHEN'e hoş geldin|Welcome to MIHEN
welcome.promise|Önem verdiğin hayatı, bugünün küçük adımlarına dönüştür.|Turn what matters into small steps today.
welcome.steps|Bir hedef seç. Haftana yer aç. Bugün küçük bir adım at.|Choose a goal. Make room in your week. Take a small step today.
welcome.privacy|Hesap gerekmez. Temel kullanım çevrimdışı çalışır; kayıtların cihazında kalır.|No account needed. Core features work offline; your records stay on your device.
welcome.focus|Bu dönemde neye yer açmak istersin?|What would you like to make room for?
welcome.focus.help|1-3 alanla başlayabilirsin. Sekiz yaşam alanı korunur; tercihlerini sonra değiştirebilirsin.|You can start with 1-3 areas. All eight areas remain available; change your choices later.
welcome.begin|Bugünkü ilk adımıma geç|Start my first step today
today.first.title|Küçük bir adımla başla|Start with one small step
today.first.body|Bugün yapmak istediğin tek bir eylem ekle. Bütün hayatını bir kerede planlaman gerekmiyor.|Add one action for today. You do not need to plan your whole life at once.
today.first.add|İlk adımımı ekle|Add my first step
today.steps|Bugünkü adımların|Your steps today
today.finished|tamamlandı|finished
today.started|işe başlandı|in progress
today.partial.encouragement|Kısmi ilerlemen kaydedildi. Kaldığın yerden devam edebilirsin.|Your partial progress is recorded. Continue where you left off.
today.completed.encouragement|Attığın adımlar kaydedildi. Devam etmek ya da dinlenmek senin seçimin.|Your steps are recorded. Continuing or resting is your choice.
today.next.encouragement|Bir sonraki küçük adımını seç.|Choose your next small step.
today.reviewsDue|Tekrar zamanı gelen kayıtlar|Reviews due
focus.choose|Bugünün odağını seç|Choose today's focus
focus.explanation|Bugün için en çok üç açık eylem seç. Bu seçim yalnızca bugünün önceliğini değiştirir; geçmişi ve gelecek tekrarları değiştirmez.|Choose up to three open actions for today. This changes today's priorities only, preserving history and future repetitions.
routine.empty|Sabah veya akşam için küçük bir rutin oluştur. Yeni adımlar ekleyebilir veya mevcut görevlerini seçebilirsin.|Build a small morning or evening routine. Add new steps or choose existing tasks.
routine.morning|Sabah rutini|Morning routine
routine.evening|Akşam rutini|Evening routine
routine.steps|Rutinin adımları|Routine steps
routine.existing|Mevcut görevlerden seç|Choose existing tasks
routine.step.add|Yeni adım oluştur|Create a new step
routine.schedule.help|Adımların sırasını düzenle, grup günlerini seç ve kendi temponda ilerle. Mevcut görevlerin tekrar planı korunur.|Reorder steps, choose group days and progress at your pace. Existing task schedules are preserved.
routine.reminder|Rutine özel saatli hatırlatma|Reminder at a chosen time
routine.pause|Rutini duraklat|Pause routine
routine.resume|Rutini sürdür|Resume routine
routine.paused|Bu rutinin grup takvimi ve hatırlatması duraklatıldı. Görevleri ayrıca düzenleyebilirsin.|This routine's group schedule and reminder are paused. Tasks can be edited separately.
routine.pause.confirm|Yalnızca bu rutinin takvimi ve grup hatırlatması değişir. Görevlerin diğer kullanımları ve geçmişi korunur.|Only this routine's schedule and group reminder change. Other task uses and history are preserved.
reminder.time|Hatırlatma saati|Reminder time
reminder.global.off|Bildirimler kapalı. Hatırlatmaların ulaşması için Profil'den bildirimleri etkinleştir.|Notifications are off. Enable them in Profile to receive reminders.
week.previous|Önceki hafta|Previous week
week.next|Sonraki hafta|Next week
week.knownTime|Süresi belirtilen plan|Plan with known duration
week.withoutTime|Süresi belirtilmeyen adım|Actions without a duration
week.intention|Haftanın odağı ve notu|Weekly focus and note
week.intention.help|Bu hafta önemli olan 1-3 şeyi yaz.|Write 1-3 things that matter this week.
week.room|Henüz adım yok. Bu güne yer açabilirsin.|No actions yet. There is room in this day.
week.backlog|Önceki 30 günün bekleyenleri|Open actions from the previous 30 days
week.backlog.help|Seçili haftadan önceki 30 güne ait açık kayıtlar. Taşımak veya atlamak için kaydı aç; değişiklikler onayla uygulanır.|Open entries in the 30 days before the selected week. Open an entry to move or skip it; changes require confirmation.
week.decide|Haftanın kalanlarını düzenle|Review unfinished actions
week.decide.help|Yalnızca seçtiğin açık kayıtlar değişir. Aynı görevin hedef günde zaten kaydı varsa taşıma yapılmaz.|Only selected open entries change. Moving is blocked if that task already has an entry on the destination day.
week.decide.apply|Seçili kayıtlara uygula|Apply to selected entries
week.decide.confirm|Seçili kayıtlar gösterilen tarihe taşınsın veya bu kez atlansın mı? Kaydedilen ilerleme korunur.|Move selected entries to the shown date or skip them this time? Recorded progress is preserved.
report.recordedDays|Kayıt bulunan gün|Days with records
report.sources.explanation|Modül kayıtları kendi birimleriyle ayrı gösterilir; görev katkılarıyla toplanmaz. Kayıtlı gün, o günün tümüyle kaydedildiği anlamına gelmez. Kaza bakiyeleri kayıt tarihine göredir.|Module records keep their own units and are not added to task contributions. A recorded day does not imply a complete daily record. Qada balances follow entry dates.
report.steps|Dönemdeki görev kayıtları|Task entries in this period
report.noTasks|Bu dönemde planlanmış görev kaydı yok.|No planned task entries in this period.
report.noData|Bu dönemde bu alanda kayıt yok.|No records in this area for this period.
report.formula|Nasıl hesaplanır?|How is this calculated?
report.goal.period|Dönemdeki hedef katkısı|Goal contribution in this period
report.reading|Kaydedilen okuma|Recorded reading
report.reviews|Yapılan ezber tekrarı|Memorization reviews
report.fasts|Tutulan oruç|Completed fasts
report.qada.opening|Kaza dönem başı kayıt bakiyesi|Qada opening recorded balance
report.qada.closing|Kaza dönem sonu kayıt bakiyesi|Qada closing recorded balance
report.next|Gelecek dönem için karar ver|Decide on the next period
report.reflect|Ne işe yaradı? Neyi değiştireceksin?|What worked? What will you change?
report.next.help|Önce kayıtlarına bak, ardından haftanı hafiflet veya önceliklerini değiştir. Plan kendiliğinden değiştirilmez.|Review your records, then lighten your week or change priorities. Plans never change automatically.
report.export|Dönem raporunu dışa aktar|Export period report
report.export.help|Paylaşılacak yaşam alanlarını açıkça seç. Bu özet yedek dosyası değildir; yalnızca seçtiğin dönem ve alanları içerir.|Explicitly select the life areas to share. This summary is not a backup; it contains the selected period and areas only.
report.export.notes|Seçili alanların kişisel notlarını da ekle|Include personal notes for selected areas
report.export.format|Dosya biçimi|File format
health.source|Kaynak: Apple Sağlık seçili gün toplamı|Source: Apple Health daily total
manual.source|Kaynak: Elle girilen kayıtlar|Source: Manual entries
health.source.help|Sağlık günü kaydedilirse o günün aktif enerji toplamı kullanılır; elle girilmiş egzersiz enerjisi ayrıca toplanmaz, kayıtları korunur. Sağlık kaydını silince elle girilen toplam geri görünür.|Saving a Health day uses its active energy total; manual exercise energy is retained but not added again. Removing the Health entry restores the manual subtotal.
health.import|Seçili gün toplamlarını kaydet|Save selected day's totals
health.import.confirm|Seçili günün Sağlık toplamları kaydedilsin mi? Aynı gün yeniden kaydedilirse miktar güncellenir, ikinci kopya eklenmez.|Save the selected day's Health totals? Saving the same day updates values without creating another copy.
health.imported|Seçili gün kaydedildi. Dönem raporunda görebilirsin.|Day saved. You can view it in period reports.
activity.steps|Adım sayısı|Step count
nutrition.quick|Hızlı su kaydı|Quick water entry
nutrition.amount.water|Su miktarı (ml)|Water quantity (ml)
nutrition.amount.energy|Enerji miktarı (kcal)|Energy quantity (kcal)
review.well|Ne işe yaradı?|What worked?
review.adjust|Nerede zorlandın, neyi azaltabilirsin?|What was difficult? What could you reduce?
review.next|Gelecek dönemin 1-3 odağı|1-3 priorities for the next period
qada.prayer|Vakit|Prayer
qada.kind.label|Kayıt türü|Entry type
qada.quick|Bir kaza kıldım|Record one completed prayer
qada.first|Başlangıç miktarını ekleyerek başla. Yaşa göre otomatik borç tahmini yapılmaz.|Start by adding your initial quantities. No debt is estimated from age.
prayer.settings|Konum ve hesap ayarları|Location and calculation settings
prayer.city|Konum|Location
prayer.asr.standard|Standart ikindi hesabı|Standard Asr calculation
prayer.asr.hanafi|Hanefî ikindi hesabı|Hanafi Asr calculation
prayer.current.city|İstanbul merkez varsayılan konumdur. Farklı konum için ayarları aç.|Central Istanbul is the default. Open settings for a different location.
notifications.status|Hatırlatmalar uygulama açıkken yenilenir; sistem teslimatı etkileyebilir. Sessiz saatlerde gönderilmez.|Reminders refresh while the app is open; delivery depends on the system. Quiet hours are respected.
planning.invalid|En çok 366 gün, uygun günler ve sıfırdan büyük bir miktar seçin.|Choose up to 366 days, available weekdays and a positive quantity.
planning.whole|Adet, kitap ve sayfa hedefleri için kalan miktar tam sayı olmalı. Önce hedef veya katkı kayıtlarını gözden geçirin.|Remaining counts, books and pages must be whole numbers. Review the target or contributions first.
planning.precision|Miktarı en çok iki ondalık basamakla girin.|Use at most two decimal places.
planning.linked|Bu hedefte etkin görevler var. Görevleri düzenleyin veya gelecek planını arşivleyip yeniden planlayın. Geçmiş kayıtlar korunur.|This goal has active tasks. Edit them or archive the future plan before replanning. History is preserved.
planning.total|Planın toplamı|Plan total
planning.range|Gün başına miktar aralığı|Quantity range per planned day
planning.preview|Oluşturulacak görevleri incele|Review proposed tasks
planning.noConversion|Birim korunur. Kitap, sayfa ve dakika birbirine otomatik dönüştürülmez.|Units are preserved. Books, pages and minutes are never converted automatically.
planning.intention|Bu dönemin odağı|Focus for this period
planning.next90|İlk 90 günlük ara sonuç|First 90-day milestone
planning.milestone.placeholder|Örneğin: ilk 3 kitabı bitir|For example: finish the first 3 books
contribution.manual|Bağımsız elle eklenen katkı|Independent manual contribution
contribution.tasks|Bağlı görevlerden gelen katkı|Contribution from linked tasks
contribution.warning|Görevde kaydettiğiniz aynı miktarı burada tekrar girmeyin. Bu alan yalnızca bağlı görevler dışında yapılan ek katkılar içindir.|Do not enter the same quantity already recorded in a task. Use this only for additional independent contributions.
contribution.confirm|Bu miktar bağlı görevlerde kaydedilmemiş bağımsız bir katkı mı?|Is this an independent contribution not already recorded in linked tasks?
contribution.add|Bağımsız katkıyı ekle|Add independent contribution
backup.lastExport|Son başarılı JSON yedek dışa aktarımı|Last successful JSON backup export
backup.none|Henüz cihaz dışına yedek aktarılmadı.|No backup has been exported yet.
backup.scope|JSON yedeği kayıtları, uygulama tercihlerini ve kaydedilmiş namaz ayarlarını içerir. Cihaz dışına güvenli bir konuma aktarın. Ekran Süresi izni ve uygulama seçimi yeni cihazda yeniden kurulur; paylaşım dosyası hassas veriler içerir.|JSON backups include records, app preferences and saved prayer settings. Export to a safe location outside this device. Screen Time authorization and app selection must be set up again on a new device; the shared file contains sensitive data.
backup.exported|Dosya dışa aktarıldı. Seçtiğiniz konumda saklandığını kontrol edin.|File exported. Check it is kept in your chosen location.
backup.prayerIncluded|Bu yedek namaz ayarlarını da geri yükler; ayar yoksa varsayılana döner.|This backup also restores prayer settings, or resets to defaults when absent.
backup.legacy|Bu eski JSON veya CSV dosyası namaz ayarlarını içermez; mevcut namaz ayarları korunur.|This legacy JSON or CSV file does not include prayer settings; current prayer settings are kept.
screen.monitor.lost|Sistem günlük izlemeyi durdurmuş. Sınır kapatıldı; seçimi ve izni kontrol edip yeniden etkinleştirin.|The system stopped daily monitoring. The limit was disabled; check authorization and selection, then enable it again.
screen.title|Uygulama süre sınırı|App time limit
screen.explanation|Seçtiğiniz uygulama, kategori ve web sitelerine ortak günlük dakika sınırı koyun. Toplam süre dolduğunda iOS seçimi kısıtlar. Günlük bütçe cihazın yerel takvim gününe göre yenilenir.|Set one shared daily minute budget for selected apps, categories and websites. iOS restricts the selection when combined usage reaches the limit. The budget resets with the device's local calendar day.
screen.device.requirement|Bu özellik Ekran Süresi izni ve uygun iPhone yapılandırması gerektirir. Bireysel izin sistem ayarlarından kaldırılabilir. Sosyal medya içerikleri veya mesajları okunmaz.|This feature needs Screen Time permission and a configured iPhone. Individual authorization can be revoked in system settings. Social media content and messages are not read.
screen.status|Durum|Status
screen.authorized|Ekran Süresi izni verildi|Screen Time authorized
screen.unauthorized|Ekran Süresi izni gerekli|Screen Time permission required
screen.blocked|Günlük sınır doldu; seçim kısıtlı|Daily limit reached; selection restricted
screen.enabled|Günlük izleme etkin|Daily monitoring enabled
screen.disabled|Sınır kapalı|Limit disabled
screen.open.until|Geçici erişim bitişi|Temporary access ends
screen.authorize|Ekran Süresi izni ver|Authorize Screen Time
screen.daily|Ortak günlük sınır|Shared daily limit
screen.select|Uygulama ve kategorileri seç|Select apps and categories
screen.selection.count|Uygulama / kategori / web sitesi|Apps / categories / websites
screen.enable|Günlük sınırı etkinleştir|Enable daily limit
screen.temporary|Onaylı geçici erişim|Approved temporary access
screen.open|Doğrula ve geçici aç|Verify and temporarily open
screen.temporary.explanation|Geçici erişim günlük bütçeyi sıfırlamaz. Face ID veya cihaz parolanızla kendiniz onay verirsiniz. Süre sonunda kısıt yeniden uygulanır. Ayarı değiştirmek için önce sınırı kapatın.|Temporary access does not reset the daily budget. You approve it yourself with Face ID or the device passcode. Restrictions return after expiry. Disable the limit before changing settings.
screen.disable|Doğrula ve sınırı kapat|Verify and disable limit
screen.refresh|Durumu yenile|Refresh status
screen.approve.temporary|Seçili uygulamalar geçici açılsın mı?|Temporarily open the selected apps?
screen.approve.disable|Günlük sınır ve kısıtlamalar kapatılsın mı?|Disable the daily limit and restrictions?
screen.auth.reason|Uygulama süre sınırını değiştirmek için kimliğinizi doğrulayın.|Verify your identity to change the app time limit.
screen.group.required|Bu sürümde uygulama sınırı kullanılamıyor. Uygulamayı güncelleyin veya Yardım bölümüne bakın.|App limits are unavailable in this build. Update the app or see Help.
screen.storage.error|Süre sınırı verisi okunamadı. Kısıtlama kendiliğinden kaldırılmadı; ayarı kapatıp yeniden kurun.|Time limit data could not be read. Restrictions were retained; disable and reconfigure the limit.
screen.invalid|Seçimi, dakika sınırını veya geçici erişim durumunu kontrol edin.|Check the selection, minute limit or temporary access state.
screen.disable.first|Ayarı değiştirmeden önce mevcut sınırı kapatın.|Disable the existing limit before changing its configuration.
screen.approval.required|Bu işlem için cihaz doğrulaması gerekli.|Device verification is required for this action.
screen.changed|Süre sınırı değişti. Durumu yenileyip tekrar deneyin.|The limit changed. Refresh and try again.
screen.system.error|Ekran Süresi işlemi tamamlanamadı. Sistem iznini kontrol edip tekrar deneyin.|Screen Time could not complete the operation. Check system permission and try again.
prayer.istanbul|İstanbul konumunu kullan|Use Istanbul location
prayer.times|Namaz vakitleri|Prayer times
prayer.source|Vakitler Adhan açık kaynak astronomik hesaplarıdır. Türkiye seçeneği yaklaşık hesaptır; resmî Diyanet verisi değildir. Yerel takvimle kontrol edin.|Times use Adhan open source astronomical calculations. Turkey is an approximation, not official Diyanet data. Check your local timetable.
prayer.diyanet|Resmî Diyanet takvimini aç|Open official Diyanet timetable
prayer.manual.location|Konum ve yöntem ayarları cihazda, widget için ortak alanda ve JSON yedeğinde saklanır. Konumu kendiniz seçersiniz.|Location and method settings are stored on device, in the widget shared area and in JSON backups. You choose the location.
latitude|Enlem|Latitude
longitude|Boylam|Longitude
prayer.method|Hesaplama yöntemi|Calculation method
prayer.hanafi|İkindi hesabı|Asr calculation
prayer.highLatitude|Yüksek enlem kuralı|High latitude rule
prayer.saved|Widget için kaydedildi|Saved for widget
prayer.unavailable|Bu ayar ve tarih için vakit hesaplanamadı.|Times unavailable for these settings and date.
prayer.sunrise|Güneş|Sunrise
rule.middleOfTheNight|Gecenin yarısı|Middle of the night
rule.seventhOfTheNight|Gecenin yedide biri|Seventh of the night
rule.twilightAngle|Şafak açısı|Twilight angle
method.muslimWorldLeague|muslimWorldLeague|muslimWorldLeague
method.egyptian|egyptian|egyptian
method.karachi|karachi|karachi
method.ummAlQura|ummAlQura|ummAlQura
method.dubai|dubai|dubai
method.moonsightingCommittee|moonsightingCommittee|moonsightingCommittee
method.northAmerica|northAmerica|northAmerica
method.kuwait|kuwait|kuwait
method.qatar|qatar|qatar
method.singapore|singapore|singapore
method.tehran|tehran|tehran
method.turkey|Türkiye (yaklaşık)|Turkey (approximation)
health.connection|Apple Sağlık|Apple Health
health.read|İzin ver ve seçili günü oku|Authorize and read selected day
health.steps|Adım|Steps
health.energy|Aktif enerji|Active energy
health.explanation|Seçili günün adım ve aktif enerji toplamlarını isteğe bağlı okuyabilirsin. Sağlık'a veri yazılmaz. Boş sonuç veri veya okuma izni olmadığını gösterebilir. Kaydet dediğinde MİHEN günlüğüne tek günlük özet eklenir.|Optionally read steps and active energy for the selected day. Nothing is written to Health. An empty result may mean no data or read permission. Saving adds one daily snapshot to your MIHEN log.
report.goals.current|Dönemle ilişkili hedefler (güncel durum)|Goals associated with this period (current status)
calendar.apple.export|Apple Takvim'de kopyasını oluştur|Create a copy in Apple Calendar
calendar.apple.explanation|Bu etkinliğin tek bir kopyası Apple düzenleyicisinde açılır. Kaydetme kararını orada verirsiniz. Tekrar kuralları aktarılmaz; iki kopya otomatik eşitlenmez.|A single copy opens in Apple's editor for you to save. Recurrence rules are not transferred; the copies do not synchronize automatically.
custom.reminders|Kişisel hatırlatmalar|Personal reminders
custom.reminders.explanation|İstediğiniz saatlere hatırlatma ekleyin. Profilde bildirimleri etkinleştirin. Sessiz saatler ve sistem izinleri geçerlidir; yakın 7 gün için en fazla 60 bildirim planlanır.|Add reminders at your preferred times. Enable notifications in Profile. Quiet hours and system permissions apply; up to 60 notifications are scheduled for the next 7 days.
reminder.water|Su içmeyi hatırla|Remember to drink water
reminder.movement|Hareket molası|Movement break
qada|Kaza namazı takibi|Missed prayer tracking
qada.explanation|Kalan sayılar kendi eklediğiniz kayıtlardan hesaplanır. Vakit başına başlangıç miktarını kendiniz belirleyin. Vitir isteğe bağlı ayrı takip edilir.|Remaining counts are based on your entries. Enter your own initial amount per prayer. Witr is tracked separately if desired.
activity.qadaDebt|Takip edilecek miktar ekle|Add amount to track
activity.qadaDone|Kılınan miktar kaydet|Record completed amount
prayer.fajr|Sabah|Fajr
prayer.dhuhr|Öğle|Dhuhr
prayer.asr|İkindi|Asr
prayer.maghrib|Akşam|Maghrib
prayer.isha|Yatsı|Isha
prayer.witr|Vitir|Witr
nutrition|Beslenme ve hareket|Nutrition and activity
nutrition.summary|Günlük kayıt özeti|Daily recorded summary
nutrition.explanation|Değerler elle kaydedilir. Egzersiz kalorisi toplam günlük enerji harcaması değildir; bu kayıtlar kalori açığı veya tıbbi öneri hesaplamaz.|Values are entered manually. Exercise calories are not total daily energy expenditure; these records do not calculate a calorie deficit or medical advice.
activity.food|Alınan enerji|Energy intake
activity.energyBurned|Egzersizde harcanan enerji|Exercise energy expenditure
activity.water|Su tüketimi|Water intake
goal.split|Hedefi günlere böl|Split goal into days
goal.split.explanation|Kalan miktar uygun günlere dağıtılır. Tam sayılı birimler korunur; onaydan önce toplamı ve günleri inceleyin.|Remaining quantity is distributed across available days. Discrete units stay whole; review totals and dates before approval.
goal.split.apply|Günlük görevleri oluştur|Create daily tasks
goal.split.confirm|Gösterilen dağılımla yeni görevler oluşturulsun mu?|Create new tasks using this distribution?
days|gün|days
routines|Rutinler|Routines
routine.new|Rutin oluştur|Create routine
routine.remove|Grubu kaldır (görevler korunur)|Remove group (keep tasks)
weekly.plan|Haftalık planlama|Weekly planning
overdue|Önceki günlerden kalanlar|Unfinished from previous days
recovery.preview|Aktarma öncesi kurtarma yedeğini incele|Preview pre-import recovery backup
reports|Dönem raporları|Period reports
report.coverage|Yalnızca kayıtlı veriler raporlanır. Kayıt olmayan günler başarısızlık sayılmaz.|Reports include recorded data only. Days without records are not failures.
report.tenYears|10 yıl|10 years
report.partial|Kısmi kayıtlar|Partial records
report.first|İlk kayıt|First record
keyboard.done|Bitti|Done
redistribute.end|Dağıtım bitiş tarihi|Distribution end date
redistribute.preview|Yeniden dağıtım önerisini göster|Preview redistribution
redistribute.confirm|Bu dağıtım uygulansın mı? Geçmiş kayıt korunacak.|Apply this distribution? The original record will be preserved.
redistribute|Yeniden dağıt|Redistribute
today|Bugün|Today
plan|Plan|Plan
calendar|Takvim|Calendar
progress|İlerleme|Progress
profile|Profil|Profile
slogan|Dengeli • Planlı • Anlamlı Yaşam|A balanced • Planned • Meaningful life
onboarding.body|Vizyonunu hedeflere, hedeflerini günlük adımlara dönüştür. Kayıtların cihazında saklanır; hesap gerekmez.|Turn your vision into goals and daily actions. Your records stay on your device; no account required.
name|Adınız|Your name
priorities|Öncelikli yaşam alanları|Priority life areas
templates.load|Seçili şablonları yükle|Load selected templates
templates.explanation|Şablonlar düzenlenebilir önerilerdir. Tamamlanmış kayıt eklenmez; mevcut şablonlar tekrar eklenmez.|Templates are editable suggestions. No completed history is added; existing templates are not duplicated.
start|Başla|Get started
skip|Atla|Skip
error|İşlem kaydedilemedi|Could not save
ok|Tamam|OK
unlock|Kilidi aç|Unlock
lock.reason|Kişisel MİHEN kayıtlarınıza erişmek için kimliğinizi doğrulayın.|Authenticate to access your personal MİHEN records.
empty.detail|İlk kaydını ekleyerek başlayabilirsin.|Start by adding your first record.
empty.tasks|Henüz görev yok|No tasks yet
empty.khatm|Henüz hatim yok|No reading plans yet
empty.memorization|Henüz ezber kaydı yok|No memorization records yet
unit|Birim|Unit
count|Adet|Count
pages|Sayfa|Pages
minutes|Dakika|Minutes
books|Kitap|Books
TRY|TL|TRY
custom|Özel|Custom
custom.unit|Özel ölçü birimi|Custom unit
today.plan|Bugünkü plan|Today's plan
manage|Yönet|Manage
spiritual|Manevi takip|Spiritual practice
quick.note|Hızlı not|Quick note
upcoming|Yaklaşan etkinlikler|Upcoming events
reviews|Haftalık ve aylık değerlendirme|Weekly and monthly reviews
task.new|Görev ekle|Add task
greeting.morning|Hayırlı sabahlar|Have a blessed morning
greeting.day|Hayırlı günler|Have a blessed day
greeting.evening|Hayırlı akşamlar|Have a blessed evening
daily.progress|Günlük ilerleme|Daily progress
tasks.completed|görev tamamlandı|tasks completed
top.three|Öncelikli üç eylem|Three priority actions
complete|Tamamlanma durumunu değiştir|Toggle completion
decrease|Bir azalt|Decrease by one
increase|Bir artır|Increase by one
planned|Planlandı|Planned
partial|Kısmen tamamlandı|Partially completed
completed|Tamamlandı|Completed
skipped|Bu seferlik atla|Skip this time
cancelled|İptal edildi|Cancelled
moved|Başka güne taşındı|Moved to another day
postponed|Ertelendi|Postponed
save|Kaydet|Save
progress.value|Gerçekleşen miktar|Recorded amount
reschedule|Yeniden planla|Reschedule
date|Tarih|Date
reschedule.explanation|Taşıma geçmiş kaydı korur ve seçilen güne yeni kayıt oluşturur. O gün zaten bir gerçekleşme varsa çakışma gösterilir.|Moving keeps the historical record and creates a new occurrence. An existing occurrence on the destination day causes a conflict.
move|Seçilen güne taşı|Move to selected day
move.confirm|Bu görevi seçilen güne taşımak istiyor musunuz?|Move this task to the selected day?
task.detail|Görev ayrıntısı|Task details
close|Kapat|Close
goals|Hedefler|Goals
inactive|Etkin değil|Inactive
eight.areas|Sekiz yaşam alanı|Eight life areas
tasks.habits|Görevler ve alışkanlıklar|Tasks and habits
goal.new|Hedef ekle|Add goal
vision|Uzun vadeli vizyon|Long-term vision
active|Etkin|Active
subcategories|Alt kategoriler|Subcategories
title|Başlık|Title
delete|Sil|Delete
add|Ekle|Add
notes|Notlar|Notes
notes.reviews|Notlar ve değerlendirmeler|Notes and reviews
priority|Öncelik|Priority
priority.0|Düşük|Low
priority.1|Orta|Medium
priority.2|Yüksek|High
all|Tümü|All
horizon|Planlama dönemi|Planning horizon
year|Yıllık|Year
quarter|90 günlük|90 days
month|Aylık|Month
week|Haftalık|Week
day|Günlük|Day
archived.show|Arşivlenenleri göster|Show archived
search|Ara|Search
daily.suggestion|Günlük önerilen miktar|Suggested daily amount
pacing.explanation|Kalan miktar / bugünden bitişe kadar kalan takvim günü; yukarı yuvarlanır. Görevler kendiliğinden değiştirilmez. Yalnızca aynı ölçü birimine sahip bağlı görevler hedefe eklenir.|Remaining amount / calendar days remaining, rounded up. Tasks are never changed automatically. Linked tasks contribute only when their unit matches the goal.
progress.add|İlerleme kaydet|Record progress
amount|Miktar|Amount
milestones|Aşamalar|Milestones
linked.tasks|Bağlı görevler|Linked tasks
edit|Düzenle|Edit
archive|Arşivle|Archive
archived|Arşivlendi|Archived
unarchive|Arşivden çıkar|Unarchive
delete.confirm|Bu kaydı silmek istiyor musunuz?|Delete this record?
goal.detail|Hedef ayrıntısı|Goal details
parent.goal|Üst hedef|Parent goal
none|Yok / tek seferlik|None / one time
target|Hedef miktar|Target amount
start.date|Başlangıç|Start date
end.date|Bitiş|End date
goal.edit|Hedef düzenle|Edit goal
cancel|Vazgeç|Cancel
streak|Planlanan günlerde istikrar|Consistency on scheduled days
area|Yaşam alanı|Life area
linked.goal|Bağlı hedef|Linked goal
end.enabled|Bitiş tarihi belirle|Set end date
recurrence|Tekrarlama|Recurrence
daily|Her gün|Daily
weekly|Her hafta|Weekly
monthly|Her ay|Monthly
yearly|Yıllık değerlendirme|Yearly reflection
hijriMonthly|Her Hicri ay|Every Hijri month
hijriYearly|Her Hicri yıl|Every Hijri year
habit|Alışkanlık olarak takip et|Track as a habit
task.edit|Görev düzenle|Edit task
task.edit.explanation|Mevcut gerçekleşmeler kendi başlık ve miktarlarını korur. Değişiklik yeni oluşturulan gerçekleşmelere uygulanır.|Existing occurrences keep their title and target. Changes apply to newly created occurrences.
calendar.view|Takvim görünümü|Calendar view
events|Etkinlikler|Events
event.new|Etkinlik düzenle|Edit event
period|Dönem|Period
completion.rate|Tamamlama oranı|Completion rate
statistics.formula|Tamamlanan gerçekleşme sayısı / planlanan gerçekleşme sayısı. Kısmi kayıtlar tamamlanmış sayılmaz. Atlanan, iptal edilen ve taşınan kayıtlar paydaya girmez. Veri yoksa yüzde gösterilmez.|Completed occurrences / scheduled occurrences. Partial entries are not counted as completed. Skipped, cancelled and moved entries are excluded. No percentage is shown without data.
chart.progress|Günlük tamamlama grafiği|Daily completion chart
qualitative.only|Sayısal kayıt yok. Bu alanı not ve değerlendirmelerinle takip edebilirsin.|No numeric records. Use notes and reflections for this area.
heatmap|Son 28 gün|Last 28 days
comparison.noData|Önceki eşit uzunluktaki dönemde kayıt yok.|No records in the preceding period of equal length.
comparison.previous|Önceki eşit uzunluktaki dönem|Previous period of equal length
type|Tür|Type
note|Not|Note
review.summary|Dönem özeti|Period summary
review.prompts|Neler tamamlandı? Hangi alanlarda ilerledin? Neler zorladı? Önümüzdeki dönemde neyi değiştireceksin? Önceliklerin değişti mi?|What did you finish? Where did you grow? What was difficult? What will you change next period? Have your priorities changed?
quran.khatm|Kur'an ve hatim takibi|Quran reading plans
memorization|Ezber ve tekrar|Memorization and review
dhikr|Zikir sayacı|Dhikr counter
fasting|Oruç planı|Fasting plan
routines|Kişisel rutinler|Personal routines
spiritual.explanation|Bu modül kişisel faaliyet takibidir. Şablonlar zorunluluk veya dini hüküm değildir; düzenleyebilir, arşivleyebilir ya da hiç eklemeyebilirsiniz. Meal, tefsir ve ses içerikleri dağıtılmaz.|This module tracks personal activities. Templates are optional and do not constitute religious rulings. Edit, archive or omit them. No translations, commentary or recordings are distributed.
templates|Başlangıç şablonları|Starter templates
templates.choose|Şablonları seç|Choose templates
reading|Okuma|Reading
translation|Meal ile okuma|Reading with translation
tafsir|Tefsir okuma|Commentary reading
khatm.explanation|Yıllık şablon: üç Kur'an hatmi; bunlardan biri meal ile. Ayrıca bir tefsir okuma planı. Mealli hatim dördüncü Kur'an hatmi olarak sayılmaz. Toplam sayfa sayısını kendi baskınıza göre düzenleyin.|Annual template: three Quran readings, one with translation, plus one commentary plan. The translation reading is included in the three. Set page totals for your own edition.
pages.total|Toplam sayfa|Total pages
juz.approximate|Yaklaşık cüz (sayfa oranı)|Approximate juz (page ratio)
reading.add|Okuma kaydet|Record reading
history|Geçmiş|History
verses|Ayet|Verses
review.next|Sonraki tekrar|Next review
review.none|İlk tekrarını kaydederek başla.|Start by recording your first review.
review.record|Tekrar yaptım|Record review
verse.first|Başlangıç ayeti|First verse
verse.last|Bitiş ayeti|Last verse
verses.learned|Ezberlenen ayet sayısı|Verses memorized
difficulty|Zorluk|Difficulty
difficulty.0|Kolay|Easy
difficulty.1|Orta|Moderate
difficulty.2|Zor|Hard
review.intervals|Tekrar aralıkları (gün, virgülle)|Review intervals (days, comma-separated)
counter.new|Yeni sayaç|New counter
fasting.calendarNote|Hicri ayların 13–15. günleri, Recep ve Şaban için kişisel hedeflerinizi manuel planlayabilirsiniz. Tutulan gün sayısı yalnızca tamamlandı kayıtlarından hesaplanır. Dini tarihler için yerel resmî takvimi doğrulayın.|You can manually plan personal goals for Hijri days 13–15, Rajab and Shaban. Only completed entries count as observed fasts. Verify religious dates against your local official calendar.
summary|Özet|Summary
status|Durum|Status
khatm.annualTemplates|Yıllık 3 hatim + 1 tefsir şablonunu ekle|Add annual 3 readings + 1 commentary template
memorization.templates|Vâkıa, Mülk, Yâsin ve Duha–Nas şablonlarını ekle|Add Waqia, Mulk, Yasin and Duha–Nas templates
language|Dil|Language
theme|Görünüm|Appearance
system|Sistem|System
light|Açık|Light
dark|Koyu|Dark
timezone|Saat dilimi|Time zone
calendar.hijri|Hicri takvim|Hijri calendar
hijri.show|Hicri tarihi göster|Show Hijri date
hijri.offset|Gün düzeltmesi|Day adjustment
hijri.explanation|Ümmü'l-Kurâ takvim hesabı kullanılır; yerel/resmî dini takvimle farklılık olabilir. ±2 gün düzeltme yalnızca Hicri gösterim ve tekrar hesaplarını etkiler; geçmiş kayıtları taşımaz.|Uses the Umm al-Qura calendar calculation. Local or official dates can differ. The ±2 day adjustment affects Hijri display and recurrence only; it never moves historical entries.
rest.days|Alışkanlıklarda dinlenme günleri|Habit rest days
notifications|Bildirimler|Notifications
notifications.enable|Hatırlatmaları etkinleştir|Enable reminders
notifications.hour|Görev ve sabah özeti saati|Task and morning summary hour
quiet.start|Sessiz saat başlangıcı|Quiet hours start
quiet.end|Sessiz saat bitişi|Quiet hours end
notifications.explanation|En yakın 60 hatırlatma, önümüzdeki 7 günlük görevler arasından planlanır. Akşam ve haftalık değerlendirme saati 20:00'dır. Sessiz saatlerdeki bildirimler atlanır. Yeni günler için uygulamayı düzenli açın; iOS teslimatı etkileyebilir.|Schedules the next 60 reminders, including tasks in the next 7 days. Evening and weekly reviews use 20:00. Reminders in quiet hours are omitted. Open the app regularly to refresh; iOS may affect delivery.
privacy|Gizlilik|Privacy
lock|Face ID / cihaz parolası kilidi|Face ID / device passcode lock
privacy.policy|Gizlilik politikası|Privacy policy
local.only|Veriler cihazda saklanır. Hesap, reklam, analiz SDK'sı veya zorunlu internet bağlantısı yoktur.|Data stays on your device. No account, advertising, analytics SDK or internet connection is required.
widget.unavailable|Widget bu sürümde henüz kullanılamıyor.|Widgets are not available in this build yet.
widget.available|Widget bugünkü gerçek kayıtlardan üretilir; uygulama kilidi açıkken içerik gizlenir.|The widget uses today's real records; content is hidden when app lock is enabled.
data|Veriler ve yedekleme|Data and backups
export.json|JSON yedek oluştur|Create JSON backup
export.csv|Kayıtları CSV olarak aktar (namaz ayarları hariç)|Export records as CSV (excluding prayer settings)
export.planCSV|Düzenlenebilir plan tablosu aktar|Export editable plan table
import|Yedek veya plan tablosundan içe aktar|Import backup or plan table
backup.explanation|JSON ve yedek CSV tüm kayıtları geri yükler. Plan CSV hedef ve görev ekler. Dosyalar şifrelenmez; güvenli bir konum seçin. İçe aktarmadan önce önizleme ve onay gerekir. XLSX desteklenmez.|JSON and backup CSV restore all records. Plan CSV adds goals and tasks. Exports are not encrypted; choose a safe destination. Imports require preview and confirmation. XLSX is not supported.
data.delete|Tüm verileri sil|Delete all data
help|Yardım|Help
help.body|Kullanım rehberi ve sık sorulanlar|User guide and common questions
cloud.unavailable|iCloud senkronizasyonu bu sürümde etkin değildir.|iCloud sync is not enabled in this version.
import.replaces|Bu yedek mevcut verilerin tamamını değiştirecek. Önce dışa aktararak yedek almanız önerilir.|This backup replaces all current data. Export a backup first.
import.adds|Geçerli satırlar mevcut plana eklenecek. Hatalar varsa hiçbir satır alınmaz.|Valid rows will be added to your plan. If any row has errors, nothing is imported.
records|Kayıtlar|Records
import.confirm|Önizlemeyi onayla ve içe aktar|Confirm preview and import
import.preview|İçe aktarma önizlemesi|Import preview
data.delete.confirm|Tüm hedefler, geçmiş ve tercihler kalıcı olarak silinsin mi? Bu işlem geri alınamaz.|Permanently delete all goals, history and preferences? This cannot be undone.
notifications.permission|Görev, hedef ve değerlendirmeler için bu cihazda bildirim izni istenecek.|Allow this device to send reminders for tasks, goals and reviews?
continue|Devam et|Continue
notifications.denied|Bildirim izni verilmedi. iOS Ayarlar bölümünden etkinleştirebilirsiniz.|Notification permission was not granted. Enable it in iOS Settings.
privacy.body|MİHEN kişisel hedeflerinizi, görevlerinizi ve isteğe bağlı manevi, sağlık ve mali kayıtlarınızı cihazınızda tutar. Geliştiriciye veri aktarılmaz; hesap, reklam veya analitik kullanılmaz. Bildirimler cihazda planlanır. Face ID biyometrik verisi uygulamaya verilmez; doğrulamayı iOS yapar. Widget, App Group üzerinden günlük özeti okur; kilit etkinse içerik gizlenir. Paylaştığınız yedekler şifrelenmemiş kişisel veriler içerir. Sistem cihaz yedekleri iOS/iCloud ayarlarınıza bağlı olabilir; uygulama iCloud senkronizasyonu sunmaz. Profil'den tüm verileri silebilirsiniz. Yayın sahibinin iletişim bilgisi ve politika URL'si yayın öncesi tamamlanmalıdır. Hukuki uyumluluk değerlendirmesi henüz tamamlanmamıştır.|MİHEN keeps your goals, tasks and optional spiritual, health and financial records on your device. No data is sent to the developer. No account, advertising or analytics is used. Notifications are scheduled locally. Biometric data is handled by iOS and is never provided to the app. The widget reads a daily summary through App Groups; content is hidden when lock is enabled. Exported backups contain unencrypted personal data. Device backups depend on your iOS/iCloud settings; the app does not provide iCloud sync. Delete all records in Profile. Publisher contact information and the policy URL must be completed before release. Legal compliance has not yet been assessed.
widget.open|Bugünü güncellemek için MİHEN'i açın.|Open MİHEN to refresh today.
widget.description|Bugünkü planın ve gerçek ilerlemen.|Today's plan and your recorded progress.
reminder.summary|Günlük planını gözden geçir.|Review your daily plan.
reminder.task|Planladığın bir eylemi hatırla.|A reminder for a planned action.
reminder.review|Değerlendirme zamanı.|Time for a reflection.
reminder.fast|Planladığın orucu gözden geçir.|Review your planned fast.
reminder.evening|Akşam değerlendirmesi|Evening reflection
reminder.weekly|Haftalık değerlendirme|Weekly reflection
activity.log|Faaliyet ve ölçüm kayıtları|Activities and measurements
activity.new|Kayıt ekle|Add record
projects|Projeler|Projects
project.new|Proje ekle|Add project
activity.exercise|Egzersiz|Exercise
activity.sleep|Uyku|Sleep
activity.income|Gelir|Income
activity.expense|Gider|Expense
activity.budget|Bütçe|Budget
activity.obligation|Mali yükümlülük|Financial obligation
activity.giving|İnfak / bağış|Giving / donation
activity.volunteering|Gönüllülük|Volunteering
activity.learning|Öğrenme|Learning
activity.other|Diğer|Other
template.quran|Kur'an okuma|Quran reading
template.movement|Hareket / egzersiz|Movement / exercise
template.family|Aileyle vakit|Family time
template.evrad|Günlük evrad|Daily awrad
template.reflection|Günlük öz değerlendirme|Daily reflection
template.skill|Mesleki öğrenme|Professional learning
template.saving|Bütçeyi gözden geçir|Review budget
template.service|Bir iyilik planla|Plan an act of service
routine.evrad|Günlük evrad|Daily awrad
routine.dua|Günlük dua|Daily supplication
routine.waqia|Akşam sonrası Vâkıa okuma|Waqia reading after evening
routine.mulk|Yatmadan Mülk okuma|Mulk reading before sleep
routine.baqarah|Bakara'dan seçilen ayetler|Selected verses from Baqarah
routine.kahf|Kehf'in son beş ayeti|Last five verses of Kahf
routine.takathur|Günlük Tekâsür|Daily Takathur
routine.allah|Allah zikri — 1.000 tekrar|Allah dhikr — 1,000 repetitions
routine.tawhid|Tevhid — 100 tekrar|Tawhid — 100 repetitions
routine.istighfar|Estağfirullah — 100 tekrar|Istighfar — 100 repetitions
routine.ikhlas|İhlâs — 100 tekrar|Ikhlas — 100 repetitions
routine.salawat|Salavat — 100 tekrar|Salawat — 100 repetitions
routine.tahajjud|Haftalık teheccüd hedefi|Weekly tahajjud goal
routine.tunjina|Salâten Tüncinâ okuma|Salaten Tunjina reading
routine.dalail|Delâilü'l-Hayrât okuma|Dalail al-Khayrat reading
validation.progress|Geçerli ve sıfırdan küçük olmayan bir miktar girin.|Enter a valid nonnegative amount.
validation.closed|Bu kayıt kapalı; yeni ilerleme eklenemez.|This occurrence is closed; progress cannot be added.
validation.missing|İlgili kayıt bulunamadı.|The referenced record was not found.
validation.duplicateDay|Bu görev için seçilen günde zaten bir kayıt var.|An occurrence already exists for this task on that day.
validation.fileSize|Dosya 10 MB sınırını aşıyor.|The file exceeds the 10 MB limit.
validation.data|Kayıt alanları, tarih aralığı veya ilişkileri geçersiz. Lütfen kontrol edin.|Record fields, dates or references are invalid. Please review them.
validation.duplicates|Mükerrer veya geçersiz kimlik bulundu.|Duplicate or invalid IDs found.
validation.version|Bu yedek sürümü desteklenmiyor.|This backup version is not supported.
validation.cycle|Hedef ilişkileri döngü oluşturamaz.|Goal relationships cannot contain cycles.
validation.csv|CSV biçimi geçersiz.|Invalid CSV format.
validation.csvHeader|CSV sütun başlıkları beklenen şablonla eşleşmiyor.|CSV headers do not match the expected template.
validation.csvEntity|CSV kayıt türü tanınmadı.|Unknown CSV record type.
validation.emptyImport|İçe aktarılabilecek satır yok.|No rows to import.
'''
strings={}
for row in rows.splitlines():
    if not row:continue
    key,tr,en=row.split('|',2)
    strings[key]={'localizations':{lang:{'stringUnit':{'state':'translated','value':value}} for lang,value in [('tr',tr),('en',en)]}}
Path('MIHEN/Localization/Localizable.xcstrings').write_text(json.dumps({'sourceLanguage':'tr','strings':strings,'version':'1.0'},ensure_ascii=False,indent=2)+'\n')
# Fail generation if literal UI keys are missing. User-entered record titles are intentionally dynamic.
missing=set()
for p in Path('MIHEN').rglob('*.swift'):
    for key in re.findall(r'\bt\("([^"\\]+)"\)',p.read_text()):
        if key not in strings:missing.add(key)
if missing:raise SystemExit('Missing keys: '+str(sorted(missing)))
print(f'{len(strings)} bilingual keys; all literal UI keys covered')
info_path = Path('MIHEN/Localization/InfoPlist.xcstrings')
info = json.loads(info_path.read_text())
info['strings']['NSHealthShareUsageDescription'] = {'localizations': {lang: {'stringUnit': {'state': 'translated', 'value': value}} for lang, value in [('tr', 'Seçtiğiniz günün adım ve aktif enerji toplamlarını MİHEN içinde göstermek için izin istenir.'), ('en', 'Allow MIHEN to display steps and active energy totals for your selected day.')]}}
info['strings']['NSHealthUpdateUsageDescription'] = {'localizations': {lang: {'stringUnit': {'state': 'translated', 'value': value}} for lang, value in [('tr', 'MİHEN Sağlık verilerinizi değiştirmez; bu açıklama, seçtiğiniz günün adım ve aktif enerji toplamlarını yalnızca okumak için istenen Sağlık erişimini açıklar.'), ('en', 'MIHEN does not modify your Health data; this description explains the Health access requested only to read step and active energy totals for your selected day.')]}}
info_path.write_text(json.dumps(info, ensure_ascii=False, indent=2) + '\n')
