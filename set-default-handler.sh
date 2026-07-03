#!/usr/bin/env bash
set -euo pipefail

# Make OpenInVim the default open handler for common text/code extensions.
# Requires duti: brew install duti
# Pass an app path as $1 to override the default location.

BUNDLE_ID="local.open-in-vim"
APP="${1:-$HOME/Applications/OpenInVim.app}"

command -v duti >/dev/null || { echo "Need duti: brew install duti"; exit 1; }
[ -d "$APP" ] || { echo "App not found: $APP (run ./build.sh and move it to ~/Applications)"; exit 1; }

# Make sure LaunchServices knows about the app + its bundle id.
LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
"$LSREGISTER" -f "$APP"

EXTS=(
	txt text md markdown mdown rst org log conf config cfg ini toml yaml yml
	json jsonc xml csv tsv env
	sh bash zsh fish
	js mjs cjs ts tsx jsx
	py rb go rs c h cpp cc hpp cs java kt swift php lua vim
	css scss sass html htm sql
)

for ext in "${EXTS[@]}"; do
	if duti -s "$BUNDLE_ID" ".$ext" all 2>/dev/null; then
		echo "  .$ext -> OpenInVim"
	else
		echo "  .$ext -> SKIP (no registered UTI)"
	fi
done

echo "Done. Extensions without a registered UTI are expected to skip."
echo "Verify one with: duti -x txt"
