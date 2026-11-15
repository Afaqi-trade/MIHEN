#!/bin/zsh
# Technical readiness only. Does not sign, install, upload or publish an app.
set -euo pipefail
cd "${0:A:h:h}"
mkdir -p .build-results
xcodebuild -version | tee .build-results/testflight-toolchain.txt
python3 Scripts/verify-project.py
MIHEN_PREPARATION_ARCHIVE="$PWD/.build-results/MIHEN-Unsigned-Release.xcarchive"
xcodebuild -project MIHEN.xcodeproj -scheme MIHEN -configuration Release \
  -destination 'generic/platform=iOS' \
  -derivedDataPath .build-results/TestFlightDerivedData \
  -archivePath "$MIHEN_PREPARATION_ARCHIVE" \
  CODE_SIGNING_ALLOWED=NO archive
python3 Scripts/testflight-readiness.py "$MIHEN_PREPARATION_ARCHIVE"
