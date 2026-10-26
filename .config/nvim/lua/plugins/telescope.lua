return {
  -- Buscador (Telescope + Integración de Proyectos)
  -- La rama 0.1.x (2023) estaba rota en Neovim 0.11+; master es la sana.
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "ahmedkhalf/project.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      defaults = {
        preview = { treesitter = false },
        use_less = true, -- se ve más entrada en la lista
        sorting_strategy = "ascending",
        layout_config = { horizontal = { preview_width = 0.55 } },
        -- iconos: por defecto Telescope usa nvim-web-devicons si está
      },
      pickers = {
        find_files = {
          hidden = true, -- muestra dotfiles (.gitignore, .env...)
        },
      },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      -- pcall: si project.nvim falla en una máquina nueva, telescope sigue funcionando
      pcall(telescope.load_extension, "projects")
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Buscar Archivos" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Buscar Texto Global" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Ver Archivos Abiertos" })
      vim.keymap.set("n", "<leader>fp", "<cmd>Telescope projects<cr>", { desc = "Cambiar de Proyecto/Directorio" })
    end,
  },
}