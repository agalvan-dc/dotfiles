return {
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
      format_on_save = { timeout_ms = 2000, lsp_format = "fallback" },
    },
  },
}