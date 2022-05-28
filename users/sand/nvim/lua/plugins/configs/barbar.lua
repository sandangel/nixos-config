vim.g.bufferline = {
  icons = 'both',
  exclude_ft = { 'neo-tree' },
  icon_close_tab_modified = '',
}

local opts = { silent = true }
vim.keymap.set('n', '<leader>1', '<cmd>BufferGoto 1<cr>', opts)
vim.keymap.set('n', '<leader>2', '<cmd>BufferGoto 2<cr>', opts)
vim.keymap.set('n', '<leader>3', '<cmd>BufferGoto 3<cr>', opts)
vim.keymap.set('n', '<leader>4', '<cmd>BufferGoto 4<cr>', opts)
vim.keymap.set('n', '<leader>5', '<cmd>BufferGoto 5<cr>', opts)
vim.keymap.set('n', '<leader>6', '<cmd>BufferGoto 6<cr>', opts)
vim.keymap.set('n', '<leader>7', '<cmd>BufferGoto 7<cr>', opts)
vim.keymap.set('n', '<leader>8', '<cmd>BufferGoto 8<cr>', opts)
vim.keymap.set('n', '<leader>9', '<cmd>BufferGoto 9<cr>', opts)
vim.keymap.set('n', '<leader>0', '<cmd>BufferGoto 10<cr>', opts)

vim.keymap.set('n', '[b', '<cmd>BufferPrevious<cr>', opts)
vim.keymap.set('n', ']b', '<cmd>BufferNext<cr>', opts)
vim.keymap.set('n', '[m', '<cmd>BufferMovePrevious<cr>', opts)
vim.keymap.set('n', ']m', '<cmd>BufferMoveNext<cr>', opts)
