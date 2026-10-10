#!/bin/bash
set -eu
ROOT="$(cd "$(dirname "$0")" && pwd)"
SUPPORT="${KOF_SUPPORT_DIR:-$HOME/Library/Application Support/KOF10Mac}"
export WINEPREFIX="$SUPPORT/Prefix"
export WINEDEBUG="${KOF_DEBUG:--all,err+all}"
export LANG=zh_CN.UTF-8
export LC_ALL=zh_CN.UTF-8
export MVK_CONFIG_LOG_LEVEL=0
export WINEDLLOVERRIDES='ddraw=n,b;mscoree,mshtml=;winemenubuilder.exe='
mkdir -p "$SUPPORT" "$HOME/Library/Logs/KOF10Mac"
exec >> "$HOME/Library/Logs/KOF10Mac/game.log" 2>&1
printf '\n--- %s ---\n' "$(date)"
printf 'preparing\n' > "$SUPPORT/run.state"
if ! /usr/bin/arch -x86_64 /usr/bin/true; then exit 10; fi
if [ -x "$ROOT/wine/bin/wine" ]; then
  RUNTIME_ROOT="$ROOT"
else
  /bin/bash "$ROOT/install-runtime.sh"
  RUNTIME_ROOT="$SUPPORT/Runtime/11.0_1"
fi
export PATH="$RUNTIME_ROOT/wine/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export WINESERVER="$RUNTIME_ROOT/wine/bin/wineserver"
export WINEDLLPATH="$RUNTIME_ROOT/wine/lib/wine"
export WINELOADER="$RUNTIME_ROOT/GameRuntime.app/Contents/MacOS/wine"
WINE="$RUNTIME_ROOT/wine/bin/wine"
SERVER="$RUNTIME_ROOT/wine/bin/wineserver"
trap '"$SERVER" -k >/dev/null 2>&1 || true; "$SERVER" -w >/dev/null 2>&1 || true; exit 0' TERM INT HUP
if [ ! -f "$SUPPORT/.ready-v1" ]; then
  "$WINE" wineboot -u
  "$SERVER" -k
  "$SERVER" -w
  if [ ! -d "$WINEPREFIX/drive_c/KOF" ]; then
    /usr/bin/ditto "$ROOT/Game" "$WINEPREFIX/drive_c/KOF"
  fi
  "$WINE" regedit /S "$ROOT/mac-settings.reg"
  "$SERVER" -k
  "$SERVER" -w
  touch "$SUPPORT/.ready-v1"
fi
if [ ! -f "$SUPPORT/.compat-v2" ]; then
  for FILE in game.exe ddraw.dll ddraw.ini mfc42.dll msvcp60.dll msvcirt.dll; do
    /bin/cp "$ROOT/Game/$FILE" "$WINEPREFIX/drive_c/KOF/$FILE"
  done
  touch "$SUPPORT/.compat-v2"
fi
# Install only the live-resize display component, preserving game data/settings.
if [ ! -f "$SUPPORT/.live-resize-v3" ]; then
  /bin/cp "$ROOT/Game/ddraw.dll" "$WINEPREFIX/drive_c/KOF/ddraw.dll"
  if [ ! -f "$WINEPREFIX/drive_c/KOF/ddraw.ini" ]; then
    /bin/cp "$ROOT/Game/ddraw.ini" "$WINEPREFIX/drive_c/KOF/ddraw.ini"
  fi
  touch "$SUPPORT/.live-resize-v3"
fi
# Keep DirectInput devices under Wine control; display hooks can clear joystick state.
if [ ! -f "$SUPPORT/.controller-input-v4" ]; then
  INPUT_CONFIG="$WINEPREFIX/drive_c/KOF/ddraw.ini"
  /usr/bin/awk '
    BEGIN { in_ddraw=0; written=0 }
    /^\[ddraw\]/ { in_ddraw=1; print; print "no_dinput_hook=true"; written=1; next }
    /^\[/ { in_ddraw=0 }
    in_ddraw && /^[[:space:]]*no_dinput_hook[[:space:]]*=/ { next }
    { print }
    END { if (!written) { print "[ddraw]"; print "no_dinput_hook=true" } }
  ' "$INPUT_CONFIG" > "$INPUT_CONFIG.tmp"
  /bin/mv "$INPUT_CONFIG.tmp" "$INPUT_CONFIG"
  touch "$SUPPORT/.controller-input-v4"
fi
cd "$WINEPREFIX/drive_c/KOF"
printf 'ready\n' > "$SUPPORT/run.state"
WINELOADERNOEXEC=1 "$WINELOADER" 'C:\KOF\game.exe' &
GAME_PID=$!
set +e
wait "$GAME_PID"
GAME_STATUS=$?
set -e
printf "Game exit status: %s\n" "$GAME_STATUS"
"$SERVER" -k >/dev/null 2>&1 || true
"$SERVER" -w >/dev/null 2>&1 || true
exit "$GAME_STATUS"
