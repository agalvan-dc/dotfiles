-- Atajos generales de Neovim
-- Se cargan antes de que lazy.nvim arranque.
-- Los atajos específicos de cada plugin viven en lua/plugins/.

-- Historial de buffers (lua/config/commands.lua)
local bufhist = require("config.commands").buffer_history

vim.api.nvim_create_autocmd("BufEnter", {
  callback = bufhist.record_buffer,
})

vim.api.nvim_create_autocmd("BufDelete", {
  callback = bufhist.cleanup_closed_buffers,
})

vim.keymap.set('n', '<leader>bp', bufhist.goto_prev_buffer, { desc = "Buffer anterior en historial" })
vim.keymap.set('n', '<leader>bn', bufhist.goto_next_buffer, { desc = "Buffer siguiente en historial" })
vim.keymap.set('n', '<leader>bh', bufhist.show_history, { desc = "Buscar en historial de buffers" })

-- Guardar y Salir
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Guardar archivo" })
vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "Cerrar ventana" })
vim.keymap.set("n", "<C-s>", "<cmd>w<CR>", { desc = "Guardar rápido" })
vim.keymap.set("i", "<C-s>", "<Esc><cmd>w<CR>a", { desc = "Guardar en modo insertar" })

-- Limpiar resaltado
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Limpiar resaltados" })

-- Mover bloques de código seleccionados (Modo Visual)
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Mover línea abajo" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Mover línea arriba" })

-- Mantener el cursor centrado al navegar páginas y búsquedas
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Bajar media página (Centrado)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Subir media página (Centrado)" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Siguiente búsqueda (Centrado)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Anterior búsqueda (Centrado)" })

-- Pegar sobre texto sin perder el texto copiado previamente
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Pegar sin sobrescribir portapapeles" })

-- Navegación rápida de búferes
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Siguiente pestaña" })
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Pestaña anterior" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Cerrar pestaña actual" })

-- Gestión de ventanas
vim.keymap.set("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "Dividir Pantalla Vertical" })
vim.keymap.set("n", "<leader>sh", "<cmd>split<cr>", { desc = "Dividir Pantalla Horizontal" })

-- Abrir terminal en un buffer nuevo (igual que :term)
vim.keymap.set("n", "<leader>t", "<cmd>terminal<CR>", { desc = "Abrir terminal" })

-- Abrir Lazydocker en una terminal dentro de Neovim
vim.keymap.set("n", "<leader>ld", "<cmd>term lazydocker<CR>", { desc = "Abrir Lazydocker (Gestor Docker)" })

-- Abrir Lazygit en una terminal dentro de Neovim
vim.keymap.set("n", "<leader>lg", "<cmd>term lazygit<CR>", { desc = "Abrir Lazygit (Control de Versiones)" })

-- Mostrar diagnósticos (errores/warnings del LSP) en una ventana flotante
vim.keymap.set("n", "<leader>n", vim.diagnostic.open_float, { desc = "Mostrar diagnóstico flotante" })

-- Cambiar de tema visual al vuelo (Telescope colorscheme)
vim.keymap.set("n", "<leader>ct", "<cmd>Telescope colorscheme<CR>", { desc = "Cambiar tema visual" })

-- Salir de la terminal pulsando ESC dos veces seguidas
vim.keymap.set('t', '<Esc><Esc>', [[<C-\><C-n>]], { desc = 'Salir de modo terminal' })

-- Opción alternativa: Usar Ctrl + o para salir rápido
vim.keymap.set('t', '<C-o>', [[<C-\><C-n>]], { desc = 'Salir de modo terminal' })

-- Insertar Header de 42
vim.keymap.set("n", "<leader>9", "<cmd>Stdheader<CR>", { desc = "Insertar Header 42" })

-- Nota: <C-h/j/k/l> (normal y terminal) los gestiona Navigator.nvim
-- en lua/plugins/tmux-navigation.lua.