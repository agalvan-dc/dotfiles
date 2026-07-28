local map = vim.keymap.set

-- Navegación entre ventanas divididas con Ctrl + h/j/k/l
map("n", "<C-h>", "<C-w>h", { desc = "Mover window to the left" })
map("n", "<C-j>", "<C-w>j", { desc = "Move window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Move window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Move window to the right" })

-- División de ventanas
map("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "Divide Vertically" })
map("n", "<leader>sh", "<cmd>split<cr>", { desc = "Divide Horizontally" })
map("n", "<leader>se", "<C-w>=", { desc = "Level Window Size" })
map("n", "<leader>sx", "<cmd>close<cr>", { desc = "Close Current Window" })

-- Gestión de Buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Close Actual Buffer" })

-- Limpiar resaltado de búsqueda con ESC
map("n", "<Esc>", "<cmd>nohlsearch<cr>")
