local cmp = require 'cmp'
local luasnip = require 'luasnip'

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match '%s' == nil
end

return {
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },
  mapping = cmp.mapping.preset.insert({
    -- Remove detaul mappings from NvChad
    ['<C-p>'] = function(fallback) fallback() end,
    ['<C-n>'] = function(fallback) fallback() end,
    ['<C-d>'] = function(fallback) fallback() end,
    ['<C-Space>'] = function(fallback) fallback() end,
    ['<CR>'] = function(fallback) fallback() end,

    ['<C-e>'] = cmp.mapping.close(),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-c>'] = cmp.mapping.complete(),
    ['<Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.confirm { behavior = cmp.ConfirmBehavior.Replace, select = true }
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end,
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'nvim_lua' },
    { name = 'path' },
  }, {
    { name = 'buffer', },
    { name = 'kitty',  keyword_length = 3 },
    { name = 'rg',     keyword_length = 3 },
  }),
  experimental = {
    ghost_text = true,
  },
}
