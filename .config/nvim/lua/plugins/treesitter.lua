-- Lenguajes con parser + queries. Se instalan con :TSInstall <lang>
-- (o automáticamente en la primera ejecución, ver build abajo).
local LANGS = {
  "c", "cpp", "python", "rust", "lua", "markdown", "markdown_inline",
  "bash", "json", "yaml", "toml", "html", "css", "javascript", "typescript",
  "vim", "vimdoc", "sh", "make", "git_config", "git_rebase", "gitignore", "gitcommit",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- Rama principal: la API es `install`/`uninstall` y el RESALTADO NO se
    -- activa solo (eso lo hace Neovim con vim.treesitter.start). Por eso el
    -- build instala lo que falte y el autocmd FileType de abajo lo enciende.
    build = function()
      local missing = {}
      for _, lang in ipairs(LANGS) do
        if not vim.uv.fs_stat(vim.fs.joinpath(vim.fn.stdpath("data"), "site", "parser", lang .. ".so")) then
          table.insert(missing, lang)
        end
      end
      if #missing > 0 then
        pcall(function()
          require("nvim-treesitter").install(missing):wait(300000)
        end)
      end
      pcall(vim.cmd.TSUpdate)
    end,
    config = function()
      require("nvim-treesitter").setup({
        install_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "site"),
      })

      -- Filetypes cuyo nombre no coincide con el del parser. Sin este alias,
      -- `get_lang("makefile")` devuelve "makefile", no existe ese parser y el
      -- Makefile se queda sin resaltado de Treesitter.
      vim.treesitter.language.register("make", { "makefile", "gnumakefile" })

      -- El resaltado hay que encenderlo a mano en la rama principal: sin esto
      -- solo funcionan lua y markdown (los únicos que arrancan otros plugins).
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("TreesitterHighlight", { clear = true }),
        callback = function(ev)
          local lang = vim.treesitter.language.get_lang(vim.bo[ev.buf].filetype)
          if not lang or not pcall(vim.treesitter.language.add, lang) then
            return
          end
          pcall(vim.treesitter.start, ev.buf, lang)
        end,
      })

      -- Indentación por sintaxis (marcada como experimental upstream, pero va
      -- bien en c/cpp/python/rust/lua y respeta shiftwidth/expandtab).
      local indent_langs = { c = true, cpp = true, python = true, rust = true, lua = true }
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("TreesitterIndent", { clear = true }),
        callback = function(ev)
          local ft = vim.bo[ev.buf].filetype
          if indent_langs[ft] then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
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