local fzf_history_dir = vim.fn.expand '~/.local/share/nvim/fzf-history'
if vim.fn.isdirectory(fzf_history_dir) == 0 then
  vim.fn.system { 'mkdir', '-p', fzf_history_dir }
end
local fzf_lua = require 'fzf-lua'

local function fzf_quickfix(selected, opts)
  if #selected > 1 then
    local qf_list = {}
    for i = 1, #selected do
      local file = require 'fzf-lua'.path.entry_to_file(selected[i], opts)
      local text = selected[i]:match ':%d+:%d?%d?%d?%d?:?(.*)$'
      table.insert(qf_list, {
        filename = file.path,
        lnum = file.line,
        col = file.col,
        text = text,
      })
    end
    vim.fn.setqflist(qf_list)
    vim.cmd 'FzfLua quickfix'
  else
    fzf_lua.actions.file_edit(selected, opts)
  end
end

fzf_lua.setup {
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
    ['--history-size'] = '2000',
  },
  actions = {
    files = {
      ['default'] = fzf_quickfix,
      ['ctrl-s']  = fzf_lua.actions.file_vsplit,
    },
    buffers = {
      ['default'] = fzf_quickfix,
      ['ctrl-s']  = fzf_lua.actions.buf_vsplit,
    }
  },
  grep = {
    git_icons = false,
    file_icons = false,
    color_icons = false,
  },
  oldfiles = {
    cwd_only = true,
    include_current_session = true,
  },
}

local opts = { silent = true }
local get_visual_selection = require('fzf-lua.utils').get_visual_selection

vim.keymap.set('n', 'gl', '<cmd>FzfLua loclist<cr>', opts)
vim.keymap.set('n', 'gq', '<cmd>FzfLua quickfix<cr>', opts)

vim.keymap.set('n', '<leader>cc', function()
  fzf_lua.git_commits()
end, opts)
vim.keymap.set('n', '<leader>bc', function()
  fzf_lua.git_bcommits()
end, opts)
vim.keymap.set('n', '<leader>hc', function()
  fzf_lua.command_history()
end, opts)
vim.keymap.set('n', '<leader>hs', function()
  fzf_lua.search_history()
end, opts)

vim.keymap.set('n', '<leader>s', function() fzf_lua.oldfiles() end, opts)
vim.keymap.set('n', '<leader>j', function() fzf_lua.files() end, opts)
vim.keymap.set('n', '<leader>J', function() fzf_lua.files { cwd = vim.fn.expand '%:p:h' } end, opts)
vim.keymap.set('n', '<leader>g', function() fzf_lua.git_status() end, opts)
vim.keymap.set('n', '<leader>a', function() fzf_lua.buffers() end, opts)
vim.keymap.set('n', '<leader>f', function() fzf_lua.grep_project() end, opts)
vim.keymap.set('n', '<leader>F', function() fzf_lua.grep_project { cwd = vim.fn.expand '%:p:h' } end, opts)
vim.keymap.set('n', '<leader>l', function() fzf_lua.blines() end, opts)

vim.keymap.set('n', '<leader>d', function()
  fzf_lua.grep_project { fzf_opts = { ['--query'] = vim.fn.expand '<cword>' } }
end, opts)
vim.keymap.set('n', '<leader>D', function()
  fzf_lua.grep_project { cwd = vim.fn.expand '%:p:h', fzf_opts = { ['--query'] = vim.fn.expand '<cword>' } }
end, opts)
vim.keymap.set('n', '<leader>k', function()
  fzf_lua.blines { fzf_opts = { ['--query'] = vim.fn.expand '<cword>' } }
end, opts)

vim.keymap.set('x', '<leader>d', function()
  fzf_lua.grep_project { fzf_opts = { ['--query'] = get_visual_selection() } }
end, opts)
vim.keymap.set('x', '<leader>D', function()
  fzf_lua.grep_project {
    cwd = vim.fn.expand '%:p:h',
    fzf_opts = { ['--query'] = get_visual_selection() },
  }
end, opts)
vim.keymap.set('x', '<leader>k', function()
  fzf_lua.blines { fzf_opts = { ['--query'] = get_visual_selection() } }
end, opts)
