# Dotfiles

Managed with [chezmoi](https://www.chezmoi.io/).

## Install

```bash
brew install chezmoi
chezmoi init --apply thekaganugur
```

## Local checkout

```bash
git clone git@github.com:thekaganugur/dotfiles.git ~/.local/share/chezmoi
chezmoi apply
```

## Edit

```bash
chezmoi edit ~/.zshrc
chezmoi diff
chezmoi apply
```

macOS-only configs are ignored on non-macOS via `home/.chezmoiignore`.

Agent skills are high-churn, so chezmoi manages `~/.agents` as a symlink to `live/agents`.
