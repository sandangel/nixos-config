vim.g.mapleader = ' '

vim.g.base46_cache = vim.fn.stdpath 'cache' .. '/nvchad/base46/'
if not vim.loop.fs_stat(vim.g.base46_cache) then
  vim.fn.mkdir(vim.g.base46_cache, 'p')
end

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup {
  spec = {
    {
      dir = '/nix-config/users/' .. vim.env.USER .. '/nvim',
      lazy = false,
      priority = 10000,
      config = function()
        require 'core'
      end
    },
    { import = 'plugins' },
  },
  performance = {
    rtp = {
      disabled_plugins = {
        'matchparen',
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
        'syntax',
        'synmenu',
        'optwin',
        'compiler',
        'bugreport',
        'ftplugin',
      },
    },
  },
}
