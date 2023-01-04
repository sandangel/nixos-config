return { 'neovim/nvim-lspconfig', dependencies = {
  'glepnir/lspsaga.nvim',
  'ibhagwan/fzf-lua',
  'nvim-lua/plenary.nvim',
  'ray-x/lsp_signature.nvim',
  'NvChad/ui',
  { 'folke/neodev.nvim', config = function()
    require('neodev').setup()
  end }
}, config = function()
  local root_pattern = require('lspconfig.util').root_pattern
  local lspconfig = require 'lspconfig'
  local capabilities = require('cmp_nvim_lsp').default_capabilities()

  capabilities.textDocument.completion.completionItem = {
    documentationFormat = { 'markdown', 'plaintext' },
    snippetSupport = true,
    preselectSupport = true,
    insertReplaceSupport = true,
    labelDetailsSupport = true,
    deprecatedSupport = true,
    commitCharactersSupport = true,
    tagSupport = { valueSet = { 1 } },
    resolveSupport = {
      properties = {
        'documentation',
        'detail',
        'additionalTextEdits',
      },
    },
  }


  require 'nvchad_ui.lsp'
  require('lsp_signature').setup {
    hint_enable = false,
  }

  local opts = { silent = true }

  vim.keymap.set('n', 'gL', '<cmd>FzfLua loclist<cr>', opts)
  vim.keymap.set('n', 'gq', '<cmd>FzfLua quickfix<cr>', opts)

  vim.api.nvim_create_augroup('LSPConfigUser', { clear = true })

  local on_attach = function(client, bufnr)
    if client.server_capabilities.documentFormattingProvider then
      vim.api.nvim_create_autocmd('BufWritePre', {
        group = 'LSPConfigUser',
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format { bufnr = bufnr }
        end,
      })
    end

    -- Mappings.
    opts.buffer = bufnr
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    vim.keymap.set('n', 'gw', '<cmd>FzfLua lsp_document_diagnostics<cr>', opts)
    vim.keymap.set('n', 'gW', '<cmd>FzfLua lsp_workspace_diagnostics<cr>', opts)
    vim.keymap.set('n', 'gd', '<cmd>Lspsaga lsp_finder<cr>', opts)
    vim.keymap.set('n', 'gl', '<cmd>Lspsaga show_line_diagnostics<cr>', opts)
    vim.keymap.set('n', 'gh', '<cmd>Lspsaga hover_doc<cr>', opts)
    vim.keymap.set('n', 'gr', '<cmd>Lspsaga rename<cr>', opts)
    vim.keymap.set('n', 'gA', '<cmd>Lspsaga code_action<cr>', opts)
    vim.keymap.set('x', 'gA', '<cmd>Lspsaga range_code_action<cr>', opts)
    vim.keymap.set('n', ']d', '<cmd>Lspsaga diagnostic_jump_next<cr>', opts)
    vim.keymap.set('n', '[d', '<cmd>Lspsaga diagnostic_jump_prev<cr>', opts)
    vim.keymap.set('n', 'gf', '<cmd>lua vim.lsp.buf.format()<cr>', opts)
    vim.keymap.set('x', 'gf', '<cmd>lua vim.lsp.buf.range_formatting()<cr>', opts)
    vim.keymap.set('n', '<c-f>', "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1, '<c-f>')<cr>", opts)
    vim.keymap.set('n', '<c-b>', "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1, '<c-b>')<cr>", opts)
  end

  local servers = {
    'rust_analyzer',
    'tsserver',
    'gopls',
    'dockerls',
    'yamlls',
    'jsonls',
    'rnix',
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

  -- local runtime_path = vim.split(package.path, ';')
  -- table.insert(runtime_path, 'lua/?.lua')
  -- table.insert(runtime_path, 'lua/?/init.lua')

  lspconfig.sumneko_lua.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
      Lua = {
        -- runtime = {
        --   version = 'LuaJIT',
        --   path = runtime_path,
        -- },
        diagnostics = {
          enable = true,
          globals = { 'vim', 'require', 'string' },
          neededFileStatus = {
            ['codestyle-check'] = 'Any',
          },
        },
        -- workspace = {
        --   library = {
        --     [vim.fn.expand '$VIMRUNTIME/lua'] = true,
        --     [vim.fn.expand '$VIMRUNTIME/lua/vim/lsp'] = true,
        --   },
        --   maxPreload = 100000,
        --   preloadFileSize = 10000,
        -- },
        -- completion = { callSnippet = 'Replace' },
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

  lspconfig.pylsp.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
      pylsp = {
        configurationSources = { 'flake8' },
        plugins = {
          flake8 = { enabled = true },
          black = { enabled = true, line_length = 120 },
          pylsp_mypy = { enabled = true },
          pyls_isort = { enabled = true },
          jedi_completion = { enabled = false },
          jedi_definition = { enabled = false },
          jedi_hover = { enabled = false },
          jedi_references = { enabled = false },
          jedi_rename = { enabled = false },
          jedi_signature_help = { enabled = false },
          jedi_symbols = { enabled = false },
          pycodestyle = { enabled = false },
          pyflakes = { enabled = false },
          mccabe = { enabled = false },
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
end }
