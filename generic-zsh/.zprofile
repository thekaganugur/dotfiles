# XDG - set defaults as they may not be set
# See https://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html
# and https://wiki.archlinux.org/title/XDG_Base_Directory#Support
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

if [[ $OSTYPE == 'darwin'* ]]; then
    # Set PATH, MANPATH, etc., for Homebrew.
    eval "$(/opt/homebrew/bin/brew shellenv)"

    # Keep the active nvm Node shims ahead of Homebrew package-manager binaries.
    if [ -n "$NVM_BIN" ]; then
        export PATH="$NVM_BIN:$PATH"
    fi
fi

# Added by `rbenv init` on Mon Sep 16 15:28:08 CEST 2024
eval "$(rbenv init - --no-rehash zsh)"

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# >>> Agent Session Hub >>>
export PATH='/Users/kgnugur/.local/bin':$PATH
csx() {
    case "${1-}" in
        browse)
            shift
            ;;
        doctor|rename|reset|delete|help|install-shell|uninstall-shell|__*)
            command csx "$@"
            return $?
            ;;
    esac

    local _ash_result
    _ash_result="$(command csx __select "$@")" || return $?
    [ -z "$_ash_result" ] && return 0

    local _ash_project="${_ash_result%%	*}"
    local _ash_session="${_ash_result#*	}"

    if [ -n "$_ash_project" ] && [ -d "$_ash_project" ]; then
        cd "$_ash_project" || return $?
    fi

    command csx --resume "$_ash_session"
}
clx() {
    case "${1-}" in
        browse)
            shift
            ;;
        doctor|rename|reset|delete|help|install-shell|uninstall-shell|__*)
            command clx "$@"
            return $?
            ;;
    esac

    local _ash_result
    _ash_result="$(command clx __select "$@")" || return $?
    [ -z "$_ash_result" ] && return 0

    local _ash_project="${_ash_result%%	*}"
    local _ash_session="${_ash_result#*	}"

    if [ -n "$_ash_project" ] && [ -d "$_ash_project" ]; then
        cd "$_ash_project" || return $?
    fi

    command clx --resume "$_ash_session"
}
opx() {
    case "${1-}" in
        browse)
            shift
            ;;
        doctor|rename|reset|delete|help|install-shell|uninstall-shell|__*)
            command opx "$@"
            return $?
            ;;
    esac

    local _ash_result
    _ash_result="$(command opx __select "$@")" || return $?
    [ -z "$_ash_result" ] && return 0

    local _ash_project="${_ash_result%%	*}"
    local _ash_session="${_ash_result#*	}"

    if [ -n "$_ash_project" ] && [ -d "$_ash_project" ]; then
        cd "$_ash_project" || return $?
    fi

    command opx --resume "$_ash_session"
}
cxs() { csx "$@"; }
# <<< Agent Session Hub <<<
