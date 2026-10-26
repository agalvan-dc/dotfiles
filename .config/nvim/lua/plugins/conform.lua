return {
  -- Formateo manual (conform.nvim). Sin format_on_save para no tocar
  -- el código: la norma 42 exige formato propio y no queremos que
  -- clang-format/ruff/etc. lo modifiquen al guardar.
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
      format_on_save = nil,
    },
  },
}