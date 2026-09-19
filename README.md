# dotfiles

Portable, opinionated shell and editor configurations that follow you from
machine to machine. One command installs your whole environment — no `sudo`
required.

## Why these dotfiles?

* **No sudo needed.** Everything lives under `$HOME`: symlinked configs,
  `$HOME/.local/bin` for standalone tools, and per-user plugin directories.
* **Selective install.** The installer has an interactive menu plus CLI flags,
  so you can ship only the pieces you actually want.
* **Safe.** Existing files are never deleted — they are backed up to
  `~/dotfiles_backup_<timestamp>/` first.
* **Portable.** Machine-specific junk (KDE state, shell history, DPI scaling)
  is intentionally left out. Per-machine tweaks go in `~/.bashrc.local`.

## What's inside

| Component | File(s) | Description |
| --- | --- | --- |
| **Shell (bash)** | `.bashrc` | Aliases, helper functions, Git-aware prompt, PATH handling |
| **Shell (fish)** | `.config/fish/config.fish` | PATH, editor, Git abbreviations |
| **Git** | `templates/gitconfig`, `templates/gitignore_global` | Generated identity + global ignores |
| **Vim** | `.vimrc` | Nord theme, vim-plug, Git/editing/multi-cursor plugins, `<Space>` leader |
| **Neovim** | `.config/nvim/` | lazy.nvim, Telescope, Treesitter, LSP, Harpoon, formatting (conform), sessions, terminal |
| **Tmux** | `.tmux.conf` | Mouse support, true color, transparent pane navigation with Vim |
| **GTK** | `.config/gtk-{3,4}.0/settings.ini` | Portable dark-theme preference |
| **Tools** | installer-managed | Lazygit and Lazydocker installed to `~/.local/bin` |
| **Templates** | `templates/` | Git config, global gitignore, SDL2/CMake starter |

> A personal walk-through of the Neovim setup (mapping cheatsheet, LSP and
> plugin usage, workflows) lives in `.config/nvim/GUIA_NVIM.txt`.

## Requirements

* `git`, `curl`, `tar` and `sed` (present on essentially every Linux/macOS box)
* `vim` and/or `nvim` for the editor components
* `fish` and `tmux` only if you install those components

The installer detects the OS and architecture automatically. Linux and macOS
(x86_64 and arm64) are supported for tool downloads.

## Installation

```bash
# 1. Clone the repository
git clone --depth=1 <your-repo-url> ~/.dotfiles
cd ~/.dotfiles

# 2. Run the installer (interactive menu)
./install.sh

# …or pick everything without asking
./install.sh --all
```

### Interactive menu

| Option | Installs |
| --- | --- |
| `1` Full setup | Every component below |
| `2` Vim + Neovim | Both editors |
| `3` Vim only | Vim + plugins |
| `4` Neovim only | Neovim + plugins |
| `5` Shell | bash, fish, Git config |
| `6` Tmux | tmux config |
| `7` Tools | Lazygit + Lazydocker → `~/.local/bin` |
| `8` Quit | — |

The menu loops, so you can stack several options in one run.

### CLI flags

Combine flags freely — components are installed in order.

| Flag | Installs |
| --- | --- |
| `--all` | Everything |
| `--shell` | bash, fish, Git config |
| `--vim` | Vim config + vim-plug + plugins |
| `--nvim` | Neovim config (plugins auto-install on first launch) |
| `--tmux` | Tmux config |
| `--tools` | Lazygit + Lazydocker |
| `-h`, `--help` | Show help |

Example:

```bash
./install.sh --shell --vim --tmux      # everything except Neovim and tools
```

### First run (after the installer)

```bash
source ~/.bashrc       # or simply open a new shell
nvim                   # first launch downloads all plugins via lazy.nvim
```

The installer asks for your Git name and email once and generates
`~/.gitconfig` from `templates/gitconfig` (with sensible defaults such as
`main` as the default branch and `diff3` as the merge conflict style, which
is auto-upgraded to `zdiff3` when Git >= 2.35 is available).

## Manual installation

If you prefer to skip the script, symlinking one or two files is enough:

```bash
ln -s "$PWD/.bashrc" ~/.bashrc
ln -s "$PWD/.vimrc" ~/.vimrc
ln -s "$PWD/.tmux.conf" ~/.tmux.conf
ln -s "$PWD/.config/nvim" ~/.config/nvim
ln -s "$PWD/.config/fish/config.fish" ~/.config/fish/config.fish
```

