#!/usr/bin/env bash
#
# =============================================================================
#  install.sh - Portable dotfiles installer  (no sudo required)
#
#  Everything is installed inside your home directory via symlinks, so it
#  works on any machine where you have a shell, regardless of sudo rights.
#
#  Usage:
#    ./install.sh                Interactive menu
#    ./install.sh --all          Install everything
#    ./install.sh --shell        Bash, fish and Git configuration
#    ./install.sh --vim          Vim configuration + plugins
#    ./install.sh --nvim         Neovim configuration + plugins
#    ./install.sh --tmux         Tmux configuration
#    ./install.sh --tools        Standalone tools (lazygit, lazydocker)
#    ./install.sh --help         Show this help
#
#  Options can be combined freely:  ./install.sh --vim --tmux
#
#  Existing files are never deleted: they are moved to
#  ~/dotfiles_backup_<timestamp>/ before being replaced.
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_BIN="$HOME/.local/bin"

# Use ANSI colors only when stdout is a real terminal; otherwise keep the
# output plain so no raw escape codes leak into captures/pipes.
if [ -t 1 ]; then
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    RED='\033[0;31m'
    NC='\033[0m'
else
    GREEN=''
    YELLOW=''
    RED=''
    NC=''
fi

info()  { echo -e "${GREEN}==>${NC} $*"; }
warn()  { echo -e "${YELLOW}==>${NC} $*"; }
error() { echo -e "${RED}==>${NC} $*" >&2; }

# ---------------------------------------------------------------------------
# Help
# ---------------------------------------------------------------------------
usage() {
    cat <<'EOF'
Usage: ./install.sh [options]

Options (combine freely):
  --all        Install and configure everything
  --shell      Bash, fish and Git configuration
  --vim        Vim configuration + plugins
  --nvim       Neovim configuration + plugins
  --tmux       Tmux configuration
  --tools      Standalone tools (lazygit, lazydocker)
  -h, --help   Show this help

No options: launches an interactive menu.
Every component installs into your $HOME - no sudo needed.
EOF
    exit 0
}

# ---------------------------------------------------------------------------
# Backup helpers
# ---------------------------------------------------------------------------
BACKUP_DIR=""

backup_path() {
    if [ -z "$BACKUP_DIR" ]; then
        BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
    fi
    mkdir -p "$BACKUP_DIR"
}

# ---------------------------------------------------------------------------
# Symlink a repo file/dir into $HOME (backing up anything in the way)
# ---------------------------------------------------------------------------
link_file() {
    local src="$1"
    local dest="$2"

    if [ ! -e "$src" ]; then
        warn "Skipped: $src does not exist."
        return 0
    fi

    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        info "Already in place: $dest"
        return 0
    fi

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        backup_path
        mv "$dest" "$BACKUP_DIR/$(basename "$dest")"
        warn "Backed up existing $(basename "$dest") -> $BACKUP_DIR"
    fi

    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
    info "Linked $src -> $dest"
}

