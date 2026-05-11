return {
  -- ─── mini.surround: remap from gs* → s* ──────────────────────────────────
  {
    'nvim-mini/mini.surround',
    opts = { mappings = {
      add            = 'sa',
      delete         = 'sd',
      find           = '',
      find_left      = '',
      highlight      = '',
      replace        = 'sr',
      update_n_lines = '',
    } },
  },

  -- ─── mini.indentscope: also disable in NvimTree ───────────────────────────
  {
    'nvim-mini/mini.indentscope',
    init = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern  = 'NvimTree',
        callback = function() vim.b.miniindentscope_disable = true end,
      })
    end,
  },

  -- ─── mini.cursorword: disable in special buffers ─────────────────────────
  {
    'nvim-mini/mini.cursorword',
    event = 'VeryLazy',
    opts = {},
    init = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern  = 'NvimTree,neo-tree,fzf,grug-far',
        callback = function() vim.b.minicursorword_disable = true end,
      })
    end,
  },

  -- ─── mini.align: ga to align ─────────────────────────────────────────────
  {
    'nvim-mini/mini.align',
    event = 'VeryLazy',
    opts = { mappings = { start = 'ga', start_with_preview = '' } },
  },

  -- ─── mini.misc: zoom keymap ───────────────────────────────────────────────
  {
    'nvim-mini/mini.misc',
    event = 'VeryLazy',
    config = function(_, opts)
      require('mini.misc').setup(opts)
      vim.keymap.set({ 'n', 'x' }, '<leader>z', require('mini.misc').zoom,
        { desc = 'Mini Zoom buffer', noremap = true, silent = true })
    end,
  },

  -- ─── mini.trailspace: trim on save, disable in special buffers ───────────
  {
    'nvim-mini/mini.trailspace',
    event = 'VeryLazy',
    config = function(_, opts)
      require('mini.trailspace').setup(opts)
      local g = vim.api.nvim_create_augroup('MiniTrailspace', { clear = true })
      vim.api.nvim_create_autocmd('BufWritePre', {
        group    = g,
        pattern  = '*',
        callback = function() require('mini.trailspace').trim() end,
      })
      vim.api.nvim_create_autocmd('FileType', {
        group    = g,
        pattern  = 'NvimTree,neo-tree,fzf,grug-far,gitcommit,diff',
        callback = function() vim.b.minitrailspace_disable = true end,
      })
    end,
  },

  -- ─── Disable yanky (replaced by neoclip) ─────────────────────────────────
  { 'gbprod/yanky.nvim', enabled = false },

  -- ─── Neoclip: clipboard/yank history via fzf-lua + sqlite persistence ────
  {
    'AckslD/nvim-neoclip.lua',
    dependencies = { 'kkharji/sqlite.lua' },
    event = 'TextYankPost',
    keys = {
      { 'gy', function() require('neoclip.fzf')() end, mode = { 'n', 'x' }, desc = 'Neoclip Yank history' },
    },
    opts = {
      enable_persistent_history = true,
      continuous_sync = true,
    },
  },

  -- ─── Abolish (case coercion: crs, crc, cru…) ─────────────────────────────
  {
    'tpope/vim-abolish',
    event = 'VeryLazy',
    init = function() vim.g.abolish_no_mappings = 1 end,
  },

  -- ─── Sayonara (smart buffer/window close) ─────────────────────────────────
  {
    'mhinz/vim-sayonara',
    cmd  = 'Sayonara',
    keys = { { '<leader>q', '<cmd>Sayonara<CR>', desc = 'Quit buffer/window' } },
  },

  -- ─── Markdown Preview: wipe <leader>cp default ───────────────────────────
  {
    'iamcco/markdown-preview.nvim',
    keys = function() return {} end,
  },

  -- ─── nvim-dap-python: wipe <leader>dPt / <leader>dPc ────────────────────
  {
    'mfussenegger/nvim-dap-python',
    keys = function() return {} end,
  },

  -- ─── venv-selector: wipe <leader>cv ──────────────────────────────────────
  {
    'linux-cultist/venv-selector.nvim',
    enabled = false,
    keys = function() return {} end,
  },

  -- ─── dadbod-ui: wipe <leader>D ───────────────────────────────────────────
  {
    'kristijanhusak/vim-dadbod-ui',
    keys = function() return {} end,
  },

  -- ─── Filetype syntax ──────────────────────────────────────────────────────
  { 'fladson/vim-kitty',               ft = 'kitty',         event = 'VeryLazy' },
  -- Detect Chart.yaml as the helm package
  { 'towolf/vim-helm',                 event = 'VeryLazy' },

  -- ─── Text objects ─────────────────────────────────────────────────────────
  { 'machakann/vim-textobj-delimited', event = 'VeryLazy' },

  -- ─── Readline keybindings in cmdline/insert ───────────────────────────────
  { 'tpope/vim-rsi',                   event = 'VeryLazy' },

  -- ─── Diff conflicts ───────────────────────────────────────────────────────
  { 'whiteinge/diffconflicts',         cmd = 'DiffConflicts' },


  -- ─── Grug-far: wipe <leader>sr default, own <leader>S ────────────────────
  {
    'MagicDuck/grug-far.nvim',
    keys = function()
      return {
        {
          '<leader>S',
          function()
            local grug = require('grug-far')
            local ext = vim.bo.buftype == '' and vim.fn.expand('%:e')
            grug.open({ transient = true, prefills = { filesFilter = ext and ext ~= '' and '*.' .. ext or nil } })
          end,
          mode = { 'n', 'x' },
          desc = 'Search and Replace',
        },
      }
    end,
  },

  -- ─── DAP: replace all <leader>d* with <leader>h* ─────────────────────────
  -- <leader>d fires grep-word instantly; DAP moved to <leader>h* (rarely used)
  {
    'mfussenegger/nvim-dap',
    keys = {
      -- remove every <leader>d* binding from the extra by shadowing them as false
      { '<leader>dB', false },
      { '<leader>db', false },
      { '<leader>dc', false },
      { '<leader>da', false },
      { '<leader>dC', false },
      { '<leader>dg', false },
      { '<leader>di', false },
      { '<leader>dj', false },
      { '<leader>dk', false },
      { '<leader>dl', false },
      { '<leader>do', false },
      { '<leader>dO', false },
      { '<leader>dP', false },
      { '<leader>dr', false },
      { '<leader>ds', false },
      { '<leader>dt', false },
      { '<leader>dw', false },
      -- primary bindings on <leader>h*
      { '<leader>ht', function() require('dap').toggle_breakpoint() end,                         desc = 'DAP Toggle breakpoint' },
      { '<leader>hT', function() require('dap').set_breakpoint(vim.fn.input('Condition: ')) end, desc = 'DAP Breakpoint condition' },
      { '<leader>hc', function() require('dap').continue() end,                                  desc = 'DAP Continue' },
      { '<leader>ho', function() require('dap').step_over() end,                                 desc = 'DAP Step over' },
      { '<leader>hi', function() require('dap').step_into() end,                                 desc = 'DAP Step into' },
      { '<leader>hO', function() require('dap').step_out() end,                                  desc = 'DAP Step out' },
      { '<leader>hr', function() require('dap').repl.toggle() end,                               desc = 'DAP Toggle REPL' },
      { '<leader>hl', function() require('dap').run_last() end,                                  desc = 'DAP Run last' },
      { '<leader>hx', function() require('dap').terminate() end,                                 desc = 'DAP Terminate' },
    },
  },
  {
    'rcarriga/nvim-dap-ui',
    keys = {
      { '<leader>du', false },
      { '<leader>de', false },
      { '<leader>hu', function() require('dapui').toggle() end, desc = 'DAP UI toggle' },
      { '<leader>he', function() require('dapui').eval() end,   mode = { 'n', 'x' },   desc = 'DAP Eval' },
    },
  },
}
