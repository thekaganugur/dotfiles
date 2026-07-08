# Dotfiles

Managed with [chezmoi](https://www.chezmoi.io/).

## Install

```bash
brew install chezmoi
chezmoi init --apply kgnugur
```

## Local checkout

```bash
git clone git@github.com:kgnugur/dotfiles.git ~/.local/share/chezmoi
chezmoi apply
```

## Edit

```bash
chezmoi edit ~/.zshrc
chezmoi diff
chezmoi apply
```

macOS-only configs are ignored on non-macOS via `home/.chezmoiignore`.
