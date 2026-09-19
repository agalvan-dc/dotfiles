--- Persistencia del tema elegido con <leader>ct (Telescope colorscheme)
--- ====================================================================
--- ORDEN DE CARGA (Lazy, por priority) ──por qué este módulo existe:
---   tokyonight = priority 1000  ─┐
---   nightfox   = priority  900  ─┼ se cargan todos en el mismo arranque
---   kanagawa   = priority  900  ─┘  pero tokyonight CORRE PRIMERO.
---
--- PROBLEMA:
---   El `config` de tokyonight (que es quien aplica el tema) se ejecuta
---   ANTES de que nightfox/kanagawa estén en runtimepath. Por eso un
---   `getcompletion('', 'color')` hecho ahí NO ve kanagawa/nightfox:
---   aunque el tema guardado sea kanagawa-wave, no se puede aplicar en ese
---   instante → cae siempre al default tokyonight-night. (El tema guardado
---   NO se restaura.) Y si fuerzas `pcall(vim.cmd.colorscheme)` igual
---   aplica tokyonight (porque kanagawa aún no existe → error silencioso).
---
--- SOLUCIÓN (dos fases, la única que funciona de verdad):
---   • setup()        → lee a MEMORIA el último tema elegido (last_intent)
---                      y registra un autocmd ColorScheme que LO GUARDA EN
---                      DISCO cuando el usuario lo cambia a mano. Durante
---                      el arranque la GRABACIÓN queda SUSPENDIDA (suspend
---                      = true) para que el default del arranque no pise
---                      lo que hubiera guardado.
---   • restore_later()→ se encola en VimEnter. En ESE momento TODOS los
---                      temas ya están en runtimepath (Lazy los cargó),
---                      así que valida last_intent contra getcompletion y
---                      lo aplica; si no había ninguno válido, aplica el
---                      default tokyonight-night. Solo ENTONCES desuscende
---                      la grabación y deja el marcador coherente.
--- ====================================================================
local M = {}

--- Fichero que guarda el último tema a disco.
local function marker_file()
  return vim.fn.stdpath("cache") .. "/colorscheme"
end

local suspended = true -- durante el arranque NO se graba en disco
local last_intent -- tema elegido la última vez (leído a memoria en setup)

local function read_marker()
  local f = io.open(marker_file(), "r")
  if not f then
    return nil
  end
  local name = f:read("*l")
  f:close()
  if name and name ~= "" then
    return name
  end
  return nil
end

local function write_marker(name)
  if suspended or not name then
    return
  end
  local f = io.open(marker_file(), "w")
  if f then
    f:write(name)
    f:close()
  end
end

-- Temas realmente disponibles AHORA MISMO (runtimepath actual).
-- Solo es fiable en VimEnter (cuando Lazy ya cargó todos).
local function themes_now()
  local ok, comp = pcall(vim.fn.getcompletion, "", "color")
  if not ok then
    return {}
  end
  return comp
end

local function theme_available(name)
  if not name then
    return false
  end
  for _, cs in ipairs(themes_now()) do
    if cs == name then
      return true
    end
  end
  return false
end

--- 1ª fase: lee a memoria + registra el autocmd que guarda a disco.
function M.setup()
  last_intent = read_marker()

  -- Mientras restauramos NO grabamos, para que el colorscheme por defecto
  -- del arranque no pise lo que hubiéramos guardado a mano.
  suspended = true

  local group = vim.api.nvim_create_augroup("ThemePersist", { clear = true })
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = function()
      local name = vim.g.colors_name
      if name then
        write_marker(name)
      end
    end,
  })
end

--- 2ª fase (se encola, NO forza): en VimEnter aplica el tema guardado.
function M.restore_later()
  local group = vim.api.nvim_create_augroup("ThemePersistRestore", { clear = true })
  vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    once = true,
    callback = function()
      local applied = false
      -- 1. Intentar el tema que el usuario eligió la última vez
      if theme_available(last_intent) then
        local ok = pcall(vim.cmd.colorscheme, last_intent)
        if ok then
          applied = true
        end
      end
      -- 2. Si no había ninguno válido → default
      if not applied then
        pcall(vim.cmd.colorscheme, "tokyonight-night")
      end
      -- Ya todo cargado y aplicado: a partir de aquí SÍ se graba
      suspended = false
      write_marker(vim.g.colors_name)
    end,
  })
end

return M
