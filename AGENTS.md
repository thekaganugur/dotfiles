# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Dotfiles repo managed with chezmoi. Primary focus is Neovim config in `home/dot_config/nvim/`, optimized for JS/TS frontend development. Also includes configs for Ghostty, Hammerspoon, Karabiner, Lazygit, Yazi, zsh, starship, and vifm.

## Installation

```bash
brew install chezmoi
chezmoi init --apply thekaganugur
```

Chezmoi source root is `home/` via `.chezmoiroot`. macOS-only configs are ignored on non-macOS by `home/.chezmoiignore`. Agent skills are high-churn: chezmoi manages `~/.agents` as a symlink to `live/agents`, and `~/.claude/skills` as a symlink to `~/.agents/skills`.

## Neovim Architecture

Lazy.nvim auto-discovers all files under `lua/plugins/` — no manual plugin registration needed. Plugin files are grouped by concern (language, editing, search, etc.).

### Key architectural decisions

- **LSP keymaps** are wired via an `LspAttach` autocmd inside `language.lua`, not a shared helper. LSP servers configured through mason + mason-lspconfig.
- **Completion** uses blink.cmp (migrated from nvim-cmp) with luasnip + friendly-snippets.
- **Formatting** via conform.nvim: prettierd/prettier for web files, stylua for lua, beautysh for shell. Format-on-save enabled.
- **Picker** is fzf-lua (`<C-p>` files, `<C-g>` live grep). Also powers LSP definition/references/symbols via `gd`, `grr`, `gO`.
- **File explorer** uses oil.nvim (`-` to open) and yazi.nvim (`<leader>-`).
- **AI** integration through sidekick.nvim → Codex CLI (`<leader>a*` prefix, `<C-a>` toggle).
- **Git** uses fugitive + gitsigns (`<leader>h*` for hunk operations) + lazygit via snacks (`<C-]>`).
- **Leader** is space, **localleader** is comma.
- Autocmd in `autocmds.lua` restarts prettierd when prettier config files change (workaround for prettierd bug).
