# =============================================================================
# .bashrc - Portable user shell configuration
#
# Installed by install.sh as a symlink. Keep it portable:
# machine-specific tweaks belong in ~/.bashrc.local (never committed).
# =============================================================================

# ---------------------------------------------------------------------------
# 1. Base distribution rc - keeps the OS defaults working
# ---------------------------------------------------------------------------
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi
if [ -f /etc/bash.bashrc ]; then
    . /etc/bash.bashrc
fi

# ---------------------------------------------------------------------------
# 2. Machine-specific overrides (untracked on purpose)
# ---------------------------------------------------------------------------
if [ -f "$HOME/.bashrc.local" ]; then
    . "$HOME/.bashrc.local"
fi

# ---------------------------------------------------------------------------
# 3. Editors
# ---------------------------------------------------------------------------
export EDITOR="${EDITOR:-vim}"
export VISUAL="${VISUAL:-vim}"

# ---------------------------------------------------------------------------
# 4. PATH - user-local directories take precedence (deduplicated)
# ---------------------------------------------------------------------------
__path_prepend() {
    local dir="$1"
    if [ -d "$dir" ] && [[ ":$PATH:" != *":$dir:"* ]]; then
        export PATH="$dir:$PATH"
    fi
}

__path_prepend "$HOME/.local/bin"
__path_prepend "$HOME/bin"
__path_prepend "$HOME/.opencode/bin"

unset -f __path_prepend

# ---------------------------------------------------------------------------
# 5. Shell behaviour & history
# ---------------------------------------------------------------------------
shopt -s histappend      # append instead of overwriting history
shopt -s checkwinsize    # fix line wrapping after resizing windows
shopt -s cdspell         # auto-correct small typos in cd
shopt -s globstar        # ** enables recursive globbing

export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL="ignoreboth:erasedups"

# ---------------------------------------------------------------------------
# 6. Aliases
# ---------------------------------------------------------------------------
alias ls='ls --color=auto'
alias ll='ls -lAh --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias reload='source "$HOME/.bashrc"'
alias e="$EDITOR"

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Git
alias g='git'
alias gs='git status -sb'
alias ga='git add -A'
alias gc='git commit'
alias gcm='git commit -m'
alias gd='git diff'
alias gt='git log --oneline --graph --decorate --all'
alias gpl='git pull --rebase'
alias gp='git push'
alias lg='lazygit'

# Misc
alias path='echo -e "${PATH//:/\\n}"'
if command -v xclip >/dev/null 2>&1; then
    alias copy='xclip -selection clipboard'
fi

# ---------------------------------------------------------------------------
# 7. Functions
# ---------------------------------------------------------------------------
mkcd() {
    mkdir -p "$1" && cd "$1"
}

extract() {
    if [ ! -f "$1" ]; then
        echo "extract: '$1' is not a file" >&2
        return 1
    fi
    case "$1" in
        *.tar.bz2)  tar xjf  "$1" ;;
        *.tar.gz)   tar xzf  "$1" ;;
        *.tar.xz)   tar xJf  "$1" ;;
        *.tbz2)     tar xjf  "$1" ;;
        *.tgz)      tar xzf  "$1" ;;
        *.tar)      tar xf   "$1" ;;
        *.gz)       gunzip   "$1" ;;
        *.bz2)      bunzip2  "$1" ;;
        *.xz)       unxz     "$1" ;;
        *.zip)      unzip    "$1" ;;
        *.rar)      unrar x  "$1" ;; 
        *.7z)       7z x     "$1" ;;
        *.Z)        uncompress "$1" ;;
        *) echo "extract: unknown format: '$1'" >&2; return 1 ;;
    esac
}

gcl() {
    git clone "$1" && cd "$(basename "$1" .git)"
}

ta() {
    if tmux has-session 2>/dev/null; then
        tmux attach
    else
        tmux new-session -s main
    fi
}

# ---------------------------------------------------------------------------
# 8. Interactive prompt with Git branch
# ---------------------------------------------------------------------------
if [ -n "$PS1" ]; then
    __git_branch() {
        local b
        b="$(git symbolic-ref --short HEAD 2>/dev/null)"
        [ -n "$b" ] && printf ' \033[01;36m(%s)\033[0m' "$b"
    }

    PS1='\[\033[01;32m\]\u@\h\[\033[0m\]:\[\033[01;34m\]\w\[\033[0m\]$(__git_branch)\$ '
fi