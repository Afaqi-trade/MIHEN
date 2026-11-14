#!/usr/bin/env python3
"""Export actual xcresult metadata and UI attachments, even when tests fail."""
from pathlib import Path
import subprocess,json
results=sorted(Path('.build-results').glob('*.xcresult'))
if not results:
    print('No xcresult: build may have failed before testing.')
    raise SystemExit(0)
for result in results:
    summary=subprocess.check_output(['xcrun','xcresulttool','get','test-results','summary','--path',str(result)])
    Path('.build-results/test-summary.json').write_bytes(summary)
    subprocess.run(['xcrun','xcresulttool','export','attachments','--path',str(result),'--output-path','.build-results/attachments'],check=True)
    print(summary.decode())
