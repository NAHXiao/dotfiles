- backup your dotfiles
- make sure `git unzip file` commands exist and useable
- `chezmoi init --apply NAHxiao --exclude encrypted` or `sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply NAHXiao --exclude encrypted`
- use `chezmoi init --apply NAHxiao --exclude encrypted --mode=file --destination <TMPDIR>` to generate config file to \<TMPDIR> (this will still override chezmoi config dir)
---
TODO:
A better way to disable files that require bw when encrypted files are excluded...
