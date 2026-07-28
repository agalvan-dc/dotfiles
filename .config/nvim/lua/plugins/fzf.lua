return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local fzf = require("fzf-lua")
    fzf.setup({ "fzf-native" })

    local map = vim.keymap.set
    map("n", "<leader>ff", fzf.files, { desc = "FZF Archivos" })
    map("n", "<leader>fg", fzf.live_grep, { desc = "FZF Live Grep" })
    map("n", "<leader>fb", fzf.buffers, { desc = "FZF Buffers" })
    map("n", "<leader>fh", fzf.help_tags, { desc = "FZF Ayuda" })
    map("n", "<leader>fr", fzf.oldfiles, { desc = "FZF Recientes" })
    map("n", "<leader>fs", fzf.lsp_document_symbols, { desc = "FZF Símbolos LSP" })
    map("n", "<leader>fS", fzf.lsp_workspace_symbols, { desc = "FZF Símbolos Workspace" })
    map("n", "<leader>gc", fzf.git_commits, { desc = "FZF Git Commits" })
    map("n", "<leader>gs", fzf.git_status, { desc = "FZF Git Status" })
  end,
}
