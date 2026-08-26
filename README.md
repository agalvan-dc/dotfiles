# My Dotfiles & Neovim Setup

## What Are Dotfiles?

Dotfiles are hidden configuration files (often prefixed with a dot) that store personalized settings for terminal tools. Keeping them in a Git repository allows for instant environment replication across different computers.

---

## Installation Guide

* **Clone the repository:** Download the configuration files to your local machine by running:
```bash
git clone <your-repo-url> ~/.dotfiles

```


* **Symlink Classic Vim:** Create a symbolic link for your Vim configuration:
```bash
ln -s ~/.dotfiles/.vimrc ~/.vimrc

```


* **Deploy Neovim Setup:** Link the Neovim folder to your standard config directory, ensuring Neovim detects your `init.lua` and plugin structure:
```bash
ln -s ~/.dotfiles/nvim ~/.config/nvim

```



---

## Overview of Configurations

### Neovim Configuration (Lua)

* **Core Mechanics:** Configures the Spacebar as the primary leader key, enables relative line numbering, integrates the system clipboard (`unnamedplus`), and defaults window splits to appear on the right and bottom.
* **Plugin Management:** Automatically bootstraps `lazy.nvim` to handle the installation and updating of all extensions on launch.
* **Essential Plugins:** Utilizes `Tokyonight` for aesthetics, `Treesitter` for advanced syntax parsing, `Telescope` for fuzzy finding, `Neo-tree` for file browsing, and `Harpoon` for rapid navigation between frequently used files.
* **LSP & Custom Keybindings:** Activates Language Server Protocols for C/C++, Python, Lua, and Rust, while mapping custom shortcuts—like `<leader>w` to save, `J`/`K` to move highlighted code blocks, and `gd` to jump to function definitions—for extreme coding speed.

### Classic Vim Configuration (`.vimrc`)

* **Visuals & Interface:** Enables syntax highlighting, true 24-bit colors (`termguicolors`), relative line numbers for easy jumping, and an enhanced `wildmenu` for command-line autocompletion.
* **Formatting:** Standardizes indentation to 4 spaces, automatically converts tabulations to spaces, and enables smart code block indentation.
* **Search & System:** Implements smart-case search sensitivity, highlights matching results, allows buffer switching without saving (`set hidden`), and maintains a persistent undo history across sessions.
* **Keymaps:** Includes custom bindings to clear search highlighting via `Space + c` and seamless window split navigation using `Ctrl + h/j/k/l`.

---

### External Integrations (Lazydocker)
While not directly installed via Neovim's package manager, this configuration is optimized to work seamlessly with **Lazydocker**, a terminal UI for both Docker and Docker Compose. 

* **Prerequisite:** You must install Lazydocker on your host operating system (e.g., via `curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash` or their official install script).
* **Usage in Neovim:** Press `<leader>ld` to instantly open a Neovim terminal window running Lazydocker. This allows you to monitor container logs, restart services, and prune images without ever leaving your editor.

---

## Neovim Configuration (Detailed)

### Plugin Architecture & Usage

Your setup uses `lazy.nvim` as the package manager, which automatically bootstraps itself on startup.

| Plugin | Purpose & Functionality | Usage / Triggers |
| --- | --- | --- |
| **Tokyonight** | Sets the core visual colorscheme to "night". | Loads automatically on startup. |
| **Render Markdown** | Enhances markdown files with visual rendering. | Activates automatically in `.md` files. |
| **Treesitter** | Provides advanced syntax highlighting via parsers. | Auto-highlights C, C++, Python, Rust, Lua, and Markdown. |
| **Mason** | Package manager for LSPs, linters, and formatters. | Type `:Mason` to open the GUI and install tools. |
| **Which-Key** | Displays a popup cheat sheet of available keybinds. | Triggers automatically after holding any key for 300ms. |
| **Bufferline** | Creates a top tab bar with slanted separators. | Auto-displays open buffers and LSP diagnostics. |
| **Flash** | Enables ultra-fast screen navigation. | Press `s` (Normal/Visual), type the highlighted letters to jump. |
| **Harpoon** | Pins frequently used files for instant navigation. | `<leader>ha` (pin), `<leader>hh` (menu), `<leader>1-4` (jump). |
| **Project.nvim** | Auto-detects project root directories. | Triggers when `.git`, `Makefile`, or `package.json` are found. |
| **Gitsigns** | Integrates Git status into the gutter. | `<leader>gp` (preview), `<leader>gr` (reset hunk), `]g`/`[g` (navigate). |
| **Neo-tree** | Sidebar file explorer. | Toggle open/closed using `<leader>e`. |
| **Telescope** | Fuzzy finder for files, text, and projects. | `<leader>ff` (files), `<leader>fg` (text), `<leader>fb` (buffers), `<leader>fp` (projects). |
| **Tmux Navigator** | Allows seamless pane switching between Vim and Tmux. | Use `<C-h>`, `<C-j>`, `<C-k>`, `<C-l>` to move directionally. |
| **Lspconfig** | Configures Language Servers (clangd, pyright, ruff, lua_ls). | Auto-attaches to provide code intelligence. |
| **Rustaceanvim** | Specialized Rust development support. | Auto-loads exclusively for Rust filetypes. |

---

### Comprehensive Keymap Reference

Configuration uses the Space bar as both the `<leader>` and `<localleader>` key.

| Shortcut | Mode | Action & Description |
| --- | --- | --- |
| `<leader>w` / `<C-s>` | Normal / Insert | Saves the current file. |
| `<leader>q` | Normal | Closes the current window. |
| `<Esc>` | Normal | Clears active search highlighting. |
| `J` / `K` | Visual | Moves the highlighted block of code down or up respectively. |
| `<C-d>` / `<C-u>` | Normal | Scrolls a half-page down/up while keeping the cursor centered. |
| `n` / `N` | Normal | Jumps to the next/previous search result, keeping it centered. |
| `<leader>p` | Visual | Pastes over highlighted text without replacing your clipboard. |
| `<S-l>` / `<S-h>` | Normal | Cycles to the next or previous buffer tab. |
| `<leader>bd` | Normal | Closes the currently active buffer tab. |
| `<leader>sv` / `<leader>sh` | Normal | Splits the screen vertically or horizontally. |
| `gd` / `gr` | Normal | Jumps to LSP definition or shows variable references. |
| `K` | Normal | Displays LSP hover documentation. |
| `<leader>rn` / `<leader>ca` | Normal | Renames a variable project-wide or opens LSP code actions. |

---

## Automated Installation Script

The included `install.sh` script automates the installation by creating symbolic links for Neovim and Vim, while safely backing up any pre-existing configuration files to avoid data loss.

### How it Works

* **Path Resolution:** Detects the repository's absolute directory location regardless of where you execute the script from.
* **Automatic Backup:** Checks if target files (`~/.config/nvim` or `~/.vimrc`) already exist. If found, it moves them to a timestamped directory at `~/.dotfiles_backup_YYYYMMDD_HHMMSS/`.
* **Symlink Creation:** Creates active symbolic links connecting `~/.config/nvim` and `~/.vimrc` directly to your repository files.

### Execution

Run the following commands in your terminal:

```bash
# Make the installation script executable
chmod +x install.sh

# Run the installation script
./install.sh

```
