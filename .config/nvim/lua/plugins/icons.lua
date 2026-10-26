return {
  -- Iconos por tipo de archivo (nvim-web-devicons)
  -- Fuente única de iconos para TODO: NeoTree, Telescope, bufferline,
  -- lualine y markview. Necesita una Nerd Font en la terminal
  -- (JetBrainsMono Nerd Font, instalada por install.sh / manual).
  {
    "nvim-tree/nvim-web-devicons",
    opts = {
      default = true, -- usa los iconos por defecto de nvim-web-devicons
      -- Archivos SIN extensión o con "extensión" rara que devicons no conoce
      extension = {
        ["justfile"] = "make",
        ["dockerfile"] = "docker",
        ["gitignore"] = "git",
        ["gitattributes"] = "git",
        ["gitconfig"] = "git",
        ["gitmodules"] = "git",
        ["env"] = "gear",
        ["envrc"] = "gear",
        ["editorconfig"] = "editorconfig",
        ["bashrc"] = "bash",
        ["zshrc"] = "shell",
        ["vimrc"] = "vim",
        ["nvimrc"] = "vim",
        ["sudoers"] = "terminal",
        ["conf"] = "settings",
        ["cfg"] = "settings",
        ["toml"] = "settings",
        ["lock"] = "lock",
        ["log"] = "file",
        ["sql"] = "database",
        ["dockerfile"] = "docker",
        ["excalidraw"] = "excalidraw",
        ["heex"] = "html",
        ["eex"] = "html",
        ["gleam"] = "gleam",
      },
      -- Iconos por filetype, para archivos sin extensión
      icons_by_filetype = {
        markdown = "md",
        gitignore = "git",
        gitconfig = "git",
        dotenv = "gear",
        makefile = "make",
        dockerfile = "docker",
        sh = "bash",
        bash = "bash",
        zsh = "shell",
        lua = "lua",
        python = "py",
        rust = "rs",
        c = "c",
        cpp = "cpp",
        text = "text",
        json = "json",
        yaml = "yaml",
        toml = "toml",
        shell = "bash",
        vim = "vim",
      },
    },
    config = function(_, opts)
      require("nvim-web-devicons").setup(opts)
    end,
  },
}