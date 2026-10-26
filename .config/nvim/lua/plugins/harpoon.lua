return {
  -- Fijar archivos frecuentes (Harpoon 2)
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup({})
      vim.keymap.set("n", "<leader>ha", function() harpoon:list():append() end, { desc = "Harpoon: Marcar archivo" })
      vim.keymap.set("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon: Ver marcados" })

      -- Se agrupan visualmente para que Which-Key no sature la pantalla
      vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end, { desc = "Harpoon (1-4)" })
      vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end, { desc = "which_key_ignore" })
      vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end, { desc = "which_key_ignore" })
      vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end, { desc = "which_key_ignore" })
    end,
  },
}