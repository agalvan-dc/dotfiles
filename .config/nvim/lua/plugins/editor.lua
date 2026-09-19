return {
  -- Navegación ultra-rápida en pantalla (Flash)
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Salto rápido (Flash)" },
    },
  },

  -- Comentar código con gc / gcc
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gc", mode = { "n", "v" }, desc = "Comentar línea/selección" },
      { "gb", mode = { "n", "v" }, desc = "Comentar bloque" },
    },
    config = function()
      require("Comment").setup()
    end,
  },

  -- Cambiar rodeos fácilmente: ys / cs / ds
  {
    "kylechui/nvim-surround",
    version = "*",
    opts = {},
  },

  -- Multicursor (Ctrl+n sobre una palabra para añadir ocurrencias)
  {
    "mg979/vim-visual-multi",
    branch = "master",
    event = "VeryLazy",
    init = function()
      vim.g.VM_theme = "nord"
    end,
  },

  -- Guías de indentación
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      indent = { char = "│" },
      scope = { enabled = true },
      exclude = {
        filetypes = { "help", "health", "man", "terminal", "lspinfo", "dashboard" },
      },
    },
  },
}