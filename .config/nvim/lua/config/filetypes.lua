-- Tipos de archivo para lo que Neovim NO reconoce solo
-- Se carga desde config/lazy.lua (antes de lazy.nvim).
--
-- Dos trabajos:
--
-- 1) ARCHIVOS SIN EXTENSIÓN QUE SÍ TIENEN TIPO CONOCIDO
--    (Makefile, Dockerfile, .gitignore, .bashrc, .env, PKGBUILD...).
--    Neovim ya detecta algunos, pero no todos: aquí se completa el mapa y
--    así también reciben icono (nvim-web-devicons) y resaltado correctos.
--
-- 2) ARCHIVOS SIN EXTENSIÓN QUE SON TEXTO "DE PROSA"
--    README, LICENSE, CHANGELOG, NOTAS, CODEOWNERS... Se marcan como
--    `markdown` para que markview los renderice (títulos, listas, código).
--    Solo si el buffer está vacío de filetype y el archivo es texto de
--    verdad: si tiene un shebang o bytes binarios, no se toca.
local M = {}

-- Nombre (en minúsculas, sin extensión) -> filetype correcto
local known_ft = {
  makefile = "makefile",
  gnumakefile = "makefile",
  justfile = "makefile",
  rakefile = "ruby",
  gemfile = "ruby",
  brewfile = "ruby",
  vagrantfile = "ruby",
  capfile = "ruby",
  podfile = "ruby",
  dockerfile = "docker",
  containerfile = "docker",
  pkgbuild = "sh",
  procfile = "sh",
  [".bashrc"] = "sh",
  [".bash_profile"] = "sh",
  [".bash_aliases"] = "sh",
  [".profile"] = "sh",
  [".zshrc"] = "zsh",
  [".zshenv"] = "zsh",
  [".profile.d"] = "sh",
  [".env"] = "dotenv",
  [".envrc"] = "sh",
  [".gitignore"] = "gitignore",
  [".gitattributes"] = "conf",
  [".gitmodules"] = "gitconfig",
  [".gitconfig"] = "gitconfig",
  [".editorconfig"] = "conf",
  [".inputrc"] = "conf",
  [".npmrc"] = "ini",
  [".condarc"] = "yaml",
  [".tmux.conf"] = "tmux",
  [".vimrc"] = "vim",
  [".nvimrc"] = "vim",
  [".gvimrc"] = "vim",
}

-- Nombres "tipo .c / .py": solo punto inicial, sin extensión real.
-- Aquí el punto ES la extensión (archivo .c -> C, .py -> Python...).
local hidden_ext = {
  c = "c",
  h = "c",
  cpp = "cpp",
  hpp = "cpp",
  py = "python",
  js = "javascript",
  ts = "typescript",
  json = "json",
  yml = "yaml",
  yaml = "yaml",
  toml = "toml",
  sh = "sh",
  rb = "ruby",
  go = "go",
  rs = "rust",
  java = "java",
  lua = "lua",
  vim = "vim",
  md = "markdown",
  html = "html",
  css = "css",
  php = "php",
  pl = "perl",
  sql = "sql",
  xml = "xml",
  ini = "ini",
  conf = "conf",
}

-- Prefijos/nombres de documentación: se renderizan como markdown
local prose = {
  readme = true,
  license = true,
  licence = true,
  copying = true,
  changelog = true,
  changes = true,
  news = true,
  todo = true,
  notes = true,
  notas = true,
  contributing = true,
  code_of_conduct = true,
  security = true,
  install = true,
  installation = true,
  usage = true,
  authors = true,
  contributors = true,
  maintainers = true,
  thanks = true,
  version = true,
  history = true,
  faq = true,
  releasenotes = true,
  notice = true,
  codeowners = true,
  owners = true,
  manifest = false,
}

local TEXT_EXTS = { md = true, markdown = true, txt = true, text = true, rst = true }

