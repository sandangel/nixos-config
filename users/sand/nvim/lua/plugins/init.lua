return {
  {
    'numToStr/Comment.nvim',
    event = 'BufEnter',
    config = true,
  },
  { 'mrjones2014/smart-splits.nvim',
    keys = { '<c-h>', '<c-j>', '<c-k>', '<c-l>' },
    build = './kitty/install-kittens.bash',
    config = function()
      require('smart-splits').setup()
      -- moving between splits
      vim.keymap.set('n', '<C-h>', require('smart-splits').move_cursor_left)
      vim.keymap.set('n', '<C-j>', require('smart-splits').move_cursor_down)
      vim.keymap.set('n', '<C-k>', require('smart-splits').move_cursor_up)
      vim.keymap.set('n', '<C-l>', require('smart-splits').move_cursor_right)
    end
  },
  {
    'iamcco/markdown-preview.nvim',
    build = 'cd app && pnpm install',
    ft = { 'markdown' },
    init = function()
      vim.g.mkdp_filetypes = { 'markdown' }
    end
  },
  {
    'chrishrb/gx.nvim',
    event = { 'BufEnter' },
    config = true,
  },
  {
    'rust-lang/rust.vim',
    ft = 'rust',
    init = function()
      vim.g.rustfmt_autosave = 1
    end
  },
  {
    'mhinz/vim-sayonara',
    cmd = 'Sayonara',
    init = function()
      vim.keymap.set('n', '<leader>q', '<cmd>Sayonara<cr>', { silent = true })
    end
  },
  {
    'kylechui/nvim-surround',
    event = 'VimEnter',
    config = true,
  },
  {
    'ggandor/leap.nvim',
    event = 'BufEnter',
    config = true,
  },
  {
    'ggandor/flit.nvim',
    event = 'BufEnter',
    dependencies = { 'ggandor/leap.nvim' },
    config = true,
  },
  {
    'hashivim/vim-terraform',
    ft = 'terraform',
    init = function()
      vim.g.terraform_align = 1
      vim.g.terraform_fold_section = 1
      vim.g.terraform_fmt_on_save = 1
    end
  },
  {
    'mbbill/undotree',
    cmd = 'UndotreeToggle',
    init = function()
      vim.g.undotree_WindowLayout = 4
      vim.g.undotree_SplitWidth = 60
      vim.keymap.set('n', '<F2>', '<cmd>UndotreeToggle<cr>', { silent = true })
    end
  },
  {
    'AckslD/nvim-neoclip.lua',
    dependencies = { 'ibhagwan/fzf-lua' },
    config = function()
      require('neoclip').setup {
        enable_persistent_history = true,
        history = 10000,
        continuous_sync = true,
      }
      vim.keymap.set({ 'n', 'x' }, 'gy', '<cmd>lua require("neoclip.fzf")()<cr>')
    end
  },
  {
    'mbbill/undotree',
    cmd = 'UndotreeToggle',
    init = function()
      vim.g.undotree_WindowLayout = 4
      vim.g.undotree_SplitWidth = 60
      vim.keymap.set('n', '<F2>', '<cmd>UndotreeToggle<cr>', { silent = true })
    end
  },
  { 'whiteinge/diffconflicts', cmd = 'DiffConflicts' },
  'matze/vim-move',
  'machakann/vim-textobj-delimited',
  'tpope/vim-rsi',
  'tpope/vim-repeat',
  'tpope/vim-abolish',
  'markonm/traces.vim',
  'romainl/vim-cool',
  'fladson/vim-kitty',
}
