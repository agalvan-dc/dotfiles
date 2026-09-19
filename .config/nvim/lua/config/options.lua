-- Opciones generales de Neovim
-- Se cargan antes de que lazy.nvim arranque

vim.opt.number = true         -- Números de línea
vim.opt.relativenumber = true -- Números relativos
vim.opt.tabstop = 4           -- Ancho visual del tab
vim.opt.softtabstop = 4       -- <Tab> en modo insertar = tab real de 4
vim.opt.shiftwidth = 4        -- Indentación (>>, autoindent)
vim.opt.expandtab = false     -- Usar tabs reales, NO espacios
vim.opt.clipboard = "unnamedplus" -- Portapapeles del sistema
vim.opt.splitright = true     -- Divisiones a la derecha
vim.opt.splitbelow = true     -- Divisiones abajo
vim.opt.scrolloff = 8         -- Mantiene 8 líneas de margen al bajar
vim.opt.updatetime = 50       -- Respuesta más rápida