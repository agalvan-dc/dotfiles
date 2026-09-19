return {
  -- Git Integración (Gitsigns)
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
      vim.keymap.set("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<CR>", { desc = "Git: Ver cambios" })
      vim.keymap.set("n", "<leader>gr", "<cmd>Gitsigns reset_hunk<CR>", { desc = "Git: Deshacer bloque" })
      vim.keymap.set("n", "]g", "<cmd>Gitsigns next_hunk<CR>", { desc = "Git: Siguiente cambio" })
      vim.keymap.set("n", "[g", "<cmd>Gitsigns prev_hunk<CR>", { desc = "Git: Cambio anterior" })
    end,
  },
}