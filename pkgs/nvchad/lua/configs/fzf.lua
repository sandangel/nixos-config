local fzf_history_dir = vim.env.HOME .. '/.local/share/nvim/fzf-history'
if vim.fn.isdirectory(fzf_history_dir) == 0 then
  vim.fn.system { 'mkdir', '-p', fzf_history_dir, }
end

local fzf_lua = require 'fzf-lua'

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
    ['--layout'] = 'default',
    ['--history'] = fzf_history_dir .. '/fzf-lua',
    ['--history-size'] = '10000',
  },
  defaults = {
    copen = 'FzfLua quickfix',
  },
  files = {
    git_icons = false,
  },
  grep = {
    git_icons = false,
    file_icons = false,
    color_icons = false,
  },
  oldfiles = {
    actions  = {
      ['ctrl-g'] = function(_, opts)
        opts.cwd_only = not opts.cwd_only
        opts.__call_fn { cwd_only = opts.cwd_only, resume = true, }
      end,
    },
    cwd_only = true,
  },
}
