---@type NvPluginSpec[]
local plugins = {
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'folke/neodev.nvim', 'b0o/schemastore.nvim', },
    event = 'VeryLazy',
    config = function()
      require('configs.lspconfig')
    end,
  },
  {
    'stevearc/conform.nvim',
    event = 'VeryLazy',
    opts = {
      formatters = {
        ruff_format = {
          command = 'rye',
          args = {
            'fmt',
            '--',
            '--force-exclude',
            '--stdin-filename',
            '$FILENAME',
            '-',

          },
        },
        ruff_fix = {
          command = 'rye',
          args = {
            'lint',
            '--fix',
            '--',
            '--force-exclude',
            '--exit-zero',
            '--no-cache',
            '--stdin-filename',
            '$FILENAME',
            '-',
          },
        },
      },
      formatters_by_ft = {
        yaml = { 'prettierd' },
        markdown = { 'prettierd' },
        json = { 'prettierd' },
        html = { 'prettierd' },
        css = { 'prettierd' },
        javascript = { 'prettierd' },
        javascriptreact = { 'prettierd' },
        typescript = { 'prettierd' },
        typescriptreact = { 'prettierd' },
        terraform = { 'terraform_fmt' },
        python = { 'ruff_format', 'ruff_fix' },
        nix = { 'nixfmt' },
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
      require 'configs.mini'
    end
  },
  {
    'wallpants/github-preview.nvim',
    cmd = { 'GithubPreviewToggle' },
    config = true,
  },
  {
    'Exafunction/codeium.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'hrsh7th/nvim-cmp',
    },
    event = 'VeryLazy',
    config = true,
  },
  {
    'zbirenbaum/copilot.lua',
    event = 'VeryLazy',
    dependencies = { { 'zbirenbaum/copilot-cmp', config = true }, 'hrsh7th/nvim-cmp' },
    config = function()
      require('copilot').setup({
        panel = {
          enabled = false,
        },
        suggestion = {
          enabled = false,
        },
        filetypes = {
          yaml = true,
          markdown = true,
          gitcommit = true,
        },
        copilot_node_command = 'bun',
      })
    end
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
      { '<C-Down>',      '<cmd>MultipleCursorsAddDown<CR>',        mode = { 'n', 'i' }, desc = 'cursors add cursor one line down' },
      { '<C-Up>',        '<cmd>MultipleCursorsAddUp<CR>',          mode = { 'n', 'i' }, desc = 'cursors add cursor one line up' },
      { '<C-LeftMouse>', '<cmd>MultipleCursorsMouseAddDelete<CR>', mode = { 'n', 'i' }, desc = 'cursors add or delete cursor at mouse position' },
    },
  },
  {
    'rcarriga/nvim-notify',
    opts = {
      background_colour = '#1e222a',
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
      require 'configs.autopairs'
    end,
  },
  {
    'hrsh7th/nvim-cmp',
    dependencies = { 'lukas-reineke/cmp-rg' },
    opts = require 'configs.cmp',
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
      require 'configs.fzf'
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    opts = {
      ensure_installed = 'all',
    },
    config = function(_, opts)
      dofile(vim.g.base46_cache .. 'syntax')
      dofile(vim.g.base46_cache .. 'treesitter')
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
  { 'nvim-tree/nvim-tree.lua',             opts = require('configs.nvim-tree'), },
  { 'NvChad/nvim-colorizer.lua',           opts = { css = true, css_fn = true, mode = 'virtualtext', }, },
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