-- Shebang -> filetype, para scripts sin extensión
local shebang_ft = {
  sh = "sh",
  bash = "sh",
  zsh = "zsh",
  fish = "fish",
  python = "python",
  python2 = "python",
  python3 = "python",
  node = "javascript",
  ruby = "ruby",
  perl = "perl",
  php = "php",
  awk = "awk",
}

-- Lee los primeros bytes del archivo para saber si es texto.
local function looks_like_text(path)
  local f = io.open(path, "rb")
  if not f then
    return false
  end
  local chunk = f:read(4096) or ""
  f:close()
  if chunk:find("\0", 1, true) then
    return false -- binario
  end
  return true
end

local function first_line(path)
  local f = io.open(path, "rb")
  if not f then
    return ""
  end
  local line = f:read("*l") or ""
  f:close()
  return line
end

-- "README.md" -> "readme", ".bashrc" -> ".bashrc"
local function base_name(path)
  local name = vim.fn.fnamemodify(path, ":t"):lower()
  local ext = name:match("%.([^.]+)$")
  if ext and TEXT_EXTS[ext] then
    name = name:sub(1, -(#ext + 2))
  end
  return name, ext
end

local function guess_ft(path)
  local name, ext = base_name(path)
  if name == "" then
    return nil
  end

  -- 1) tipo conocido exacto
  if known_ft[name] then
    return known_ft[name]
  end
  -- 2) documentación sin extensión -> markdown
  if prose[name] then
    return "markdown"
  end
  -- README-EN, README_v2, LICENSE-APACHE... -> markdown
  for prefix in pairs(prose) do
    if #prefix > 3 and name:match("^" .. prefix .. "[%w_%-.]*$") then
      return "markdown"
    end
  end
  -- 3) archivos tipo .c / .py / .json: el punto inicial ES la extensión
  local hidden = name:match("^%.([%w_+%-]+)$")
  if hidden then
    local matched = vim.filetype.match({ filename = name })
    if matched and matched ~= "" then
      return matched
    end
    if hidden_ext[hidden] then
      return hidden_ext[hidden]
    end
  end
  -- 4) sin extensión y con texto dentro -> markdown
  if not ext or ext == "" then
    local line = first_line(path)
    if line:sub(1, 2) == "#!" then
      -- script sin extensión: el intérprete del shebang manda
      local interp = line:match("^#!%s*(%S+)")
      if interp then
        interp = vim.fn.fnamemodify(interp, ":t"):lower()
        if interp == "env" then
          interp = (line:match("^#!%s*%S+%s+(%S+)") or ""):lower()
        end
      end
      return shebang_ft[interp] or "sh"
    end
    if looks_like_text(path) then
      return "markdown"
    end
  end
  return nil
end

function M.apply(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  if vim.bo[buf].filetype ~= "" then
    return -- Neovim ya lo detectó
  end
  local name = vim.api.nvim_buf_get_name(buf)
  if name == "" or vim.fn.filereadable(name) == 0 then
    return
  end
  -- Neovim ya conoce muchos de estos nombres y su resultado manda: Makefile
  -- es `make` (no `makefile`), Dockerfile es `dockerfile` (no `docker`),
  -- .h es `cpp`, .ini es `dosini`... Si se usa un alias inventado el buffer
  -- se queda sin archivo de sintaxis ni parser y por eso sale sin colores.
  -- `text` es el comodín de Neovim para README/LICENSE/AUTHORS sin extensión:
  -- en ese caso seguimos abajo para que se abran como markdown (markview).
  local builtin = vim.filetype.match({ filename = name, buf = buf })
  if builtin and builtin ~= "" and builtin ~= "text" then
    vim.bo[buf].filetype = builtin
    return
  end

  local ft = guess_ft(name)
  if ft then
    vim.bo[buf].filetype = ft
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup("FiletypeGuess", { clear = true })
  vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "BufFilePost" }, {
    group = group,
    callback = function(args)
      M.apply(args.buf)
    end,
  })
end

return M