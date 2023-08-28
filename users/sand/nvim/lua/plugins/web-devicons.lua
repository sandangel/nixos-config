return {
  'nvim-tree/nvim-web-devicons',
  dependencies = { { 'NvChad/ui', branch = 'v2.0' }, { 'NvChad/base46', branch = 'v2.0' } },
  config = function()
    dofile(vim.g.base46_cache .. 'devicons')
    local colors = require('base46').get_theme_tb 'base_30'
    local override = vim.tbl_deep_extend('force', require('nvchad.icons.devicons'), {
      default_icon = { color = colors.red },
      c = { color = colors.blue },
      css = { color = colors.blue },
      deb = { color = colors.cyan },
      Dockerfile = { color = colors.cyan, icon = '' },
      html = { color = colors.baby_pink },
      jpeg = { color = colors.dark_purple },
      jpg = { color = colors.dark_purple },
      js = { color = colors.sun },
      kt = { color = colors.orange },
      lock = { color = colors.red },
      lua = { color = colors.blue },
      mp3 = { color = colors.white },
      mp4 = { color = colors.white },
      out = { color = colors.white },
      png = { color = colors.dark_purple },
      py = { color = colors.cyan },
      toml = { color = colors.blue },
      ts = { color = colors.teal },
      ttf = { color = colors.white },
      rb = { color = colors.pink },
      rpm = { color = colors.orange },
      vue = { color = colors.vibrant_green },
      woff = { color = colors.white },
      woff2 = { color = colors.white },
      xz = { color = colors.sun },
      zip = { color = colors.sun },
      ['robots.txt'] = { color = colors.blue },
      ['docker-compose.yaml'] = {
        icon = '',
        name = 'DockerCompose',
        color = colors.cyan,
      },
      ['.dockerignore'] = {
        icon = '',
        name = 'DockerIgnore',
        color = colors.cyan,
      },
      yaml = {
        icon = '',
        name = 'yaml',
        color = colors.orange,
      },
      yml = {
        icon = '',
        name = 'yml',
        color = colors.orange,
      },
      hcl = {
        icon = '',
        color = colors.green,
        name = 'hcl',
      },
      json = {
        icon = '',
        color = colors.green,
        name = 'Json',
      },
      md = {
        icon = '',
        color = colors.vibrant_green,
        name = 'md',
      },
      sh = {
        icon = '',
        color = colors.yellow,
        name = 'sh',
      },
      sql = {
        icon = '',
        color = colors.red,
        name = 'sql',
      },
    })
    require('nvim-web-devicons').setup {
      override = override
    }
  end
}
