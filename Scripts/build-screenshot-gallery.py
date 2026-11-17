#!/usr/bin/env python3
"""Merge unedited XCUITest PNGs into a portable offline gallery with provenance."""
import argparse
import base64
import datetime
import hashlib
import html
import json
from pathlib import Path
import shutil
import zipfile

REQUIRED_MODULE_CAPTURES = {'MIHEN-Qada-TR', 'MIHEN-WeeklyPlan-TR', 'MIHEN-Routines-TR', 'MIHEN-GoalSplit-TR', 'MIHEN-GoalSplit-Preview-TR'}
LABELS = {
    'MIHEN-Guided-Example-TR': 'Düzenlenebilir 90 günlük alan örneği',
    'MIHEN-Executive-Report-TR': 'Yönetici özeti — gerçek kayıtlarla dönem görünümü',
    'MIHEN-Report-Trend-TR': 'Kaynak seçimi ve dönem eğilimi',
    'MIHEN-Report-Health-TR': 'Sağlık alanının ayrıntılı raporu',
    'MIHEN-Report-Comparison-TR': 'Önceki dönem ve kaynak kapsamı',
    'MIHEN-Executive-LargeText-TR': 'Yönetici özeti — en büyük yazı',
    'MIHEN-Prayer-Cities-TR': 'Çevrimdışı şehir ve ülke seçimi',
    'MIHEN-Template-Week-TR': 'Seçilen şablonun örnek haftası', 
    'MIHEN-Capacity-TR': 'Haftalık zaman kapasitesi',
    'MIHEN-Weekly-Focus-TR': 'Hedefe bağlı haftalık odaklar',
    'MIHEN-Routine-Run-TR': 'Rutini adım adım çalıştırma',
    'MIHEN-Nutrition-Planning-TR': 'Beslenme · plan ve gerçekleşme',
    'MIHEN-Source-Link-TR': 'Tek olay · modül ve görev bağlantısı',
    'MIHEN-Onboarding-TR': 'İlk kullanım · kısa başlangıç',
    'MIHEN-Onboarding-SmallText-TR': 'İlk kullanım · küçük yazı ölçümü',
    'MIHEN-Onboarding-LargeText-TR': 'İlk kullanım · en büyük yazı ölçümü',
    'MIHEN-Onboarding-Choices-TR': 'İlk kullanım · açık şablon seçimi',
    'MIHEN-Today-Empty-TR': 'Bugün · ilk adım',
    'MIHEN-Today-Guided-TR': 'Bugün · seçilen adımlar',
    'MIHEN-Backup-TR': 'Yedekleme · kapsam ve dışa aktarma',
    'MIHEN-Reports-Qada-TR': 'Dönem raporu · gerçek kaza hareketleri',
    'MIHEN-Report-Export-TR': 'Dönem raporu · paylaşılacak alan seçimi',
    'MIHEN-Nutrition-Quick-TR': 'Beslenme · hızlı su kaydı ve geri alma',
    'MIHEN-Help-TR': 'Yardım · anlaşılır kullanım rehberi',
    'MIHEN-Today-Accessibility-TR': 'Bugün · erişilebilirlik kontrolü',
    'MIHEN-Today-LargeText-TR': 'Bugün · küçük ekran ve büyük metin',
    'MIHEN-Today-LargeText-Task-TR': 'Bugün · büyük yazıda kaydırma sonrası özet',

    'MIHEN-Qada-TR': 'Kaza namazı takibi',
    'MIHEN-WeeklyPlan-TR': 'Haftalık planlama',
    'MIHEN-GoalSplit-TR': 'Hedef parçalama · tarih ve gün seçimi',
    'MIHEN-GoalSplit-Preview-TR': 'Hedef parçalama · günlük öneri',
    'MIHEN-Routines-TR': 'Rutin oluşturucu',
    'MIHEN-Today-Partial-TR': 'Bugün · kısmi ilerleme',
    'MIHEN-Plan-TR': 'Plan · sekiz yaşam alanı',
    'MIHEN-Calendar-TR': 'Takvim', 'MIHEN-Progress-TR': 'İlerleme',
    'MIHEN-Prayer-TR': 'İstanbul namaz vakitleri',
    'MIHEN-Nutrition-TR': 'Beslenme ve hareket',
    'MIHEN-Reports-TR': 'Dönem raporları',
    'MIHEN-ScreenTime-TR': 'Ekran Süresi · kurulum',
    'MIHEN-Khatm-TR': 'Hatim takibi', 'MIHEN-Memorization-TR': 'Ezber ve tekrar',
    'MIHEN-Dhikr-TR': 'Zikir sayacı', 'MIHEN-Fasting-TR': 'Oruç takibi',
    'MIHEN-Today-TR': 'Bugün · tamamlanan görev',
    'MIHEN-Profile-Light-EN': 'Profil · İngilizce açık tema',
    'MIHEN-Profile-Dark-EN': 'Profil · İngilizce koyu tema',
    'MIHEN-Today-Light-EN': 'Bugün · İngilizce',
}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('artifact', type=Path)
    parser.add_argument('--run', required=True)
    parser.add_argument('--source', required=True)
    parser.add_argument('--require-capture', action='append', help='Required capture name for a focused follow-up run; default requires all five module captures.')
    parser.add_argument('--scope', default='full')
    parser.add_argument('--output', type=Path, default=Path('.build-results/current-screens-20261116'))
    parser.add_argument('--review-date', default='2026-11-16')
    args = parser.parse_args()
    summaries = list(args.artifact.rglob('test-summary.json'))
    if len(summaries) != 1:
        raise ValueError('Expected one actual test result summary')
    summary = json.loads(summaries[0].read_text())
    if summary.get('failedTests') != 0 or summary.get('result') != 'Passed':
        raise ValueError('Only successful test captures may enter the gallery')
    args.output.mkdir(parents=True, exist_ok=True)
    provenance = args.output / 'provenance.json'
    previous = json.loads(provenance.read_text())['images'] if provenance.exists() else []
    entries = {Path(item['file']).stem: item for item in previous}
    manifests = list(args.artifact.rglob('attachments/manifest.json'))
    if len(manifests) != 1:
        raise ValueError('Expected one actual xcresult attachment manifest')
    manifest = manifests[0]
    captures = json.loads(manifest.read_text())
    captured_names = {a['suggestedHumanReadableName'].split('_0_')[0] for test in captures for a in test['attachments']}
    required = set(args.require_capture) if args.require_capture else REQUIRED_MODULE_CAPTURES
    if not required <= captured_names:
        raise ValueError('Missing requested module captures: ' + ', '.join(sorted(required - captured_names)))
    for test in captures:
        for attachment in test['attachments']:
            name = attachment['suggestedHumanReadableName'].split('_0_')[0]
            if name not in LABELS:
                continue
            target = args.output / (name + '.png')
            shutil.copy2(manifest.parent / attachment['exportedFileName'], target)
            entries[name] = {
                'file': target.name, 'run': args.run, 'source': args.source,
                'test': test['testIdentifier'], 'scope': args.scope,
                'capturedUTC': datetime.datetime.fromtimestamp(attachment['timestamp'], datetime.timezone.utc).isoformat(),
                'sha256': hashlib.sha256(target.read_bytes()).hexdigest(),
            }
    cards = []
    for name, label in LABELS.items():
        if name not in entries:
            continue
        entry = entries[name]
        image = (args.output / entry['file']).read_bytes()
        if hashlib.sha256(image).hexdigest() != entry['sha256']:
            raise ValueError('Screenshot hash mismatch: ' + name)
        source = base64.b64encode(image).decode()
        caption = html.escape(label)
        captured = html.escape(entry['capturedUTC'][:10])
        cards.append(f'<article><h2>{caption}</h2><button class="shot" aria-label="{caption} ekranını büyüt"><img loading="lazy" src="data:image/png;base64,{source}" alt="{caption}"></button><p>{captured} · gerçek simülatör görüntüsü · koşu {html.escape(entry["run"])}</p></article>')
    page = '''<!doctype html><html lang="tr"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>MİHEN · Güncel uygulama ekranları</title><style>
*{box-sizing:border-box}body{margin:0;background:#f7f5ef;color:#0b2244;font:16px system-ui,-apple-system,sans-serif}header,main{max-width:1300px;margin:auto;padding:28px}header p{max-width:950px;line-height:1.65}h1{font-size:32px;margin:0 0 12px}.notice{background:#fff;padding:18px;border-radius:16px}main{display:grid;grid-template-columns:repeat(auto-fit,minmax(250px,1fr));gap:24px;padding-top:0}article{background:white;border-radius:20px;padding:16px}h2{font-size:17px;min-height:38px;margin:0 0 14px}article p{font-size:12px;color:#596775;line-height:1.5}.shot{background:none;border:0;padding:0;width:100%;cursor:zoom-in}.shot img{width:100%;height:auto;display:block;border-radius:14px}dialog{border:0;border-radius:18px;background:#fff;padding:16px;max-width:95vw;max-height:95vh}dialog::backdrop{background:#000b}dialog img{max-width:85vw;max-height:80vh;object-fit:contain;display:block;margin:auto}dialog button{border:0;background:#0b2244;color:white;border-radius:10px;padding:10px 16px;margin-bottom:12px;cursor:pointer}</style><header><h1>MİHEN · Güncel uygulama ekranları</h1>'''
    page += f'<p>{html.escape(args.review_date)} incelemesi · {len(cards)} özgün ekran görüntüsü. Her ekran gerçek XCUITest koşusunda çalışan SwiftUI uygulamasından alınmıştır. Görsellerin içeriği düzenlenmemiştir. Çekim tarihi her kartın altında gösterilir. Büyütmek için ekrana dokunun.</p>'
    page += '<p class="notice">Görev, rutin, kaza kaydı ve hedef ayrı test oturumunda arayüz üzerinden oluşturulmuştur; kişisel geçmişiniz değildir. Kartlardaki kaynak koşu ve çekim tarihleri korunur. Hedef dağıtım görüntüsü onaydan önceki öneriyi gösterir. Ekran Süresi görüntüsü Apple izni ve App Group kurulumu bekleyen gerçek durumdur. Widget ana ekranı, biyometri ve gerçek Sağlık verisi bu galeride taklit edilmez.</p></header><main>'
    page += ''.join(cards)
    page += '''</main><dialog id="viewer"><button id="close">Kapat</button><img alt="Büyütülmüş uygulama ekranı"></dialog><script>const viewer=document.querySelector('#viewer');document.querySelectorAll('.shot').forEach(button=>button.addEventListener('click',()=>{const image=button.querySelector('img');viewer.querySelector('img').src=image.src;viewer.querySelector('img').alt=image.alt;viewer.showModal()}));document.querySelector('#close').addEventListener('click',()=>viewer.close());viewer.addEventListener('click',event=>{if(event.target===viewer)viewer.close()});</script></html>'''
    provenance.write_text(json.dumps({'reviewedOn': args.review_date, 'images': list(entries.values())}, ensure_ascii=False, indent=2) + '\n')
    (args.output / 'index.html').write_text(page)
    stamp=args.review_date.replace('-', '')
    Path(f'.build-results/MIHEN_Current_Screens_{stamp}.html').write_text(page)
    with zipfile.ZipFile(f'.build-results/MIHEN_Current_Screens_{stamp}.zip', 'w', zipfile.ZIP_DEFLATED) as archive:
        for item in sorted(args.output.iterdir()):
            if item.is_file():
                archive.write(item, item.name)
    print(f'Gallery built: {len(cards)} original screenshots; original PNG bytes preserved.')


if __name__ == '__main__':
    main()
