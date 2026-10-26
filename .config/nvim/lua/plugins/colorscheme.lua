--- Temas visuales.
---
--- Jerarquía de carga (Lazy, por `priority`):
---   tokyonight (1000, el config corre PRIMERO) → nightfox (900) → kanagawa (900)
---
--- Idea central: el tema se guarda POR CARPETA (por "ruta" abierta).
--- `nvim ~/proyecto/a` o `nvim ~/proyecto/a/archivo.lua` recuerdan el tema
--- que usaste la última vez ahí; al volver a abrir esa ruta se restaura solo.
--- Cada ruta tiene su archivo en `stdpath("cache")/themes/<hash>.txt` con dos
--- líneas: la ruta completa y el nombre del tema.
---
--- DOS conceptos clave que este archivo maneja en serio:
---
--- 1) PERMANENCIA DEL TEMA ELEGIDO CON <leader>ct:
---    El `config` de tokyonight (priority 1000) aplica el default. Pero si
---    intentas RESTAURAR el tema guardado DENTRO de ese config, falla en
---    silencio: en ese instante nightfox/kanagawa todavía NO están en
---    runtimepath (priority 900) → tu tema guardado "no existe" → Lazy pisa
---    siempre con tokyonight-night. (Bug que parece "el tema no se guarda".)
---
---    Por eso TODO ocurre en dos fases echa aquí dentro:
---      - fase 1 (este `config`): aplica el DEFAULT y deja la grabación
---        SUSPENDIDA (no guarda NADA en disco mientras arranca).
---      - fase 2 (VimEnter): ya todos los temas están en runtimepath → valida
---        el tema guardado de ESTA ruta contra getcompletion y lo aplica; si
---        no hay ninguno, deja tokyonight-night. Solo después reanuda la
---        grabación en disco del tema a mano.
---
--- 2) El autocmd ColorScheme (que graba a disco cada cambio A MANO) está
---    "suspendido" hasta que terminemos de restaurar. Así el `colorscheme
---    tokyonight-night` del arranque NO pisa lo que había guardado en una
---    sesión anterior de esa misma carpeta.
---
--- Detalles de implementación:
---   - La ruta NO se saca de getcwd(): Neovim no hace cd al argumento, así
---     que se deduce del primer buffer cargado al entrar (el archivo o el
---     directorio que abriste). Si no abriste nada, se usa el cwd. Esto se
---     resuelve en VimEnter, cuando ese buffer ya existe.
---   - Los cambios de tema se graban con un pequeño debounce: el picker de
---     Telescope previsualiza muchos temas seguidos y al cerrarse restaura
---     el anterior, así que escribimos el ÚLTIMO aplicado por la sesión.
---   - Si haces `:cd` (o abres una sesión guardada de persistence.nvim), la
---     ruta nueva recupera su tema y la vieja conserva el suyo.

local DEFAULT_THEME = "tokyonight-night"
local themes_dir = vim.fn.stdpath("cache") .. "/themes"
local FLUSH_DELAY = 150 -- ms de calma antes de escribir a disco

local grab_suspended = true -- durante el arranque NO grabamos a disco
local current_dir -- ruta activa en esta sesión
local pending -- { dir, name } último tema aplicado, aún sin escribir

-- kanagawa.nvim define sus 4 variantes (kanagawa, kanagawa-dragon,
-- kanagawa-lotus, kanagawa-wave) como 4 ficheros en colors/ PERO las cuatro
-- hacen `let g:colors_name = "kanagawa"`. Guardar g:colors_name perdía la
-- variante: al reabrir se aplicaba siempre la normal.
--
-- Solución: guardamos el nombre REAL, deducido de la variante interna que
-- kanagawa tiene cargada (kanagawa._CURRENT_THEME). Todos esos nombres
-- ("kanagawa-dragon", "kanagawa-lotus", "kanagawa-wave") son colores válidos,
-- así que al restaurar funcionan sin más.
--
-- Nota: "kanagawa" a secas equivale a la variante wave (es el _CURRENT_THEME
-- por defecto de kanagawa.nvim), así que se guarda como "kanagawa-wave".
local function refine_kanagawa(colors_name)
  if colors_name ~= "kanagawa" then
    return colors_name
  end
  local ok, kanagawa = pcall(require, "kanagawa")
  local variant = ok and kanagawa._CURRENT_THEME or nil
  if type(variant) ~= "string" or variant == "" then
    return colors_name
  end
  return "kanagawa-" .. variant
end

