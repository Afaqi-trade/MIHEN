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
