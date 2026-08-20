#!/bin/bash

# Define paths
DOTFILES_DIR="$HOME/dotfiles"  
BACKUP_DIR="$HOME/dotfiles_backup"

# Asegurarse de que el directorio .config existe (necesario para Neovim)
mkdir -p "$HOME/.config"

# Files and directories to link and their source locations
declare -A FILES
FILES[".bashrc"]="$DOTFILES_DIR/bash/.bashrc"
FILES[".vimrc"]="$DOTFILES_DIR/vim/.vimrc"
FILES[".config/nvim"]="$DOTFILES_DIR/nvim"

# Create a backup directory
mkdir -p "$BACKUP_DIR"

# Loop through each file/dir and create a symlink
for target_path in "${!FILES[@]}"; do
    src="${FILES[$target_path]}"
    dest="$HOME/$target_path"

    # Backup existing file, directory, or symlink if it exists (-L atrapa enlaces rotos)
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        echo "Backing up existing $target_path to $BACKUP_DIR"
        mv "$dest" "$BACKUP_DIR/"
    fi

    # Create symlink
    echo "Linking $src to $dest"
    ln -s "$src" "$dest"
done

echo "Dotfiles setup complete!"