# ---------------------------------------------------------------------------
# Component: shell (bash + fish + git)
# ---------------------------------------------------------------------------
install_shell() {
    info "Configuring the shell..."

    link_file "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
    link_file "$DOTFILES_DIR/.config/fish/config.fish" "$HOME/.config/fish/config.fish"
    link_file "$DOTFILES_DIR/templates/gitignore_global" "$HOME/.gitignore_global"

    local src="$DOTFILES_DIR/templates/gitconfig"
    local dest="$HOME/.gitconfig"

    local cur_name cur_email reconfigure
    cur_name="$(git config --global user.name 2>/dev/null || true)"
    cur_email="$(git config --global user.email 2>/dev/null || true)"

    # Supported: show current identity and offer to change it. If there is no
    # identity yet (or it is incomplete), jump straight into the prompts below.
    if [ -f "$dest" ] && [ -n "$cur_name" ] && [ -n "$cur_email" ]; then
        info "Git identity already configured: $cur_name <$cur_email>"
        read -rp "Reconfigure Git identity? [y/N]: " reconfigure || reconfigure=""
        if [[ ! "$reconfigure" =~ ^[YySs]$ ]]; then
            echo ""
            return 0
        fi
    fi

    local default_name default_email name email content
    default_name="${cur_name:-$(whoami)}"
    default_email="${cur_email:-${USER}@$(hostname)}"

    echo ""
    read -rp "Git user.name  (default: ${default_name}): " name || name=""
    name="${name:-$default_name}"
    read -rp "Git user.email (default: ${default_email}): " email || email=""
    email="${email:-$default_email}"

    if [ -e "$dest" ]; then
        backup_path
        mv "$dest" "$BACKUP_DIR/gitconfig"
        warn "Backed up existing ~/.gitconfig -> $BACKUP_DIR"
    fi

    local conflict_style="diff3"
    local git_major git_minor
    git_major="$(git --version 2>/dev/null | awk '{print $3}' | cut -d. -f1)"
    git_minor="$(git --version 2>/dev/null | awk '{print $3}' | cut -d. -f2)"
    if [ -n "$git_major" ] && { [ "$git_major" -gt 2 ] || { [ "$git_major" -eq 2 ] && [ "${git_minor:-0}" -ge 35 ]; }; }; then
        conflict_style="zdiff3"   # Word-level conflict markers (Git >= 2.35)
    fi

    content="$(<"$src")"
    content="${content//'{{NAME}}'/${name}}"
    content="${content//'{{EMAIL}}'/${email}}"
    content="${content//conflictstyle = diff3/conflictstyle = ${conflict_style}}"
    printf '%s\n' "$content" > "$dest"
    info "Wrote Git identity to ~/.gitconfig."
}

# ---------------------------------------------------------------------------
# Component: vim (+ vim-plug)
# ---------------------------------------------------------------------------
install_vimplug() {
    local autoload="$HOME/.vim/autoload/plug.vim"
    [ -f "$autoload" ] && { info "vim-plug already installed."; return 0; }

    if curl -fsSLo "$autoload" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim; then
        info "Installed vim-plug."
    else
        error "Failed to download vim-plug."
    fi
}

install_vim() {
    info "Configuring Vim..."

    link_file "$DOTFILES_DIR/.vimrc" "$HOME/.vimrc"
    install_vimplug

    if command -v vim >/dev/null 2>&1; then
        info "Installing Vim plugins (this can take a minute)..."
        if ! vim -es -u "$HOME/.vimrc" -c "PlugInstall" -c "qa" >/dev/null 2>&1; then
            warn "Plugin install finished with warnings; run :PlugInstall inside Vim."
        fi
    else
        warn "vim is not installed: .vimrc is linked but plugins were skipped."
    fi
}

# ---------------------------------------------------------------------------
# Component: nvim (lazy.nvim bootstraps itself on first launch)
# ---------------------------------------------------------------------------
install_nvim() {
    info "Configuring Neovim..."

    link_file "$DOTFILES_DIR/.config/nvim" "$HOME/.config/nvim"

    if command -v nvim >/dev/null 2>&1; then
        info "lazy.nvim will install all plugins on the first launch."
        warn "Run 'nvim' once to bootstrap the plugins."
    else
        warn "nvim is not installed: config is linked but you still need Neovim itself."
    fi
}

# ---------------------------------------------------------------------------
# Component: tmux
# ---------------------------------------------------------------------------
install_tmux() {
    info "Configuring Tmux..."
    link_file "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
}

