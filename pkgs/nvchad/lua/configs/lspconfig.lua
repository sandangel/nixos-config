dofile(vim.g.base46_cache .. 'lsp')
require 'nvchad.lsp'

local lspconfig = require 'lspconfig'
local root_pattern = require 'lspconfig.util'.root_pattern

local on_init = require 'nvchad.configs.lspconfig'.on_init
local capabilities = require 'nvchad.configs.lspconfig'.capabilities

local group = vim.api.nvim_create_augroup('LspFormatting', {})

---@param client vim.lsp.Client
---@param bufnr integer
local on_attach = function(client, bufnr)
  if client.supports_method 'textDocument/formatting' then
    vim.api.nvim_clear_autocmds { group = group, buffer = bufnr, }
    vim.api.nvim_create_autocmd('BufWritePre', {
      group = group,
      buffer = bufnr,
      callback = function()
        local prettier = require('null-ls.builtins.formatting.prettier')
        local ft = vim.bo[bufnr].filetype
        if vim.tbl_contains({ 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' }, ft) then
          vim.cmd "EslintFixAll"
        end
        if vim.tbl_contains(prettier.filetypes, ft) then
          vim.lsp.buf.format { async = false, filter = function() return client.name == 'null-ls' end }
        else
          vim.lsp.buf.format { async = false }
        end
      end,
    })
  end
end

local servers = {
  cssls = {},
  dockerls = {},
  eslint = {},
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
  },
  yamlls = {
    filetypes = vim.tbl_filter(function(ft)
      -- Not start with Helm files
      return not vim.tbl_contains({ 'helm', }, ft)
    end, require 'lspconfig.configs.yamlls'.default_config.filetypes),
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
  ts_ls = {},
  tailwindcss = {},
  lua_ls = {
    settings = {
      Lua = {
        runtime = {
          version = 'LuaJIT',
        },
        telemetry = { enable = false },
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
    null_ls.builtins.diagnostics.codespell.with {
      cwd = h.cache.by_bufnr(function(params)
        return (root_pattern '.git')(params.bufname)
      end),
    },
    null_ls.builtins.diagnostics.actionlint,
    null_ls.builtins.diagnostics.stylelint,
    null_ls.builtins.diagnostics.yamllint,

    null_ls.builtins.formatting.prettier,
    null_ls.builtins.formatting.nixfmt,
    null_ls.builtins.formatting.terraform_fmt,

    require 'none-ls.formatting.ruff',
    require 'none-ls.formatting.ruff_format',
  },
}
