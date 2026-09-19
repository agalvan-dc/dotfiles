-- Comandos y funciones de configuración
-- <leader>bp / <leader>bn / <leader>bh : historial de buffers con Telescope

vim.api.nvim_create_user_command('BufOnly', '%bd | e# | bd#', { bang = true })

local M = {}

-- Historial de buffers (navegación adelante/atrás + búsqueda con Telescope)
M.buffer_history = {
  history = {},
  index = 0,

  should_record = function(bufnr)
    local bt = vim.bo[bufnr].buftype
    return bt == "" or bt == "acwrite"
  end,

  record_buffer = function()
    local buf = vim.api.nvim_get_current_buf()
    if not M.buffer_history.should_record(buf) then return end

    if M.buffer_history.index == 0 or M.buffer_history.history[M.buffer_history.index] ~= buf then
      while #M.buffer_history.history > M.buffer_history.index do
        table.remove(M.buffer_history.history)
      end
      table.insert(M.buffer_history.history, buf)
      M.buffer_history.index = #M.buffer_history.history
    end
  end,

  goto_prev_buffer = function()
    if M.buffer_history.index > 1 then
      M.buffer_history.index = M.buffer_history.index - 1
      vim.api.nvim_set_current_buf(M.buffer_history.history[M.buffer_history.index])
    end
  end,

  goto_next_buffer = function()
    if M.buffer_history.index < #M.buffer_history.history then
      M.buffer_history.index = M.buffer_history.index + 1
      vim.api.nvim_set_current_buf(M.buffer_history.history[M.buffer_history.index])
    end
  end,

  cleanup_closed_buffers = function()
    local i = 1
    while i <= #M.buffer_history.history do
      if not vim.api.nvim_buf_is_valid(M.buffer_history.history[i]) then
        table.remove(M.buffer_history.history, i)
        if M.buffer_history.index >= i then
          M.buffer_history.index = math.max(1, M.buffer_history.index - 1)
        end
      else
        i = i + 1
      end
    end
  end,

  -- Búsqueda del historial con Telescope (adaptado del fzf-lua de dot)
  show_history = function()
    local buffers = {}
    local current_index = M.buffer_history.index

    for i, bufnr in ipairs(M.buffer_history.history) do
      if vim.api.nvim_buf_is_valid(bufnr) then
        local name = vim.api.nvim_buf_get_name(bufnr)
        name = name ~= "" and vim.fn.fnamemodify(name, ":~:.") or "[Sin nombre]"
        local prefix = i == current_index and "* " or "  "
        table.insert(buffers, string.format("%s%d: %s", prefix, i, name))
      end
    end

    if #buffers == 0 then
      vim.notify("No hay historial de buffers disponible", vim.log.levels.INFO)
      return
    end

    require("telescope.pickers").new({}, {
      prompt_title = "Buffer History",
      finder = require("telescope.finders").new_table({
        results = buffers,
        entry_maker = function(line)
          local index = tonumber(line:match("^%s*%*?%s*(%d+):"))
          return {
            value = index,
            display = line,
            ordinal = line,
          }
        end,
      }),
      sorter = require("telescope.config").values.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        map("i", "<CR>", function()
          local entry = require("telescope.actions.state").get_selected_entry(prompt_bufnr)
          require("telescope.actions").close(prompt_bufnr)
          if entry and entry.value then
            M.buffer_history.index = entry.value
            vim.api.nvim_set_current_buf(M.buffer_history.history[entry.value])
          end
        end)
        return true
      end,
    }):find()
  end,
}

return M