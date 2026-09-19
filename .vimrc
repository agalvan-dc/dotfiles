" =============================================================================
" .vimrc - Portable, plugin-rich Vim configuration
" Leader key is <Space>. See README.md for the full keymap reference.
" =============================================================================

" ---------------------------------------------------------------------------
" 1. Core settings
" ---------------------------------------------------------------------------
set nocompatible                 " Break out of Vi compatibility mode
filetype plugin indent on        " Filetype detection, plugins and indentation
syntax on                        " Syntax highlighting

set number                       " Absolute line numbers
set relativenumber               " Relative line numbers
set hidden                       " Move between unsaved buffers
set confirm                      " Confirm instead of failing on :q
set showcmd                      " Show partial commands in the status line
set ruler                        " Always show the cursor position
set laststatus=2                 " Always show the status line
set mouse=a                      " Mouse support in all modes
set encoding=utf-8               " Default encoding UTF-8
set fileencodings=utf-8,latin1   " UTF-8 first, fall back gracefully
set nobackup                     " No ~ backup files
set noswapfile                   " No swap files (use git instead)
set undofile                     " Persistent undo across sessions
set undodir=~/.vim/undo//        " Central undo storage (// avoids collisions)
set undolevels=1000

if has('clipboard')
    set clipboard=unnamedplus    " Sync with the OS clipboard when available
endif

" ---------------------------------------------------------------------------
" 2. Search
" ---------------------------------------------------------------------------
set hlsearch                     " Highlight search matches
set incsearch                    " Highlight as you type
set ignorecase                   " Case-insensitive search...
set smartcase                    " ...unless an uppercase letter is typed

" ---------------------------------------------------------------------------
" 3. Indentation & spaces
" ---------------------------------------------------------------------------
set tabstop=4                    " Visual width of a tab
set softtabstop=4                " Tab key step in insert mode
set shiftwidth=4                 " Indentation width (>>, <<, autoindent)
set expandtab                    " Use spaces instead of tabs
set smarttab                     " Backspace respects shiftwidth
set autoindent                   " Keep the previous line's indentation

" ---------------------------------------------------------------------------
" 4. Appearance & behaviour
" ---------------------------------------------------------------------------
if has('termguicolors')
    set termguicolors            " True color support when the terminal allows it
endif

set scrolloff=8                  " Keep 8 lines of context above/below the cursor
set sidescrolloff=5              " Horizontal scrolling context
set signcolumn=yes               " Always reserve space for Git/error signs
set wildmenu                     " Better command-line completion
set wildmode=longest:full,full   " Cycle through completions
set splitright                   " :vsplit opens on the right
set splitbelow                   " :split opens below
set updatetime=50                " Faster plugin/tool lag response
set timeoutlen=500               " Leader + key timeout
set backspace=indent,eol,start   " Backspace works across everything
set listchars=tab:▸\ ,trail:·    " Visible tabs and trailing whitespace
set noshowmode                   " airline shows the mode

" Make sure the persistent undo directory exists
if !isdirectory(expand('~/.vim/undo'))
    call mkdir(expand('~/.vim/undo'), 'p')
endif

" ---------------------------------------------------------------------------
" 5. Plugins (vim-plug)
" ---------------------------------------------------------------------------
call plug#begin('~/.vim/plugged')

" Theme
Plug 'nordtheme/vim'

" Navigation & files
Plug 'preservim/nerdtree'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug '42Paris/42header'

" Git
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-repeat'

" Cscope / Gtags (símbolos en proyectos grandes)
Plug 'ludovicchabant/vim-gutentags'
Plug 'skywind3000/gutentags_plus'

" Editing utilities
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'jiangmiao/auto-pairs'
Plug 'machakann/vim-highlightedyank'
Plug 'mbbill/undotree'

" Advanced editing
Plug 'mg979/vim-visual-multi'   " Multi-cursor (Ctrl+n)
Plug 'wellle/targets.vim'       " Text objects (ia, aa, i), a), ...)
Plug 'tpope/vim-dispatch'       " Asynchronous builds (:Make, :Dispatch)

