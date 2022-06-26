vim.o.runtimepath = '/nix-config/users/' .. vim.env.USER .. '/nvim,' .. vim.o.runtimepath

require 'core'
require 'plugins'
