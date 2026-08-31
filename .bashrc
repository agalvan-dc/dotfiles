# ==============================================================================
# .bashrc - User Configuration
# ==============================================================================

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Environment Variables
export EDITOR="vim"
export VISUAL="vim"

# Fix KDE Konsole key repeat issue (disables accent pop-up menu)
export QT_IM_MODULE=simple

# User Bin Directories (Deduplicated PATH entries)
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi

# Source custom modular configs from ~/.bashrc.d if present
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
    unset rc
fi

# Useful Aliases
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias grep='grep --color=auto'
alias reload='source ~/.bashrc'
alias vim='gvim -v'
