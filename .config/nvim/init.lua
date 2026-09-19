-- =========================================================================
-- 1. CONFIGURACIÓN BÁSICA Y TECLA LÍDER
-- =========================================================================
vim.g.mapleader = " "         -- Espacio como tecla líder
vim.g.maplocalleader = " "

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

  -- Temas alternativos (se eligen con <leader>ct)
  {
    "EdenEast/nightfox.nvim",
    lazy = false,
    priority = 900,
  },
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 900,
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {},
  },

  -- Treesitter (Resaltado)
  -- Los parsers se instalan SOLO vía ensure_installed; el build :TSUpdate
  -- los actualiza. No hace falta autocmd: Neovim activa el resaltado solo.
  -- Requisito: un compilador de C (gcc/clang) para compilar los parsers.
  {
    "nvim-treesitter/nvim-treesitter",
    main = "nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = { "c", "cpp", "python", "rust", "lua", "markdown", "markdown_inline" },
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
  -- La rama 0.1.x (2023) estaba rota en Neovim 0.11+; master es la sana.
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "ahmedkhalf/project.nvim" },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = { preview = { treesitter = false } },
      })
      -- pcall: si project.nvim falla en una máquina nueva, telescope sigue funcionando
      pcall(telescope.load_extension, "projects")
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

  -- Iconos ligeros (Mini.icons)
  {
    "echasnovski/mini.icons",
    opts = {},
    config = function()
      require("mini.icons").setup()
    end,
  },

  { "mrcjkb/rustaceanvim", version = "^4", ft = { "rust" } },
  { "42Paris/42header", cmd = "Stdheader" },

  -- Comentar código con gc / gcc
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gc", mode = { "n", "v" }, desc = "Comentar línea/selección" },
      { "gb", mode = { "n", "v" }, desc = "Comentar bloque" },
    },
    config = function()
      require("Comment").setup()
    end,
  },

  -- Barra de estado (se adapta al tema activo)
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    config = function()
      require("lualine").setup({ options = { theme = "auto" } })
    end,
  },

  -- Formateo al guardar (conform.nvim)
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      { "<leader>cf", function() require("conform").format({ async = true }) end, desc = "Formatear archivo" },
    },
    opts = {
      formatters_by_ft = {
        c        = { "clang-format" },
        cpp      = { "clang-format" },
        python   = { "ruff_format" },
        lua      = { "stylua" },
        rust     = { "rustfmt" },
        sh       = { "shfmt" },
        markdown = { "prettierd", "prettier", stop_after_first = true },
        json     = { "prettierd", "prettier", stop_after_first = true },
      },
      format_on_save = function(bufnr)
        local ft = vim.bo[bufnr].filetype
        if ft == "c" or ft == "cpp" then
          return nil
        end
        return { timeout_ms = 2000, lsp_format = "fallback" }
      end,
    },
  },

  -- Cambiar rodeos facilmente: ys / cs / ds
  {
    "kylechui/nvim-surround",
    version = "*",
    opts = {},
  },

  -- Sesiones persistentes por proyecto (se guardan solas al salir)
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    keys = {
      { "<leader>ss", function() require("persistence").save() end, desc = "Guardar sesión" },
      { "<leader>so", function() require("persistence").load() end, desc = "Restaurar sesión" },
      { "<leader>sl", function() require("persistence").load({ last = true }) end, desc = "Última sesión" },
      { "<leader>sd", function() require("persistence").stop() end, desc = "Borrar sesión" },
    },
  },

  -- Multicursor (Ctrl+n sobre una palabra para añadir ocurrencias)
  {
    "mg979/vim-visual-multi",
    branch = "master",
    event = "VeryLazy",
    init = function()
      vim.g.VM_theme = "nord"
    end,
  },

  -- Guías de indentación
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      indent = { char = "│" },
      scope = { enabled = true },
      exclude = {
        filetypes = { "help", "health", "man", "terminal", "lspinfo", "dashboard" },
      },
    },
  },
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

-- Navegar a otras ventanas/splits directamente desde la terminal (sin necesidad de salir a modo normal antes)
vim.keymap.set('t', '<C-h>', [[<C-\><C-n><C-w>h]], { desc = 'Mover a la ventana izquierda' })
vim.keymap.set('t', '<C-j>', [[<C-\><C-n><C-w>j]], { desc = 'Mover a la ventana abajo' })
vim.keymap.set('t', '<C-k>', [[<C-\><C-n><C-w>k]], { desc = 'Mover a la ventana arriba' })
vim.keymap.set('t', '<C-l>', [[<C-\><C-n><C-w>l]], { desc = 'Mover a la ventana derecha' })


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
end,
})
