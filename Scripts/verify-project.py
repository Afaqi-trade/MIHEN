#!/usr/bin/env python3
"""Structural checks; deliberately does not claim SwiftUI typechecking or an iOS build."""
import json, pathlib, plistlib, subprocess, xml.etree.ElementTree as ET
root=pathlib.Path(__file__).resolve().parents[1]
raw=subprocess.check_output(['plutil','-convert','json','-o','-',str(root/'MIHEN.xcodeproj/project.pbxproj')])
project=json.loads(raw)
objects=project['objects']
for obj in objects.values():
    if obj['isa']=='PBXFileReference' and obj.get('sourceTree')=='<group>':
        assert (root/obj['path']).exists(),obj['path']
for path in list(root.glob('MIHEN/Resources/*.plist'))+list(root.glob('MIHEN/Resources/*.entitlements'))+list(root.glob('MIHENWidget/*.plist'))+list(root.glob('MIHENWidget/*.entitlements'))+list(root.glob('MIHENActivityMonitor/*.plist'))+list(root.glob('MIHENActivityMonitor/*.entitlements'))+list(root.rglob('*.xcprivacy')):
    with path.open('rb') as f:plistlib.load(f)
for path in root.glob('MIHEN/Assets.xcassets/*/Contents.json'):
    manifest=json.loads(path.read_text())
    for image in manifest.get('images',[]):
        if 'filename' in image:assert (path.parent/image['filename']).exists()
for path in list(root.glob('MIHEN.xcodeproj/xcshareddata/xcschemes/*'))+list(root.glob('MIHEN/Resources/*.storyboard')):ET.parse(path)
catalog=json.loads((root/'MIHEN/Localization/Localizable.xcstrings').read_text())
assert all(set(v['localizations'])=={'tr','en'} for v in catalog['strings'].values())
subprocess.run(['swiftc','-frontend','-parse']+[str(p) for p in root.glob('MIHEN/**/*.swift')]+[str(p) for p in root.glob('Core/*.swift')]+[str(p) for p in root.glob('ScreenTimeShared/*.swift')]+[str(p) for p in root.glob('MIHENActivityMonitor/*.swift')],check=True)
subprocess.run(['swiftc','-frontend','-parse',str(root/'MIHENWidget/MIHENWidget.swift')],check=True)
print(f'Structure verified: {len(catalog["strings"])} bilingual keys, all target references, plist/XML/assets, Swift syntax. iOS typechecking NOT performed.')

# A monitor that is not embedded cannot enforce limits when the app is closed.
monitor_info=plistlib.loads((root/'MIHENActivityMonitor/Info.plist').read_bytes())
assert monitor_info['NSExtension']['NSExtensionPointIdentifier']=='com.apple.deviceactivity.monitor-extension'
for name in ['MIHEN/Resources/MIHEN.entitlements','MIHENActivityMonitor/MIHENActivityMonitor.entitlements']:
    entitlement=plistlib.loads((root/name).read_bytes())
    assert entitlement['com.apple.developer.family-controls'] is True
    assert entitlement['com.apple.security.application-groups']==['$(MIHEN_APP_GROUP)']
monitor_products={key for key,value in objects.items() if value['isa']=='PBXFileReference' and value.get('path')=='MIHENActivityMonitor.appex'}
monitor_builds={key for key,value in objects.items() if value['isa']=='PBXBuildFile' and value.get('fileRef') in monitor_products}
assert any(value['isa']=='PBXCopyFilesBuildPhase' and monitor_builds.intersection(value.get('files',[])) for value in objects.values()),'Monitor extension must be embedded'

expected_core_tests='// Generated from Tests/MIHENCoreTests.\n'+'\n'.join(p.read_text().replace('@testable import MIHENCore','@testable import MIHEN') for p in sorted((root/'Tests/MIHENCoreTests').glob('*.swift')))
assert (root/'MIHENTests/CoreScenarios.swift').read_text()==expected_core_tests,'Generated iOS test scenarios are stale; run generate_project.py'
