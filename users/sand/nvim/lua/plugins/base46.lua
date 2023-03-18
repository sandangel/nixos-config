return {
  'NvChad/base46',
  branch = 'v2.0',
  lazy = false,
  dependencies = { 'nvim-lua/plenary.nvim' },
  init = function()
    local config = require('core.utils').load_config()
    vim.g.nvchad_theme = config.ui.theme
    vim.g.toggle_theme_icon = '   '
    vim.g.transparency = config.ui.transparency
  end,
  build = function()
    require('base46').load_all_highlights()
  end,
  config = function()
    dofile(vim.g.base46_cache .. 'defaults')
  end,
}