# ---------------------------------------------------------------------------
# Component: standalone tools (lazygit, lazydocker) -> $HOME/.local/bin
# ---------------------------------------------------------------------------
github_latest_version() {
    local repo="$1"
    curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" \
        | sed -n 's/.*"tag_name": "v\([^"]*\)".*/\1/p' \
        | head -n1
}

install_github_tool() {
    local name="$1"
    local repo="$2"

    if command -v "$name" >/dev/null 2>&1; then
        info "$name already installed at $(command -v "$name")."
        return 0
    fi

    local os arch
    case "$(uname -s)" in
        Linux)  os="Linux" ;;
        Darwin) os="Darwin" ;;
        *) error "Unsupported OS: $(uname -s)."; return 1 ;;
    esac
    case "$(uname -m)" in
        x86_64 | amd64)  arch="x86_64" ;;
        aarch64 | arm64) arch="arm64" ;;
        *) error "Unsupported architecture: $(uname -m)."; return 1 ;;
    esac

    mkdir -p "$LOCAL_BIN"

    local version
    version="$(github_latest_version "$repo")" || true
    if [ -z "$version" ]; then
        error "Could not resolve the latest version of ${name}."
        return 1
    fi

    local url="https://github.com/${repo}/releases/download/v${version}/${name}_${version}_${os}_${arch}.tar.gz"
    info "Downloading $name v${version}..."

    if ! curl -fSLo "$LOCAL_BIN/$name.tar.gz" "$url"; then
        error "Download failed: $url"
        rm -f "$LOCAL_BIN/$name.tar.gz"
        return 1
    fi

    mkdir -p "$LOCAL_BIN/${name}.tmp"
    tar -xzf "$LOCAL_BIN/$name.tar.gz" -C "$LOCAL_BIN/${name}.tmp"
    mv "$LOCAL_BIN/${name}.tmp/$name" "$LOCAL_BIN/$name"
    chmod +x "$LOCAL_BIN/$name"
    rm -rf "$LOCAL_BIN/${name}.tmp" "$LOCAL_BIN/$name.tar.gz"
    info "Installed $name -> $LOCAL_BIN/$name"
}

install_tools() {
    info "Installing standalone tools..."
    install_github_tool "lazygit"   "jesseduffield/lazygit"
    install_github_tool "lazydocker" "jesseduffield/lazydocker"
}

# ---------------------------------------------------------------------------
# Full setup
# ---------------------------------------------------------------------------
install_all() {
    install_shell
    install_vim
    install_nvim
    install_tmux
    install_tools
}

# ---------------------------------------------------------------------------
# Interactive menu
# ---------------------------------------------------------------------------
menu() {
    while true; do
        echo ""
        echo "What would you like to install?"
        echo "  1) Full setup (everything)"
        echo "  2) Vim + Neovim"
        echo "  3) Vim only"
        echo "  4) Neovim only"
        echo "  5) Shell (bash, fish, git config)"
        echo "  6) Tmux"
        echo "  7) Standalone tools (lazygit, lazydocker)"
        echo "  8) Quit"
        echo ""
        read -rp "Select an option: " choice || break

        case "$choice" in
            1) install_all; break ;;
            2) install_vim; install_nvim ;;
            3) install_vim ;;
            4) install_nvim ;;
            5) install_shell ;;
            6) install_tmux ;;
            7) install_tools ;;
            8) break ;;
            *) warn "Invalid option: $choice" ;;
        esac
        echo ""
    done
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
    if [ "$#" -eq 0 ]; then
        menu
    else
        local do_shell=0 do_vim=0 do_nvim=0 do_tmux=0 do_tools=0

        for arg in "$@"; do
            case "$arg" in
                --all)    do_shell=1 do_vim=1 do_nvim=1 do_tmux=1 do_tools=1 ;;
                --shell)  do_shell=1 ;;
                --vim)    do_vim=1 ;;
                --nvim)   do_nvim=1 ;;
                --tmux)   do_tmux=1 ;;
                --tools)  do_tools=1 ;;
                -h | --help) usage ;;
                *) error "Unknown option: $arg"; usage ;;
            esac
        done

        [ "$do_shell" -eq 1 ] && install_shell
        [ "$do_vim" -eq 1 ]   && install_vim
        [ "$do_nvim" -eq 1 ]  && install_nvim
        [ "$do_tmux" -eq 1 ]  && install_tmux
        [ "$do_tools" -eq 1 ] && install_tools
    fi

    echo ""
    echo -e "${GREEN}==>${NC} Setup complete."
    if [ -n "$BACKUP_DIR" ]; then
        echo -e "${YELLOW}==>${NC} Previous configs were backed up to: $BACKUP_DIR"
    fi
    echo -e "${YELLOW}==>${NC} Next steps:"
    echo "    1. Open a new shell (or run 'source ~/.bashrc') to apply changes."
    echo "    2. Run 'nvim' once to install all Neovim plugins via lazy.nvim."
    echo "    3. Put machine-specific tweaks in ~/.bashrc.local (never committed)."
    echo "    4. To install individual pieces later: ./install.sh --vim --tmux"
}

main "$@"