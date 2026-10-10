#!/bin/bash
# Fetch the unmodified upstream distribution for the local user's runtime cache.
set -eu
ROOT="$(cd "$(dirname "$0")" && pwd)"
SUPPORT="${KOF_SUPPORT_DIR:-$HOME/Library/Application Support/KOF10Mac}"
CACHE="$SUPPORT/Runtime/11.0_1"
URL='https://github.com/Gcenx/macOS_Wine_builds/releases/download/11.0_1/wine-stable-11.0_1-osx64.tar.xz'
SHA='b50dc50ec7f41d58b115a6b685d4d1315ba3c797bd3aa0f49213f2703cb82388'
if [ -f "$CACHE/.complete" ]; then exit 0; fi
mkdir -p "$SUPPORT/Downloads" "$SUPPORT/Runtime"
printf 'downloading\n' > "$SUPPORT/run.state"
ARCHIVE="$SUPPORT/Downloads/wine-stable-11.0_1-osx64.tar.xz"
if [ ! -f "$ARCHIVE" ] || [ "$(/usr/bin/shasum -a 256 "$ARCHIVE" | /usr/bin/awk '{print $1}')" != "$SHA" ]; then
  if ! /usr/bin/curl --fail --location --retry 2 --connect-timeout 20 --max-time 1200 "$URL" --output "$ARCHIVE.part"; then exit 20; fi
  ACTUAL="$(/usr/bin/shasum -a 256 "$ARCHIVE.part" | /usr/bin/awk '{print $1}')"
  if [ "$ACTUAL" != "$SHA" ]; then printf 'Runtime checksum mismatch\n'; exit 21; fi
  /bin/mv "$ARCHIVE.part" "$ARCHIVE"
fi
printf 'preparing\n' > "$SUPPORT/run.state"
STAGING="$SUPPORT/Runtime/.install-$$"
mkdir -p "$STAGING/unpack"
trap 'rm -rf "$STAGING"' EXIT
/usr/bin/tar -xf "$ARCHIVE" -C "$STAGING/unpack"
UPSTREAM="$STAGING/unpack/Wine Stable.app/Contents/Resources/wine"
if [ ! -x "$UPSTREAM/bin/wine" ]; then printf 'Unexpected upstream runtime layout\n'; exit 22; fi
mkdir -p "$STAGING/ready"
/bin/mv "$UPSTREAM" "$STAGING/ready/wine"
UNIX="$STAGING/ready/wine/lib/wine/x86_64-unix"
RUNTIME="$STAGING/ready/GameRuntime.app/Contents"
mkdir -p "$RUNTIME/MacOS" "$RUNTIME/Resources"
/bin/cp "$ROOT/Runtime-Info.plist" "$RUNTIME/Info.plist"
/bin/cp "$UNIX/wine" "$UNIX/wine-raw"
/bin/cp "$UNIX/wine-raw" "$RUNTIME/MacOS/wine"
/bin/ln -s ../../../wine/lib/wine/x86_64-unix/ntdll.so "$RUNTIME/MacOS/ntdll.so"
if [ -f "$ROOT/WindowsOriginal.icns" ]; then /bin/cp "$ROOT/WindowsOriginal.icns" "$RUNTIME/Resources/WindowsOriginal.icns"; fi
cat > "$UNIX/wine" <<'SHIM'
#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
case "$*" in
  *[Gg][Aa][Mm][Ee].[Ee][Xx][Ee]*) exec "$DIR/../../../../GameRuntime.app/Contents/MacOS/wine" "$@" ;;
  *) exec "$DIR/wine-raw" "$@" ;;
esac
SHIM
chmod +x "$UNIX/wine" "$UNIX/wine-raw" "$RUNTIME/MacOS/wine"
/usr/bin/codesign --force --deep --sign - "$STAGING/ready/GameRuntime.app"
touch "$STAGING/ready/.complete"
# Do not overwrite an already installed runtime produced by another instance.
if [ -e "$CACHE" ]; then printf 'Runtime directory already exists without a complete marker\n'; exit 22; fi
/bin/mv "$STAGING/ready" "$CACHE"
printf 'Runtime installed and checksum verified\n'
