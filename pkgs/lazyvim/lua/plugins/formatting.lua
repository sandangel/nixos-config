return {
  -- ─── Mason: wipe <leader>cm ───────────────────────────────────────────────
  {
    'mason-org/mason.nvim',
    keys = function() return {} end,
  },

  {
    'stevearc/conform.nvim',
    -- ─── Conform: wipe <leader>cF (injected format) ──────────────────────────
    keys = function() return {} end,
    -- LazyVim manages format-on-save via vim.g.autoformat; do NOT set format_on_save here.
    opts = {
      formatters_by_ft = {
        python = { 'ruff_format', 'ruff_fix', 'ruff_organize_imports', lsp_format = 'fallback' },
        typescriptreact = { 'prettier', lsp_format = 'fallback' },
        ['*'] = { 'trim_whitespace' },
      },
    },
  },
}
