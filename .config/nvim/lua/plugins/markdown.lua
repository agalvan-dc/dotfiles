return {
  -- Markdown renderizado dentro del propio Neovim (markview)
  -- Sustituye a render-markdown.nvim: markview usa los iconos de
  -- nvim-web-devicons para listas, checkboxes y títulos, y añade toggles.
  --
  -- El repo cambió de dueño (robertmartin8 -> OXY2DEV) y su API es otra:
  -- se configura con `setup()` y se controla con `:Markview <subcomando>`.
  {
    "OXY2DEV/markview.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false, -- ya viene lazy por dentro; forzarlo da errores de arranque
    priority = 500, -- después del colorscheme para que use sus highlights
    opts = {
      icon_provider = "devicons", -- iconos de nvim-web-devicons
      -- los archivos sin extensión con texto (README, NOTAS, CODEOWNERS)
      -- los marca config/filetypes.lua como `markdown`, así que entran aquí
      filetypes = { "markdown", "quarto", "rmd", "typst", "asciidoc" },
      debounce = 150,
      map_gx = true, -- gx salta a la definición del enlace
      preview = {
        modes = { "n", "no", "c" },
        hybrid_modes = {}, -- render en la línea bajo el cursor
        linewise_hybrid_mode = false,
      },
      on_mode_change = nil, -- usa el comportamiento por defecto
    },
    keys = {
      {
        "<leader>mv",
        "<cmd>Markview<cr>",
        desc = "Markdown: activar/desactivar el render",
      },
      {
        "<leader>ml",
        "<cmd>Markview linewiseToggle<cr>",
        desc = "Markdown: render solo en la línea actual",
      },
      {
        "<leader>mr",
        "<cmd>Markview render<cr>",
        desc = "Markdown: renderizar el buffer",
      },
      {
        "<leader>mc",
        "<cmd>Markview clear<cr>",
        desc = "Markdown: quitar el render",
      },
    },
  },
}