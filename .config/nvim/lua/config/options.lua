local opt = vim.opt

-- Mapear tecla Leader a Espacio
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Numeración de líneas
opt.number = true
opt.relativenumber = true

-- Tabulación e Indentación
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

-- Búsqueda
opt.ignorecase = true
opt.smartcase = true

-- Apariencia de la interfaz
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8

-- Comportamiento de divisiones (splits)
opt.splitright = true
opt.splitbelow = true

-- Rendimiento y backup
opt.updatetime = 250
opt.timeoutlen = 300
opt.swapfile = false
opt.backup = false
opt.undofile = true
