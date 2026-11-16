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
typeset -a MIHEN_TEST_ARGUMENTS=()
case "${MIHEN_TEST_SCOPE:-full}" in
  full) ;;
  screen-time) MIHEN_TEST_ARGUMENTS=(-only-testing:MIHENTests -only-testing:MIHENUITests/MIHENUITests/testScreenTimeSetupDoesNotRequestPermissionOnEntry) ;;
  module-gallery) MIHEN_TEST_ARGUMENTS=(-only-testing:MIHENTests -only-testing:MIHENUITests/MIHENUITests/testNewModuleScreensGallery -only-testing:MIHENUITests/MIHENUITests/testMemorizationAndNextReview -only-testing:MIHENUITests/MIHENUITests/testDhikrCounterIncreaseDecrease -only-testing:MIHENUITests/MIHENUITests/testKhatmCalendarProgressAndMainTabs) ;;
  *) print -u2 'Unknown MIHEN_TEST_SCOPE'; exit 2 ;;
esac
print "Test scope: ${MIHEN_TEST_SCOPE:-full}"
MIHEN_RESULT_PATH=".build-results/MIHEN-$(date +%Y%m%d-%H%M%S).xcresult"
xcodebuild -project MIHEN.xcodeproj -scheme MIHEN -configuration Debug -destination "platform=iOS Simulator,id=${MIHEN_SIMULATOR_ID}" -derivedDataPath .build-results/DerivedData -resultBundlePath "$MIHEN_RESULT_PATH" CODE_SIGNING_ALLOWED=NO "${MIHEN_TEST_ARGUMENTS[@]}" test
