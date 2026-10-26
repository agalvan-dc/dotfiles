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
Plug 'menisadi/kanagawa.vim'      " Kanagawa (port de rebelot/kanagawa a Vim)
Plug 'shrikecode/kyotonight.vim'  " Tokyo Night + Nord (funciona en Vim y Neovim)

" Markdown renderizado dentro del propio Vim
Plug 'preservim/vim-markdown'

" Navigation & files
Plug 'preservim/nerdtree'   " NERDTree: scrooloose/nerdtree redirige aquí
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

" Iconos por tipo de archivo (Nerd Font) — SIEMPRE el último plugin
Plug 'ryanoasis/vim-devicons'

call plug#end()

" ---------------------------------------------------------------------------
" 6. Tema: elección + persistencia POR CARPETA
"
" Temas disponibles:
"   kanagawa   -> Kanagawa (por defecto)
"   kyotonight -> Tokyo Night + Nord
"   nord       -> Nord
"
" El tema elegido se guarda POR RUTA (igual que en Neovim): al reabrir la
" misma carpeta se restaura sola. Archivo por ruta en:
"     ~/.cache/vim/themes/<hash>.txt   (línea 1 = ruta, línea 2 = tema)
" ---------------------------------------------------------------------------
let g:dotfiles_theme_default = 'kanagawa'
" airline se adapta al tema activo
let g:dotfiles_airline_map = {
      \ 'kanagawa':   'hybrid',
      \ 'kyotonight': 'hybrid',
      \ 'nord':       'nord_minimal',
      \ }

function! s:DfThemeNormalize(dir) abort
    let l:p = simplify(a:dir)
    return substitute(l:p, '/$', '', '')
endfunction

" El primer argumento puede ser un archivo o una carpeta; Vim no hace :cd,
" así que la ruta se deduce del primer buffer (o del cwd si no hay nada).
function! s:DfThemeRoute() abort
    let l:name = bufname(1)
    if empty(l:name)
        return s:DfThemeNormalize(getcwd())
    endif
    if isdirectory(l:name)
        return s:DfThemeNormalize(fnamemodify(l:name, ':p'))
    endif
    return s:DfThemeNormalize(fnamemodify(l:name, ':h'))
endfunction

" Vim no tiene stdpath() (eso es Neovim): usamos XDG_CACHE_HOME
function! s:DfThemeFile(dir) abort
    let l:cache = empty($XDG_CACHE_HOME) ? expand('~/.cache') : $XDG_CACHE_HOME
    return l:cache . '/vim/themes/' . sha256(a:dir)[:20] . '.txt'
endfunction

" ¿Existe ese colorscheme en el runtimepath? (protege de plugins borrados)
function! s:DfThemeValid(name) abort
    if empty(a:name)
        return 0
    endif
    return len(globpath(&runtimepath, 'colors/' . a:name . '.vim')) > 0
endfunction

function! s:DfThemeRead(dir) abort
    let l:file = s:DfThemeFile(a:dir)
    if !filereadable(l:file)
        return ''
    endif
    let l:lines = readfile(l:file)
    if len(l:lines) < 2 || l:lines[0] !=# a:dir
        return ''
    endif
    return l:lines[1]
endfunction

function! s:DfThemeWrite(dir, name) abort
    if empty(a:dir) || empty(a:name)
        return
    endif
    let l:dir = s:DfThemeFile(a:dir)
    call mkdir(fnamemodify(l:dir, ':h'), 'p')
    call writefile([a:dir, a:name], l:dir)
endfunction

" Nombre del tema ACTIVO.
" g:colors_name no sirve solo en Vim: ":hi clear" la borra y varios
" colorschemes (kanagawa.vim entre ellos) la asignan ANTES de ese ":hi clear",
" así que se queda sin definir. Por eso nos apoyamos en el nombre que
" guardamos nosotros al aplicar, y solo como plan B usamos lo que Vim dice.
function! s:DfCurrentTheme() abort
    let l:name = get(g:, 'colors_name', '')
    if empty(l:name)
        let l:out = trim(execute('colorscheme'))
        let l:out = substitute(l:out, '^.*currently using \zs', '', '')
        let l:name = trim(split(l:out, "\n")[0])
    endif
    if empty(l:name) || l:name ==# 'default'
        let l:name = get(g:, 'dotfiles_theme_wanted', '')
    endif
    return l:name
