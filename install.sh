#!/bin/bash

# Define paths
DOTFILES_DIR="$HOME/dotfiles"  
BACKUP_DIR="$HOME/dotfiles_backup"

# Files to link and their source directories
declare -A FILES
FILES[".bashrc"]="$DOTFILES_DIR/bash/.bashrc"
FILES[".vimrc"]="$DOTFILES_DIR/vim/.vimrc"

# Create a backup directory
mkdir -p "$BACKUP_DIR"

# Loop through each file and create a symlink
for file in "${!FILES[@]}"; do
    src="${FILES[$file]}"
    dest="$HOME/$file"

    # Backup existing file if it exists
    if [ -e "$dest" ]; then
        echo "Backing up existing $file to $BACKUP_DIR"
        mv "$dest" "$BACKUP_DIR/"
    fi

    # Create symlink
    echo "Linking $src to $dest"
    ln -s "$src" "$dest"
done

echo "Dotfile installation complete!"
