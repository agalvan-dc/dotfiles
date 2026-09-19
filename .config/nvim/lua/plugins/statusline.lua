return {
  -- Barra de estado (se adapta al tema activo)
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    config = function()
      require("lualine").setup({ options = { theme = "auto" } })
    end,
  },
}