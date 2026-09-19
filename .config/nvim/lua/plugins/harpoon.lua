return {
  -- Fijar archivos frecuentes (Harpoon)
  {
    "ThePrimeagen/harpoon",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local mark = require("harpoon.mark")
      local ui = require("harpoon.ui")
      vim.keymap.set("n", "<leader>ha", mark.add_file, { desc = "Harpoon: Marcar archivo" })
      vim.keymap.set("n", "<leader>hh", ui.toggle_quick_menu, { desc = "Harpoon: Ver marcados" })

      -- Se agrupan visualmente para que Which-Key no sature la pantalla
      vim.keymap.set("n", "<leader>1", function() ui.nav_file(1) end, { desc = "Harpoon (1-4)" })
      vim.keymap.set("n", "<leader>2", function() ui.nav_file(2) end, { desc = "which_key_ignore" })
      vim.keymap.set("n", "<leader>3", function() ui.nav_file(3) end, { desc = "which_key_ignore" })
      vim.keymap.set("n", "<leader>4", function() ui.nav_file(4) end, { desc = "which_key_ignore" })
    end,
  },
}