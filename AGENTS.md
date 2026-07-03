# AGENTS.md

Orientation for AI agents (and humans) working on this repo.

## What this is

A macOS **file handler** that opens text/code files in **Neovim inside the user's
already-running tmux + Ghostty session** — not a fresh editor per file. It's an
AppleScript droplet (`OpenInVim.app`) plus helper scripts.

It is **not** a URL-scheme handler. The `Info.plist` has no `CFBundleURLTypes`;
integration is file-association via the AppleScript `on open` handler.

## How it works

`src/main.applescript` (`on open theFiles`), per file:
1. `POSIX path` of the file + `dirname`.
2. Find tmux session: first attached client's session, else first session
   (`tmux list-clients` → fallback `tmux list-sessions`). Aborts if none.
3. `tmux new-window -c <dir> nvim <file>` in that session.
4. `open -a Ghostty` to focus the terminal.

## Layout

```
build.sh                 osacompile + Info.plist patch -> OpenInVim.app
set-default-handler.sh   duti-based default-app registration
src/main.applescript     droplet source (tmux + nvim + Ghostty)
src/doctypes.plist       "associate all files" document-types fragment
bin/open-in-vim          standalone no-tmux variant
```

## Build / run

- `./build.sh` — `osacompile` compiles `src/main.applescript` → `OpenInVim.app`,
  then patches `Info.plist`: replaces `CFBundleDocumentTypes` from
  `src/doctypes.plist` (associate all files) and sets
  `CFBundleIdentifier=local.open-in-vim`.
- Install: `mv OpenInVim.app ~/Applications/`.
- `./set-default-handler.sh` — `duti` sets OpenInVim as default for the `EXTS`
  list. Needs `brew install duti`; runs `lsregister -f` first.
- `bin/open-in-vim <file>` — simpler variant: `ghostty -e vim`, no tmux.

## Key facts & constraints

- **`OpenInVim.app` is a build artifact** — git-ignored, never commit it.
  Source of truth is `src/`. Rebuild anywhere with `./build.sh`.
- **Hardcoded Apple-silicon paths**: `/opt/homebrew/bin/{tmux,nvim}` in
  `main.applescript`, `/Applications/Ghostty.app/...` in `bin/open-in-vim`.
  Editing these is the main portability change (Intel = `/usr/local/bin`).
- **The bundle id `local.open-in-vim` is a contract** between `build.sh` (sets it)
  and `set-default-handler.sh` (targets it). Change both together.
- Requires a running tmux session; the droplet aborts otherwise.
- `osacompile` writes a stub `Info.plist` associated only with `.scpt` — the
  `plutil -replace` step in `build.sh` is what makes it a general file handler.
- No custom icon committed; `osacompile` default is used.

## Conventions

- Keep `main.applescript` faithful to the deployed behavior; it's the spec.
- Public repo — no secrets, no `/Users/<name>` absolute paths, no personal data.
  Use `~` / `$HOME` / tool install paths only.

## Verify a change

1. `./build.sh` → `OpenInVim.app` builds clean.
2. `plutil -p OpenInVim.app/Contents/Info.plist` → `CFBundleDocumentTypes`
   present, `CFBundleIdentifier=local.open-in-vim`.
3. `bash -n set-default-handler.sh bin/open-in-vim` → syntax OK.
4. End-to-end: install to `~/Applications`, open a `.txt` → new tmux window with
   nvim on the file, Ghostty focused.