endfunction

" Aplica tema + barra de estado + iconos recoloreados
function! s:DfThemeApply(name) abort
    let l:name = a:name
    if !s:DfThemeValid(l:name)
        let l:name = g:dotfiles_theme_default
    endif
    try
        execute 'colorscheme ' . l:name
    catch
        let l:name = g:dotfiles_theme_default
        execute 'colorscheme ' . l:name
    endtry
    " Si el colorscheme no dejó g:colors_name (lo borra "hi clear"), la
    " dejamos puesta con el nombre que realmente aplicamos.
    if !exists('g:colors_name')
        let g:colors_name = l:name
    endif
    let g:airline_theme = get(g:dotfiles_airline_map, l:name, 'hybrid')
    " vim-devicons 0.11.0 expone la API como webdevicons#hardRefresh();
    " las funciones WebDevIconsGetFileIcon/VimDevIconsRefresh son de forks.
    if exists('*webdevicons#hardRefresh')
        call webdevicons#hardRefresh()
    endif
    " Los plugins pueden poner su propio colorscheme en SU VimEnter (que se
    " registra despues del nuestro). Un timer a 0ms corre cuando ya han
    " terminado todos los autocmd: si se han impuesto, imponemos el nuestro.
    let g:dotfiles_theme_wanted = l:name
    call s:DfThemeReassert()
    return l:name
endfunction

function! s:DfThemeReassert() abort
    if empty(get(g:, 'dotfiles_theme_wanted', ''))
        return
    endif
    call timer_start(0, {-> s:DfCurrentTheme() ==# g:dotfiles_theme_wanted
          \ ? 0
          \ : execute('colorscheme ' . g:dotfiles_theme_wanted)})
endfunction

let g:dotfiles_theme_dir = ''
let g:dotfiles_theme_grab = 1 " suspendido hasta terminar el arranque
let g:dotfiles_theme_pending = {}
let g:dotfiles_theme_wanted = ''

function! s:DfThemeFlush() abort
    let l:p = g:dotfiles_theme_pending
    let g:dotfiles_theme_pending = {}
    if !empty(l:p) && !g:dotfiles_theme_grab
        call s:DfThemeWrite(l:p.dir, l:p.name)
    endif
endfunction

" El picker de fzf/Telescope no existe aquí, pero preview o scripts pueden
" cambiar el tema rápido: escribimos con 150ms de calma (gana el último).
function! s:DfThemeQueue() abort
    if g:dotfiles_theme_grab || empty(g:dotfiles_theme_dir)
        return
    endif
    let g:dotfiles_theme_pending = {
          \ 'dir': g:dotfiles_theme_dir,
          \ 'name': s:DfCurrentTheme(),
          \ }
    if exists('g:dotfiles_theme_timer')
        call timer_stop(g:dotfiles_theme_timer)
    endif
    let g:dotfiles_theme_timer = timer_start(150, {-> s:DfThemeFlush()})
endfunction

" :cd (o salto entre carpetas) -> la ruta vieja conserva su tema
function! s:DfThemeDirChanged() abort
    let l:new = s:DfThemeNormalize(getcwd())
    if l:new ==# g:dotfiles_theme_dir
        return
    endif
    call s:DfThemeQueue() " flush del tema de la ruta anterior
    let g:dotfiles_theme_dir = l:new
    let l:saved = s:DfThemeRead(l:new)
    if empty(l:saved) || !s:DfThemeValid(l:saved)
        call s:DfThemeApply(g:dotfiles_theme_default)
    else
        call s:DfThemeApply(l:saved)
    endif
endfunction

