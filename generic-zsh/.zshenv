skip_global_compinit=1

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/.local/share/bob/nvim-bin" ] ; then
    PATH="$HOME/.local/share/bob/nvim-bin:$PATH"
fi
