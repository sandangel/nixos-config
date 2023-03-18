return {
  'nvim-tree/nvim-tree.lua',
  dependencies = { 'nvim-tree/nvim-web-devicons', },
  config = function()
    dofile(vim.g.base46_cache .. 'nvimtree')
    require('nvim-tree').setup({
      remove_keymaps = true,
      view = {
        mappings = {
          list = {
            { key = 'h',             action = 'dir_up' },
            { key = 'l',             action = 'cd' },
            { key = 'd',             action = 'trash' },
            { key = 'I',             action = 'toggle_git_ignored' },
            { key = 'H',             action = 'toggle_dotfiles' },
            { key = 'R',             action = 'refresh' },
            { key = 'a',             action = 'create' },
            { key = 'r',             action = 'rename' },
            { key = 'x',             action = 'cut' },
            { key = 'c',             action = 'copy' },
            { key = 'p',             action = 'paste' },
            { key = 'p',             action = 'paste' },
            { key = { '<CR>', 'o' }, action = 'edit' },
            { key = 'x',             action = 'cut' },
            { key = 'c',             action = 'copy' },
            { key = 'p',             action = 'paste' },
            { key = 'y',             action = 'copy_name' },
            { key = 'Y',             action = 'copy_path' },
            { key = 'gy',            action = 'copy_absolute_path' },
            { key = '[c',            action = 'prev_git_item' },
            { key = ']c',            action = 'next_git_item' },
            { key = '.',             action = 'system_open' },
            { key = 'f',             action = 'live_filter' },
            { key = 'F',             action = 'clear_live_filter' },
            { key = 'q',             action = 'close' },
            { key = '?',             action = 'toggle_help' },
          },
        },
      },
      renderer = {
        icons = {
          git_placement = 'after',
          glyphs = {
            default = '',
            symlink = '',
            folder = {
              default = '',
              empty = '',
              empty_open = '',
              open = '',
              symlink = '',
              symlink_open = '',
              arrow_open = '',
              arrow_closed = '',
            },
            git = {
              unstaged = '✗',
              staged = '✓',
              unmerged = '',
              renamed = '➜',
              untracked = '★',
              deleted = '',
              ignored = '◌',
            },
          },
        },
      },
    })
    vim.keymap.set('n', '<c-p>', '<cmd>NvimTreeFindFileToggle<cr>', { silent = true })
  end,
}
