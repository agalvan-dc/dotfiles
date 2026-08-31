 #!/bin/bash

# ==========================================
# Ejecución Silenciosa
# ==========================================
DOTFILES_DIR="$HOME/dotfiles"  
BACKUP_DIR="$HOME/dotfiles_backup"
LOCAL_BIN="$HOME/.local/bin"

mkdir -p "$HOME/.config" "$LOCAL_BIN" "$BACKUP_DIR"

# 1. Función de enlaces silenciosa
create_symlink() {
    local src="$1"
    local dest="$2"
    if [ ! -e "$src" ]; then return; fi
    
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        if [ "$(readlink "$dest")" != "$src" ]; then
            mv "$dest" "$BACKUP_DIR/$(basename "$dest")_backup" 2>/dev/null
        fi
    fi
    ln -snf "$src" "$dest"
}

create_symlink "$DOTFILES_DIR/.config/nvim" "$HOME/.config/nvim"
create_symlink "$DOTFILES_DIR/.vimrc" "$HOME/.vimrc"

# 2. Instalar vim-plug silenciosamente
if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
    curl -fsSLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# 3. Instalar plugins de Vim en segundo plano (Oculta el error E185)
if command -v vim &> /dev/null && [ -f "$HOME/.vimrc" ]; then
    vim -es -c "PlugInstall" -c "qa" &> /dev/null
fi

# 4. Instalar Lazygit silenciosamente
if ! command -v lazygit &> /dev/null; then
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -fsSLo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit 2>/dev/null
    mv lazygit "$LOCAL_BIN/lazygit" 2>/dev/null
    rm lazygit.tar.gz 2>/dev/null
fi

# 5. Instalar Lazydocker silenciosamente
if ! command -v lazydocker &> /dev/null; then
    DIR="$LOCAL_BIN" curl -fsSL https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash &> /dev/null
fi

# ==========================================
# Mensaje Único Final
# ==========================================
GREEN='\033[0;32m'
NC='\033[0m'

clear
echo -e "${GREEN}✨ Entorno configurado correctamente.${NC}"
