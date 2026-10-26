return {
  -- Explorador Neo-Tree
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" },
    opts = {
      source = "nui-web-devicons", -- iconos por tipo de archivo
      close_if_last_window = true,
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
      },
      window = {
        width = 34,
        mappings = {
          ["<space>"] = { "toggle_node", desc = "Expandir/Plegar" },
          ["<cr>"] = { "open", desc = "Abrir" },
          ["<2-LeftMouse>"] = { "open", desc = "Abrir con click" },
          -- Ojo: en neo-tree v3.x las acciones válidas son "add" y
          -- "close_window". "create" y "close" no existen y neo-tree avisa
          -- con "Invalid mapping for ..." cada vez que se abre el árbol.
          ["a"] = { "add", desc = "Nuevo archivo/carpeta" },
          ["A"] = { "add_directory", desc = "Nueva carpeta" },
          ["d"] = { "delete", desc = "Borrar" },
          ["r"] = { "rename", desc = "Renombrar" },
          ["y"] = { "copy_to_clipboard", desc = "Copiar ruta" },
          ["/"] = { "fuzzy_finder", desc = "Filtro rápido" },
          ["q"] = { "close_window", desc = "Cerrar" },
          ["?"] = { "show_help", desc = "Ayuda de Neo-Tree" },
        },
      },
      default_component_configs = {
        indent = { with_expanders = true },
        file_type = { enabled = false }, -- el icono ya dice el tipo
      },
      renderer = { highlight_opened_files = true },
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Explorador de Archivos" },
    },
    config = function(_, opts)
      require("neo-tree").setup(opts)
    end,
  },
}