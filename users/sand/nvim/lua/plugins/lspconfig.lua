return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'ibhagwan/fzf-lua',
    'nvim-lua/plenary.nvim',
    { 'NvChad/ui', branch = 'v2.0' },
    {
      'folke/neodev.nvim',
      config = function()
        require('neodev').setup()
      end
    }
  },
  config = function()
    local root_pattern = require('lspconfig.util').root_pattern
    local lspconfig = require 'lspconfig'
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    dofile(vim.g.base46_cache .. 'lsp')
    require 'nvchad.lsp'

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

    local opts = { silent = true }

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

      if client.server_capabilities.signatureHelpProvider then
        require('nvchad.signature').setup(client)
      end

      -- Mappings.
      opts.buffer = bufnr
      -- See `:help vim.lsp.*` for documentation on any of the below functions
      vim.keymap.set('n', 'gw', '<cmd>FzfLua lsp_document_diagnostics<cr>', opts)
      vim.keymap.set('n', 'gW', '<cmd>FzfLua lsp_workspace_diagnostics<cr>', opts)
      vim.keymap.set('n', 'gd', '<cmd>FzfLua lsp_finder<cr>', opts)
      vim.keymap.set('n', 'gl', function() vim.diagnostic.open_float() end, opts)
      vim.keymap.set('n', 'gh', function() vim.lsp.buf.hover() end, opts)
      vim.keymap.set('n', 'gr', function() require('nvchad.renamer').open() end, opts)
      vim.keymap.set('n', 'gA', '<cmd>FzfLua lsp_code_actions<cr>', opts)
      vim.keymap.set('x', 'gA', '<cmd>FzfLua lsp_code_actions<cr>', opts)
      vim.keymap.set('n', ']d', function() vim.diagnostic.goto_next() end, opts)
      vim.keymap.set('n', '[d', function() vim.diagnostic.goto_prev() end, opts)
      vim.keymap.set('n', 'gf', function() vim.lsp.buf.format { async = true } end, opts)
      vim.keymap.set('x', 'gf', function() vim.lsp.buf.range_formatting() end, opts)
    end

    local servers = {
      'rust_analyzer',
      'gopls',
      'dockerls',
      'jsonls',
      'rnix',
    }

    for _, lsp in ipairs(servers) do
      lspconfig[lsp].setup {
        capabilities = capabilities,
        on_attach = on_attach,
      }
    end

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

    lspconfig.lua_ls.setup {
      on_attach = on_attach,
      capabilities = capabilities,
      settings = {
        Lua = {
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

    lspconfig.yamlls.setup {
      on_attach = on_attach,
      capabilities = capabilities,
      settings = {
        yaml = {
          format = { enable = true, printWidth = 120, singleQuote = true, proseWrap = 'always' },
          keyOrdering = false,
          hover = true,
          completion = true,
          validate = true,
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
  end
}
