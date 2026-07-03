#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

APP="OpenInVim.app"
BUNDLE_ID="local.open-in-vim"

rm -rf "$APP"
osacompile -o "$APP" src/main.applescript

# osacompile writes a stub Info.plist that only associates the app with .scpt.
# Replace its document types with our "all files" association and set a stable
# bundle identifier so set-default-handler.sh can target it.
PLIST="$APP/Contents/Info.plist"
plutil -replace CFBundleDocumentTypes -json \
	"$(plutil -extract CFBundleDocumentTypes json -o - src/doctypes.plist)" \
	"$PLIST"
plutil -replace CFBundleIdentifier -string "$BUNDLE_ID" "$PLIST"

echo "Built $APP"
echo "Next: mv $APP ~/Applications/ && ./set-default-handler.sh"
