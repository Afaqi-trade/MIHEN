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
if [[ "${MIHEN_TEST_SCOPE:-full}" == "accessibility" ]]; then
  MIHEN_A11Y_RUNTIME="$(python3 - <<'RUNTIME'
import json
x=json.load(open('.build-results/devices.json'))
print(next(k for k,v in x['devices'].items() if 'iOS' in k and any(d.get('isAvailable') for d in v)))
RUNTIME
)"
  xcrun simctl shutdown all
  MIHEN_SIMULATOR_ID="$(xcrun simctl create 'MIHEN Small Accessibility' com.apple.CoreSimulator.SimDeviceType.iPhone-SE-3rd-generation "$MIHEN_A11Y_RUNTIME")"
  xcrun simctl boot "$MIHEN_SIMULATOR_ID"
  xcrun simctl bootstatus "$MIHEN_SIMULATOR_ID" -b
  xcrun simctl ui "$MIHEN_SIMULATOR_ID" content_size accessibility-extra-extra-extra-large
  xcrun simctl list devices available -j > .build-results/accessibility-devices.json
fi
xcodebuild -project MIHEN.xcodeproj -scheme MIHEN -configuration Debug -destination 'generic/platform=iOS Simulator' -derivedDataPath .build-results/DerivedData CODE_SIGNING_ALLOWED=NO build
typeset -a MIHEN_TEST_ARGUMENTS=()
case "${MIHEN_TEST_SCOPE:-full}" in
  full) ;;
  roadmap) MIHEN_TEST_ARGUMENTS=(-only-testing:MIHENTests -only-testing:MIHENUITests/MIHENUITests/testModuleSourceConnectionRestoresManualProgress -only-testing:MIHENUITests/MIHENUITests/testRoadmapCapacityRoutineAndNutrition -only-testing:MIHENUITests/MIHENUITests/testExecutiveReportAndOfflineCityGallery -only-testing:MIHENUITests/MIHENUITests/testExecutiveReportLargeTypeNavigation -only-testing:MIHENUITests/MIHENUITests/testNutritionPersistsManualCalories -only-testing:MIHENUITests/MIHENUITests/testBackupInformationAndNutritionQuickWater -only-testing:MIHENUITests/MIHENUITests/testNewModuleScreensGallery -only-testing:MIHENUITests/MIHENUITests/testReportsNavigation) ;;
  accessibility) MIHEN_TEST_ARGUMENTS=(-only-testing:MIHENTests -only-testing:MIHENUITests/MIHENUITests/testAccessibilityDescriptionsAndDynamicTypeOnFirstUse -only-testing:MIHENUITests/MIHENUITests/testExecutiveReportLargeTypeNavigation) ;;
  screen-time) MIHEN_TEST_ARGUMENTS=(-only-testing:MIHENTests -only-testing:MIHENUITests/MIHENUITests/testScreenTimeSetupDoesNotRequestPermissionOnEntry) ;;
  module-gallery) MIHEN_TEST_ARGUMENTS=(-only-testing:MIHENTests -only-testing:MIHENUITests/MIHENUITests/testNewModuleScreensGallery -only-testing:MIHENUITests/MIHENUITests/testMemorizationAndNextReview -only-testing:MIHENUITests/MIHENUITests/testDhikrCounterIncreaseDecrease -only-testing:MIHENUITests/MIHENUITests/testKhatmCalendarProgressAndMainTabs) ;;
  daily-flows) MIHEN_TEST_ARGUMENTS=(-only-testing:MIHENTests -only-testing:MIHENUITests/MIHENUITests/testGuidedAreaExampleRequiresExplicitConfirmation -only-testing:MIHENUITests/MIHENUITests/testOnboardingLinkedGoalPartialCompletionAndPersistence -only-testing:MIHENUITests/MIHENUITests/testLanguageAndLightDarkThemes -only-testing:MIHENUITests/MIHENUITests/testFastingPlannedAndCompletedRemainDistinct -only-testing:MIHENUITests/MIHENUITests/testGuidedOnboardingExplicitTemplatesAndQuickTaskUndo) ;;
  daily-fasting) MIHEN_TEST_ARGUMENTS=(-only-testing:MIHENTests -only-testing:MIHENUITests/MIHENUITests/testFastingPlannedAndCompletedRemainDistinct) ;;
  daily-guided) MIHEN_TEST_ARGUMENTS=(-only-testing:MIHENTests -only-testing:MIHENUITests/MIHENUITests/testGuidedOnboardingExplicitTemplatesAndQuickTaskUndo -only-testing:MIHENUITests/MIHENUITests/testOnboardingStartsWithOneStepWithoutExamples) ;;
  research) MIHEN_TEST_ARGUMENTS=(-only-testing:MIHENTests -only-testing:MIHENUITests/MIHENUITests/testOnboardingStartsWithOneStepWithoutExamples -only-testing:MIHENUITests/MIHENUITests/testGuidedOnboardingExplicitTemplatesAndQuickTaskUndo -only-testing:MIHENUITests/MIHENUITests/testRoadmapCapacityRoutineAndNutrition -only-testing:MIHENUITests/MIHENUITests/testNutritionPersistsManualCalories -only-testing:MIHENUITests/MIHENUITests/testBackupInformationAndNutritionQuickWater -only-testing:MIHENUITests/MIHENUITests/testOfflinePrayerTimes -only-testing:MIHENUITests/MIHENUITests/testNewModuleScreensGallery -only-testing:MIHENUITests/MIHENUITests/testExecutiveReportAndOfflineCityGallery -only-testing:MIHENUITests/MIHENUITests/testExecutiveReportLargeTypeNavigation) ;;
  prayer) MIHEN_TEST_ARGUMENTS=(-only-testing:MIHENTests -only-testing:MIHENUITests/MIHENUITests/testOfflinePrayerTimes) ;;
  appearance) MIHEN_TEST_ARGUMENTS=(-only-testing:MIHENTests -only-testing:MIHENUITests/MIHENUITests/testLanguageAndLightDarkThemes) ;;
  *) print -u2 'Unknown MIHEN_TEST_SCOPE'; exit 2 ;;
esac
print "Test scope: ${MIHEN_TEST_SCOPE:-full}"
MIHEN_RESULT_PATH=".build-results/MIHEN-$(date +%Y%m%d-%H%M%S).xcresult"
xcodebuild -project MIHEN.xcodeproj -scheme MIHEN -configuration Debug -destination "platform=iOS Simulator,id=${MIHEN_SIMULATOR_ID}" -derivedDataPath .build-results/DerivedData -resultBundlePath "$MIHEN_RESULT_PATH" CODE_SIGNING_ALLOWED=NO "${MIHEN_TEST_ARGUMENTS[@]}" test
