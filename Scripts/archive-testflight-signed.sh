#!/bin/zsh
# Produces a signed IPA artifact only. It intentionally does not upload or publish.
set -euo pipefail
cd "${0:A:h:h}"

: "${MIHEN_DISTRIBUTION_CERTIFICATE_BASE64:?missing signing certificate secret}"
: "${MIHEN_DISTRIBUTION_CERTIFICATE_PASSWORD:?missing signing certificate password secret}"
: "${MIHEN_APP_PROFILE_BASE64:?missing main app provisioning profile secret}"
: "${MIHEN_WIDGET_PROFILE_BASE64:?missing widget provisioning profile secret}"
: "${MIHEN_MONITOR_PROFILE_BASE64:?missing monitor provisioning profile secret}"

MIHEN_SIGNING_WORK="${RUNNER_TEMP:-/tmp}/mihen-testflight-signing"
umask 077
mkdir -p "$MIHEN_SIGNING_WORK" "$HOME/Library/MobileDevice/Provisioning Profiles" .build-results
python3 - "$MIHEN_SIGNING_WORK" <<'PY'
import base64, os, pathlib, sys
work = pathlib.Path(sys.argv[1])
for variable, filename in [
    ('MIHEN_DISTRIBUTION_CERTIFICATE_BASE64', 'distribution.p12'),
    ('MIHEN_APP_PROFILE_BASE64', 'app.mobileprovision'),
    ('MIHEN_WIDGET_PROFILE_BASE64', 'widget.mobileprovision'),
    ('MIHEN_MONITOR_PROFILE_BASE64', 'monitor.mobileprovision'),
]:
    try:
        data = base64.b64decode(os.environ[variable], validate=True)
    except Exception as error:
        raise SystemExit(f'{variable} is not valid base64: {error}')
    if not data:
        raise SystemExit(f'{variable} is empty')
    (work / filename).write_bytes(data)
PY

for role in app widget monitor; do
  security cms -D -i "$MIHEN_SIGNING_WORK/$role.mobileprovision" > "$MIHEN_SIGNING_WORK/$role.plist"
done
python3 - "$MIHEN_SIGNING_WORK" <<'PY'
import pathlib, plistlib, sys
work = pathlib.Path(sys.argv[1])
team = 'PY75Z73294'
group = 'group.com.afaqitrade.mihenapp'
bundles = {
    'app': 'com.afaqitrade.mihenapp',
    'widget': 'com.afaqitrade.mihenapp.widget',
    'monitor': 'com.afaqitrade.mihenapp.monitor',
}
for role, bundle in bundles.items():
    profile = plistlib.loads((work / f'{role}.plist').read_bytes())
    entitlements = profile.get('Entitlements', {})
    if entitlements.get('application-identifier') != f'{team}.{bundle}':
        raise SystemExit(f'{role} profile does not belong to {bundle}')
    if group not in entitlements.get('com.apple.security.application-groups', []):
        raise SystemExit(f'{role} profile does not contain {group}')
    if role in {'app', 'monitor'} and entitlements.get('com.apple.developer.family-controls') is not True:
        raise SystemExit(f'{role} profile does not contain the approved Family Controls entitlement')
    if role == 'app' and entitlements.get('com.apple.developer.healthkit') is not True:
        raise SystemExit('app profile does not contain HealthKit')
PY

MIHEN_KEYCHAIN="$MIHEN_SIGNING_WORK/mihen-signing.keychain-db"
MIHEN_KEYCHAIN_PASSWORD="$(uuidgen)$(uuidgen)"
security create-keychain -p "$MIHEN_KEYCHAIN_PASSWORD" "$MIHEN_KEYCHAIN"
security set-keychain-settings -lut 21600 "$MIHEN_KEYCHAIN"
security unlock-keychain -p "$MIHEN_KEYCHAIN_PASSWORD" "$MIHEN_KEYCHAIN"
security import "$MIHEN_SIGNING_WORK/distribution.p12" -P "$MIHEN_DISTRIBUTION_CERTIFICATE_PASSWORD" -A -t cert -f pkcs12 -k "$MIHEN_KEYCHAIN"
security set-key-partition-list -S apple-tool:,apple: -s -k "$MIHEN_KEYCHAIN_PASSWORD" "$MIHEN_KEYCHAIN"
security list-keychains -d user -s "$MIHEN_KEYCHAIN" login.keychain-db
for role in app widget monitor; do
  profile_uuid="$(/usr/libexec/PlistBuddy -c 'Print :UUID' "$MIHEN_SIGNING_WORK/$role.plist")"
  cp "$MIHEN_SIGNING_WORK/$role.mobileprovision" "$HOME/Library/MobileDevice/Provisioning Profiles/$profile_uuid.mobileprovision"
