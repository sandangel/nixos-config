dofile(vim.g.base46_cache .. 'lsp')
require 'nvchad.lsp'

local on_init = require 'nvchad.configs.lspconfig'.on_init
local base_capabilities = require 'nvchad.configs.lspconfig'.capabilities
local capabilities = require('blink.cmp').get_lsp_capabilities(base_capabilities)
local group = vim.api.nvim_create_augroup('LspFormatting', {})

---@param client vim.lsp.Client
---@param bufnr integer
local on_attach = function(client, bufnr)
  if client:supports_method 'textDocument/formatting' then
    vim.api.nvim_clear_autocmds { group = group, buffer = bufnr, }
    vim.api.nvim_create_autocmd('BufWritePre', {
      group = group,
      buffer = bufnr,
      callback = function()
        require("conform").format({ bufnr = bufnr })
      end,
    })
  end
end

local servers = {
  -- cssls = {},
  dockerls         = {},
  eslint           = {},
  -- basedpyright = {},
  gopls            = {},
  golangci_lint_ls = {},
  helm_ls          = {},
  nixd             = {},
  rust_analyzer    = {},
  ruff             = {},
  pyright          = {},
  yamlls           = {
    filetypes = vim.tbl_filter(function(ft)
      return not vim.tbl_contains({ 'helm' }, ft)
    end, require 'lspconfig.configs.yamlls'.default_config.filetypes),
    settings = {
      yaml = {
        format      = { enable = true },
        keyOrdering = false,
        hover       = true,
        completion  = true,
        validate    = true,
        schemaStore = { enable = false, url = '' },
        schemas     = require 'schemastore'.yaml.schemas {
          replace = {
            ['Deployer Recipe'] = {
              description = 'YAML GitHub Workflow',
              fileMatch   = { 'deploy.yml', 'deploy.yaml' },
              name        = 'Deployer Recipe',
              url         = 'https://json.schemastore.org/github-workflow.json',
            },
          },
        },
      },
      redhat = { telemetry = { enabled = false, }, },
    },
  },
  jsonls           = {
    settings = {
      json = {
        schemas  = require 'schemastore'.json.schemas(),
        validate = { enable = true, },
      },
    },
  },
  tflint           = {},
  terraformls      = {},
  ty               = {
    settings = {
      ty = {
        diagnosticMode = 'workspace',
      },
    },
  },
  vtsls            = {},
  tailwindcss      = {},
  lua_ls           = {
    settings = {
      Lua = {
        runtime   = {
          version = 'LuaJIT',
        },
        workspace = {
          checkThirdParty = false,
          library = {
            vim.fn.expand "$VIMRUNTIME/lua",
            vim.fn.stdpath "data" .. "/lazy/ui/nvchad_types",
            vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy",
            vim.fn.stdpath "data" .. "/lazy/noice.nvim/lua/noice/types",
            vim.fn.stdpath "data" .. "/lazy/snacks.nvim/lua/snacks",
            vim.fn.stdpath "data" .. "/lazy/conform.nvim/lua/conform",
            "${3rd}/luv/library",
          }
        },
        telemetry = { enable = false },
      },
    },
  },
}

for name, opts in pairs(servers) do
  opts.on_init      = on_init
  opts.on_attach    = on_attach
  opts.capabilities = capabilities
  vim.lsp.config(name, opts)
  vim.lsp.enable(name)
end
