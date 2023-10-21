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
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    build = 'cd app && npx --yes yarn install',
    init = function()
      vim.g.mkdp_filetypes = { 'markdown' }
    end,
    ft = { 'markdown' },
  },
  {
    'rust-lang/rust.vim',
    ft = 'rust',
    init = function()
      vim.g.rustfmt_autosave = 1
    end,
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
    'rcarriga/nvim-notify',
    opts = {
      background_colour = '#61afef',
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
    dependencies = { 'MunifTanjim/nui.nvim', 'rcarriga/nvim-notify', 'NvChad/ui' },
    event = 'VeryLazy',
    ---@type NoiceConfig
    opts = {
      lsp = {
        progress = { enabled = false },
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true,
        },
        signature = { enabled = false },
      },
      presets = {
        command_palette = true, -- position the cmdline and popupmenu together
        lsp_doc_border = true,  -- add a border to hover docs and signature help
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
  { 'lukas-reineke/indent-blankline.nvim', enabled = false, },
  { 'whiteinge/diffconflicts',             cmd = 'DiffConflicts', },
  { 'machakann/vim-textobj-delimited',     event = 'VeryLazy', },
  { 'tpope/vim-rsi',                       event = 'VeryLazy', },
  { 'tpope/vim-repeat',                    event = 'VeryLazy', },
  { 'markonm/traces.vim',                  event = 'VeryLazy', },
  { 'romainl/vim-cool',                    event = 'VeryLazy', },
}

return plugins
