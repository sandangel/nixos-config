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
    }, 'b0o/schemastore.nvim', },
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
          map('n', '<leader>ht', function() require 'dap'.toggle_breakpoint() end, { desc = 'Dap Toggle breakpoint', })
          map('n', '<leader>hT', function() require 'dap'.set_breakpoint(vim.fn.input 'Condition: ') end,
            { desc = 'Dap Breakpoint condition', })
          map('n', '<leader>hc', function() require 'dap'.continue() end, { desc = 'Dap Continue', })
          map('n', '<leader>ho', function() require 'dap'.step_over() end, { desc = 'Dap Step over', })
          map('n', '<leader>hi', function() require 'dap'.step_into() end, { desc = 'Dap Step into', })
          map('n', '<leader>hO', function() require 'dap'.step_out() end, { desc = 'Dap Step out', })
          map('n', '<leader>hr', function() require 'dap'.repl.toggle() end, { desc = 'Dap Toggle REPL', })
          map('n', '<leader>hl', function() require 'dap'.run_last() end, { desc = 'Dap Run last', })
          map('n', '<leader>hx', function() require 'dap'.terminate() end, { desc = 'Dap Terminate', })
          map('n', '<leader>hu', function() require 'dapui'.toggle() end, { desc = 'Dap UI toggle', })
          map({ 'n', 'x' }, '<leader>he', function() require 'dapui'.eval() end, { desc = 'Dap Eval', })
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
    'stevearc/conform.nvim',
    ---@type conform.setupOpts
    opts = {
      formatters_by_ft = {
        python = { "ruff_format", "ruff_fix", "ruff_organize_imports", lsp_format = "fallback" },
        typescriptreact = { "prettier", lsp_format = "fallback" },
        ["*"] = { "trim_whitespace" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_format = "prefer",
      },
      default_format_opts = {
        lsp_format = "prefer",
      }
    },
  },
  {
    'zbirenbaum/copilot.lua',
    event = 'VeryLazy',
    config = function()
      require 'copilot'.setup {
        panel = { enabled = false, },
        suggestion = { enabled = false, },
        filetypes = {
          yaml = true,
          markdown = true,
          gitcommit = true,
        },
      }
    end,
  },
  {
    'saghen/blink.cmp',
    build = function() require('blink.cmp').build():wait(60000) end,
    dependencies = {
      'saghen/blink.lib',
      'fang2hou/blink-copilot',
    },
    event = 'InsertEnter',
    opts = {
      keymap = {
        preset = 'enter',
        ['<Tab>'] = { 'select_and_accept', 'snippet_forward', 'fallback' },
        ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
        ['<C-p>'] = {},
        ['<C-n>'] = {},
        ['<C-c>'] = { 'show', 'fallback' },
        ['<C-e>'] = { 'cancel', 'fallback' },
        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer', 'copilot' },
        providers = {
          copilot = {
            name = 'copilot',
            module = 'blink-copilot',
            score_offset = 100,
            async = true,
          },
        },
      },
      completion = {
        accept = { auto_brackets = { enabled = true } },
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
      },
    },
  },
  {
    'rust-lang/rust.vim',
    ft = 'rust',
    init = function()
      vim.g.rustfmt_autosave = 1
    end,
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
    event = 'VeryLazy',
    ---@type NoiceConfig
    opts = {
      lsp = {
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
        },
        progress = { enabled = false, },
        signature = { enabled = false, silent = true, },
        hover = { enabled = false, silent = true, },
      },
      routes = {
        {
          filter = {
            event = 'msg_show',
            any = {
              { find = '%d+L, %d+B', },
              { find = '; after #%d+', },
              { find = '; before #%d+', },
            },
          },
          view = 'mini',
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
      },
    },
    config = function(_, opts)
      dofile(vim.g.base46_cache .. 'notify')
      if vim.o.filetype == 'lazy' then
        vim.cmd 'messages clear'
      end
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
    'MagicDuck/grug-far.nvim',
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
