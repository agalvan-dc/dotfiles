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
        show_file_icons = true, -- icono del tipo de archivo en cada pestaña
        show_buffer_close_icons = true,
        close_command = "bdelete!",
        right_mouse_command = "bdelete!",
        offsets = {
          {
            filetype = "neo-tree",
            text = "Archivos",
            highlight = "NeoTreeNormalTitle",
            padding = 1,
          },
        },
      },
    },
  },
}