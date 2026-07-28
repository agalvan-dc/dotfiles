" =============================================================================
" CONFIGURACIÓN ESENCIAL DE VIM 
" =============================================================================

" --- 1. SOPORTE DE RATÓN Y PORTAPAPELES ---
set mouse=a                 " Habilita el ratón en todos los modos (seleccionar, clicar, scroll)
set clipboard=unnamedplus   " Sincroniza las copias/pegados con el portapapeles del sistema

" --- 2. APARIENCIA Y NAVEGACIÓN ---
syntax on                   " Activa el resaltado de sintaxis
set number                  " Muestra el número de línea
set relativenumber          " Números de línea relativos (facilita saltos como '5j')
set cursorline              " Resalta la línea actual donde está el cursor
set termguicolors           " Habilita colores verdaderos de 24 bits
set scrolloff=8             " Mantiene siempre 8 líneas visibles arriba/abajo al desplazarse
set wildmenu                " Menú visual mejorado para el autocompletado de comandos con Tab
set nu
" --- 3. INDENTACIÓN Y FORMATO ---
set tabstop=4               " Un tabulador equivale a 4 espacios
set shiftwidth=4            " Tamaño de la sangría en 4 espacios
set expandtab               " Convierte las tabulaciones en espacios automáticamente
set autoindent              " Mantiene la indentación de la línea anterior
set smartindent             " Indentación inteligente para bloques de código

" --- 4. BÚSQUEDA INTELIGENTE ---
set ignorecase              " Ignora mayúsculas/minúsculas al buscar
set smartcase               " Si escribes una mayúscula, la búsqueda se vuelve sensible a mayúsculas
set hlsearch                " Resalta las coincidencias de la búsqueda
set incsearch               " Muestra resultados mientras vas escribiendo la búsqueda

" --- 5. COMPORTAMIENTO DEL SISTEMA ---
set hidden                  " Permite cambiar de buffer sin tener que guardar los cambios primero
set splitbelow              " Las divisiones horizontales se abren abajo
set splitright              " Las divisiones verticales se abren a la derecha
set updatetime=300          " Reduce el tiempo de respuesta del sistema (útil para plugins)
set undofile                " Guarda el historial de deshacer incluso tras cerrar Vim

" --- 6. ATAJOS DE TECLADO ÚTILES ---
" Desactivar el resaltado de búsqueda presionando 'Espacio + c'
nnoremap <silent> <space>c :nohlsearch<CR>

" Moverse entre ventanas/splits fácilmente con Ctrl + hjkl
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
