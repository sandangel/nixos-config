return { 'echasnovski/mini.nvim', config = function()

  local modules = {
    'ai',
    'align',
    'cursorword',
    'indentscope',
    'trailspace',
  }

  for _, m in ipairs(modules) do
    require('mini.' .. m).setup()
  end

  local animate = require 'mini.animate'
  animate.setup({
    cursor = {
      timing = animate.gen_timing.exponential({ easing = 'in-out', unit = 'step', duration = 4 }),
      path = animate.gen_path.angle(),
    },
    scroll = {
      timing = animate.gen_timing.linear({ unit = 'step', duration = 2 }),
      subscroll = animate.gen_subscroll.equal({ max_output_steps = 120 })
    }
  })

  vim.api.nvim_create_augroup('MiniNvimUser', { clear = true })
  vim.api.nvim_create_autocmd('BufWritePre', {
    group = 'MiniNvimUser',
    pattern = '*',
    callback = function()
      require('mini.trailspace').trim()
    end,
  })
  vim.api.nvim_create_autocmd('FileType', {
    group = 'MiniNvimUser',
    pattern = 'NvimTree,neo-tree,fzf',
    callback = function()
      vim.b.miniindentscope_disable = true
      vim.b.minicursorword_disable = true
      vim.b.minitrailspace_disable = true
    end,
  })
  vim.api.nvim_create_autocmd('FileType', {
    group = 'MiniNvimUser',
    pattern = 'gitcommit',
    callback = function()
      vim.b.minitrailspace_disable = true
    end,
  })
end }