" Status line
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ryanoasis/vim-devicons'

call plug#end()

" ---------------------------------------------------------------------------
" 6. Theme
" ---------------------------------------------------------------------------
autocmd vimenter * ++nested try | colorscheme nord | catch | endtry
let g:airline_theme = 'nord'
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'short_path'
let g:VM_theme = 'nord'

" ---------------------------------------------------------------------------
" 7. Custom mappings (leader = <Space>)
" ---------------------------------------------------------------------------
let mapleader = " "

" Save & quit
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
inoremap jj <Esc>

" Jump to previous buffer
nnoremap <leader><leader> <C-^>

" Keep the visual selection when shifting indentation
vnoremap < <gv
vnoremap > >gv

" Move lines up/down in visual mode
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Window splits & navigation
nnoremap <leader>sv :vsplit<CR>
nnoremap <leader>sh :split<CR>
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Open a terminal in a new buffer (same as :term)
nnoremap <leader>t :terminal<CR>

" Run make asynchronously (vim-dispatch)
nnoremap <leader>m :Make<CR>

" Buffers
nnoremap <S-l> :bnext<CR>
nnoremap <S-h> :bprevious<CR>
nnoremap <leader>bd :bdelete<CR>

" Search
nnoremap <leader>l :nohlsearch<CR>
nnoremap * *N        " Highlight all occurrences without moving

" +42 header
nnoremap <leader>h :Stdheader<CR>

" File explorer & fuzzy search
nnoremap <leader>e :NERDTreeToggle<CR>
nnoremap <leader>f :Files<CR>
nnoremap <leader>s :Rg<CR>

" Git (fugitive)
nnoremap <leader>gg :Git<CR>
nnoremap <leader>gd :Gvdiffsplit<CR>

" Undo tree
nnoremap <leader>u :UndotreeToggle<CR>

" Y acts like the other capital commands (yank to end of line)
nnoremap Y y$

" ---------------------------------------------------------------------------
" 8. Cscope & Gtags (vim-gutentags + gutentags_plus)
"    Símbolos de C/C++: definiciones, llamadas, referencias...
" ---------------------------------------------------------------------------
let g:gutentags_define_advanced_commands = 1
let g:gutentags_modules = ['ctags', 'gtags_cscope']
let g:gutentags_project_root = ['.root', '.git', '.hg', '.project']
let g:gutentags_ctags_tagfile = '.tags'
let g:gutentags_cache_dir = expand('~/.cache/vim/ctags/')
let g:gutentags_plus_nomap = 1 " No usar los mapeos por defecto (los defino aquí)
let g:gutentags_plus_switch = 1 " Cambiar el foco a la ventana de resultados

" Los resultados se abren en la ventana de resultados (quickfix).
" Nota: <leader>gg y <leader>gd ya están tomados por Git (fugitive),
" así que "definición" va en <leader>gD y "funciones a las que llama" en <leader>gB.
noremap <silent> <leader>gs :GscopeFind s <C-R><C-W><cr>   " Símbolo (C symbol)
noremap <silent> <leader>gD :GscopeFind g <C-R><C-W><cr>   " Definición
noremap <silent> <leader>gc :GscopeFind c <C-R><C-W><cr>   " Funciones que llaman a esto
noremap <silent> <leader>gt :GscopeFind t <C-R><C-W><cr>   " Texto
noremap <silent> <leader>ge :GscopeFind e <C-R><C-W><cr>   " Patrón egrep
noremap <silent> <leader>gf :GscopeFind f <C-R>=expand("<cfile>")<cr><cr> " Archivo
noremap <silent> <leader>gi :GscopeFind i <C-R>=expand("<cfile>")<cr><cr> " Archivos que incluyen esto
noremap <silent> <leader>gB :GscopeFind d <C-R><C-W><cr>   " Funciones a las que llama
noremap <silent> <leader>ga :GscopeFind a <C-R><C-W><cr>   " Dónde se asigna un valor
noremap <silent> <leader>gz :GscopeFind z <C-R><C-W><cr>   " Llamadas a esta función