return {
  -- ─── Nvim-tree ────────────────────────────────────────────────────────────
  {
    'nvim-tree/nvim-tree.lua',
    cmd  = { 'NvimTreeToggle', 'NvimTreeFocus', 'NvimTreeFindFile' },
    keys = { { '<C-p>', '<cmd>NvimTreeFindFileToggle<CR>', desc = 'NvimTree Toggle' } },
    opts = function()
      local icons = LazyVim.config.icons
      return {
        on_attach = function(bufnr)
          local api = require('nvim-tree.api')
          local function o(desc)
            return { desc = 'NvimTree ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
          end
          vim.keymap.set('n', 'h',    api.tree.change_root_to_parent,   o('Up'))
          vim.keymap.set('n', 'l',    api.tree.change_root_to_node,     o('CD'))
          vim.keymap.set('n', 'o',    api.node.open.edit,               o('Open'))
          vim.keymap.set('n', '<CR>', api.node.open.edit,               o('Open'))
          vim.keymap.set('n', 'd',    api.fs.trash,                     o('Trash'))
          vim.keymap.set('n', 'D',    api.fs.remove,                    o('Delete'))
          vim.keymap.set('n', 'I',    api.filter.git.ignored.toggle,    o('Toggle Git Ignore'))
          vim.keymap.set('n', 'H',    api.filter.dotfiles.toggle,       o('Toggle Dotfiles'))
          vim.keymap.set('n', 'R',    api.tree.reload,                  o('Refresh'))
          vim.keymap.set('n', 'a',    api.fs.create,                    o('Create'))
          vim.keymap.set('n', 'r',    api.fs.rename,                    o('Rename'))
          vim.keymap.set('n', 'x',    api.fs.cut,                       o('Cut'))
          vim.keymap.set('n', 'c',    api.fs.copy.node,                 o('Copy'))
          vim.keymap.set('n', 'p',    api.fs.paste,                     o('Paste'))
          vim.keymap.set('n', 'y',    api.fs.copy.relative_path,        o('Copy Relative Path'))
          vim.keymap.set('n', 'Y',    api.fs.copy.absolute_path,        o('Copy Absolute Path'))
          vim.keymap.set('n', 'gy',   api.fs.copy.filename,             o('Copy Filename'))
          vim.keymap.set('n', '[c',   api.node.navigate.git.prev,       o('Prev Git'))
          vim.keymap.set('n', ']c',   api.node.navigate.git.next,       o('Next Git'))
          vim.keymap.set('n', '.',    api.node.run.system,              o('Run System'))
          vim.keymap.set('n', 'f',    api.filter.live.start,            o('Filter'))
          vim.keymap.set('n', 'F',    api.filter.live.clear,            o('Clean Filter'))
          vim.keymap.set('n', 'q',    api.tree.close,                   o('Close'))
          vim.keymap.set('n', '?',    api.tree.toggle_help,             o('Help'))
        end,
        view     = { width = {}, side = 'left' },
        trash    = { cmd = 'trash' },
        renderer = {
          icons = {
            git_placement = 'after',
            glyphs = {
              git = {
                unstaged  = icons.git.modified,
                staged    = icons.git.added,
                untracked = icons.git.added,
                renamed   = icons.git.modified,
                deleted   = icons.git.removed,
                unmerged  = icons.diagnostics.Warn,
                ignored   = "◌",
              },
            },
          },
        },
        diagnostics = {
          icons = {
            hint    = icons.diagnostics.Hint,
            info    = icons.diagnostics.Info,
            warning = icons.diagnostics.Warn,
            error   = icons.diagnostics.Error,
          },
        },
      }
    end,
  },

  -- ─── Gitsigns ────────────────────────────────────────────────────────────
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      on_attach = function(bufnr)
        local gs = require('gitsigns')
        local function map(mode, lhs, rhs, opts)
          vim.keymap.set(mode, lhs, rhs, vim.tbl_extend('force', { buffer = bufnr, silent = true }, opts))
        end
        map('n', '<leader>cp', gs.preview_hunk,              { desc = 'Gitsigns Preview hunk' })
        map('n', '<leader>cr', gs.reset_hunk,                { desc = 'Gitsigns Reset hunk' })
        map('n', '<leader>cu', gs.reset_buffer,              { desc = 'Gitsigns Reset buffer' })
        map('n', '<leader>cb', gs.toggle_current_line_blame, { desc = 'Gitsigns Toggle blame' })
        map('n', ']c', function()
          if vim.wo.diff then return ']c' end
          vim.schedule(function() gs.nav_hunk('next', { preview = true, target = 'all' }) end)
          return '<Ignore>'
        end, { expr = true, desc = 'Gitsigns Next hunk' })
        map('n', '[c', function()
          if vim.wo.diff then return '[c' end
          vim.schedule(function() gs.nav_hunk('prev', { preview = true, target = 'all' }) end)
          return '<Ignore>'
        end, { expr = true, desc = 'Gitsigns Prev hunk' })
      end,
    },
  },

  -- ─── Treesitter: install all stable parsers ──────────────────────────────
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSInstall stable',
  },

  -- ─── Treesitter textobjects: disable all move keymaps (]f/]a/]c/… noise) ──
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    opts = { move = { enable = false } },
  },

  -- ─── Flash: wipe all defaults, remap jump to gs ──────────────────────────
  {
    'folke/flash.nvim',
    keys = function()
      return {
        { 'gs', mode = { 'n', 'x', 'o' }, function() require('flash').jump() end, desc = 'Flash' },
      }
    end,
  },

  -- ─── Which-key: wipe default keymaps ─────────────────────────────────────
  {
    'folke/which-key.nvim',
    keys = function() return {} end,
  },

  -- ─── Trouble: wipe all default keymaps ───────────────────────────────────
  {
    'folke/trouble.nvim',
    keys = function() return {} end,
  },

  -- ─── Todo-comments: wipe ]t/[t and fzf-extra <leader>st/sT ─────────────
  {
    'folke/todo-comments.nvim',
    keys = function() return {} end,
  },

  -- ─── Illuminate: replace config to strip all keymap.set calls ───────────
  -- LazyVim's config sets ]]./[[ globally and via a FileType autocmd, and wires
  -- <leader>ux via Snacks.toggle — none of which can be suppressed via keys=.
  -- Replace the whole config with just the illuminate.configure() call.
  {
    'RRethy/vim-illuminate',
    keys = function() return {} end,
    config = function(_, opts)
      opts.filetypes_denylist = vim.list_extend(opts.filetypes_denylist or {}, { 'NvimTree' })
      require('illuminate').configure(opts)
    end,
  },

  -- ─── Undotree ─────────────────────────────────────────────────────────────
  {
    'mbbill/undotree',
    cmd  = 'UndotreeToggle',
    keys = { { '<F2>', '<cmd>UndotreeToggle<CR>', desc = 'UndoTree Toggle' } },
    init = function()
      vim.g.undotree_WindowLayout = 4
      vim.g.undotree_SplitWidth   = 60
    end,
  },

  -- ─── Fzf-lua: extend LazyVim's fzf-extra opts with user preferences ───────
  {
    'ibhagwan/fzf-lua',
    -- Wipe all fzf-extra default keymaps (<leader>f*, g*, s*, :, ,, <space>…)
    -- Keep only the fzf-terminal pass-throughs needed for <c-j>/<c-k> navigation.
    keys = function()
      return {
        { '<c-j>', '<c-j>', ft = 'fzf', mode = 't', nowait = true },
        { '<c-k>', '<c-k>', ft = 'fzf', mode = 't', nowait = true },
      }
    end,
    opts = function(_, opts)
      local fzf_history_dir = vim.env.HOME .. '/.local/share/nvim/fzf-history'
      if vim.fn.isdirectory(fzf_history_dir) == 0 then
        vim.fn.system { 'mkdir', '-p', fzf_history_dir }
      end

      return vim.tbl_deep_extend('force', opts or {}, {
        keymap = {
          builtin = {
            ['<F1>']       = 'toggle-help',
            ['<F2>']       = 'toggle-fullscreen',
            ['<F3>']       = 'toggle-preview',
            ['<PageDown>'] = 'preview-page-down',
            ['<PageUp>']   = 'preview-page-up',
            ['<Home>']     = 'preview-page-reset',
          },
          fzf = {
            ['tab']    = 'toggle',
            ['ctrl-a'] = 'toggle-all',
            ['ctrl-f'] = 'half-page-down',
            ['ctrl-b'] = 'half-page-up',
          },
        },
        fzf_opts = {
          ['--layout']       = 'default',
          ['--history']      = fzf_history_dir .. '/fzf-lua',
          ['--history-size'] = '10000',
        },
        defaults = { copen = 'FzfLua quickfix' },
        files    = { git_icons = false },
        grep     = { git_icons = false, file_icons = false, color_icons = false },
        oldfiles = {
          cwd_only = true,
          actions  = {
            ['ctrl-g'] = function(_, o)
              o.cwd_only = not o.cwd_only
              o.__call_fn { cwd_only = o.cwd_only, resume = true }
            end,
          },
        },
      })
    end,
  },
}
