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

## Workflow

**This repo is home-first.** Edit live files in `~` first. Then import intentional changes into this repo and commit them.

```bash
# 1. Edit ~/.config/... or another live target.
# 2. Import only changed file(s); do not use bare `re-add`.
chezmoi re-add ~/.config/herdr/config.toml

# 3. Review and save source state.
git diff -- home
git add -A
git commit -m "Update dotfiles"
git push
```

### Choose command

| Home state | Command |
| --- | --- |
| Changed managed file | `chezmoi re-add <path>` |
| New unmanaged file | `chezmoi add <path>` |
| Deleted managed file | `chezmoi forget <path>` |
| Intentionally restore home from source | `chezmoi apply <path>` |

`re-add` and `add` update source. They do **not** overwrite machine files.

### Directories

Do **not** use `chezmoi add --exact` for a directory containing `.git`, caches, logs, sessions, or generated artifacts. `--exact` makes `apply` remove target entries absent from source.

Add only desired project files from such directories. For example, manage `pi-extensions` source files but leave its nested `.git/` and `.pi-subagents/` directories unmanaged.

### When to use `apply`

`chezmoi apply` writes source state to `~`. It is for restoring this machine from source, or setting up another machine. Do **not** run it after local edits you want to keep.

```bash
# Another machine: pull source, then write it to that machine.
chezmoi update
```

### Read `chezmoi diff`

`chezmoi diff` shows what `apply` would do:

```text
- current file in ~
+ source version that apply would write
```

So home-first changes under `-` need `chezmoi re-add` if they are intentional.

### Source-first (optional)

Use only when deliberately editing source before home:

```bash
chezmoi edit ~/.zshrc
chezmoi apply ~/.zshrc
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