-- rose-pine tiene 4 ficheros en colors/ pero rose-pine, rose-pine-main,
-- rose-pine-moon y rose-pine-dawn hacen TODOS `g:colors_name = "rose-pine"`.
-- La variante pedida queda en `require("rose-pine.config").options.variant`
-- (o "auto", que sigue a 'background': dark→main, light→dawn).
local function refine_rose_pine(colors_name)
  if colors_name ~= "rose-pine" then
    return colors_name
  end
  local ok, config = pcall(require, "rose-pine.config")
  local variant = ok and config.options and config.options.variant or nil
  if variant == "auto" or not variant then
    variant = vim.o.background == "light" and "dawn" or "main"
  end
  return "rose-pine-" .. variant
end

-- gruvbox y everforest tienen UN solo colour file cada uno: la variante se
-- elige con 'background' (dark/light), no con el nombre. Guardamos el sufijo
-- para poder restaurarla: "gruvbox-dark" / "gruvbox-light", etc.
local function refine_background(colors_name)
  if colors_name ~= "gruvbox" and colors_name ~= "everforest" then
    return colors_name
  end
  return colors_name .. "-" .. vim.o.background
end

-- Nombre del tema que hay que guardar AHORA MISMO.
local function current_theme()
  return refine_background(refine_rose_pine(refine_kanagawa(vim.g.colors_name)))
end

-- Ruta canónica (resuelve symlinks, quita la / final).
local function normalize_dir(dir)
  if vim.fs and vim.fs.normalize then
    dir = vim.fs.normalize(dir)
  else
    dir = vim.fn.fnamemodify(dir, ":p")
  end
  return (dir:gsub("/+$", ""))
end

-- Ruta de la sesión: el primer buffer con nombre real (el archivo o el
-- directorio que se abrió). Si no hay ninguno, el cwd.
local function session_dir()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(buf)
    if name ~= "" then
      if vim.fn.isdirectory(name) == 1 then
        return normalize_dir(name)
      end
      return normalize_dir(vim.fn.fnamemodify(name, ":h"))
    end
  end
  return normalize_dir(vim.fn.getcwd())
end

local function active_dir()
  current_dir = current_dir or session_dir()
  return current_dir
end

-- Un archivo por ruta. El hash evita nombres raros en disco; dentro se
-- guarda la ruta completa para detectar colisiones y poder leerlo a mano.
local function state_file(dir)
  return themes_dir .. "/" .. vim.fn.sha256(dir):sub(1, 20) .. ".txt"
end

local function read_theme(dir)
  local f = io.open(state_file(dir), "r")
  if not f then
    return nil
  end
  local saved_path = f:read("*l")
  local name = f:read("*l")
  f:close()
  if saved_path ~= dir then -- colisión de hash (prácticamente imposible)
    return nil
  end
  return name
end

local function write_theme(dir, name)
  if not dir or not name then
    return
  end
  if vim.fn.isdirectory(themes_dir) == 0 then
    vim.fn.mkdir(themes_dir, "p")
  end
  local f = io.open(state_file(dir), "w")
  if f then
    f:write(dir .. "\n" .. name .. "\n")
    f:close()
  end
end

-- Encola la escritura del tema de `dir`. Colapsa ráfagas (preview de
-- Telescope) para escribir solo el último tema aplicado.
local function queue_write(dir, name)
  if grab_suspended or not dir or not name then
    return
  end
  pending = { dir = dir, name = name }
  vim.defer_fn(function()
    local p = pending
    if not p then
      return
    end
    pending = nil
    if not grab_suspended then
      write_theme(p.dir, p.name)
    end
  end, FLUSH_DELAY)
end

-- Temas REALMENTE en runtimepath AHORA. Solo fiable tras VimEnter.
local function available_here()
  local ok, comp = pcall(vim.fn.getcompletion, "", "color")
  if not ok then
    return {}
  end
  return comp
end

local function theme_valid(name)
  if not name then
    return false
  end
  for _, cs in ipairs(available_here()) do
    if cs == name then
      return true
    end
  end
  return false
end

-- Aplica el tema guardado de `dir` si existe y sigue siendo válido.
-- Devuelve true si se aplicó.
--
-- Ojo con los sufijos: los nombres que grabamos no siempre son ficheros de
-- colors/ reales. "gruvbox-dark"/"everforest-light" no existen como colour file
-- (su variante se elige con 'background'), así que getcompletion NO los ve y
-- theme_valid los rechazaría. Por eso los desenrollamos aquí:
--   1) probamos el nombre tal cual
--   2) si no, partimos el sufijo -dark/-light: ponemos 'background' y aplicamos
--      la base, que sí es un colour file válido.
local function restore_for(dir)
  local intent = read_theme(dir)
  if not intent then
    return false
  end
  if theme_valid(intent) then
    return (pcall(vim.cmd.colorscheme, intent))
  end
  local base, bg = intent:match("^(.*)%-(dark)$")
  if not base then
    base, bg = intent:match("^(.*)%-(light)$")
  end
  if base and theme_valid(base) then
    vim.o.background = bg
    return (pcall(vim.cmd.colorscheme, base))
  end
  return false
