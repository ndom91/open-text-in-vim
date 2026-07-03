# open-text-in-vim

Open any text file in **Neovim inside your existing Ghostty + tmux session**.

Double-click a file in Finder (or set OpenInVim as the default app for text/code
extensions) and it opens as a new tmux window running `nvim`, in your already-running
Ghostty session — instead of spawning a fresh editor every time.

It's a small AppleScript droplet registered as a file handler. On open it:

1. resolves the file's path and directory,
2. finds your first attached tmux client's session (falling back to the first
   session),
3. runs `tmux new-window -c <dir> nvim <file>` in that session,
4. `open -a Ghostty` to bring the terminal to the front.

## Requirements

- [Ghostty](https://ghostty.org/)
- [Neovim](https://neovim.io/)
- [tmux](https://github.com/tmux/tmux) with at least one running session
- macOS with `osacompile` (ships with the OS)
- [`duti`](https://github.com/moretension/duti) — only for `set-default-handler.sh`
  (`brew install duti`)

> **Path assumption:** the droplet uses Apple-silicon Homebrew paths
> (`/opt/homebrew/bin/tmux`, `/opt/homebrew/bin/nvim`). On Intel or a custom
> setup, edit `src/main.applescript` before building.

## Install

```bash
./build.sh                      # osacompile -> OpenInVim.app
mv OpenInVim.app ~/Applications/
```

The compiled `.app` is a build artifact and is git-ignored — rebuild it anywhere
from source with `./build.sh`.

## Set as default for text/code files

```bash
./set-default-handler.sh        # requires duti
```

Makes OpenInVim the default for a broad list of extensions (txt, md, json, yaml,
sh, js, ts, py, go, rs, c, …). Edit the `EXTS` list in the script to taste.
Extensions with no registered UTI on your system are skipped. Verify one:

```bash
duti -x txt                     # should report OpenInVim
```

Or set it per file: right-click → Open With → Other → OpenInVim → "Always Open With".

## Simpler variant (no tmux)

`bin/open-in-vim` just opens vim in a fresh Ghostty window — no tmux integration:

```bash
bin/open-in-vim path/to/file
```

Use it when you don't want the file landing in your tmux session.

## Layout

```
build.sh                 osacompile + Info.plist patch -> OpenInVim.app
set-default-handler.sh   duti-based default-app registration
src/main.applescript     droplet source (tmux + nvim + Ghostty)
src/doctypes.plist       "associate all files" document-types fragment
bin/open-in-vim          standalone no-tmux variant
```

## License

MIT
