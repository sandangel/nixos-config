dofile(vim.g.base46_cache .. 'lsp')
require 'nvchad.lsp'

local lspconfig = require 'lspconfig'
local root_pattern = require 'lspconfig.util'.root_pattern

local on_init = require 'nvchad.configs.lspconfig'.on_init
local capabilities = require 'nvchad.configs.lspconfig'.capabilities

local group = vim.api.nvim_create_augroup('LspFormatting', {})

local on_attach = function(client, bufnr)
  -- setup signature popup
  if require 'nvconfig'.ui.lsp.signature and client.server_capabilities.signatureHelpProvider then
    require 'nvchad.lsp.signature'.setup(client, bufnr)
  end
  if client.supports_method 'textDocument/formatting' then
    vim.api.nvim_clear_autocmds { group = group, buffer = bufnr, }
    vim.api.nvim_create_autocmd('BufWritePre', {
      group = group,
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format { async = false, }
      end,
    })
  end
end

local servers = {
  dockerls = {},
  gopls = {},
  golangci_lint_ls = {},
  helm_ls = {},
  nixd = {},
  rust_analyzer = {},
  ruff = {
    root_dir = root_pattern '.git',
  },
  pyright = {
    root_dir = root_pattern '.git',
    settings = {
      python = {
        analysis = {
          typeCheckingMode = 'off',
        },
      },
    },
  },
  yamlls = {
    filetypes = vim.tbl_filter(function(ft)
      -- Not start with Helm files
      return not vim.tbl_contains({ 'helm', }, ft)
    end, require 'lspconfig.server_configurations.yamlls'.default_config.filetypes),
    settings = {
      yaml = {
        format = { enable = true, printWidth = 120, singleQuote = true, proseWrap = 'always', },
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
        schemas = require 'schemastore'.yaml.schemas {
          replace = {
            ['Deployer Recipe'] = {
              description = 'YAML GitHub Workflow', -- description = "A Deployer yaml recipes",
              fileMatch = { 'deploy.yml', 'deploy.yaml', },
              name = 'Deployer Recipe',
              url = 'https://json.schemastore.org/github-workflow.json', -- url = "https://raw.githubusercontent.com/deployphp/deployer/master/src/schema.json"
            },
          },
        },
      },
      redhat = { telemetry = { enabled = false, }, },
    },
  },
  jsonls = {
    settings = {
      json = {
        schemas = require 'schemastore'.json.schemas(),
        validate = { enable = true, },
      },
    },
  },
  tflint = {
    root_dir = root_pattern('.git', '.terraform', 'main.tf', '.terraform.lock.hcl'),
  },
  terraformls = {
    root_dir = root_pattern('.git', '.terraform', 'main.tf', '.terraform.lock.hcl'),
  },
  tsserver = {
    init_options = {
      hostInfo = 'neovim',
      preferences = {
        quotePreference = 'single',
      },
    },
  },
  lua_ls = {
    settings = {
      Lua = {
        runtime = {
          version = 'LuaJIT',
        },
        diagnostics = {
          globals = { 'vim', },
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
            call_arg_parentheses = 'remove',
            trailing_table_separator = 'always',
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
  },
}

for name, opts in pairs(servers) do
  opts.on_init = on_init
  opts.on_attach = on_attach
  opts.capabilities = capabilities

  lspconfig[name].setup(opts)
end

local null_ls = require 'null-ls'
local h = require 'null-ls.helpers'

-- Need to set root_dir to `.git` for pyproject because there might be
-- multiple pyproject files in a python monorepo. So by default we only
-- check the pyproject at root to avoid config duplication.

null_ls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  root_dir = root_pattern '.git',
  sources = {
    require 'none-ls.code_actions.eslint_d',

    null_ls.builtins.completion.spell,

    null_ls.builtins.diagnostics.codespell.with {
      cwd = h.cache.by_bufnr(function(params)
        return (root_pattern '.git')(params.bufname)
      end),
    },
    null_ls.builtins.diagnostics.actionlint,
    null_ls.builtins.diagnostics.mypy.with {
      cwd = h.cache.by_bufnr(function(params)
        return (root_pattern '.git')(params.bufname)
      end),
    },
    null_ls.builtins.diagnostics.stylelint,
    null_ls.builtins.diagnostics.yamllint,
    require 'none-ls.diagnostics.eslint_d',

    null_ls.builtins.formatting.prettierd,
    null_ls.builtins.formatting.nixfmt,
    null_ls.builtins.formatting.terraform_fmt,
    require 'none-ls.formatting.eslint_d',
    require 'none-ls.formatting.ruff',
    require 'none-ls.formatting.ruff_format',
  },
}