Remember to back up anything already at those paths first.

## Keymaps (quick reference)

### Common (bash/vim/neovim)

| Keys | Action |
| --- | --- |
| `jj` | Exit insert mode (Vim) |
| `<leader><leader>` | Jump to previous buffer |
| `J` / `K` | Move selected lines down/up |
| `Ctrl+h/j/k/l` | Move between splits/panes |
| `<leader>t` | Open a new terminal buffer (same as `:term`) |

### Vim `<leader>` = `<Space>`

| Keys | Action |
| --- | --- |
| `<leader>w` / `<leader>q` | Save / quit |
| `<leader>e` | Toggle NERDTree |
| `<leader>f` / `<leader>s` | Fuzzy-find files / search text (fzf + Rg) |
| `<leader>gg` / `<leader>gd` | Fugitive status / vertical diff |
| `<leader>u` | Toggle the undo tree |
| `<leader>l` | Clear search highlight |
| `<leader>h` | Insert the 42 header |
| `<leader>sv` / `<leader>sh` | Vertical / horizontal split |
| `<leader>m` | Run `make` asynchronously (vim-dispatch) |

### Neovim `<leader>` = `<Space>`

| Keys | Action |
| --- | --- |
| `<leader>w` / `<C-s>` | Save (works in insert mode too) |
| `<leader>e` | Toggle Neo-tree file explorer |
| `<leader>ff` / `fg` / `fb` / `fp` | Find files / text / buffers / projects |
| `<leader>ha` / `hh` / `1-4` | Harpoon: pin, list, jump |
| `gd` / `gr` | Go to definition / references |
| `K` | LSP hover documentation |
| `<leader>rn` / `<leader>ca` | Rename symbol / code actions |
| `<leader>lg` / `<leader>ld` | Open Lazygit / Lazydocker |
| `<leader>ct` | Switch colorscheme |
| `<leader>9` | Insert the 42 header |
| `<leader>cf` | Format the current file (conform.nvim) |
| `<leader>ss` / `so` / `sl` / `sd` | Sessions: save / restore / last / delete |
| `ys` / `cs` / `ds` | Surround: add / change / delete |
| `Ctrl+n` | Multi-cursor: add the next occurrence |

> The complete reference with per-plugin details is in
> `.config/nvim/GUIA_NVIM.txt`.

## Terminal & extras

> This setup intentionally ships **no autocompletion engine and no AI
> assistants** — LSP servers provide the language intelligence.

### Terminal (`<leader>t`)

Opens a fresh terminal buffer exactly like `:term`, in both Vim and
Neovim. Press it again to spawn another one.

* In Neovim, return to Normal mode with `<Esc><Esc>` or `<C-o>`.
* In Vim, return to Normal mode with `<C-\><C-n>`.
* Inside any terminal split you can still move between windows with
  `Ctrl+h/j/k/l`.

### Formatting on save (Neovim)

`conform.nvim` runs a formatter automatically on every save, per file type:

| File type | Formatter |
| --- | --- |
| C / C++ | `clang-format` |
| Python | `ruff format` |
| Lua | `stylua` |
| Rust | `rustfmt` |
| Shell | `shfmt` |
| Markdown / JSON | `prettier` |

Install the formatters once with `:Mason` (`clang-format`, `stylua`, `shfmt`,
`prettier`; `ruff` already ships `ruff format`). Run `<leader>cf` to format the
current file manually.

### Surround (`ys` / `cs` / `ds`)

Add, change or delete surrounding characters in both editors (`nvim-surround`
in Neovim, `vim-surround` in Vim):

* `ysiw"`  — wrap the word under the cursor in double quotes
* `cs"'`   — change `"text"` into `'text'`
* `ds"`    — delete the surrounding quotes

In Vim, `wellle/targets.vim` adds text objects such as `ia`/`aa` (argument)
and `i)`/`a)` that also make `vim-surround` and `vim-commentary` far more
powerful (e.g. `ysa"'`).

### Session persistence (Neovim)

`persistence.nvim` saves your window layout and buffers automatically when you
quit, and restores them when you reopen a project. Manual controls:

