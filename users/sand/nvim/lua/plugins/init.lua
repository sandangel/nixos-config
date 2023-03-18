return {
  { 'numToStr/Comment.nvim', event = 'VimEnter', config = function()
    require('Comment').setup()
  end },
  { 'knubie/vim-kitty-navigator', keys = { '<c-h>', '<c-j>', '<c-k>', '<c-l>' }, build = 'cp ./*.py ~/.config/kitty/' },
  { 'iamcco/markdown-preview.nvim', build = 'cd app && pnpm install', ft = { 'markdown' }, init = function()
    vim.g.mkdp_filetypes = { 'markdown' }
  end },
  { 'tyru/open-browser.vim', keys = { '<leader>u' }, config = function()
    local opts = { silent = true, remap = true }
    vim.keymap.set('n', '<leader>u', '<Plug>(openbrowser-smart-search)', opts)
    vim.keymap.set('x', '<leader>u', '<Plug>(openbrowser-smart-search)', opts)
  end },
  { 'rust-lang/rust.vim', ft = 'rust', init = function()
    vim.g.rustfmt_autosave = 1
  end },
  { 'mhinz/vim-sayonara', cmd = 'Sayonara', init = function()
    vim.keymap.set('n', '<leader>q', '<cmd>Sayonara<cr>', { silent = true })
  end },
  { 'kylechui/nvim-surround', event = 'VimEnter', config = function()
    require('nvim-surround').setup()
  end },
  { 'ggandor/leap.nvim', event = 'VimEnter', config = function()
    require('leap').add_default_mappings()
  end },
  { 'ggandor/flit.nvim', event = 'VimEnter', dependencies = { 'ggandor/leap.nvim' }, config = function()
    require('flit').setup()
  end },
  { 'hashivim/vim-terraform', ft = 'terraform', init = function()
    vim.g.terraform_align = 1
    vim.g.terraform_fold_section = 1
    vim.g.terraform_fmt_on_save = 1
  end },
  { 'mbbill/undotree', cmd = 'UndotreeToggle', init = function()
    vim.g.undotree_WindowLayout = 4
    vim.g.undotree_SplitWidth = 60
    vim.keymap.set('n', '<F2>', '<cmd>UndotreeToggle<cr>', { silent = true })
  end },
  { 'AckslD/nvim-neoclip.lua', dependencies = { 'kkharji/sqlite.lua', 'ibhagwan/fzf-lua' }, config = function()
    require('neoclip').setup {
      enable_persistent_history = true,
      history = 10000,
      continuous_sync = true,
    }
    vim.keymap.set({ 'n', 'x' }, 'gy', '<cmd>lua require("neoclip.fzf")()<cr>')
  end },
  { 'mbbill/undotree', cmd = 'UndotreeToggle', init = function()
    vim.g.undotree_WindowLayout = 4
    vim.g.undotree_SplitWidth = 60
    vim.keymap.set('n', '<F2>', '<cmd>UndotreeToggle<cr>', { silent = true })
  end },
  { 'whiteinge/diffconflicts',    cmd = 'DiffConflicts' },
  'matze/vim-move',
  'machakann/vim-textobj-delimited',
  'tpope/vim-rsi',
  'tpope/vim-repeat',
  'tpope/vim-abolish',
  'markonm/traces.vim',
  'romainl/vim-cool',
  'fladson/vim-kitty',
}
