-- =========================================================================
-- 1. CONFIGURACIÓN BÁSICA Y TECLA LÍDER
-- =========================================================================
vim.g.mapleader = " "         -- Barra espaciadora como tecla líder
vim.g.maplocalleader = " "

vim.opt.number = true         -- Números de línea
vim.opt.relativenumber = true -- Números relativos
vim.opt.shiftwidth = 4        -- Tabulación de 4 espacios
vim.opt.expandtab = false      -- Convertir tabs a espacios
vim.opt.clipboard = "unnamedplus" -- Sincronizar portapapeles del sistema
vim.opt.splitright = true     -- Al dividir pantalla verticalmente, abrir a la derecha
vim.opt.splitbelow = true     -- Al dividir horizontalmente, abrir abajo

-- Limpiar resaltado con ESC
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Limpiar resaltados" })

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

  -- Tema Visual (TokyoNight)
{
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("tokyonight").setup({
      style = "night", -- Opciones: "storm", "moon", "night", "day"
      transparent = false,
      styles = {
        keywords = { italic = true },
        functions = { bold = true },
        variables = {},
      },
    })
    vim.cmd([[colorscheme tokyonight-night]])
  end,
},

-- =========================================================================
-- TREESITTER: SINTAXIS Y COLOREADO AVANZADO
-- =========================================================================
{
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "c", "cpp", "lua", "python", "bash", "cmake" },
      auto_install = true,
      highlight = {
        enable = true, -- ¡Activa el coloreado inteligente!
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
    })
  end,
},

{
    "williamboman/mason.nvim",
    opts = {},
},
  -- Menú flotante al pulsar Espacio (Which-Key)
{
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {},
  },

  -- Explorador de archivos lateral (Neo-Tree)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Explorador de Archivos" })
    end,
  },

  -- Buscador y navegación (Telescope)
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

  -- Navegación transparente entre Neovim y Tmux
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
    },
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
-- 4. ATAJOS DE TECLADO Y LSP
-- =========================================================================
vim.keymap.set("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "Dividir Pantalla Vertical" })
vim.keymap.set("n", "<leader>sh", "<cmd>split<cr>", { desc = "Dividir Pantalla Horizontal" })

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
  callback = function(ev)
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "gd", builtin.lsp_definitions, { buffer = ev.buf, desc = "Ir a Definición" })
    vim.keymap.set("n", "gr", builtin.lsp_references, { buffer = ev.buf, desc = "Ver Referencias" })
    vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = ev.buf, desc = "Documentación" })
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = ev.buf, desc = "Renombrar Variable" })
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = ev.buf, desc = "Acciones de Código" })
    vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Siguiente búfer" })
    vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Búfer anterior" })
    vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Cerrar búfer actual" })
  end,
})
