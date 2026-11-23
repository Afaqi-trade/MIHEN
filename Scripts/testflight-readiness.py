#!/usr/bin/env python3
"""Inspect a real, unsigned device archive without claiming distribution readiness."""
import argparse
import json
import os
from pathlib import Path
import plistlib
import subprocess


def inspect_archive(archive: Path) -> dict:
    app = archive / 'Products/Applications/MIHEN.app'
    targets = [('app', app, 'MIHEN'),
               ('widget', app / 'PlugIns/MIHENWidget.appex', 'MIHENWidget'),
               ('monitor', app / 'PlugIns/MIHENActivityMonitor.appex', 'MIHENActivityMonitor')]
    result = []
    versions = set()
    for kind, bundle, executable in targets:
        with (bundle / 'Info.plist').open('rb') as handle:
            info = plistlib.load(handle)
        binary = bundle / executable
        if not binary.is_file():
            raise ValueError(f'{kind}: archive executable is missing')
        architectures = subprocess.check_output(['lipo', '-archs', str(binary)], text=True).strip().split()
        if 'arm64' not in architectures:
            raise ValueError(f'{kind}: archive has no iPhone arm64 executable')
        if info.get('DTPlatformName', '').lower() != 'iphoneos':
            raise ValueError(f'{kind}: archive is not built for a physical iPhone')
        if not (bundle / 'PrivacyInfo.xcprivacy').is_file():
            raise ValueError(f'{kind}: privacy manifest is missing')
        versions.add((info['CFBundleShortVersionString'], info['CFBundleVersion']))
        result.append({'target': kind, 'bundleID': info['CFBundleIdentifier'], 'architectures': architectures})
    if len(versions) != 1:
        raise ValueError('App and extensions must have matching versions/build numbers')
    app_id = result[0]['bundleID']
    if result[1]['bundleID'] != app_id + '.widget' or result[2]['bundleID'] != app_id + '.monitor':
        raise ValueError('Extension bundle IDs do not match the app')
    monitor = plistlib.loads((targets[2][1] / 'Info.plist').read_bytes())
    if monitor['NSExtension']['NSExtensionPointIdentifier'] != 'com.apple.deviceactivity.monitor-extension':
        raise ValueError('DeviceActivity extension point is incorrect')
    version, build = next(iter(versions))
    return {
        'phase': 'unsigned-device-release-archive',
        'archiveVerified': True,
        'signedArchiveVerified': False,
        'uploadedToAppStoreConnect': False,
        'installableOnIPhone': False,
        'testFlightReady': False,
        'version': version, 'build': build, 'targets': result,
        'remainingOwnerSteps': [
            'Confirm App Group assignment and capabilities on app, widget and monitor identifiers',
            'Obtain Family Controls distribution permission for app and monitor',
            'Configure distribution signing and provisioning for all three targets',
            'Create App Store Connect app record and authorize the upload method',
            'Produce and validate a signed archive, upload, wait for Apple processing',
            'Create an internal TestFlight group and add the account owner as tester'
        ]
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('archive', type=Path)
    args = parser.parse_args()
    report = inspect_archive(args.archive)
    destination = Path('.build-results/testflight-readiness.json')
    destination.parent.mkdir(exist_ok=True)
    destination.write_text(json.dumps(report, indent=2) + '\n')
    summary = ('## TestFlight technical preparation\n\n'
               'Unsigned iPhone Release archive verified for app, widget and monitor.\n\n'
               '**No signed distribution, upload, invitation or installable build was produced.**\n\n'
               'Capability approval, signing and upload remain owner steps.\n')
    if os.environ.get('GITHUB_STEP_SUMMARY'):
        with open(os.environ['GITHUB_STEP_SUMMARY'], 'a') as handle:
            handle.write(summary)
    print('Verified unsigned iPhone Release archive. TestFlight upload has NOT occurred.')


if __name__ == '__main__':
    main()
