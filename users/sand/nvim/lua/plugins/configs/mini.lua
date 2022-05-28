local modules = {
  'comment',
  'cursorword',
  'indentscope',
  'trailspace',
}

for _, m in ipairs(modules) do
  require('mini.' .. m).setup {}
end

vim.api.nvim_create_augroup('MiniNvimUser', { clear = true })
vim.api.nvim_create_autocmd('BufWritePre', {
  group = 'MiniNvimUser',
  pattern = '*',
  callback = function()
    require('mini.trailspace').trim()
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  group = 'MiniNvimUser',
  pattern = 'neo-tree',
  callback = function()
    vim.b.miniindentscope_disable = true
    vim.b.minicursorword_disable = true
    vim.b.minitrailspace_disable = true
    vim.b.minicomment_disable = true
  end,
})