function! s:DfThemeRestore() abort
    let g:dotfiles_theme_dir = s:DfThemeRoute()
    let l:saved = s:DfThemeRead(g:dotfiles_theme_dir)
    " Ruta sin tema guardado -> el de por defecto, para no arrancar sin color
    if empty(l:saved) || !s:DfThemeValid(l:saved)
        call s:DfThemeApply(g:dotfiles_theme_default)
    else
        call s:DfThemeApply(l:saved)
    endif
    let g:dotfiles_theme_grab = 0
    call s:DfThemeWrite(g:dotfiles_theme_dir, s:DfCurrentTheme())
endfunction

augroup DotfilesTheme
    autocmd!
    autocmd ColorScheme * call s:DfThemeQueue()
    autocmd DirChanged * call s:DfThemeDirChanged()
    autocmd VimEnter * call s:DfThemeRestore()
    autocmd VimLeavePre * call s:DfThemeWrite(empty(g:dotfiles_theme_dir) ? s:DfThemeRoute() : g:dotfiles_theme_dir, s:DfCurrentTheme())
augroup END

function! s:DfThemeComplete(arglead, cmdline, cursorpos) abort
    let l:names = split(globpath(&runtimepath, 'colors/*.vim'), '\n')
    call map(l:names, 'fnamemodify(v:val, ":t:r")')
    return sort(uniq(filter(copy(l:names), 'v:val =~# "^" . a:arglead')))
endfunction

function! s:DfThemeSwitch(name) abort
    if !s:DfThemeValid(a:name)
        echo 'Tema no encontrado: ' . a:name | return
    endif
    let l:applied = s:DfThemeApply(a:name)
    echo 'Tema: ' . l:applied . '  (guardado para esta ruta)'
endfunction

function! s:DfThemeList() abort
    call s:DfThemeComplete('', '', 0)
    echomsg 'Temas: ' . join(s:DfThemeComplete('', '', 0), ', ')
endfunction

function! s:DfThemeReset() abort
    if !empty(g:dotfiles_theme_dir)
        call delete(s:DfThemeFile(g:dotfiles_theme_dir))
    endif
    call s:DfThemeApply(g:dotfiles_theme_default)
    echomsg 'Tema de esta ruta borrado: ' . g:dotfiles_theme_default
endfunction

command! -nargs=1 -complete=customlist,s:DfThemeComplete Theme call s:DfThemeSwitch(<f-arg>)
command! ThemeReset call s:DfThemeReset()
command! Themes call s:DfThemeList()

let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'short_path'
let g:VM_theme = 'nord'

" ---------------------------------------------------------------------------
" 7. Iconos por tipo de archivo (vim-devicons + Nerd Font)
"    Salen en NERDTree (<leader>e), fzf (<leader>f) y la barra de pestañas.
"    La Nerd Font (JetBrainsMono Nerd Font) ya está instalada en el sistema.
" ---------------------------------------------------------------------------
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols = {}
" Sin overrides: los glifos por defecto de vim-devicons ya son correctos con
" la Nerd Font. Poner cadenas vacías aquí deja los nombres SIN ICONO.
let g:WebDevIconsUnicodeDecorateFileNodesExactSymbols = {}
let g:WebDevIconsUnicodeDecorateFileNodesPatternSymbols = {}
let g:webdevicons_enable_nerdtree_statusline = 1
let g:WebDevIconsUnicodeDecorateFolderNodes = 1
let g:DevIconsEnableFolderPatternMatching = 1
let g:DevIconsEnableFolderExtensionPatternMatching = 0
let g:WebDevIconsTabAirLineBeforeGlyphPadding = ' '
let g:WebDevIconsTabAirLineAfterGlyphPadding = ' '
let g:WebDevIconsUnicodeGlyphDoubleWidth = 1

