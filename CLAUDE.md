# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a dotfiles repository containing Neovim configuration optimized for frontend development, along with configurations for Hammerspoon, Karabiner, tmux, zsh, starship, and vifm. The primary focus is the Neovim setup in `generic-neovim/.config/nvim/`.

## Installation Commands

```bash
# Install all generic configurations
stow generic-*

# For macOS users
stow osx-*
./osx-setup.sh

# For Linux users  
stow linux-*
```

## Neovim Configuration Architecture

The Neovim config follows a modular Lazy.nvim structure:

- `init.lua` - Entry point that loads config modules and initializes Lazy.nvim
- `lua/config/` - Core configuration modules:
  - `options.lua` - Vim options and settings
  - `autocmds.lua` - Auto-commands including auto-reload on config changes
  - `keymaps.lua` - Global key mappings
  - `commands.lua` - Custom commands
  - `lsp/init.lua` - LSP key mappings and configurations
- `lua/plugins/` - Plugin specifications organized by functionality:
  - `lsp.lua` - LSP servers, formatters (prettier/prettierd), and linters
  - `coding.lua` - Completion, snippets, and coding assistance
  - `telescope-config.lua` - File finder and search (fzf-lua)
  - `treesitter.lua` - Syntax highlighting and text objects
  - `editor.lua` - Text editing enhancements
  - `ui.lua` - UI components and appearance
  - `colorscheme.lua` - Theme configuration
  - `ai.lua` - AI-powered coding assistance
  - `test.lua` - Testing framework integration
  - `snacks.lua` - Utility plugins (zen mode, lazygit, notifications)
  - `file-explorer.lua` - File management
  - `util.lua` - Utility plugins and icons
- `lua/utils.lua` - Shared utility functions for LSP attach, server filtering, and platform detection

## Frontend Development Focus

The configuration is optimized for JavaScript/TypeScript development with:
- Language servers for JS/TS, Vue, and other web technologies
- Prettier/prettierd formatting for web files
- Treesitter support for modern web languages
- Specialized snippets and completions

## Key Configuration Patterns

- Uses `utils.on_attach()` for consistent LSP client setup
- Platform detection via `utils.is_wsl`, `utils.is_mac`, `utils.is_linux`
- Auto-reload functionality triggers on any `.lua` file changes in nvim config
- Modular plugin organization with clear separation of concerns
- Lazy loading for performance optimization

## Important File Locations

- Main config: `generic-neovim/.config/nvim/`
- Platform-specific: `osx-*` and `linux-*` directories
- Setup script: `osx-setup.sh` for macOS initialization