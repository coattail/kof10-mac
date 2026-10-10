#!/usr/bin/env python3
"""Create a download archive and checksums without publishing anything."""
import argparse
import hashlib
import json
import plistlib
import subprocess
import zipfile
from pathlib import Path

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('app',type=Path)
p.add_argument('--output-dir',type=Path,default=Path('dist'))
a=p.parse_args();app=a.app.resolve();out=a.output_dir.resolve()
if not (app/'Contents/Info.plist').is_file():p.error('Not an app bundle')
subprocess.run(['codesign','--verify','--deep','--strict',str(app)],check=True)
info=plistlib.loads((app/'Contents/Info.plist').read_bytes())
if info.get('LSMinimumSystemVersion')!='11.0':p.error('Unexpected macOS deployment target')
if 'KOFSupportDirectoryName' in info or info.get('CFBundleIdentifier') != 'local.kof10.mac':p.error('Restore release bundle identity before packaging')
for f in app.rglob('*'):
 if f.is_file() and (f.suffix.lower() in ['.log','.bin'] or f.name in ['user.reg','system.reg','userdef.reg','.DS_Store']):
  p.error(f'Private/debug data present: {f.relative_to(app)}')
out.mkdir(parents=True,exist_ok=True)
archive=out/'KOF10Mac-AppleSilicon.zip'
if archive.exists():p.error('Archive already exists')
subprocess.run(['/usr/bin/ditto','-c','-k','--sequesterRsrc','--keepParent',str(app),str(archive)],check=True)
# Visible help remains available even if macOS blocks the first app launch.
help_file=Path(__file__).resolve().parents[1]/'docs/打不开时看这里.txt'
with zipfile.ZipFile(archive,'a',compression=zipfile.ZIP_DEFLATED) as z:
 z.write(help_file,help_file.name)
sha=hashlib.sha256(archive.read_bytes()).hexdigest()
(out/'SHA256SUMS').write_text(f'{sha}  {archive.name}\n')
files=[]
for f in sorted(app.rglob('*')):
 if f.is_file() and not f.is_symlink():
  files.append({'path':str(f.relative_to(app)),'bytes':f.stat().st_size,'sha256':hashlib.sha256(f.read_bytes()).hexdigest()})
(out/'bundle-manifest.json').write_text(json.dumps({'archive':archive.name,'sha256':sha,'files':files},ensure_ascii=False,indent=2)+'\n')
print(f'{archive}\nSHA256 {sha}')
