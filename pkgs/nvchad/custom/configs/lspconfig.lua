local capabilities = require('plugins.configs.lspconfig').capabilities
local root_pattern = require('lspconfig.util').root_pattern

local lspconfig = require 'lspconfig'

vim.api.nvim_create_augroup('LSPConfigUser', { clear = true })

local on_attach = function(client, bufnr)
  -- To avoid nvchad setting formatting to false, we store the value and reset them later
  local documentFormattingProvider = client.server_capabilities.documentFormattingProvider
  local documentRangeFormattingProvider = client.server_capabilities.documentRangeFormattingProvider

  require('plugins.configs.lspconfig').on_attach(client, bufnr)

  client.server_capabilities.documentFormattingProvider = documentFormattingProvider
  client.server_capabilities.documentRangeFormattingProvider = documentRangeFormattingProvider

  if client.server_capabilities.documentFormattingProvider then
    vim.api.nvim_create_autocmd('BufWritePre', {
      group = 'LSPConfigUser',
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format { bufnr = bufnr }
      end,
    })
  end
end

local servers = {
  'dockerls',
  'gopls',
  'helm_ls',
  'rnix',
  'rust_analyzer',
}

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

lspconfig.lua_ls.setup {
  on_attach = on_attach,
  capabilities = capabilities,

  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        globals = { 'vim' },
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
      workspace = {
        library = {
          [vim.fn.expand '$VIMRUNTIME/lua'] = true,
          [vim.fn.expand '$VIMRUNTIME/lua/vim/lsp'] = true,
          [vim.fn.stdpath 'data' .. '/lazy/ui/nvchad_types'] = true,
          [vim.fn.stdpath 'data' .. '/lazy/lazy.nvim/lua/lazy'] = true,
          [vim.fn.stdpath 'data' .. '/lazy/noice.nvim/lua/noice'] = true,
        },
        maxPreload = 100000,
        preloadFileSize = 10000,
      },
    },
  },
}

lspconfig.tsserver.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  init_options = {
    hostInfo = 'neovim',
    preferences = {
      quotePreference = 'single',
    },
  }
}

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

lspconfig.jsonls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    json = {
      schemas = require('schemastore').json.schemas(),
      validate = { enable = true },
    },
  },
}

local yamlls = require('lspconfig.server_configurations.yamlls')

lspconfig.yamlls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  -- Not start with Helm files
  filetypes = vim.tbl_filter(function(ft)
    return not vim.tbl_contains({ 'helm' }, ft)
  end, yamlls.default_config.filetypes),
  settings = {
    yaml = {
      format = { enable = true, printWidth = 120, singleQuote = true, proseWrap = 'always' },
      keyOrdering = false,
      hover = true,
      completion = true,
      validate = true,
      schemaStore = {
        -- You must disable built-in schemaStore support if you want to use
        -- this plugin and its advanced options like `ignore`.
        enable = false,
        -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
        url = '',
      },
      schemas = require('schemastore').yaml.schemas(),
    },
    redhat = { telemetry = { enabled = false } },
  }
}

lspconfig.pylsp.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    pylsp = {
      configurationSources = { 'flake8' },
      plugins = {
        flake8              = { enabled = true },
        black               = { enabled = true, line_length = 120 },
        ruff                = { enabled = true, extendSelect = { 'I' }, },
        pylsp_mypy          = { enabled = true },
        pyls_isort          = { enabled = true },
        pylint              = { enabled = true },
        jedi_completion     = { enabled = false },
        jedi_definition     = { enabled = false },
        jedi_hover          = { enabled = false },
        jedi_references     = { enabled = false },
        jedi_rename         = { enabled = false },
        jedi_signature_help = { enabled = false },
        jedi_symbols        = { enabled = false },
        pycodestyle         = { enabled = false },
        pyflakes            = { enabled = false },
        mccabe              = { enabled = false },
      },
    },
  },
}

lspconfig.pyright.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    python = {
      analysis = {
        typeCheckingMode = 'off',
      },
    },
  }
}
