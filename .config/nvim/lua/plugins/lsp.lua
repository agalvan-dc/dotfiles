return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "hrsh7th/cmp-nvim-lsp",
  },
  config = function()
    require("mason").setup()
    require("mason-lspconfig").setup({
      -- IMPORTANTE: No añadas "rust_analyzer" aquí.
      ensure_installed = { "clangd", "pyright", "ruff", "lua_ls" },
    })

    local lspconfig = require("lspconfig")
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    -- 1. Servidor C/C++: Clangd
    lspconfig.clangd.setup({
      capabilities = capabilities,
      cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
        "--function-arg-placeholders",
        "--fallback-style=llvm",
      },
    })

    -- 2. Servidores Python: Pyright y Ruff
    lspconfig.pyright.setup({
      capabilities = capabilities,
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

    lspconfig.ruff.setup({
      capabilities = capabilities,
    })

    -- 3. Lua LS
    lspconfig.lua_ls.setup({
      capabilities = capabilities,
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          workspace = { library = vim.api.nvim_get_runtime_file("", true) },
        },
      },
    })

    -- =====================================================================
    -- ATAJOS GLOBALES PARA CUALQUIER LSP (¡Incluido Rust!)
    -- =====================================================================
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
        end

        map("n", "gd", vim.lsp.buf.definition, "Ir a Definición")
        map("n", "gD", vim.lsp.buf.declaration, "Ir a Declaración")
        map("n", "gr", vim.lsp.buf.references, "Ver Referencias")
        map("n", "gi", vim.lsp.buf.implementation, "Ir a Implementación")
        map("n", "K", vim.lsp.buf.hover, "Documentación Hover")
        map("n", "<leader>rn", vim.lsp.buf.rename, "Renombrar Símbolo")
        map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Actions")
        map("n", "<leader>d", vim.diagnostic.open_float, "Ver Diagnóstico Flotante")
        map("n", "[d", vim.diagnostic.goto_prev, "Diagnóstico Anterior")
        map("n", "]d", vim.diagnostic.goto_next, "Diagnóstico Siguiente")

        -- Atajo exclusivo para C/C++ (solo se activa si el servidor es clangd)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client and client.name == "clangd" then
          map("n", "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", "Alternar C/H")
        end
      end,
    })
  end,
}