| Keys | Action |
| --- | --- |
| `<leader>ss` | Save the current session |
| `<leader>so` | Restore the session for this directory |
| `<leader>sl` | Restore the last-used session |
| `<leader>sd` | Stop persistence (delete the session) |

Session keys use the `<leader>s*` prefix on purpose, so `<leader>q` (quit)
stays instant.

### Multi-cursor (both editors)

`vim-visual-multi`: place the cursor on a word and press `Ctrl+n` to select the
next occurrence. Keep pressing to add more cursors, then edit them all at once.
Each `Ctrl+n` adds one cursor; `Ctrl+p` moves back and `<leader>x` cancels.

### Indentation guides (Neovim)

`indent-blankline.nvim` draws subtle vertical guides and highlights the current
indentation scope automatically — no keys involved.

### Asynchronous builds (Vim)

`vim-dispatch` lets you build without blocking the editor:

* `<leader>m` — run `:Make` (uses your `makeprg`); results appear once ready
* `:Dispatch` — run any command (e.g. `:Dispatch cmake ..`) in the background

## Machine-specific configuration

Portability means shared configs stay generic. Drop anything machine-specific
into a file never tracked by git:

```bash
# ~/.bashrc.local
alias myprinter='lp -d office_printer'
export MY_WORK_TOKEN="…"
```

`.bashrc` sources `~/.bashrc.local` if it exists.

## Uninstall

There is no script on purpose — reversing is trivial. For every symlink created
by the installer, point `readlink` at your `~/dotfiles_backup_*` directory:

```bash
# Example: restore the previous shell config
mv ~/dotfiles_backup_<timestamp>/.bashrc ~/.bashrc
# Remove a symlink created by the installer
rm ~/.vimrc
```

Tools installed to `~/.local/bin` (lazygit, lazydocker) are removed by deleting
those two binaries.

## Directory layout

```
.
├── .bashrc                    # Bash shell config
├── .vimrc                     # Vim config + plugins
├── .tmux.conf                 # Tmux config
├── install.sh                 # Portable installer (menu + CLI flags)
├── .config/
│   ├── nvim/                  # Neovim (lazy.nvim) config + personal guide
│   ├── fish/config.fish       # Fish shell config
│   └── gtk-{3,4}.0/settings.ini
└── templates/
    ├── gitconfig              # Git identity template ({{NAME}} / {{EMAIL}})
    ├── gitignore_global       # Global git ignore rules
    └── ...                    # SDL2/CMake project starter
```

## Troubleshooting

* **`vim` has no clipboard** — some minimal builds lack `+clipboard`. `.vimrc`
  guards against it; install `vim-gtk3` / `neovim` for full clipboard support.
* **Icons show as boxes** — install a Nerd Font and use it as your terminal
  font; `vim-devicons` and the Neovim UI depend on one.
* **Plugins don't appear after install** — run `:PlugInstall` inside Vim, or
  simply launch `nvim` once to let lazy.nvim bootstrap.
* **`yq`/`jq` errors** — the installer uses `sed` for JSON parsing on purpose,
  so no extra tools are required.
* **Tree-sitter parsers won't install on a fresh machine** — parsers are
  compiled locally on first launch, so the machine needs a C toolchain
  (`gcc`/`clang` and `git`). Ubuntu/Debian: `sudo apt install build-essential`.
  Fedora: `sudo dnf groupinstall "Development Tools"`. Parsers land in
  `~/.local/share/nvim/site/parser/`.
* **Telescope errors on a new machine** — make sure the config is not pinned to
  the obsolete `0.1.x` branch (it is on `master` here, which is the only one
  compatible with Neovim 0.11+). If you cloned an older state, run
  `:Lazy update telescope.nvim`.
* **`project.nvim` problem after installing elsewhere** — the `projects`
  Telescope extension is loaded behind a `pcall` guard, so Telescope keeps
  working even when that plugin misbehaves; fix it with
  `:Lazy update project.nvim`.
* **Terminal spawned with `<leader>t`** — exiting to Normal mode: Neovim
  `<Esc><Esc>` or `<C-o>`; Vim `<C-\><C-n>`. Then `q`/`<leader>q` closes the
  terminal buffer as usual.
* **A change didn't apply** — configs are symlinks to this repo, so edits are
  live. Reminder: `source ~/.bashrc` reloads the shell config.

## License

MIT — use it, adapt it, break it.