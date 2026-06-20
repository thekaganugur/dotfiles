# mkdir -p $XDG_CACHE_HOME/zsh
mkdir -p $HOME/.local/bin

eval "$(starship init zsh)"

# Vi mode
bindkey -v
export KEYTIMEOUT=1

# Use modern completion system
autoload -Uz compinit
compinit -d $XDG_CACHE_HOME/zsh/zcompdump

# Above line must be added after
eval "$(zoxide init zsh)"

if [[ $OSTYPE == 'darwin'* ]]; then
  source /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh
fi

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000

# Options
# Do not enter command lines into the history list if they are duplicates of the previous event.
setopt histignorealldups
setopt sharehistory #Share history across terminals
setopt auto_list # automatically list choices on ambiguous completion
setopt auto_menu # automatically use menu completion
setopt always_to_end # move cursor to end if word had one match
setopt hist_ignore_all_dups # remove older duplicate entries from history setopt hist_reduce_blanks # remove superfluous blanks from history items
setopt inc_append_history # save history entries as soon as they are entered
setopt share_history # share history between different instances
setopt interactive_comments # allow comments in interactive shells

# Improve auto completion style
zstyle ':completion:*' menu select # select completions with arrow keys
zstyle ':completion:*' group-name '' # group results by category
zstyle ':completion:::::' completer _expand _complete _ignored _approximate # enable approximate matches for completion

# Key bindings
bindkey '^[[Z' reverse-menu-complete
bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down
bindkey '^K' history-substring-search-up

bindkey '^J' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# Aliases
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias v="nvim"
alias vf="vifm"
alias g="git"
alias lg="lazygit"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  command yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

# nvm
export NVM_DIR="$HOME/.nvm"

load-nvm() {
  [ -n "$_NVM_LOADED" ] && return

  unset -f nvm
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  _NVM_LOADED=1
}

nvm() {
  load-nvm
  nvm "$@"
}

find-nvmrc() {
  local dir="$PWD"

  while [ "$dir" != "/" ]; do
    if [ -f "$dir/.nvmrc" ]; then
      echo "$dir/.nvmrc"
      return
    fi

    dir="${dir:h}"
  done
}

current-node-matches-nvmrc() {
  local wanted current

  IFS= read -r wanted < "$1"
  current="$(command node -v 2>/dev/null)" || return 1

  case "$wanted" in
    [0-9]*)
      case "$current" in
        "v$wanted"|"v$wanted".*) return 0 ;;
      esac
      ;;
    v[0-9]*)
      case "$current" in
        "$wanted"|"$wanted".*) return 0 ;;
      esac
      ;;
  esac

  return 1
}

load-nvmrc() {
  local nvmrc_path
  nvmrc_path="$(find-nvmrc)"

  if [ "$nvmrc_path" = "$_LAST_NVMRC_PATH" ]; then
    return
  fi

  _LAST_NVMRC_PATH="$nvmrc_path"

  if [ -n "$nvmrc_path" ] && ! current-node-matches-nvmrc "$nvmrc_path"; then
    load-nvm
    nvm use --silent || nvm install
  fi
}

autoload -U add-zsh-hook
add-zsh-hook chpwd load-nvmrc
load-nvmrc

# Added by git-ai installer on Fri Jun  5 09:30:32 +03 2026
export PATH="/Users/kgnugur/.git-ai/bin:$PATH"

# cubic
export PATH="/Users/kgnugur/.cubic/bin":$PATH

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi

. "$HOME/.local/share/../bin/env"
