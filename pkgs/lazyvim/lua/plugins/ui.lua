return {
  -- ─── snacks: notifier + disable statuscolumn ──────────────────────────────
  {
    'folke/snacks.nvim',
    opts = {
      statuscolumn = { enabled = false },
    },
    -- Wipe all default snacks keys (<leader>n, <leader>un, <leader>., <leader>S,
    -- <leader>dps, terminal <C-h/j/k/l>, <c-/>, <c-_>, <leader>wm, <leader>uZ,
    -- <leader>uz, <leader>dpp, <leader>dph); user owns all these in keymaps.lua
    keys = function()
      return {
        { '<leader>nd', function() Snacks.notifier.hide() end, desc = 'Dismiss all notifications' },
      }
    end,
  },

  -- ─── Noice: wipe all default keymaps ─────────────────────────────────────
  {
    'folke/noice.nvim',
    keys = function() return {} end,
  },

  -- ─── Persistence: wipe all default keymaps ───────────────────────────────
  {
    'folke/persistence.nvim',
    enabled = false,
    keys = function() return {} end,
  },

  -- ─── Colorizer ────────────────────────────────────────────────────────────
  {
    'catgoose/nvim-colorizer.lua',
    event = 'VeryLazy',
    opts = {
      user_default_options = {
        tailwind    = true,
        css         = true,
        names       = false,
        mode        = 'virtualtext',
        virtualtext = '■■■',
      },
    },
  },

  -- ─── Bufferline: show only modified buffers ───────────────────────────────
  {
    'akinsho/bufferline.nvim',
    keys = function() return {} end,
    opts = {
      options = {
        custom_filter = function(bufnr)
          return vim.bo[bufnr].modified
        end,
        offsets = {
          {
            filetype   = 'NvimTree',
            text       = '   Explorer   ',
            highlight  = 'Directory',
            text_align = 'left',
          },
        },
      },
    },
  },

  -- ─── Colorscheme: base46 onedark ─────────────────────────────────────────
  {
    'AvengeMedia/base46',
    url = 'https://github.com/AvengeMedia/base46.git',
    lazy = false,
    priority = 1000,
    opts = {},
    config = function(_, opts)
      require('base46').setup(opts)
      vim.cmd.colorscheme('base46-onedark')
    end,
  },
  {
    'LazyVim/LazyVim',
    opts = { colorscheme = 'base46-onedark' },
  },
}
