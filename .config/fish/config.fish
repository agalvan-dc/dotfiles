# =============================================================================
# config.fish - Portable fish configuration
# Installed by install.sh as a symlink.
# =============================================================================

# PATH - user-local directories take precedence
fish_add_path --move "$HOME/.local/bin" "$HOME/bin"

# Editors
set -gx EDITOR vim
set -gx VISUAL vim

if status is-interactive
    # Git abbreviations
    abbr -a g git
    abbr -a gs 'git status -sb'
    abbr -a gd 'git diff'
    abbr -a gc 'git commit'
    abbr -a gcm 'git commit -m'
    abbr -a gpl 'git pull --rebase'
    abbr -a gp 'git push'
    abbr -a lg lazygit

    # Utilities
    abbr -a ll 'ls -lAh'
    abbr -a la 'ls -A'
    abbr -a e "$EDITOR"
end