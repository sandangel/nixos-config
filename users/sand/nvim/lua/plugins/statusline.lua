return {
  {
    'NvChad/ui',
    branch = 'v2.0',
    lazy = false,
    config = function()
      dofile(vim.g.base46_cache .. 'statusline')
      local config = require('core.utils').load_config()
      vim.opt.statusline = "%!v:lua.require('nvchad_ui.statusline." .. config.ui.statusline.theme .. "').run()"
    end
  },
}
