return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- Los parsers se instalan SOLO vía ensure_installed; el build :TSUpdate
    -- los actualiza. No hace falta autocmd: Neovim activa el resaltado solo.
    -- Requisito: un compilador de C (gcc/clang) para compilar los parsers.
    main = "nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = { "c", "cpp", "python", "rust", "lua", "markdown", "markdown_inline" },
      })
    end,
  },

  -- Text objects por sintaxis: af/if (función), ac/ic (clase), as (scope)
  -- Uso: dif, cif, yif, vif... (igual que los objetos de texto clásicos)
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = "VeryLazy",
    config = function()
      local ts_select = require("nvim-treesitter-textobjects.select")

      -- La config solo se guarda; los mapeos NO los crea el plugin solo.
      require("nvim-treesitter-textobjects").setup({
        select = {
          lookahead = true,
          -- Modo de selección según el tipo de objeto
          selection_modes = {
            ['@parameter.outer'] = 'v', -- por caracteres
            ['@function.outer'] = 'V',  -- por líneas
            ['@class.outer'] = '<c-v>', -- por bloques
          },
          include_surrounding_whitespace = true,
        },
      })

      -- Registrar los mapeos de selección (ver minimal_init.lua del plugin)
      local function textobj(query, group)
        return function()
          ts_select.select_textobject(query, group)
        end
      end

      vim.keymap.set({ "x", "o" }, "af", textobj("@function.outer"), { desc = "Añadir función" })
      vim.keymap.set({ "x", "o" }, "if", textobj("@function.inner"), { desc = "Interior de la función" })
      vim.keymap.set({ "x", "o" }, "ac", textobj("@class.outer"), { desc = "Añadir clase" })
      vim.keymap.set({ "x", "o" }, "ic", textobj("@class.inner"), { desc = "Interior de la clase" })
      vim.keymap.set({ "x", "o" }, "as", textobj("@local.scope", "locals"), { desc = "Añadir scope" })
    end,
  },
}