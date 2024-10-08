# XDG - set defaults as they may not be set
# See https://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html
# and https://wiki.archlinux.org/title/XDG_Base_Directory#Support
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

if [[ $OSTYPE == 'darwin'* ]]; then
    # Set PATH, MANPATH, etc., for Homebrew.
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Added by `rbenv init` on Mon Sep 16 15:28:08 CEST 2024
eval "$(rbenv init - --no-rehash zsh)"