" ---------------------------------------------------------------------------
" 8. Markdown renderizado (vim-markdown)
"    Solo actua con filetype=markdown, y config/filetypes (más abajo) se
"    encarga de dárselo a README, LICENSE, NOTAS, .c, .py... sin extensión.
" ---------------------------------------------------------------------------
let g:vim_markdown_folding_disabled = 1        " sin pliegues automáticos
let g:vim_markdown_toc_autofit = 1
let g:vim_markdown_conceal_code_blocks = 0
let g:vim_markdown_emphasis_multiline = 1
let g:vim_markdown_follow_anchor = 1
let g:vim_markdown_new_list_item_indent = 2
let g:vim_markdown_strikethrough = 1

" ---------------------------------------------------------------------------
" 9. Tipos de archivo para lo que Vim NO reconoce solo
"    (espejo de lua/config/filetypes.lua de Neovim)
"
"      - .c, .py, .json... (archivos que SOLO llevan punto inicial) -> su
"        filetype real, para que tengan icono y resaltado
"      - Makefile, .bashrc, .env, Dockerfile... -> su filetype conocido
"      - README, LICENSE, CHANGELOG, NOTAS... -> markdown (se renderizan)
"      - scripts sin extensión -> el intérprete de su shebang
"      - binarios -> nunca se tocan
" ---------------------------------------------------------------------------
let s:known_ft = {
      \ 'makefile': 'makefile', 'gnumakefile': 'makefile',
      \ 'justfile': 'makefile', 'rakefile': 'ruby', 'gemfile': 'ruby',
      \ 'brewfile': 'ruby', 'vagrantfile': 'ruby', 'podfile': 'ruby',
      \ 'dockerfile': 'docker', 'containerfile': 'docker',
      \ 'pkgbuild': 'sh', 'procfile': 'sh',
      \ '.bashrc': 'sh', '.bash_profile': 'sh', '.bash_aliases': 'sh',
      \ '.profile': 'sh', '.zshrc': 'zsh', '.zshenv': 'zsh', '.envrc': 'sh',
      \ '.gitignore': 'gitignore', '.gitattributes': 'conf',
      \ '.gitmodules': 'gitconfig', '.gitconfig': 'gitconfig',
      \ '.editorconfig': 'conf', '.inputrc': 'conf', '.npmrc': 'ini',
      \ '.condarc': 'yaml', '.vimrc': 'vim', '.nvimrc': 'vim', '.gvimrc': 'vim',
      \ }

let s:prose = ['readme', 'license', 'licence', 'copying', 'changelog', 'changes',
      \ 'news', 'todo', 'notes', 'notas', 'contributing', 'code_of_conduct',
      \ 'security', 'install', 'installation', 'usage', 'authors',
      \ 'contributors', 'maintainers', 'thanks', 'version', 'history', 'faq',
      \ 'releasenotes', 'notice', 'codeowners', 'owners']

let s:text_exts = ['md', 'markdown', 'txt', 'text', 'rst']

let s:shebang_ft = {'sh': 'sh', 'bash': 'sh', 'zsh': 'zsh', 'fish': 'fish',
      \ 'python': 'python', 'python2': 'python', 'python3': 'python',
      \ 'node': 'javascript', 'ruby': 'ruby', 'perl': 'perl', 'php': 'php',
      \ 'awk': 'awk'}

" Archivos con nombre tipo ".c", ".py": solo punto inicial y nada más. Vim no
" tiene vim.filetype (eso es Neovim), así que el mapa es explícito.
let s:hidden_ext = {
      \ 'c': 'c', 'h': 'c', 'cpp': 'cpp', 'hpp': 'cpp',
      \ 'py': 'python', 'js': 'javascript', 'ts': 'typescript',
      \ 'json': 'json', 'yml': 'yaml', 'yaml': 'yaml', 'toml': 'toml',
      \ 'sh': 'sh', 'rb': 'ruby', 'go': 'go', 'rs': 'rust',
      \ 'java': 'java', 'lua': 'lua', 'vim': 'vim', 'md': 'markdown',
      \ 'html': 'html', 'css': 'css', 'php': 'php', 'pl': 'perl',
      \ 'sql': 'sql', 'xml': 'xml', 'ini': 'ini', 'conf': 'conf',
      \ }

