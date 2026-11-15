from pathlib import Path
import json,re
rows='''screen.title|Uygulama süre sınırı|App time limit
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
screen.temporary.explanation|Geçici erişim günlük bütçeyi sıfırlamaz. Face ID veya cihaz parolası gerekir. Süre bitince iOS izleme uzantısı kısıtı geri uygular; sistem callback zamanlaması cihazda doğrulanmalıdır. Ayarı değiştirmek için önce sınırı kapatın.|Temporary access does not reset the daily budget. Face ID or device passcode is required. The iOS monitor restores restrictions after expiry; system callback timing must be verified on device. Disable the limit before changing the configuration.
screen.disable|Doğrula ve sınırı kapat|Verify and disable limit
screen.refresh|Durumu yenile|Refresh status
screen.approve.temporary|Seçili uygulamalar geçici açılsın mı?|Temporarily open the selected apps?
screen.approve.disable|Günlük sınır ve kısıtlamalar kapatılsın mı?|Disable the daily limit and restrictions?
screen.auth.reason|Uygulama süre sınırını değiştirmek için kimliğinizi doğrulayın.|Verify your identity to change the app time limit.
screen.group.required|Ortak uygulama alanı kullanılamıyor. iPhone kurulumu için App Group yetkilerini yapılandırın.|Shared app storage is unavailable. Configure App Group entitlements for iPhone installation.
screen.storage.error|Süre sınırı verisi okunamadı. Kısıtlama kendiliğinden kaldırılmadı; ayarı kapatıp yeniden kurun.|Time limit data could not be read. Restrictions were retained; disable and reconfigure the limit.
screen.invalid|Seçimi, dakika sınırını veya geçici erişim durumunu kontrol edin.|Check the selection, minute limit or temporary access state.
screen.disable.first|Ayarı değiştirmeden önce mevcut sınırı kapatın.|Disable the existing limit before changing its configuration.
screen.approval.required|Bu işlem için cihaz doğrulaması gerekli.|Device verification is required for this action.
screen.changed|Süre sınırı değişti. Durumu yenileyip tekrar deneyin.|The limit changed. Refresh and try again.
screen.system.error|Ekran Süresi işlemi tamamlanamadı. Sistem izni ve Family Controls yetkilerini kontrol edin.|Screen Time could not complete the operation. Check system authorization and Family Controls entitlements.
prayer.istanbul|İstanbul konumunu kullan|Use Istanbul location
prayer.times|Namaz vakitleri|Prayer times
prayer.source|Vakitler Adhan açık kaynak astronomik hesaplarıdır. Türkiye seçeneği yaklaşık hesaptır; resmî Diyanet verisi değildir. Yerel takvimle kontrol edin.|Times use Adhan open source astronomical calculations. Turkey is an approximation, not official Diyanet data. Check your local timetable.
prayer.diyanet|Resmî Diyanet takvimini aç|Open official Diyanet timetable
prayer.manual.location|Koordinatları ve saat dilimini kendiniz seçin. Başlangıç konumu İstanbul merkezidir; kesin konumunuza göre değiştirebilirsiniz. Ayarlar cihazda ve widget için App Group'ta saklanır; JSON yedeğine dahil değildir.|Choose coordinates and timezone. The initial location is central Istanbul; adjust it for your exact location. Settings stay on device and in the widget App Group; they are not included in JSON backup.
latitude|Enlem|Latitude
longitude|Boylam|Longitude
prayer.method|Hesaplama yöntemi|Calculation method
prayer.hanafi|İkindi: Hanefî (kapalı: standart/Şafiî)|Asr: Hanafi (off: standard/Shafi)
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
health.explanation|Yalnızca seçili günün adım ve aktif enerji toplamları okunur. Sağlık'a veri yazılmaz. Boş sonuç veri yok veya okuma izni yok anlamına gelebilir. Elle girilen egzersiz kayıtlarına eklenmez.|Only steps and active energy totals for the selected day are read. No data is written to Health. An empty result may mean no data or no read permission. Totals are not added to manual exercise entries.
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
goal.split.explanation|Kalan miktar seçilen günlere eşit dağıtılır (en çok 366 gün). Aynı birim korunur. Etkin bağlı görev varsa önce mevcut planı düzenleyin.|The remaining quantity is distributed equally over selected days (up to 366 days). Units are preserved. Edit existing active linked tasks before creating another plan.
goal.split.apply|Günlük görevleri oluştur|Create daily tasks
goal.split.confirm|Gösterilen dağılımla yeni görevler oluşturulsun mu?|Create new tasks using this distribution?
days|gün|days
routines|Rutinler|Routines
routine.new|Görevlerden rutin oluştur|Create a routine from tasks
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
greeting.morning|Günaydın|Good morning
greeting.day|İyi günler|Good afternoon
greeting.evening|İyi akşamlar|Good evening
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
yearly|Her yıl|Yearly
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
widget.unavailable|Widget için App Group henüz yapılandırılmamış. Ana uygulama yerel olarak kullanılabilir.|App Group is not configured for the widget. The main app remains available locally.
widget.available|Widget bugünkü gerçek kayıtlardan üretilir; uygulama kilidi açıkken içerik gizlenir.|The widget uses today's real records; content is hidden when app lock is enabled.
data|Veriler ve yedekleme|Data and backups
export.json|JSON yedeğini dışa aktar|Export JSON backup
export.csv|CSV yedeğini dışa aktar|Export CSV backup
export.planCSV|Excel için düzenlenebilir plan CSV'si|Editable plan CSV for Excel
import|İçe aktar / yedekten dön|Import / restore
backup.explanation|JSON ve yedek CSV tüm kayıtları geri yükler. Plan CSV hedef ve görev ekler. Dosyalar şifrelenmez; güvenli bir konum seçin. İçe aktarmadan önce önizleme ve onay gerekir. XLSX desteklenmez.|JSON and backup CSV restore all records. Plan CSV adds goals and tasks. Exports are not encrypted; choose a safe destination. Imports require preview and confirmation. XLSX is not supported.
data.delete|Tüm verileri sil|Delete all data
help|Yardım|Help
help.body|Plan'dan yaşam alanını seçerek hedef oluşturun. Günlük görevi bir hedefe bağlayın ve Bugün ekranından ilerleme kaydedin. Düzenli yedek alın.|Choose a life area in Plan to create a goal. Link a daily task to a goal, then record progress in Today. Back up regularly.
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
info_path.write_text(json.dumps(info, ensure_ascii=False, indent=2) + '\n')
