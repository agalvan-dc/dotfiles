return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      vim.lsp.config("clangd", { cmd = { "clangd", "--background-index" } })
      vim.lsp.config("pyright", {})
      vim.lsp.config("ruff", {})
      vim.lsp.config("lua_ls", { settings = { Lua = { diagnostics = { globals = { "vim" } } } } })
      vim.lsp.enable({ "clangd", "pyright", "ruff", "lua_ls" })

      -- Atajos LSP al conectarse un servidor
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
    end,
  },

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

  -- Gestor de servidores LSP
  { "williamboman/mason.nvim", opts = {} },
}