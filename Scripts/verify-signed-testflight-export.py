#!/usr/bin/env python3
"""Verify a signed TestFlight IPA export without uploading it."""
import json
from pathlib import Path
import plistlib
import sys

archive, ipa, entitlements_directory = map(Path, sys.argv[1:4])
if not ipa.is_file() or ipa.stat().st_size == 0:
    raise SystemExit('signed IPA is missing')
bundles = {
    'app': (archive / 'Products/Applications/MIHEN.app', 'com.afaqitrade.mihenapp'),
    'widget': (archive / 'Products/Applications/MIHEN.app/PlugIns/MIHENWidget.appex', 'com.afaqitrade.mihenapp.widget'),
    'monitor': (archive / 'Products/Applications/MIHEN.app/PlugIns/MIHENActivityMonitor.appex', 'com.afaqitrade.mihenapp.monitor'),
}
group = 'group.com.afaqitrade.mihenapp'
for role, (bundle, expected_id) in bundles.items():
    info = plistlib.loads((bundle / 'Info.plist').read_bytes())
    if info['CFBundleIdentifier'] != expected_id:
        raise SystemExit(f'{role} archive bundle ID is not {expected_id}')
    if not (bundle / 'embedded.mobileprovision').is_file():
        raise SystemExit(f'{role} has no embedded provisioning profile')
    entitlements = plistlib.loads((entitlements_directory / f'{role}.plist').read_bytes())
    if group not in entitlements.get('com.apple.security.application-groups', []):
        raise SystemExit(f'{role} signed entitlement does not contain {group}')
    if role in {'app', 'monitor'} and entitlements.get('com.apple.developer.family-controls') is not True:
        raise SystemExit(f'{role} signed entitlement lacks Family Controls')
report = {
    'phase': 'signed-ipa-export',
    'signedArchiveVerified': True,
    'ipaExported': True,
    'uploadedToAppStoreConnect': False,
    'installableOnIPhone': False,
    'testFlightReady': False,
    'ipaBytes': ipa.stat().st_size,
    'targets': [{'target': role, 'bundleID': bundle_id} for role, (_, bundle_id) in bundles.items()],
    'remainingOwnerSteps': [
        'Wait for Apple Family Controls distribution approval for app and monitor',
        'Create the App Store Connect app record and accept applicable agreements',
        'Upload this verified IPA only with the account owner\'s explicit authorization',
        'Wait for Apple processing, then add the account owner to an internal TestFlight group',
    ],
}
Path('.build-results/signed-testflight-readiness.json').write_text(json.dumps(report, indent=2) + '\n')
print('Verified signed archive and IPA export. No upload or TestFlight invitation occurred.')
