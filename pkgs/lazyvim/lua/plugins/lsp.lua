return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      {
        'folke/lazydev.nvim',
        ft = 'lua',
        opts = {
          library = {
            { path = '${3rd}/luv/library',                                     words = { 'vim%.uv' } },
            { path = vim.fn.stdpath('data') .. '/lazy/snacks.nvim/lua/snacks', words = { 'Snacks' } },
            { path = vim.fn.stdpath('data') .. '/lazy/LazyVim/lua',            words = { 'LazyVim' } },
          },
        }
      },
      'b0o/schemastore.nvim',
    },
    -- Use opts = function() so require('schemastore') is deferred until after dependencies are loaded.
    opts = function(_, opts)
      -- Wipe all LazyVim LSP buffer-local defaults; user defines own in keymaps.lua
      opts.servers = opts.servers or {}
      local star = opts.servers['*'] or {}
      star.keys = {}
      opts.servers['*'] = star

      opts.servers = vim.tbl_deep_extend('force', opts.servers, {
        dockerls         = { mason = false },
        eslint           = { mason = false },
        gopls            = { mason = false },
        golangci_lint_ls = { mason = false },
        helm_ls          = {
          mason = false,
          settings = {
            ['helm-ls'] = {
              yamlls = {
                -- helm_ls spawns its own internal yamlls subprocess which by
                -- default sets schemas={"kubernetes":"templates/**"}, triggering
                -- CRD auto-detection against the datreeio catalog and causing
                -- "Unable to load schema: No content" errors for unknown CRDs.
                -- Override with empty schemas to disable that lookup.
                config = {
                  schemas    = {},
                  schemaStore = { enable = false, url = '' },
                },
              },
            },
          },
        },
        nil_ls           = { mason = false, enabled = false },
        nixd             = { mason = false },
        rust_analyzer    = { mason = false },
        ruff             = { mason = false },
        pyright          = { mason = false },
        tflint           = { mason = false },
        terraformls      = { mason = false },
        vtsls            = { mason = false },
        tailwindcss      = { mason = false },
        lua_ls           = {
          mason = false,
          settings = {
            Lua = {
              runtime = { version = 'LuaJIT' },
              workspace = {
                checkThirdParty = false,
                library = {
                  vim.fn.expand('$VIMRUNTIME/lua'),
                  vim.fn.stdpath('data') .. '/lazy/snacks.nvim/lua/snacks',
                  vim.fn.stdpath('data') .. '/lazy/noice.nvim/lua/noice/types',
                  vim.fn.stdpath('data') .. '/lazy/LazyVim/lua',
                  vim.fn.stdpath('data') .. '/lazy/conform.nvim/lua/conform',
                  '${3rd}/luv/library',
                },
              },
              telemetry = { enable = false },
            },
          },
        },
        yamlls           = {
          mason = false,
          settings = {
            yaml = {
              format      = { enable = true },
              keyOrdering = false,
              hover       = true,
              completion  = true,
              validate    = true,
              schemaStore = { enable = false, url = '' },
              schemas     = require('schemastore').yaml.schemas {
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
            redhat = { telemetry = { enabled = false } },
          },
        },
        jsonls           = {
          mason = false,
          settings = {
            json = {
              schemas  = require('schemastore').json.schemas(),
              validate = { enable = true },
            },
          },
        },
        ty               = {
          mason = false,
          settings = { ty = { diagnosticMode = 'workspace' } },
        },
      })
      return opts
    end,
  },
}
