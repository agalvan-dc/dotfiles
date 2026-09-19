return {
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
}