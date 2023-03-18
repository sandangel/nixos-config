return {
  'glepnir/lspsaga.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  event = 'BufRead',
  branch = 'main',
  config = function()
    local lspsaga = require 'lspsaga'
    lspsaga.setup {
      finder = {
        edit = { 'o', '<cr>' },
        vsplit = 's',
        quit = { 'q', '<esc>' },
      },
    }
  end
}
