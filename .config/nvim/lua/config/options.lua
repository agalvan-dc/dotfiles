-- Opciones generales de Neovim
-- Se cargan antes de que lazy.nvim arranque

-- nvim se puede lanzar desde el menú de aplicaciones o cron, donde el PATH
-- heredado no incluye ~/.cargo/bin (rustup) ni las herramientas de mason.
-- LSP como rust-analyzer las busca en el PATH (y su root_dir aborta si no
-- encuentra `cargo`), así que las añadimos aquí.
--
-- Ojo: hay que tocar vim.env.PATH, no vim.opt.path. nvim-lspconfig usa
-- vim.fn.executable() → vim.fn.exepath(), que mira $PATH del proceso.
local extra_path = {}
for _, dir in ipairs({
  vim.fn.expand("~/.cargo/bin"), -- rustc, cargo, rust-analyzer, clippy
  vim.fn.stdpath("data") .. "/mason/bin", -- binarios instalados por mason
}) do
  if vim.fn.isdirectory(dir) == 1 and not vim.env.PATH:find(dir, 1, true) then
    table.insert(extra_path, dir)
  end
end
if #extra_path > 0 then
  vim.env.PATH = table.concat(extra_path, ":") .. ":" .. vim.env.PATH
end

vim.opt.number = true         -- Números de línea
vim.opt.relativenumber = true -- Números relativos
vim.opt.tabstop = 4           -- Ancho visual del tab
vim.opt.softtabstop = 4       -- <Tab> en modo insertar = tab real de 4
vim.opt.shiftwidth = 4        -- Indentación (>>, autoindent)
vim.opt.expandtab = false     -- Usar tabs reales, NO espacios
vim.opt.clipboard = "unnamedplus" -- Portapapeles del sistema
vim.opt.splitright = true     -- Divisiones a la derecha
vim.opt.splitbelow = true     -- Divisiones abajo
vim.opt.scrolloff = 8         -- Mantiene 8 líneas de margen al bajar
vim.opt.updatetime = 50       -- Respuesta más rápida

-- Header 42: login y correo de 42 Madrid
vim.g.user42 = "agalvan-"
vim.g.mail42 = "agalvan-@student.42madrid.com"