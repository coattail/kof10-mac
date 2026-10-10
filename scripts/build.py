#!/usr/bin/env python3
"""Build a personal macOS bundle from separately supplied game/runtime files."""
import argparse
import hashlib
import json
import plistlib
import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def run(*args):
    subprocess.run([str(x) for x in args], check=True)

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--game-dir', type=Path, required=True, help='Folder containing a compatible game.exe, ROMS and legally obtained dependencies')
    p.add_argument('--wine-dir', type=Path, help='Optional Wine bundle runtime directory for a personal offline build')
    p.add_argument('--download-runtime', action='store_true', help='Fetch upstream Wine on first launch; required for public release')
    p.add_argument('--ddraw-dll', type=Path, default=ROOT/'third_party/cnc-ddraw/ddraw.dll')
    p.add_argument('--output', type=Path, default=ROOT/'dist/拳皇十周年 Mac.app')
    a = p.parse_args()
    a.game_dir = a.game_dir.resolve(); a.output = a.output.resolve()
    if a.wine_dir: a.wine_dir = a.wine_dir.resolve()
    if bool(a.wine_dir) == a.download_runtime: p.error("Choose exactly one of --wine-dir or --download-runtime")
    for f in ['game.exe', 'mfc42.dll', 'msvcp60.dll', 'msvcirt.dll']:
        if not (a.game_dir/f).is_file():
            p.error(f'Missing game dependency: {a.game_dir/f}')
    if not (a.game_dir/'ROMS').is_dir() or not list((a.game_dir/'ROMS').glob('*.zip')):
        p.error('ROMS must contain your game ZIP files')
    if not a.ddraw_dll.is_file():
        p.error('Build the MIT renderer first: make -C third_party/cnc-ddraw')
    if a.wine_dir and not (a.wine_dir/'bin/wine').is_file():
        p.error('Wine runtime directory is invalid')
    exe_hash = hashlib.sha256((a.game_dir/'game.exe').read_bytes()).hexdigest()
    if exe_hash == 'a135810459f94eb6a246c35e911a20e33f6357424de78d0ce6f687da7ec58082':
        p.error('This is the incompatible protected Windows executable. Supply a compatible executable; see docs/COMPATIBILITY.md.')
    if a.output.exists():
        p.error('Output already exists; choose a new --output path')
    if a.game_dir == a.output or a.output in a.game_dir.parents or a.game_dir in a.output.parents:
        p.error('Game input and bundle output must be separate directories')
    contents=a.output/'Contents'; resources=contents/'Resources'
    (contents/'MacOS').mkdir(parents=True)
    shutil.copytree(a.game_dir,resources/'Game',ignore=shutil.ignore_patterns('*.log','.DS_Store','close-game.exe'))
    if a.wine_dir: shutil.copytree(a.wine_dir,resources/'wine',symlinks=True)
    shutil.copy2(a.ddraw_dll,resources/'Game/ddraw.dll')
    shutil.copy2(ROOT/'config/ddraw.ini',resources/'Game/ddraw.ini')
    shutil.copy2(ROOT/'config/mac-settings.reg',resources/'mac-settings.reg')
    shutil.copy2(ROOT/'src/launch.sh',resources/'launch.sh')
    (resources/'launch.sh').chmod(0o755)
    shutil.copy2(ROOT/'src/install-runtime.sh',resources/'install-runtime.sh')
    shutil.copy2(ROOT/'config/Runtime-Info.plist',resources/'Runtime-Info.plist')
    info=plistlib.loads((ROOT/'config/Info.plist').read_bytes())
    info['CFBundleShortVersionString']='1.0.4'; info['CFBundleVersion']='6'
    (contents/'Info.plist').write_bytes(plistlib.dumps(info))
    runtime=resources/'GameRuntime.app/Contents'
    (runtime/'MacOS').mkdir(parents=True)
    if a.wine_dir:
        unix=resources/'wine/lib/wine/x86_64-unix'
        raw=unix/'wine-raw'
        if not raw.exists():
            # Upstream runtimes have a Mach-O loader here. Keep an unmodified copy.
            if (unix/'wine').read_bytes()[:2] == b'#!':
                raise RuntimeError('Existing Wine shim has no wine-raw loader')
            shutil.copy2(unix/'wine',raw)
        shutil.copy2(raw,runtime/'MacOS/wine')
        (runtime/'MacOS/wine').chmod(0o755)
        (runtime/'MacOS/ntdll.so').symlink_to('../../../wine/lib/wine/x86_64-unix/ntdll.so')
        shim='''#!/bin/bash
    DIR="$(cd "$(dirname "$0")" && pwd)"
    case "$*" in
      *[Gg][Aa][Mm][Ee].[Ee][Xx][Ee]*) exec "$DIR/../../../../GameRuntime.app/Contents/MacOS/wine" "$@" ;;
      *) exec "$DIR/wine-raw" "$@" ;;
    esac
    '''
        (unix/'wine').write_text(shim); (unix/'wine').chmod(0o755)
    rinfo=plistlib.loads((ROOT/'config/Runtime-Info.plist').read_bytes())
    (runtime/'Info.plist').write_bytes(plistlib.dumps(rinfo))
    ico=a.game_dir/'game.ico'
    if ico.is_file():
        from PIL import Image
        icon=Image.open(ico)
        iconset=resources/'Sources/WindowsOriginal.iconset'; iconset.mkdir(parents=True)
        sizes=[('16x16',16),('16x16@2x',32),('32x32',32),('32x32@2x',64),('128x128',128),('128x128@2x',256),('256x256',256),('256x256@2x',512),('512x512',512),('512x512@2x',1024)]
        available=icon.ico.sizes()
        for label,size in sizes:
            wanted=(16,16) if size==16 and (16,16) in available else max(available,key=lambda t:t[0]*t[1])
            icon.ico.getimage(wanted).convert('RGBA').resize((size,size),Image.Resampling.NEAREST).save(iconset/f'icon_{label}.png')
        run('/usr/bin/iconutil','-c','icns',iconset,'-o',resources/'WindowsOriginal.icns')
        (runtime/'Resources').mkdir()
        shutil.copy2(resources/'WindowsOriginal.icns',runtime/'Resources/WindowsOriginal.icns')
    else:
        for target in [contents/'Info.plist',runtime/'Info.plist']:
            data=plistlib.loads(target.read_bytes());data.pop('CFBundleIconFile',None);target.write_bytes(plistlib.dumps(data))
    (resources/'Sources').mkdir(exist_ok=True)
    shutil.copy2(ROOT/'src/Launcher.swift',resources/'Sources/Launcher.swift')
    shutil.copytree(ROOT/'licenses',resources/'Licenses')
    shutil.copy2(ROOT/'LICENSE',resources/'Licenses/KOF10Mac-MIT.txt')
    shutil.copy2(ROOT/'third_party/cnc-ddraw/LICENSE',resources/'Licenses/cnc-ddraw-LICENSE.txt')
    shutil.copy2(ROOT/'docs/INSTALL.md',resources/'安装说明.md')
    source_zip=resources/'Sources/cnc-ddraw-source'
    shutil.copytree(ROOT/'third_party/cnc-ddraw',source_zip,ignore=shutil.ignore_patterns('*.o','*.dll','*.exe','.git'))
    # No shell/runtime dependency is needed to build the native entry point.
    run('xcrun','swiftc','-O','-target','arm64-apple-macosx11.0',ROOT/'src/Launcher.swift','-o',contents/'MacOS/KOFMac')
    metadata={'version':'1.0.4','game_exe_sha256':exe_hash,'ddraw_sha256':hashlib.sha256(a.ddraw_dll.read_bytes()).hexdigest(),'wine_release':'https://github.com/Gcenx/macOS_Wine_builds/releases/tag/11.0_1','target':'arm64-apple-macosx11.0','notarized':False,'runtime_mode':'download-on-first-launch' if a.download_runtime else 'bundled-personal-runtime'}
    (resources/'build-info.json').write_text(json.dumps(metadata,ensure_ascii=False,indent=2)+'\n')
    if a.download_runtime:
        shutil.rmtree(resources/'GameRuntime.app')
    run('codesign','--force','--deep','--sign','-',a.output)
    run('codesign','--verify','--deep','--strict',a.output)
    print(a.output)

if __name__=='__main__':main()
