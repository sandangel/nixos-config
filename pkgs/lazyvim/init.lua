vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out,                            'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  spec = {
    { 'LazyVim/LazyVim', import = 'lazyvim.plugins' },
    -- fzf-lua as picker
    { import = 'lazyvim.plugins.extras.editor.fzf' },
    -- Copilot via blink-copilot
    { import = 'lazyvim.plugins.extras.ai.copilot' },
    -- LuaSnip snippet engine
    { import = 'lazyvim.plugins.extras.coding.luasnip' },
    -- DAP core debugger
    { import = 'lazyvim.plugins.extras.dap.core' },
    -- Python DAP + LSP
    { import = 'lazyvim.plugins.extras.lang.python' },
    -- Rust LSP + crates.nvim (replaces rust.vim)
    { import = 'lazyvim.plugins.extras.lang.rust' },
    -- Markdown rendering + preview
    { import = 'lazyvim.plugins.extras.lang.markdown' },
    -- Language extras
    { import = 'lazyvim.plugins.extras.lang.nix' },
    { import = 'lazyvim.plugins.extras.lang.docker' },
    { import = 'lazyvim.plugins.extras.lang.yaml' },
    { import = 'lazyvim.plugins.extras.lang.toml' },
    { import = 'lazyvim.plugins.extras.lang.json' },
    { import = 'lazyvim.plugins.extras.lang.typescript' },
    { import = 'lazyvim.plugins.extras.lang.go' },
    { import = 'lazyvim.plugins.extras.lang.git' },
    -- Editor extras
    { import = 'lazyvim.plugins.extras.editor.illuminate' },
    -- UI extras
    { import = 'lazyvim.plugins.extras.ui.treesitter-context' },
    { import = 'lazyvim.plugins.extras.ui.mini-indentscope' },
    -- Coding extras
    { import = 'lazyvim.plugins.extras.coding.mini-surround' },
    { import = 'lazyvim.plugins.extras.editor.mini-move' },
    -- Util extras
    { import = 'lazyvim.plugins.extras.util.dot' },
    -- Formatting + linting
    { import = 'lazyvim.plugins.extras.formatting.prettier' },
    { import = 'lazyvim.plugins.extras.linting.eslint' },
    -- Additional lang extras
    { import = 'lazyvim.plugins.extras.lang.helm' },
    { import = 'lazyvim.plugins.extras.lang.sql' },
    { import = 'lazyvim.plugins.extras.lang.terraform' },
    -- User plugins
    { import = 'plugins' },
  },
  lockfile = vim.fn.stdpath('data') .. '/lazy-lock.json',
  checker = {
    enabled = true,
    frequency = 3600 * 2,
    notify = false,
  },
  rocks = { enabled = false },
  defaults = {
    lazy = true,
    version = false,
  },
  install = { colorscheme = { 'habamax' } },
  performance = {
    rtp = {
      disabled_plugins = {
        '2html_plugin',
        'tohtml',
        'getscript',
        'getscriptPlugin',
        'gzip',
        'logipat',
        'netrw',
        'netrwPlugin',
        'netrwSettings',
        'netrwFileHandlers',
        'matchit',
        'tar',
        'tarPlugin',
        'rrhelper',
        'spellfile_plugin',
        'vimball',
        'vimballPlugin',
        'zip',
        'zipPlugin',
        'tutor',
        'rplugin',
        'synmenu',
        'optwin',
        'compiler',
        'bugreport',
        'ftplugin',
      },
    },
  },
})
