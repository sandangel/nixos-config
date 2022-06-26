local cmp = require 'cmp'
local snippy = require 'snippy'

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match '%s' == nil
end

cmp.setup {
  snippet = {
    expand = function(args)
      require('snippy').expand_snippet(args.body)
    end,
  },
  formatting = {
    format = function(entry, vim_item)
      local lspkind_icons = require('plugins.configs.lspkind').icons
      vim_item.kind = string.format('%s %s', lspkind_icons[vim_item.kind], vim_item.kind)
      vim_item.menu = ({
        buffer = '[Buffer]',
        nvim_lsp = '[LSP]',
        nvim_lua = '[Lua]',
        path = '[Path]',
        snippy = '[Snippy]',
      })[entry.source.name]
      return vim_item
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<c-b>'] = cmp.mapping.scroll_docs(-4),
    ['<c-f>'] = cmp.mapping.scroll_docs(4),
    ['<c-c>'] = cmp.mapping.complete({ reason = 'triggerOnly' }),
    ['<tab>'] = function(fallback)
      if cmp.visible() then
        cmp.confirm { behavior = cmp.ConfirmBehavior.Replace, select = true }
      elseif snippy.can_expand_or_advance() then
        snippy.expand_or_advance()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end,
    ['<s-tab>'] = function(_)
      snippy.previous()
    end,
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lua' },
    { name = 'nvim_lsp' },
  }, {
    {
      name = 'buffer',
      max_item_count = 10,
      option = {
        get_bufnrs = function()
          return vim.api.nvim_list_bufs()
        end,
      },
    },
  }, {
    { name = 'path' },
  }, {
    { name = 'snippy', max_item_count = 10 },
  }),
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },
  experimental = {
    ghost_text = true,
  },
}

local M = {}

M.capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
M.capabilities.textDocument.completion.completionItem.preselectSupport = true
M.capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
M.capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
M.capabilities.textDocument.completion.completionItem.deprecatedSupport = true
M.capabilities.textDocument.completion.completionItem.commitCharactersSupport = true
M.capabilities.textDocument.completion.completionItem.tagSupport = { valueSet = { 1 } }
M.capabilities.textDocument.completion.completionItem.snippetSupport = true
M.capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = {
    'documentation',
    'detail',
    'additionalTextEdits',
  },
}

return M
