#!/bin/zsh
set -euo pipefail
cd "${0:A:h:h}"
mkdir -p .build-results
xcodebuild -version
xcrun simctl list devices available -j > .build-results/devices.json
MIHEN_SIMULATOR_ID="${MIHEN_SIMULATOR_ID:-$(python3 - <<'PY'
import json
x=json.load(open('.build-results/devices.json'))
phones=[d for devices in x['devices'].values() for d in devices if d.get('isAvailable') and 'iPhone' in d['name']]
phones.sort(key=lambda d:d['state']!='Booted')
if not phones:raise SystemExit('No iPhone runtime installed. Install one in Xcode Settings > Components.')
print(phones[0]['udid'])
PY
)}"
xcodebuild -project MIHEN.xcodeproj -scheme MIHEN -configuration Debug -destination 'generic/platform=iOS Simulator' -derivedDataPath .build-results/DerivedData CODE_SIGNING_ALLOWED=NO build
xcodebuild -project MIHEN.xcodeproj -scheme MIHEN -configuration Debug -destination "platform=iOS Simulator,id=${MIHEN_SIMULATOR_ID}" -derivedDataPath .build-results/DerivedData -resultBundlePath ".build-results/MIHEN-$(date +%Y%m%d-%H%M%S).xcresult" CODE_SIGNING_ALLOWED=NO test