end

vim.api.nvim_create_user_command("ThemeReset", function()
  if current_dir then
    pending = nil
    os.remove(state_file(current_dir))
  end
  vim.g.colors_name = nil
  vim.cmd("colorscheme " .. DEFAULT_THEME)
  vim.notify("Tema de esta ruta borrado: " .. tostring(current_dir), vim.log.levels.Info)
end, {
  desc = "Borra el tema guardado de la ruta actual (vuelve al default)",
})

return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({ style = "night" })
      -- FASE 1: default garantizado al arrancar.
      vim.cmd("colorscheme " .. DEFAULT_THEME)
      -- current_dir se resuelve en VimEnter, cuando el buffer de apertura
      -- ya está cargado.

      local group = vim.api.nvim_create_augroup("ThemePersistSave", { clear = true })

      -- El tema aplicado a mano (típicamente con <leader>ct) se guarda para
      -- la ruta activa. Durante el arranque está suspendido: no pisa nada.
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = group,
        callback = function()
          queue_write(active_dir(), current_theme())
        end,
      })

      -- :cd (o carga de sesión de persistence.nvim): la ruta vieja conserva
      -- su tema y la nueva recupera el suyo.
      vim.api.nvim_create_autocmd("DirChanged", {
        group = group,
        callback = function()
          local new_dir = normalize_dir(vim.fn.getcwd())
          local old_dir = active_dir()
          if new_dir == old_dir then
            return
          end
          queue_write(old_dir, current_theme()) -- flush de la vieja
          current_dir = new_dir
          if not restore_for(new_dir) then
            pcall(vim.cmd.colorscheme, DEFAULT_THEME)
          end
        end,
      })

      -- FASE 2 (VimEnter): todos los temas ya existen → restaurar el de esta
      -- ruta. Solo entonces reanudamos la grabación a disco.
      local restore_group = vim.api.nvim_create_augroup(
        "ThemePersistRestore",
        { clear = true }
      )
      vim.api.nvim_create_autocmd("VimEnter", {
        group = restore_group,
        once = true,
        callback = function()
          current_dir = session_dir()
          restore_for(current_dir)
          -- Reanudamos la grabación con el estado ya coherente
          grab_suspended = false
          write_theme(current_dir, current_theme() or DEFAULT_THEME)
        end,
      })

      -- Red de seguridad: si se cierra la sesión sin pasar por VimEnter, o si
      -- el tema cambió en los últimos ms, el tema final queda guardado.
      vim.api.nvim_create_autocmd("VimLeavePre", {
        group = restore_group,
        once = true,
        callback = function()
          local name = current_theme() or DEFAULT_THEME
          if current_dir then
            write_theme(current_dir, name)
          else
            write_theme(session_dir(), name)
          end
        end,
      })
    end,
  },

  -- Temas alternativos (se eligen con <leader>ct)
  --
  -- lazy = false + priority 900 es OBLIGATORIO aquí: la fase 2 (VimEnter)
  -- valida el tema guardado contra getcompletion, así que a esa hora TODOS los
  -- colors/ tienen que estar ya en runtimepath. Si uno fuera lazy, su
  -- "colorscheme guardado" daría E185 y se perdería la persistencia.
  {
    "EdenEast/nightfox.nvim",
    lazy = false,
    priority = 900,
  },
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 900,
  },
  -- Catppuccin: latte (claro) / frappe / macchiato / mocha (oscuro)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 900,
    opts = {},
  },
  -- Gruvbox: dark / dimmed / light  (retro, cálido)
  {
    "ellisonleao/gruvbox.nvim",
    name = "gruvbox",
    lazy = false,
    priority = 900,
    opts = {
      terminal_colors = true,
      highlight_overrides = {},
    },
  },
  -- Rosé Pine: main / moon (oscuros) / dawn (claro)
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 900,
    opts = { disable_background = false },
  },
  -- Everforest: verde cálido y suave; variant soft/medium/hard.
  {
    "neanias/everforest-nvim",
    name = "everforest",
    lazy = false,
    priority = 900,
    opts = { background = "medium" },
  },
}