 "Dotfiles setup complete!"#!/bin/bash

DOTFILES_DIR="$HOME/dotfiles"  
BACKUP_DIR="$HOME/dotfiles_backup"
LOCAL_BIN="$HOME/.local/bin"

mkdir -p "$HOME/.config"
mkdir -p "$LOCAL_BIN"


declare -A FILES
FILES[".vimrc"]="$DOTFILES_DIR/vim/.vimrc"
FILES[".config/nvim"]="$DOTFILES_DIR/nvim"


mkdir -p "$BACKUP_DIR"

for target_path in "${!FILES[@]}"; do
    src="${FILES[$target_path]}"
    dest="$HOME/$target_path"

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        echo "Copiando $target_path a $BACKUP_DIR..."
        mv "$dest" "$BACKUP_DIR/"
    fi

    echo "Creando symlink: $src -> $dest"
    ln -s "$src" "$dest"
done

if ! command -v lazygit &> /dev/null; then
    echo "Instalando Lazygit en $LOCAL_BIN..."
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    
    tar xf lazygit.tar.gz lazygit
    mv lazygit "$LOCAL_BIN/lazygit"
    rm lazygit.tar.gz
else
    echo "Lazygit ya está instalado."
fi

if ! command -v lazydocker &> /dev/null; then
    echo "Instalando Lazydocker en $LOCAL_BIN..."
    # Forzamos la instalación en .local/bin para evitar sudo
    DIR="$LOCAL_BIN" curl -s https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
else
    echo "Lazydocker ya está instalado."
fi

echo "=========================================="
echo "✅ Instalación completada sin usar sudo."
echo "⚠️  ATENCIÓN: Añade esta línea a tu .bashrc si aún no la tienes:"
echo '    export PATH="$HOME/.local/bin:$PATH"'
echo "=========================================="
