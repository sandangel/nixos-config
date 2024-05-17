local fzf_history_dir = vim.env.HOME .. '/.local/share/nvim/fzf-history'
if vim.fn.isdirectory(fzf_history_dir) == 0 then
  vim.fn.system { 'mkdir', '-p', fzf_history_dir, }
end
local fzf_lua = require 'fzf-lua'
local utils = require 'fzf-lua.utils'

local sel_to_qf = function(selected, opts)
  local qf_list = {}
  for i = 1, #selected do
    local file = fzf_lua.path.entry_to_file(selected[i], opts)
    local text = selected[i]:match ':%d+:%d?%d?%d?%d?:?(.*)$'
    table.insert(qf_list, {
      filename = file.bufname or file.path,
      lnum = file.line,
      col = file.col,
      text = text,
    })
  end
  vim.fn.setqflist(qf_list)
  vim.cmd 'FzfLua quickfix'
end

local function file_edit_or_qf(selected, opts)
  if #selected > 1 then
    return sel_to_qf(selected, opts)
  else
    fzf_lua.actions.file_edit(selected, opts)
  end
end

local function buf_edit_or_qf(selected, opts)
  if #selected > 1 then
    return sel_to_qf(selected, opts)
  else
    return fzf_lua.actions.buf_edit(selected, opts)
  end
end

fzf_lua.setup { 'max-perf', {
  keymap = {
    builtin = {
      ['<F1>'] = 'toggle-help',
      ['<F2>'] = 'toggle-fullscreen',
      ['<F3>'] = 'toggle-preview',
      ['<PageDown>'] = 'preview-page-down',
      ['<PageUp>'] = 'preview-page-up',
      ['<Home>'] = 'preview-page-reset',
    },
    fzf = {
      ['tab'] = 'toggle',
      ['ctrl-a'] = 'toggle-all',
      ['ctrl-f'] = 'half-page-down',
      ['ctrl-b'] = 'half-page-up',
    },
  },
  fzf_opts = {
    ['--layout'] = false,
    ['--history'] = fzf_history_dir .. '/fzf-lua',
    ['--history-size'] = '10000',
  },
  actions = {
    files = {
      ['enter']  = file_edit_or_qf,
      ['ctrl-s'] = fzf_lua.actions.file_vsplit,
    },
  },
}, }
