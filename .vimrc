" ==============================================================================
" .vimrc - Clean & Efficient Configuration
" ==============================================================================

" 1. CORE SETTINGS
set nocompatible            " Disable Vi compatibility
filetype plugin indent on   " Enable filetype detection
syntax on                   " Enable syntax highlighting

set number                  " Show absolute line number
set relativenumber          " Show relative line numbers
set mouse=a                 " Enable mouse support
set encoding=utf-8          " Set default encoding to UTF-8
set clipboard=unnamedplus   " Sync Vim clipboard with system OS (allows pasting outside Vim)

" 2. SEARCH & APPEARANCE
set hlsearch                " Highlight search matches
set incsearch               " Highlight matches as you type
set ignorecase              " Ignore case in search...
set smartcase               " ...unless uppercase letters are used

" 3. INDENTATION & SPACES
set tabstop=4               " 1 tab = 4 spaces
set shiftwidth=4            " Auto-indent size
set expandtab               " Convert tabs to spaces
set autoindent              " Keep previous line's indentation

" 4. PLUGINS (vim-plug)
call plug#begin('~/.vim/plugged')

" Theme
Plug 'nordtheme/vim'

" Navigation & Files
Plug 'preservim/nerdtree'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" UI
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Editing Utilities
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'jiangmiao/auto-pairs'

call plug#end()

" 5. THEME CONFIGURATION
set termguicolors
autocmd vimenter * ++nested try | colorscheme nord | catch | endtry

" 6. CUSTOM MAPPINGS
let mapleader = " "         " Set Space as leader key

" File Explorer (NERDTree)
nnoremap <leader>e :NERDTreeToggle<CR>

" File Search (FZF)
nnoremap <leader>f :Files<CR>
nnoremap <leader>s :Rg<CR>

" Save & Quit
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>

" Window Splits Navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Clear Search Highlight
nnoremap <leader>l :nohlsearch<CR>
