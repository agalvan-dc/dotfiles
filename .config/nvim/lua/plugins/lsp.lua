return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Neovim 0.12.5 no define los filetype compuestos 'c.doxygen' /
      -- 'cpp.doxygen', pero nvim-lspconfig los declara para clangd.
      -- :checkhealth vim.lsp los marca como "Unknown filetype". No sirven
      -- para nada (nadie se los asigna), así que los quitamos de la lista.
      vim.lsp.config("clangd", {
        cmd = { "clangd", "--background-index" },
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
      })
      vim.lsp.config("pyright", {})
      vim.lsp.config("ruff", {})
      vim.lsp.config("lua_ls", { settings = { Lua = { diagnostics = { globals = { "vim" } } } } })
      -- Rust: antes usábamos mrcjkb/rustaceanvim, pero su v4 llama a APIs
      -- que Neovim 0.12 marca como deprecadas y que desaparecen en 0.13/1.0:
      --   * vim.lsp.get_buffers_by_client_id()
      --   * client.request(...)   → client:request(...)
      --   * vim.validate{...}
      -- No tocamos cmd/filetypes: nvim-lspconfig ya resuelve el binario de
      -- mason y trae la config completa (inlay hints, cargo commands...).
      vim.lsp.enable({ "clangd", "pyright", "ruff", "lua_ls", "rust_analyzer" })

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