local overrides = require('custom.configs.overrides')

---@type NvPluginSpec[]
local plugins = {
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'folke/neodev.nvim', 'b0o/schemastore.nvim', },
    config = function()
      require 'plugins.configs.lspconfig'
      require 'custom.configs.lspconfig'
    end,
  },
  {
    'stevearc/conform.nvim',
    event = 'VeryLazy',
    opts = {
      formatters_by_ft = {
        yaml = { 'yamlfmt' },
        javascript = { 'prettierd' },
        typescript = { 'prettierd' },
        terraform = { 'terraform_fmt' },
        go = { 'goimports' },
      },
      format_on_save = {
        lsp_fallback = true,
      },
    },
  },
  {
    'mbbill/undotree',
    cmd = 'UndotreeToggle',
    init = function()
      vim.g.undotree_WindowLayout = 4
      vim.g.undotree_SplitWidth = 60
    end,
  },
  {
    'echasnovski/mini.nvim',
    event = 'VeryLazy',
    config = function()
      require 'custom.configs.mini'
    end
  },
  {
    'wallpants/github-preview.nvim',
    cmd = { 'GithubPreviewToggle' },
    config = true,
  },
  {
    'nomnivore/ollama.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    cmd = { 'Ollama' },
    keys = {
      {
        '<leader>a',
        '<cmd>lua require("ollama").prompt("Raw")<CR>',
        desc = 'Ollama prompt',
        mode = { 'n', 'x' },
      },
    },
    ---@type Ollama.Config
    opts = {
      url = 'http://172.16.129.1:11434',
      model = 'codellama:70b-instruct',
    }
  },
  {
    'rust-lang/rust.vim',
    ft = 'rust',
    init = function()
      vim.g.rustfmt_autosave = 1
    end,
  },
  {
    'mrjones2014/smart-splits.nvim',
    event = 'VeryLazy',
    build = './kitty/install-kittens.bash',
  },
  {
    'AckslD/nvim-neoclip.lua',
    dependencies = { 'kkharji/sqlite.lua', 'ibhagwan/fzf-lua' },
    event = 'VeryLazy',
    opts = {
      history = 10000,
      enable_persistent_history = true,
      continuous_sync = true,
    },
  },
  {
    'brenton-leighton/multiple-cursors.nvim',
    config = true,
    keys = {
      { '<C-Down>',      '<cmd>MultipleCursorsAddDown<CR>',        mode = { 'n', 'i' }, desc = 'Add cursor one line down' },
      { '<C-Up>',        '<cmd>MultipleCursorsAddUp<CR>',          mode = { 'n', 'i' }, desc = 'Add cursor one line up' },
      { '<C-LeftMouse>', '<cmd>MultipleCursorsMouseAddDelete<CR>', mode = { 'n', 'i' }, desc = 'Add or delete cursor at mouse position' },
    },
  },
  {
    'rcarriga/nvim-notify',
    opts = {
      timeout = 2000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
    },
  },
  {
    'folke/noice.nvim',
    dependencies = { 'MunifTanjim/nui.nvim', 'rcarriga/nvim-notify' },
    lazy = false,
    ---@type NoiceConfig
    opts = {
      lsp = {
        progress = { enabled = false },
        signature = { enabled = false, silent = true, },
        hover = { enabled = false, silent = true, },
      },
      presets = {
        command_palette = true, -- position the cmdline and popupmenu together
      },
    },
    config = function(_, opts)
      dofile(vim.g.base46_cache .. 'notify')
      require('noice').setup(opts)
    end,
  },
  {
    'windwp/nvim-autopairs',
    config = function(_, opts)
      require('nvim-autopairs').setup(opts)
      require 'custom.configs.autopairs'
    end,
  },
  {
    'hrsh7th/nvim-cmp',
    dependencies = { 'lukas-reineke/cmp-rg' },
    opts = require 'custom.configs.cmp',
  },
  {
    'garyhurtz/cmp_kitty',
    dependencies = { 'hrsh7th/nvim-cmp' },
    init = function()
      require('cmp_kitty'):setup()
    end
  },
  {
    'ibhagwan/fzf-lua',
    config = function()
      require 'custom.configs.fzf'
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    opts = overrides.treesitter,
    config = function(_, opts)
      dofile(vim.g.base46_cache .. 'syntax')
      -- Default clang compiler will generate errors.
      require('nvim-treesitter.install').compilers = { 'gcc' }
      require('nvim-treesitter.configs').setup(opts)
    end,
  },
  {
    'nvim-pack/nvim-spectre',
    event = 'VeryLazy',
    config = true,
  },
  {
    'tpope/vim-abolish',
    event = 'VeryLazy',
    init = function()
      vim.g.abolish_no_mappings = 1
    end,
  },
  {
    'fladson/vim-kitty',
    ft = 'kitty',
    event = 'VeryLazy',
  },
  { 'towolf/vim-helm',                     ft = 'helm', },
  { 'mhinz/vim-sayonara',                  cmd = 'Sayonara', },
  { 'williamboman/mason.nvim',             opts = overrides.mason, },
  { 'nvim-tree/nvim-tree.lua',             opts = overrides.nvimtree, },
  { 'NvChad/nvterm',                       enabled = false, },
  { 'williamboman/mason.nvim',             enabled = false, },
  { 'lukas-reineke/indent-blankline.nvim', enabled = false, },
  { 'whiteinge/diffconflicts',             cmd = 'DiffConflicts', },
  { 'machakann/vim-textobj-delimited',     event = 'VeryLazy', },
  { 'tpope/vim-rsi',                       event = 'VeryLazy', },
  { 'tpope/vim-repeat',                    event = 'VeryLazy', },
  { 'markonm/traces.vim',                  event = 'VeryLazy', },
  { 'romainl/vim-cool',                    event = 'VeryLazy', },
}

return plugins
