export BASH_SILENCE_DEPRECATION_WARNING=1

if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

. "$HOME/.cargo/env"

export PATH="$PATH:/Users/donquinleone/.local/bin"
