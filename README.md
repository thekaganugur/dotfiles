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

## Cheatsheet

### Source -> home

Use after editing files in this repo (`home/...`).

```bash
chezmoi diff
chezmoi apply
```

### Home -> source

Use after editing live files directly (`~/.zshrc`, `~/.config/...`).

```bash
chezmoi status
chezmoi re-add ~/.zshrc
chezmoi re-add
```

### Edit one managed file

```bash
chezmoi edit --apply ~/.zshrc
```

### Sync another machine

Pull repo, then apply.

```bash
chezmoi update
```

### Commit changes

```bash
git status
git add -A
git commit -m "Update dotfiles"
```

### Agent skills

`~/.agents` is a chezmoi-managed symlink to `live/agents`, so skill installers write straight into git-tracked files.

```bash
npx skills@latest add mattpocock/skills
git status
git add -A
git commit -m "Update skills"
```

`~/.claude/skills` points to `~/.agents/skills`.

## Notes

macOS-only configs are ignored on non-macOS via `home/.chezmoiignore`.
