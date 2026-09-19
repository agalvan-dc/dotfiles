--- Temas visuales.
---
--- Jerarquía de carga (Lazy, por `priority`):
---   tokyonight (1000, el config corre PRIMERO) → nightfox (900) → kanagawa (900)
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
---      - fase 1 (este `config`): aplica el DEFAULT y escribe el marcador
---        SUSPENDIDO (no guarda NADA en disco mientras arranca).
---      - fase 2 (restore_later, VimEnter): ya todos los temas están en
---        runtimepath → valida el último tema guardado contra getcompletion
---        y lo aplica; si no hay ninguno, deja tokyonight-night. Solo
---        después "reanuda" la grabación en disco del tema a mano.
---
--- 2) El autocmd ColorScheme (que graba a disco cada cambio A MANO) está
---    "suspendido" hasta que terminemos de restaurar. Así el `colorscheme
---    tokyonight-night` del arranque NO pisa lo que había guardado en una
---    sesión anterior.
local M = {}

-- Marcador en disco: cache/colorscheme  (no versionable, por máquina)
local marker_file = vim.fn.stdpath("cache") .. "/colorscheme"
local grab_suspended = true -- durante el arranque NO grabamos a disco
local last_choice -- tema guardado en la sesión anterior (memoria)

local function read_marker()
  local f = io.open(marker_file, "r")
  if not f then
    return nil
  end
  local name = f:read("*l")
  f:close()
  return name
end

local function write_marker(name)
  if grab_suspended or not name then
    return
  end
  local f = io.open(marker_file, "w")
  if f then
    f:write(name)
    f:close()
  end
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

return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({ style = "night" })
      -- FASE 1: default garantizado al arrancar.
      vim.cmd([[colorscheme tokyonight-night]])

      -- Registra el autocmd que guarda el tema en disco cuando el usuario
      -- lo cambia a mano (mientras arranca: suspendido, no pisa).
      local group = vim.api.nvim_create_augroup("ThemePersistSave", { clear = true })
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = group,
        callback = function()
          local name = vim.g.colors_name
          if name then
            write_marker(name)
          end
        end,
      })

      -- FASE 2 (VimEnter): todos los temas ya existen aquí → restaurar.
      -- Solo entonces reanudamos la grabación con el estado coherente.
      local restore_group = vim.api.nvim_create_augroup(
        "ThemePersistRestore",
        { clear = true }
      )
      vim.api.nvim_create_autocmd("VimEnter", {
        group = restore_group,
        once = true,
        callback = function()
          local intent = read_marker()
          local applied = false
          if theme_valid(intent) then
            local ok = pcall(vim.cmd.colorscheme, intent)
            if ok then
              applied = true
            end
          end
          local final = vim.g.colors_name or "tokyonight-night"
          -- Reanudamos la grabación a disco con el estado ya coherente
          grab_suspended = false
          write_marker(final)
        end,
      })
    end,
  },

  -- Temas alternativos (se eligen con <leader>ct)
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
}
