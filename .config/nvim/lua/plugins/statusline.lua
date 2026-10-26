return {
  -- Barra de estado (se adapta al tema activo)
  -- Nota: NO se hardcodean glifos Nerd Font (se pierden al editar el
  -- archivo). Con icons_enabled = true, lualine usa los iconos por defecto
  -- de nvim-web-devicons para modo, diagnósticos, progreso y filetype.
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
      options = {
        theme = "auto", -- los colores se adaptan al tema activo
        icons_enabled = true,
      },
      sections = {
        lualine_a = { "mode", "diagnostics" },
        lualine_b = { "branch", { "filename", path = 1 } },
        lualine_c = { { "diff" }, "diagnostics", "progress" },
        lualine_x = {
          "filetype", -- muestra el icono del tipo de archivo
          "encoding",
          { "cword" },
          { "diff" },
        },
        lualine_y = { "progress" },
        lualine_z = { "lspprogress" },
      },
      inactive = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
      },
    },
    config = function(_, opts)
      require("lualine").setup(opts)
    end,
  },
}