done

MIHEN_APP_PROFILE_NAME="$(/usr/libexec/PlistBuddy -c 'Print :Name' "$MIHEN_SIGNING_WORK/app.plist")"
MIHEN_WIDGET_PROFILE_NAME="$(/usr/libexec/PlistBuddy -c 'Print :Name' "$MIHEN_SIGNING_WORK/widget.plist")"
MIHEN_MONITOR_PROFILE_NAME="$(/usr/libexec/PlistBuddy -c 'Print :Name' "$MIHEN_SIGNING_WORK/monitor.plist")"
MIHEN_ARCHIVE="$PWD/.build-results/MIHEN-Signed-Release.xcarchive"
MIHEN_EXPORT="$PWD/.build-results/TestFlightExport"
xcodebuild -project MIHEN.xcodeproj -scheme MIHEN -configuration Release \
  -destination 'generic/platform=iOS' \
  -derivedDataPath .build-results/TestFlightSignedDerivedData \
  -archivePath "$MIHEN_ARCHIVE" \
  CODE_SIGN_STYLE=Manual \
  CODE_SIGN_IDENTITY="Apple Distribution" \
  MIHEN_APP_PROFILE_NAME="$MIHEN_APP_PROFILE_NAME" \
  MIHEN_WIDGET_PROFILE_NAME="$MIHEN_WIDGET_PROFILE_NAME" \
  MIHEN_MONITOR_PROFILE_NAME="$MIHEN_MONITOR_PROFILE_NAME" archive
python3 - "$MIHEN_SIGNING_WORK/export-options.plist" "$MIHEN_APP_PROFILE_NAME" "$MIHEN_WIDGET_PROFILE_NAME" "$MIHEN_MONITOR_PROFILE_NAME" <<'PY'
import pathlib, plistlib, sys
path = pathlib.Path(sys.argv[1])
app, widget, monitor = sys.argv[2:]
plistlib.dump({
    'method': 'app-store-connect',
    'signingStyle': 'manual',
    'teamID': 'PY75Z73294',
    'provisioningProfiles': {
        'com.afaqitrade.mihenapp': app,
        'com.afaqitrade.mihenapp.widget': widget,
        'com.afaqitrade.mihenapp.monitor': monitor,
    },
    'uploadSymbols': False,
}, path.open('wb'))
PY
xcodebuild -exportArchive -archivePath "$MIHEN_ARCHIVE" -exportPath "$MIHEN_EXPORT" -exportOptionsPlist "$MIHEN_SIGNING_WORK/export-options.plist"
MIHEN_IPA="$(find "$MIHEN_EXPORT" -maxdepth 1 -type f -name '*.ipa' -print -quit)"
[[ -n "$MIHEN_IPA" && -s "$MIHEN_IPA" ]]
for target in "$MIHEN_ARCHIVE/Products/Applications/MIHEN.app" "$MIHEN_ARCHIVE/Products/Applications/MIHEN.app/PlugIns/MIHENWidget.appex" "$MIHEN_ARCHIVE/Products/Applications/MIHEN.app/PlugIns/MIHENActivityMonitor.appex"; do
  codesign --verify --deep --strict --verbose=2 "$target"
done
mkdir -p .build-results/signed-entitlements
codesign -d --entitlements :- "$MIHEN_ARCHIVE/Products/Applications/MIHEN.app" 2>/dev/null > .build-results/signed-entitlements/app.plist
codesign -d --entitlements :- "$MIHEN_ARCHIVE/Products/Applications/MIHEN.app/PlugIns/MIHENWidget.appex" 2>/dev/null > .build-results/signed-entitlements/widget.plist
codesign -d --entitlements :- "$MIHEN_ARCHIVE/Products/Applications/MIHEN.app/PlugIns/MIHENActivityMonitor.appex" 2>/dev/null > .build-results/signed-entitlements/monitor.plist
python3 Scripts/verify-signed-testflight-export.py "$MIHEN_ARCHIVE" "$MIHEN_IPA" .build-results/signed-entitlements
