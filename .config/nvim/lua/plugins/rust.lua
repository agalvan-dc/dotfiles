return {
  "mrcjkb/rustaceanvim",
  version = "^4",
  ft = { "rust" },
  config = function()
    -- Rustaceanvim se autoconfigura al abrir un archivo .rs
    -- Como hemos usado 'LspAttach' en tu archivo lsp.lua,
    -- automáticamente heredará todos los atajos de teclado (gd, K, etc.)
  end
}
