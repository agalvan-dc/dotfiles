-- Instalación automática de lazy.nvim si no existe
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Cargar la lista de plugins desde lua/plugins/
require("lazy").setup({
  require("plugins.ui"),
  require("plugins.treesitter"),
  require("plugins.fzf"),
  require("plugins.lsp"),
  require("plugins.completion"),
  require("plugins.formatting"),
})
