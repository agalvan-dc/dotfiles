-- =========================================================================
-- 1. CONFIGURACIÓN BÁSICA Y TECLA LÍDER
-- =========================================================================
vim.g.mapleader = " "         -- Barra espaciadora como tecla líder
vim.g.maplocalleader = " "

vim.opt.number = true         -- Números de línea
vim.opt.relativenumber = true -- Números relativos
vim.opt.shiftwidth = 4        -- Tabulación de 4 espacios
vim.opt.expandtab = true      -- Convertir tabs a espacios
vim.opt.clipboard = "unnamedplus" -- Sincronizar portapapeles del sistema
vim.opt.splitright = true     -- Al dividir pantalla verticalmente, abrir a la derecha
vim.opt.splitbelow = true     -- Al dividir horizontalmente, abrir abajo

-- Hacer que ESC limpie los resaltados de búsquedas anteriores
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Limpiar resaltados" })

-- Navegación rápida entre pantallas divididas (Ctrl + h/j/k/l)
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Mover a la ventana izquierda" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Mover a la ventana inferior" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Mover a la ventana superior" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Mover a la ventana derecha" })

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
-- 3. PLUGINS
-- =========================================================================
require("lazy").setup({

  -- Tema Visual (TokyoNight)
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme tokyonight-moon]])
    end,
  },

  -- MENÚ FLOTANTE AL PULSAR ESPACIO (Which-Key)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300 -- Muestra el menú tras 300ms de presionar Espacio
    end,
    opts = {},
  },

  -- EXPLORADOR DE ARCHIVOS LATERAL (Neo-Tree)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- Iconos bonitos
      "MunifTanjim/nui.nvim",
    },
    config = function()
      -- Espacio + e: Abrir / Cerrar el árbol de archivos
      vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Explorador de Archivos" })
    end,
  },

  -- BUSCADOR Y NAVEGACIÓN (Telescope)
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")

      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Buscar Archivos" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Buscar Texto Global" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Ver Archivos Abiertos" })
    end,
  },

  -- Treesitter (Sintaxis y Colores)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "rust", "c", "cpp", "python", "lua" },
      highlight = { enable = true },
    },
    config = function(_, opts)
      local status, treesitter = pcall(require, "nvim-treesitter.configs")
      if status then
        treesitter.setup(opts)
      end
    end,
  },

  -- Servidores LSP (Neovim 0.11+)
  {
    "neovim/nvim-lspconfig",
    config = function()
      vim.lsp.config("clangd", {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--fallback-style=llvm",
        },
      })

      vim.lsp.config("pyright", {
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "workspace",
            },
          },
        },
      })

      vim.lsp.config("ruff", {})
      vim.lsp.config("lua_ls", {
        settings = { Lua = { diagnostics = { globals = { "vim" } } } },
      })

      vim.lsp.enable({ "clangd", "pyright", "ruff", "lua_ls" })
    end,
  },

  -- Rustaceanvim (Rust)
  {
    "mrcjkb/rustaceanvim",
    version = "^4",
    ft = { "rust" },
  },
})

-- =========================================================================
-- 4. ATAJOS DE TECLADO GLOBALES Y LSP
-- =========================================================================
-- Atajos para dividir pantalla cómodamente
vim.keymap.set("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "Dividir Pantalla Vertical" })
vim.keymap.set("n", "<leader>sh", "<cmd>split<cr>", { desc = "Dividir Pantalla Horizontal" })

-- Atajos del Servidor de Lenguaje (LSP)
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    local builtin = require("telescope.builtin")

    -- Navegación e inteligencia de código con Telescope
    vim.keymap.set("n", "gd", builtin.lsp_definitions, { buffer = ev.buf, desc = "Ir a Definición" })
    vim.keymap.set("n", "gr", builtin.lsp_references, { buffer = ev.buf, desc = "Ver Referencias" })
    vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = ev.buf, desc = "Documentación" })
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = ev.buf, desc = "Renombrar Variable" })
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = ev.buf, desc = "Acciones de Código" })
  end,
})
