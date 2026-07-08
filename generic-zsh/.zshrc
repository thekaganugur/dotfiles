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
alias p="pi"
alias vf="vifm"
alias g="git"
alias lg="lazygit"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
alias ssh-msi="ssh kgnugur@100.79.253.101"

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

    if [ "$nvmrc_path" = "$_LAST_NVMRC_PATH" ] && command -v node >/dev/null 2>&1; then
        return
    fi

    _LAST_NVMRC_PATH="$nvmrc_path"

    if [ -n "$nvmrc_path" ] && ! current-node-matches-nvmrc "$nvmrc_path"; then
        load-nvm
        nvm use --silent || nvm install
    elif [ -z "$nvmrc_path" ]; then
        load-nvm
        nvm use default --silent >/dev/null
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

# Short zellij socket dir → clean, untruncated session names.
# macOS $TMPDIR prefix (~79 chars) vs the 104-byte unix-socket limit leaves
# only ~25 for the name; this short dir frees ~72. uid-namespaced like zellij's own.
export ZELLIJ_SOCKET_DIR="/tmp/zlj-$UID"

za() {
    local layout="$HOME/.config/zellij/layouts/agents.kdl"
    local name="${1:-$(git symbolic-ref --quiet --short HEAD 2>/dev/null || print -r -- ${PWD:t})}"
    name="${name//[^A-Za-z0-9_.-]/-}"
    if (( ${#name} > 60 )); then
        local hash="${$(print -rn -- "$PWD" | cksum)%% *}"
        name="${name[1,15]}-${hash[1,4]}"
    fi
    if [[ -n "$ZELLIJ" ]]; then
        zellij action switch-session "$name" --layout "$layout" --cwd "$PWD"
    else
        zellij attach --create "$name" options --default-layout "$layout" --default-cwd "$PWD"
    fi
}

alias cc="claude"
alias cx="codex"

# worktrunk: new worktree + AI agent (run bare to see usage)
wtc() { [ $# -eq 0 ] && { echo "wtc <branch> [-- 'task']   # new worktree + Claude"; return; }; local b="$1"; shift; [ "$1" = "--" ] && shift; wt switch --create "$b" && claude "$@"; }
wtx() { [ $# -eq 0 ] && { echo "wtx <branch> [-- 'task']   # new worktree + Codex";  return; }; local b="$1"; shift; [ "$1" = "--" ] && shift; wt switch --create "$b" && codex  "$@"; }
wta() { [ $# -eq 0 ] && { echo "wta <branch>   # new worktree + zellij 'agents' workspace"; return; }; wt switch --create "$1" && za; }

# tmux twins of za/wta (A/B trial alongside zellij). Windows = fullscreen views.
ta() {
    local name="${1:-$(git symbolic-ref --quiet --short HEAD 2>/dev/null || print -r -- ${PWD:t})}"
    name="${name//[^A-Za-z0-9_-]/-}"   # tmux session names: no . or :
    if ! tmux has-session -t "=$name" 2>/dev/null; then
        tmux new-session -d -s "$name" -c "$PWD" -n main
        tmux new-window  -t "=$name"  -c "$PWD" -n side
        tmux new-window  -t "=$name"  -c "$PWD" -n edit
        tmux new-window  -t "=$name"  -c "$PWD" -n git
        tmux new-window  -t "=$name"  -c "$PWD" -n shell
        tmux send-keys   -t "=$name:main" claude Enter   # only main is eager
        tmux select-window -t "=$name:main"
    fi
    if [[ -n "$TMUX" ]]; then tmux switch-client -t "=$name"; else tmux attach -t "=$name"; fi
}
wtt() { [ $# -eq 0 ] && { echo "wtt <branch>   # new worktree + tmux 'agents' session"; return; }; wt switch --create "$1" && ta; }

# worktrunk: remove worktrees whose PR is already merged (any merge strategy)
wtprune() {
    local cur b; cur="$(git symbolic-ref --quiet --short HEAD 2>/dev/null)"
    wt list --format=json | jq -r '.[] | select(.is_main | not) | .branch' | while read -r b; do
        [ -z "$b" ] && continue
        [ "$b" = "$cur" ] && { echo "skip $b (current worktree)"; continue; }
        [ "$(gh pr view "$b" --json state -q .state 2>/dev/null)" = MERGED ] || continue
        if wt remove -D "$b"; then echo "removed $b"; else echo "kept $b (dirty or removal failed)"; fi
    done
}

# wtnew <task> — Haiku names the branch, wt creates the worktree + opens a Claude session
wtnew() {
    [[ -z "$*" ]] && { echo "usage: wtnew <task description>"; return 1; }
    local task="$*" branch fb; local -a names
    while true; do
        printf "⋯ naming branch…"
        names=(${(f)"$(claude --model haiku -p "Output 3 git branch names, one per line, no numbering, no quotes, no prose, format <conventional-type>/<kebab-desc>, no author prefix.${fb:+ Previous set rejected: $fb.} Task: $task")"})
        printf "\r"
        local i=1; for n in $names; do printf "  %d) %s\n" $i "$n"; ((i++)); done
        read "fb?pick 1-3 · or type feedback: "
        [[ "$fb" == [1-3] && -n "$names[$fb]" ]] && { branch=$names[$fb]; break; }
    done
    wt switch --create "$branch" && claude
}

