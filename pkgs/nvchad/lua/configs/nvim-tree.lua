return vim.tbl_deep_extend('force', require 'nvchad.configs.nvimtree', {
  on_attach = function(bufnr)
    local api = require 'nvim-tree.api'

    local function opts(desc)
      return { desc = 'NvimTree ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true, }
    end

    vim.keymap.set('n', 'h', api.tree.change_root_to_parent, opts 'Up')
    vim.keymap.set('n', 'l', api.tree.change_root_to_node, opts 'CD')
    vim.keymap.set('n', 'd', api.fs.trash, opts 'Trash')
    vim.keymap.set('n', 'D', api.fs.remove, opts 'Delete')
    vim.keymap.set('n', 'I', api.tree.toggle_gitignore_filter, opts 'Toggle Git Ignore')
    vim.keymap.set('n', 'H', api.tree.toggle_hidden_filter, opts 'Toggle Dotfiles')
    vim.keymap.set('n', 'R', api.tree.reload, opts 'Refresh')
    vim.keymap.set('n', 'a', api.fs.create, opts 'Create')
    vim.keymap.set('n', 'r', api.fs.rename, opts 'Rename')
    vim.keymap.set('n', 'x', api.fs.cut, opts 'Cut')
    vim.keymap.set('n', 'c', api.fs.copy.node, opts 'Copy')
    vim.keymap.set('n', 'p', api.fs.paste, opts 'Paste')
    vim.keymap.set('n', '<CR>', api.node.open.edit, opts 'Open')
    vim.keymap.set('n', 'o', api.node.open.edit, opts 'Open')
    vim.keymap.set('n', 'x', api.fs.cut, opts 'Cut')
    vim.keymap.set('n', 'c', api.fs.copy.node, opts 'Copy')
    vim.keymap.set('n', 'p', api.fs.paste, opts 'Paste')
    vim.keymap.set('n', 'y', api.fs.copy.filename, opts 'Copy Name')
    vim.keymap.set('n', 'Y', api.fs.copy.relative_path, opts 'Copy Relative Path')
    vim.keymap.set('n', 'gy', api.fs.copy.absolute_path, opts 'Copy Absolute Path')
    vim.keymap.set('n', '[c', api.node.navigate.git.prev, opts 'Prev Git')
    vim.keymap.set('n', ']c', api.node.navigate.git.next, opts 'Next Git')
    vim.keymap.set('n', '.', api.node.run.system, opts 'Run System')
    vim.keymap.set('n', 'f', api.live_filter.start, opts 'Filter')
    vim.keymap.set('n', 'F', api.live_filter.clear, opts 'Clean Filter')
    vim.keymap.set('n', 'q', api.tree.close, opts 'Close')
    vim.keymap.set('n', '?', api.tree.toggle_help, opts 'Help')
  end,
  view = {
    width = {}, -- Adaptive size
    side = 'right',
  },
  trash = {
    cmd = 'trash',
  },
  renderer = {
    icons = {
      git_placement = 'after',
    },
  },
})
