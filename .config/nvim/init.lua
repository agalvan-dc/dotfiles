-- =========================================================================
-- 1. CONFIGURACIÓN BÁSICA Y TECLA LÍDER
-- =========================================================================
vim.g.mapleader = " "         -- Espacio como tecla líder
vim.g.maplocalleader = " "

vim.opt.number = true         -- Números de línea
vim.opt.relativenumber = true -- Números relativos
vim.opt.shiftwidth = 4        -- Tabulación de 4 espacios
vim.opt.expandtab = false     -- Usar tabs
vim.opt.clipboard = "unnamedplus" -- Portapapeles del sistema
vim.opt.splitright = true     -- Divisiones a la derecha
vim.opt.splitbelow = true     -- Divisiones abajo
vim.opt.scrolloff = 8         -- Mantiene 8 líneas de margen al bajar
vim.opt.updatetime = 50       -- Respuesta más rápida

-- Parche Neovim 0.10+ para Telescope
if vim.treesitter and vim.treesitter.language and vim.treesitter.language.ft_to_lang == nil then
  vim.treesitter.language.ft_to_lang = function(ft)
    return vim.treesitter.language.get_lang(ft) or ft
  end
end

-- =========================================================================
-- 2. INSTALACIÓN DE LAZY.NVIM
-- =========================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- =========================================================================
-- 3. DECLARACIÓN DE PLUGINS
-- =========================================================================
require("lazy").setup({

  -- Tema Visual
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({ style = "night" })
      vim.cmd([[colorscheme tokyonight-night]])
    end,
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {},
  },

  -- Treesitter (Resaltado) - CORREGIDO
    {
      'nvim-treesitter/nvim-treesitter',
      branch = 'main',
      build = ':TSUpdate',
      config = function()
    local ts = require('nvim-treesitter')
    ts.setup()

    -- Install language parsers
     ts.install({ 'c', 'cpp', 'python', 'rust', 'lua', 'markdown', 'markdown_inline' })

     -- Enable syntax highlighting on file load
      vim.api.nvim_create_autocmd('FileType', {
          callback = function()
        pcall(vim.treesitter.start)
          end,
    })
      end,
    },

  { "williamboman/mason.nvim", opts = {} },

  -- Menú Flotante (Which-Key)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {},
  },

  -- Barra de Pestañas (Bufferline)
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        separator_style = "slant",
      },
    },
  },

  -- Navegación ultra-rápida en pantalla (Flash)
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Salto rápido (Flash)" },
    },
  },

  -- Fijar archivos frecuentes (Harpoon)
  {
    "ThePrimeagen/harpoon",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local mark = require("harpoon.mark")
      local ui = require("harpoon.ui")
      vim.keymap.set("n", "<leader>ha", mark.add_file, { desc = "Harpoon: Marcar archivo" })
      vim.keymap.set("n", "<leader>hh", ui.toggle_quick_menu, { desc = "Harpoon: Ver marcados" })
      
      -- Se agrupan visualmente para que Which-Key no sature la pantalla
      vim.keymap.set("n", "<leader>1", function() ui.nav_file(1) end, { desc = "Harpoon (1-4)" })
      vim.keymap.set("n", "<leader>2", function() ui.nav_file(2) end, { desc = "which_key_ignore" })
      vim.keymap.set("n", "<leader>3", function() ui.nav_file(3) end, { desc = "which_key_ignore" })
      vim.keymap.set("n", "<leader>4", function() ui.nav_file(4) end, { desc = "which_key_ignore" })
    end,
  },

  -- Gestor de Proyectos y Directorios (Project.nvim)
  {
    "ahmedkhalf/project.nvim",
    config = function()
      require("project_nvim").setup({
        detection_methods = { "pattern" },
        patterns = { ".git", "Makefile", "package.json" },
      })
    end,
  },

  -- Git Integración (Gitsigns)
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
      vim.keymap.set("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<CR>", { desc = "Git: Ver cambios" })
      vim.keymap.set("n", "<leader>gr", "<cmd>Gitsigns reset_hunk<CR>", { desc = "Git: Deshacer bloque" })
      vim.keymap.set("n", "]g", "<cmd>Gitsigns next_hunk<CR>", { desc = "Git: Siguiente cambio" })
      vim.keymap.set("n", "[g", "<cmd>Gitsigns prev_hunk<CR>", { desc = "Git: Cambio anterior" })
    end,
  },

  -- Explorador Neo-Tree
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" },
    config = function()
      vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Explorador de Archivos" })
    end,
  },

  -- Buscador (Telescope + Integración de Proyectos)
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim", "ahmedkhalf/project.nvim" },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = { preview = { treesitter = false } },
      })
      telescope.load_extension("projects")
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Buscar Archivos" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Buscar Texto Global" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Ver Archivos Abiertos" })
      vim.keymap.set("n", "<leader>fp", "<cmd>Telescope projects<cr>", { desc = "Cambiar de Proyecto/Directorio" })
    end,
  },

  -- Navegación con Tmux
  {
    "christoomey/vim-tmux-navigator",
    cmd = { "TmuxNavigateLeft", "TmuxNavigateDown", "TmuxNavigateUp", "TmuxNavigateRight" },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
    },
  },

  -- LSP (Servidores de lenguaje)
  {
    "neovim/nvim-lspconfig",
    config = function()
      vim.lsp.config("clangd", { cmd = { "clangd", "--background-index" } })
      vim.lsp.config("pyright", {})
      vim.lsp.config("ruff", {})
      vim.lsp.config("lua_ls", { settings = { Lua = { diagnostics = { globals = { "vim" } } } } })
      vim.lsp.enable({ "clangd", "pyright", "ruff", "lua_ls" })
    end,
  },

  { "mrcjkb/rustaceanvim", version = "^4", ft = { "rust" } },
})

-- =========================================================================
-- 4. ATAJOS PRO PARA VELOCIDAD EXTREMA
-- =========================================================================

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

-- LSP
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
  callback = function(ev)
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "gd", builtin.lsp_definitions, { buffer = ev.buf, desc = "Ir a Definición" })
    vim.keymap.set("n", "gr", builtin.lsp_references, { buffer = ev.buf, desc = "Ver Referencias" })
    vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = ev.buf, desc = "Documentación" })
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = ev.buf, desc = "Renombrar Variable" })
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = ev.buf, desc = "Acciones de Código" })

-- Salir de la terminal pulsando ESC dos veces seguidas
vim.keymap.set('t', '<Esc><Esc>', [[<C-\><C-n>]], { desc = 'Salir de modo terminal' })

-- Opción alternativa: Usar Ctrl + o para salir rápido
vim.keymap.set('t', '<C-o>', [[<C-\><C-n>]], { desc = 'Salir de modo terminal' })

-- Navegar a otras ventanas/splits directamente desde la terminal (sin necesidad de salir a modo normal antes)
vim.keymap.set('t', '<C-h>', [[<C-\><C-n><C-w>h]], { desc = 'Mover a la ventana izquierda' })
vim.keymap.set('t', '<C-j>', [[<C-\><C-n><C-w>j]], { desc = 'Mover a la ventana abajo' })
vim.keymap.set('t', '<C-k>', [[<C-\><C-n><C-w>k]], { desc = 'Mover a la ventana arriba' })
vim.keymap.set('t', '<C-l>', [[<C-\><C-n><C-w>l]], { desc = 'Mover a la ventana derecha' })

-- Abrir Lazydocker en una terminal dentro de Neovim
vim.keymap.set("n", "<leader>ld", "<cmd>term lazydocker<CR>", { desc = "Abrir Lazydocker (Gestor Docker)" })
end,
})
