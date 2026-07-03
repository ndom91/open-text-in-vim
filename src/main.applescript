-- OpenInVim: open dropped/associated files in Neovim inside your existing
-- tmux session, then focus Ghostty.
--
-- Assumes Apple-silicon Homebrew paths (/opt/homebrew/bin). Edit the paths
-- below if tmux/nvim live elsewhere (e.g. /usr/local/bin on Intel).

on open theFiles
	repeat with theFile in theFiles
		set filePath to POSIX path of theFile
		set fileDir to do shell script "dirname " & quoted form of filePath
		do shell script "session=$(/opt/homebrew/bin/tmux list-clients -F '#{session_name}' | head -1); " & ¬
			"if [ -z \"$session\" ]; then session=$(/opt/homebrew/bin/tmux list-sessions -F '#{session_name}' | head -1); fi; " & ¬
			"test -n \"$session\"; " & ¬
			"exec /opt/homebrew/bin/tmux new-window -c " & quoted form of fileDir & " -t \"=${session}:\" /opt/homebrew/bin/nvim " & quoted form of filePath
		do shell script "open -a Ghostty"
	end repeat
end open
