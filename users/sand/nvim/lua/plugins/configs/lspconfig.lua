local root_pattern = require('lspconfig.util').root_pattern
local lspconfig = require 'lspconfig'
local capabilities = require('plugins.configs.cmp').capabilities

vim.lsp.set_log_level 'error'

local function lspSymbol(name, icon)
  local hl = 'DiagnosticSign' .. name
  vim.fn.sign_define(hl, { text = icon, numhl = hl, texthl = hl })
end

lspSymbol('Error', '')
lspSymbol('Info', '')
lspSymbol('Hint', '')
lspSymbol('Warn', '')

vim.diagnostic.config {
  virtual_text = {
    prefix = '',
  },
  signs = true,
  underline = true,
  update_in_insert = false,
}

vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = 'single',
})
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = 'single',
})

local opts = { silent = true }

vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>', opts)
vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>', opts)
vim.keymap.set('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>', opts)
vim.keymap.set('n', 'gL', '<cmd>lua vim.diagnostic.setloclist()<cr>', opts)
vim.keymap.set('n', 'gq', '<cmd>lua vim.diagnostic.setqflist()<cr>', opts)

vim.api.nvim_create_augroup('LSPConfigUser', { clear = true })

local on_attach = function(client, bufnr)
  if client.name == 'sumneko_lua' or client.name == 'gopls' then
    vim.api.nvim_create_autocmd('BufWritePre', {
      group = 'LSPConfigUser',
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format()
      end,
    })
  end

  -- Mappings.
  opts.buffer = bufnr
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
  vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
  vim.keymap.set('n', 'gh', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
  vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
  vim.keymap.set('n', 'gk', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
  vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
  vim.keymap.set('n', 'gR', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
  vim.keymap.set('n', 'gA', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
  vim.keymap.set('n', 'gf', '<cmd>lua vim.lsp.buf.format()<cr>', opts)
end

local servers = {
  'rust_analyzer',
  'tsserver',
  'gopls',
  'dockerls',
  'vimls',
  'yamlls',
  'jsonls',
}

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    capabilities = capabilities,
    on_attach = on_attach,
  }
end

lspconfig.terraformls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  root_dir = root_pattern('.git', '.terraform', 'main.tf', '.terraform.lock.hcl'),
}

lspconfig.tflint.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  root_dir = root_pattern('.git', '.terraform', 'main.tf', '.terraform.lock.hcl'),
}

local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')

lspconfig.sumneko_lua.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
        path = runtime_path,
      },
      diagnostics = {
        enable = true,
        globals = { 'vim' },
        neededFileStatus = {
          ['codestyle-check'] = 'Any',
        },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file('', true),
      },
      telemetry = {
        enable = false,
      },
      format = {
        enable = true,
        defaultConfig = {
          indent_style = 'space',
          indent_size = '2',
          quote_style = 'single',
          call_arg_parentheses = 'unambiguous_remove_string_only',
        },
      },
    },
  },
}

require('lsp_signature').setup {
  bind = true,
  handler_opts = {
    border = 'single',
  },
  hint_enable = true,
  floating_window = true,
}
