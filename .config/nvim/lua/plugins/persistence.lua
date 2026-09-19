return {
  -- Sesiones persistentes por proyecto (se guardan solas al salir)
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    keys = {
      { "<leader>ss", function() require("persistence").save() end, desc = "Guardar sesión" },
      { "<leader>so", function() require("persistence").load() end, desc = "Restaurar sesión" },
      { "<leader>sl", function() require("persistence").load({ last = true }) end, desc = "Última sesión" },
      { "<leader>sd", function() require("persistence").stop() end, desc = "Borrar sesión" },
    },
  },
}