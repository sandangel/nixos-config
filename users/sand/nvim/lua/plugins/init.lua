local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.system {
    'git',
    'clone',
    '--depth',
    '1',
    'https://github.com/wbthomason/packer.nvim',
    install_path,
  }
end

require('packer').startup(function(use)
  use { 'wbthomason/packer.nvim', config = function()
    vim.api.nvim_create_augroup('PackerNvimUser', { clear = true })
    vim.api.nvim_create_autocmd('BufWritePost', {
      group = 'PackerNvimUser',
      pattern = '*.lua',
      callback = function()
        vim.api.nvim_command('luafile ' .. vim.env.MYVIMRC)
        vim.api.nvim_command 'PackerCompile'
      end,
    })
  end }

  use { 'navarasu/onedark.nvim', config = function()
    require('onedark').setup {
      style = 'dark',
      code_style = {
        comments = 'italic',
        keywords = 'italic',
        functions = 'italic',
        strings = 'none',
        variables = 'italic',
      },
    }
    require('onedark').load()
  end }

  use { 'kyazdani42/nvim-web-devicons', config = [[ require 'plugins.configs.icons' ]] }

  use { 'rust-lang/rust.vim', ft = 'rust', setup = function()
    vim.g.rustfmt_autosave = 1
  end }

  use { 'hashivim/vim-terraform', ft = 'terraform', setup = function()
    vim.g.terraform_align = 1
    vim.g.terraform_fold_section = 1
    vim.g.terraform_fmt_on_save = 1
  end }

  use { 'nvim-treesitter/nvim-treesitter', event = 'BufRead', run = ':TSUpdate',
    config = [[ require 'plugins.configs.nvim-treesitter' ]],
  }

  use { 'norcalli/nvim-colorizer.lua', event = 'BufRead', config = [[ require('plugins.configs.others').colorizer() ]] }

  use 'markonm/traces.vim'
  use { 'romainl/vim-cool', setup = function()
    vim.g.CoolTotalMatches = 1
  end }

  use { 'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' },
    config = [[ require 'plugins.configs.gitsigns' ]],
  }

  use { 'akinsho/toggleterm.nvim', keys = { 'n', '<leader>cl' }, config = function()
    local Terminal = require('toggleterm.terminal').Terminal
    local lazygit = Terminal:new {
      cmd = 'lazygit',
      direction = 'float',
      close_on_exit = true,
      float_opts = {
        border = 'single',
      },
      hidden = true,
      on_open = function()
        vim.cmd 'startinsert!'
      end,
    }
    vim.keymap.set('n', '<leader>cl', function()
      lazygit:toggle()
    end, { silent = true })
  end }

  use { 'whiteinge/diffconflicts' }

  use {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'main',
    requires = {
      'nvim-lua/plenary.nvim',
      'kyazdani42/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    config = [[ require 'plugins.configs.neo-tree' ]],
  }

  use { 'feline-nvim/feline.nvim', requires = { 'kyazdani42/nvim-web-devicons' },
    config = [[ require 'plugins.configs.statusline' ]],
  }

  use { 'romgrk/barbar.nvim', requires = { 'kyazdani42/nvim-web-devicons' },
    config = [[ require 'plugins.configs.barbar' ]],
  }

  use { 'mbbill/undotree', cmd = 'UndotreeToggle', setup = function()
    vim.g.undotree_WindowLayout = 4
    vim.g.undotree_SplitWidth = 60
    vim.keymap.set('n', '<F2>', '<cmd>UndotreeToggle<cr>', { silent = true })
  end }

  use { 'tyru/open-browser.vim', keys = '<leader>u', config = function()
    local opts = { silent = true, remap = true }
    vim.keymap.set('n', '<leader>u', '<Plug>(openbrowser-smart-search)', opts)
    vim.keymap.set('x', '<leader>u', '<Plug>(openbrowser-smart-search)', opts)
  end }

  use { 'mhinz/vim-sayonara', cmd = 'Sayonara', setup = function()
    vim.keymap.set('n', '<leader>q', '<cmd>Sayonara<cr>', { silent = true })
  end }

  use { 'windwp/nvim-autopairs', config = [[ require 'plugins.configs.nvim-autopairs' ]] }

  use { 'junegunn/vim-easy-align', config = function()
    local opts = { silent = true, remap = true }
    vim.keymap.set('x', 'ga', '<Plug>(EasyAlign)', opts)
    vim.keymap.set('n', 'ga', '<Plug>(EasyAlign)', opts)
  end }

  use { 'psliwka/vim-smoothie', event = 'VimEnter', setup = function()
    vim.g.smoothie_no_default_mappings = true
    vim.g.smoothie_update_interval = 10
    vim.g.smoothie_speed_linear_factor = 25
    vim.g.smoothie_speed_constant_factor = 25
    vim.g.smoothie_speed_exponentiation_factor = 0.99
    local opts = { silent = true, remap = true }
    vim.keymap.set({ 'x', 'n', 'i' }, '<PageDown>', '<Plug>(SmoothieForwards)', opts)
    vim.keymap.set({ 'x', 'n', 'i' }, '<PageUp>', '<Plug>(SmoothieBackwards)', opts)
  end }

  use { 'ggandor/leap.nvim', config = function()
    require('leap').set_default_keymaps()
  end }

  use { 'knubie/vim-kitty-navigator', run = 'cp ./*.py ~/.config/kitty/' }

  use { 'echasnovski/mini.nvim', config = [[ require 'plugins.configs.mini' ]] }

  use 'wellle/targets.vim'
  use 'matze/vim-move'
  use 'machakann/vim-textobj-delimited'
  use 'tpope/vim-surround'
  use 'tpope/vim-rsi'
  use 'tpope/vim-repeat'
  use 'tpope/vim-abolish'

  use { 'hrsh7th/nvim-cmp',
    requires = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lua',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'dcampos/nvim-snippy',
      'dcampos/cmp-snippy',
    },
    config = [[ require 'plugins.configs.cmp' ]]
  }

  use { 'ibhagwan/fzf-lua', requires = 'kyazdani42/nvim-web-devicons', event = 'VimEnter',
    config = [[ require 'plugins.configs.fzf' ]],
  }
  use { 'glepnir/lspsaga.nvim', branch = 'main', config = [[ require 'plugins.configs.lspsaga' ]] }
  use { 'jose-elias-alvarez/null-ls.nvim', requires = { 'nvim-lua/plenary.nvim' } }
  use { 'neovim/nvim-lspconfig', requires = {
    'glepnir/lspsaga.nvim',
    'ibhagwan/fzf-lua',
    'nvim-lua/plenary.nvim',
    'jose-elias-alvarez/null-ls.nvim',
  }, config = [[ require 'plugins.configs.lspconfig' ]] }

  use { 'iamcco/markdown-preview.nvim', run = 'cd app && npm install', ft = { 'markdown' }, setup = function()
    vim.g.mkdp_filetypes = { 'markdown' }
  end }
end)