function! s:DfFirstLine(path) abort
    let l:f = readfile(a:path, '', 1)
    return empty(l:f) ? '' : l:f[0]
endfunction

function! s:DfIsBinary() abort
    " Vim guarda internamente los NUL del archivo como NL dentro de la línea,
    " así que un NUL en el archivo es un carácter NL dentro de getline().
    " readblob() no sirve: devuelve blobs vacíos para archivos pequeños.
    for l:i in range(1, min([line('$'), 500]))
        if getline(l:i) =~# '\%x00'
            return 1
        endif
    endfor
    return 0
endfunction

function! s:DfGuessFt(path) abort
    let l:lower = tolower(fnamemodify(a:path, ':t'))

    " 1) tipo conocido por nombre exacto (Makefile, .bashrc, .env...)
    if has_key(s:known_ft, l:lower)
        return s:known_ft[l:lower]
    endif

    " 2) documentación (.md/.txt se ignoran: manda el nombre base)
    let l:stem = l:lower
    let l:ext = matchstr(l:stem, '\.[^.]*$')
    let l:ext = strpart(l:ext, 1)
    if index(s:text_exts, l:ext) >= 0
        let l:stem = strpart(l:stem, 0, strlen(l:stem) - strlen(l:ext) - 1)
        let l:ext = ''
    endif
    if index(s:prose, l:stem) >= 0
        return 'markdown'
    endif
    " README-ES, LICENSE-APACHE, CHANGELOG_2... -> markdown
    for l:prefix in s:prose
        if strlen(l:prefix) > 3 && l:stem =~# '^' . l:prefix . '[-_.0-9a-z]*$'
            return 'markdown'
        endif
    endfor

    " 3) nombre tipo .c / .py / .json: el punto inicial ES la extensión
    if l:lower =~# '^\.[a-z0-9_+-]+$'
        let l:hidden = strpart(l:lower, 1)
        if has_key(s:hidden_ext, l:hidden)
            return s:hidden_ext[l:hidden]
        endif
        let l:ext = l:hidden
    endif

    " 4) sin extensión: el intérprete del shebang manda, si no markdown
    if empty(l:ext)
        let l:line = s:DfFirstLine(a:path)
        if strpart(l:line, 0, 2) ==# '#!'
            let l:interp = tolower(fnamemodify(matchstr(l:line, '^#!\s*\zs\S\+'), ':t'))
            if l:interp ==# 'env'
                let l:interp = tolower(matchstr(l:line, '^#!\s*\S\+\s\+\zs\S\+'))
            endif
            return get(s:shebang_ft, l:interp, 'sh')
        endif
        if !s:DfIsBinary()
            return 'markdown'
        endif
    endif
    return ''
endfunction

function! s:DfApplyFt() abort
    " Vim ya detectó un tipo concreto -> respetamos su decisión.
    " Solo actuamos si no hay tipo, o si es genérico (text/conf), porque para
    " README/NOTAS/LICENSE lo útil es markdown (que vim-markdown renderiza).
    if &filetype !=# '' && &filetype !~# '^\%(text\|conf\)$'
        return
    endif
    if &buftype !=# '' || &modifiable ==# 0
        return
    endif
    let l:path = expand('%:p')
    if empty(l:path) || !filereadable(l:path)
        return
    endif
    let l:ft = s:DfGuessFt(l:path)
    if !empty(l:ft) && l:ft !=# &l:filetype
        execute 'setlocal filetype=' . l:ft
    endif
endfunction

augroup DotfilesFiletype
    autocmd!
    autocmd BufReadPost,BufNewFile,BufFilePost * call s:DfApplyFt()
augroup END

" ---------------------------------------------------------------------------
" 10. Custom mappings (leader = <Space>)
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
let g:user42 = 'agalvan-'
let g:mail42 = 'agalvan-@student.42madrid.com'
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
" 11. Cscope & Gtags (vim-gutentags + gutentags_plus)
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