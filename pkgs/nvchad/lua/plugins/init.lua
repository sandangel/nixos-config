---@type NvPluginSpec[]
local plugins = {
  {
    'neovim/nvim-lspconfig',
    dependencies = { {
      'folke/lazydev.nvim',
      ft = 'lua',
      opts = {
        library = {
          vim.fn.stdpath 'data' .. '/lazy/ui/nvchad_types',
          vim.fn.stdpath 'data' .. '/lazy/lazy.nvim/lua/lazy',
        },
      },
    }, 'b0o/schemastore.nvim', { 'nvimtools/none-ls.nvim', dependencies = { 'nvimtools/none-ls-extras.nvim', }, }, },
    event = 'VeryLazy',
    config = function()
      require 'configs.lspconfig'
    end,
  },
  {
    'rcarriga/nvim-dap-ui',
    opts = { floating = { border = 'rounded', }, },
    event = 'VeryLazy',
    config = function(_, opts)
      local dap, dapui = require 'dap', require 'dapui'
      dap.listeners.before.attach.dapui_config = function() dapui.open() end
      dap.listeners.before.launch.dapui_config = function() dapui.open() end
      dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
      dap.listeners.before.event_exited.dapui_config = function() dapui.close() end
      dapui.setup(opts)
    end,
    dependencies = {
      { 'nvim-neotest/nvim-nio', },
      {
        'mfussenegger/nvim-dap',
        config = function()
          local map = vim.keymap.set
          map('n', '<leader>ht', function() require 'dap'.toggle_breakpoint() end, { desc = 'Dap toggle breakpoint', })
          map('n', '<leader>hc', function() require 'dap'.continue() end, { desc = 'Dap continue', })
          map('n', '<leader>ho', function() require 'dap'.step_over() end, { desc = 'Dap step over', })
          map('n', '<leader>hi', function() require 'dap'.step_into() end, { desc = 'Dap step into', })
          map('n', '<leader>hr', function() require 'dap'.repl.open() end, { desc = 'Dap repl open', })
        end,
      },
      {
        'mfussenegger/nvim-dap-python',
        config = function()
          require 'dap-python'.test_runner = 'pytest'
          require 'dap-python'.setup()
        end,
        dependencies = { 'mfussenegger/nvim-dap', },
      },
      {
        'rcarriga/cmp-dap',
        dependencies = { 'hrsh7th/nvim-cmp', },
        config = function(_, _)
          require 'cmp'.setup.filetype({ 'dap-repl', 'dapui_watches', 'dapui_hover', }, {
            sources = {
              { name = 'dap', },
            },
          })
        end,
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
    end,
  },
  {
    'wallpants/github-preview.nvim',
    cmd = { 'GithubPreviewToggle', },
    config = true,
  },
  {
    "GeorgesAlkhouri/nvim-aider",
    cmd = {
      "AiderTerminalToggle",
      "AiderTerminalSend",
      "AiderQuickSendCommand",
      "AiderQuickSendBuffer",
      "AiderTreeAddFile",
      "AiderTreeDropFiles",
    },
    keys = {
      { "<leader>a/", "<cmd>AiderTerminalToggle<cr>",   desc = "Aider Open" },
      { "<leader>as", "<cmd>AiderTerminalSend<cr>",     desc = "Aider Send",                  mode = { "n", "x" } },
      { "<leader>ac", "<cmd>AiderQuickSendCommand<cr>", desc = "Aider Send Command" },
      { "<leader>ab", "<cmd>AiderQuickSendBuffer<cr>",  desc = "Aider Send Buffer" },
      { "=",          "<cmd>AiderTreeAddFile<cr>",      desc = "Aider Add File in NvimTree",  ft = "NvimTree" },
      { "-",          "<cmd>AiderTreeDropFile<cr>",     desc = "Aider Drop File in NvimTree", ft = "NvimTree" },
    },
    dependencies = {
      {
        "folke/snacks.nvim",
        ---@type snacks.Config
        opts = {
          ---@type table<string, snacks.win.Config>
          styles = {
            terminal = {
              bo = {
                filetype = "snacks_terminal",
              },
              wo = {},
              keys = {
                -- Override default keymap
                term_normal = false,
              },
            }
          },
        },
      },
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("nvim_aider").setup({
        -- Command line arguments passed to aider
        aider_cmd = "AWS_PROFILE=wovey-dev-admin aider",
        args = {
          "--no-auto-commits",
          "--pretty",
          "--stream",
          "--watch-files",
        },
        win = {
          style = "nvim_aider",
          position = "left",
        },
      })
    end,
  },
  -- {
  --   "olimorris/codecompanion.nvim",
  --   event = 'VeryLazy',
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "nvim-treesitter/nvim-treesitter",
  --     { "MeanderingProgrammer/render-markdown.nvim", ft = { "markdown", "codecompanion" } },
  --   },
  --   config = true,
  -- },
  -- {
  --   'zbirenbaum/copilot.lua',
  --   event = 'VeryLazy',
  --   dependencies = { { 'zbirenbaum/copilot-cmp', config = true, }, 'hrsh7th/nvim-cmp', },
  --   config = function()
  --     require 'copilot'.setup {
  --       panel = {
  --         enabled = false,
  --       },
  --       suggestion = {
  --         enabled = false,
  --       },
  --       filetypes = {
  --         yaml = true,
  --         markdown = true,
  --         gitcommit = true,
  --       },
  --     }
  --   end,
  -- },
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
    dependencies = { 'kkharji/sqlite.lua', 'ibhagwan/fzf-lua', },
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
      { '<C-Down>',      '<cmd>MultipleCursorsAddDown<CR>',        mode = { 'n', 'i', }, desc = 'Cursors Add cursor one line down', },
      { '<C-Up>',        '<cmd>MultipleCursorsAddUp<CR>',          mode = { 'n', 'i', }, desc = 'Cursors Add cursor one line up', },
      { '<C-LeftMouse>', '<cmd>MultipleCursorsMouseAddDelete<CR>', mode = { 'n', 'i', }, desc = 'Cursors Add or delete cursor at mouse position', },
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
    'folke/noice.nvim', -- codespell:ignore noice
    dependencies = { 'MunifTanjim/nui.nvim', 'rcarriga/nvim-notify', },
    lazy = false,
    ---@type NoiceConfig
    opts = {
      lsp = {
        progress = { enabled = false, },
        signature = { enabled = false, silent = true, },
        hover = { enabled = false, silent = true, },
      },
      presets = {
        command_palette = true, -- position the cmdline and popupmenu together
      },
    },
    config = function(_, opts)
      dofile(vim.g.base46_cache .. 'notify')
      require 'noice'.setup(opts)
    end,
  },
  {
    'windwp/nvim-autopairs',
    config = function(_, opts)
      require 'nvim-autopairs'.setup(opts)
      require 'configs.autopairs'
    end,
  },
  {
    'hrsh7th/nvim-cmp',
    dependencies = { 'lukas-reineke/cmp-rg', },
    opts = require 'configs.cmp',
  },
  -- {
  --   'garyhurtz/cmp_kitty',
  --   dependencies = { 'hrsh7th/nvim-cmp', },
  --   init = function()
  --     require 'cmp_kitty':setup()
  --   end,
  -- },
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
      require 'nvim-treesitter.install'.compilers = { 'gcc', }
      require 'nvim-treesitter.configs'.setup(opts)
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
  { 'towolf/vim-helm', ft = 'helm', },
  { 'mhinz/vim-sayonara', cmd = 'Sayonara', },
  { 'nvim-tree/nvim-tree.lua', opts = require 'configs.nvim-tree', },
  { 'catgoose/nvim-colorizer.lua', event = 'VeryLazy', opts = { user_default_options = { tailwind = true, css = true, names = false, mode = 'virtualtext', virtualtext = '■■■', }, }, },
  { 'williamboman/mason.nvim', enabled = false, },
  { 'lukas-reineke/indent-blankline.nvim', enabled = false, },
  { 'whiteinge/diffconflicts', cmd = 'DiffConflicts', },
  { 'machakann/vim-textobj-delimited', event = 'VeryLazy', },
  { 'tpope/vim-rsi', event = 'VeryLazy', },
  { 'tpope/vim-repeat', event = 'VeryLazy', },
  { 'markonm/traces.vim', event = 'VeryLazy', },
  { 'romainl/vim-cool', event = 'VeryLazy', },
}

return plugins
