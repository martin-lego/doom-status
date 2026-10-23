#!/usr/bin/env bash
# swift build -c release, then Doom Status.app and dist/DoomStatus.dmg.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

export MACOSX_DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET:-14.0}"

swift build -c release --arch arm64
BIN="$(swift build -c release --arch arm64 --show-bin-path)/DoomStatus"
if [[ ! -x "$BIN" ]]; then
  echo "No se encontró el binario: $BIN" >&2
  exit 1
fi

DIST="$ROOT/dist"
APP="$DIST/Doom Status.app"
rm -rf "$DIST"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

cp "$BIN" "$APP/Contents/MacOS/DoomStatus"
chmod +x "$APP/Contents/MacOS/DoomStatus"
cp "$ROOT/Sources/DoomStatus/Resources/"[1-6].png "$APP/Contents/Resources/"

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>es</string>
	<key>CFBundleDisplayName</key>
	<string>Doom Status</string>
	<key>CFBundleExecutable</key>
	<string>DoomStatus</string>
	<key>CFBundleIconFile</key>
	<string>AppIcon</string>
	<key>CFBundleIdentifier</key>
	<string>com.martinlego.doomstatus</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>Doom Status</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>0.1.0</string>
	<key>CFBundleSupportedPlatforms</key>
	<array>
		<string>MacOSX</string>
	</array>
	<key>CFBundleVersion</key>
	<string>0.1.0</string>
	<key>LSMinimumSystemVersion</key>
	<string>14.0</string>
	<key>LSUIElement</key>
	<true/>
	<key>NSHighResolutionCapable</key>
	<true/>
	<key>NSHumanReadableCopyright</key>
	<string>Copyright © 2026 Martin LeGo. Caras de DOOM, id Software. PNG de rjzak/doom-status.</string>
</dict>
</plist>
PLIST

ICONSET="$(mktemp -d)/AppIcon.iconset"
mkdir -p "$ICONSET"
SRC="$ROOT/Sources/DoomStatus/Resources/1.png"
for size in 16 32 128 256 512; do
  sips -z "$size" "$size" "$SRC" --out "$ICONSET/icon_${size}x${size}.png" >/dev/null
  double=$((size * 2))
  sips -z "$double" "$double" "$SRC" --out "$ICONSET/icon_${size}x${size}@2x.png" >/dev/null
done
iconutil -c icns "$ICONSET" -o "$APP/Contents/Resources/AppIcon.icns"
rm -rf "$(dirname "$ICONSET")"

plutil -lint "$APP/Contents/Info.plist" >/dev/null

codesign --force --sign - "$APP"
codesign --verify --verbose=2 "$APP"

STAGE="$(mktemp -d)"
cp -R "$APP" "$STAGE/Doom Status.app"
ln -s /Applications "$STAGE/Applications"

DMG="$DIST/DoomStatus.dmg"
hdiutil create \
  -volname "Doom Status" \
  -srcfolder "$STAGE" \
  -ov \
  -format UDZO \
  "$DMG"
rm -rf "$STAGE"

echo "DMG listo: $DMG"
