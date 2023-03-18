return {
  'lewis6991/gitsigns.nvim',
  event = 'VimEnter',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    dofile(vim.g.base46_cache .. 'git')
    vim.api.nvim_create_augroup('GitSignsUser', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufWritePost', 'FocusGained', 'FocusLost' }, {
      pattern = '*',
      command = 'Gitsigns refresh',
    })

    require('gitsigns').setup {
      signs = {
        add = { hl = 'DiffAdd', text = '│', numhl = 'GitSignsAddNr' },
        change = { hl = 'DiffChange', text = '│', numhl = 'GitSignsChangeNr' },
        delete = { hl = 'DiffDelete', text = '', numhl = 'GitSignsDeleteNr' },
        topdelete = { hl = 'DiffDelete', text = '‾', numhl = 'GitSignsDeleteNr' },
        changedelete = { hl = 'DiffChangeDelete', text = '~', numhl = 'GitSignsChangeNr' },
        untracked = { hl = 'GitSignsAdd', text = '│', numhl = 'GitSignsAddNr', linehl = 'GitSignsAddLn' },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then
            return ']c'
          end
          vim.schedule(function()
            gs.next_hunk({ preview = true })
          end)
          return '<Ignore>'
        end, {
          expr = true,
        })

        map('n', '[c', function()
          if vim.wo.diff then
            return '[c'
          end
          vim.schedule(function()
            gs.prev_hunk({ preview = true })
          end)
          return '<Ignore>'
        end, {
          expr = true,
        })

        -- Actions
        map({ 'n', 'x' }, '<leader>cs', gs.stage_hunk)
        map({ 'n', 'x' }, '<leader>cr', gs.reset_hunk)
        map('n', '<leader>cS', gs.stage_buffer)
        map('n', '<leader>cu', gs.undo_stage_hunk)
        map('n', '<leader>cR', gs.reset_buffer)
        map('n', '<leader>cp', gs.preview_hunk)
        map('n', '<leader>cb', function()
          gs.blame_line { full = true }
        end)
        map('n', '<leader>cb', gs.toggle_current_line_blame)
        map('n', '<leader>cd', gs.diffthis)
        map('n', '<leader>cD', function()
          gs.diffthis '~'
        end)
        map('n', '<leader>cd', gs.toggle_deleted)

        -- Text object
        map({ 'o', 'x' }, 'ih', '<cmd>Gitsigns select_hunk<cr>')
      end,
    }
  end
}
