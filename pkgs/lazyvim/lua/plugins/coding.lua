vim.g.lazyvim_blink_main = true
vim.g.ai_cmp = true

return {
  -- blink.cmp: override Tab to confirm (matching previous nvim-cmp muscle memory)
  -- LazyVim's default "enter" preset: Enter=confirm, Tab=snippet_forward/ai_accept.
  -- Remap Tab to confirm-or-snippet-forward, disable <C-p>/<C-n> (user uses <C-p> for nvim-tree).
  {
    'saghen/blink.cmp',
    branch = 'main',
    dependencies = { { 'saghen/blink.lib', 'blink-copilot', 'mikavilpas/blink-ripgrep.nvim' } },
    build = function() require('blink.cmp').build():wait(60000) end,
    opts = {
      keymap = {
        preset = 'enter',
        -- Tab: confirm selected item, or jump snippet, or fall through
        ['<Tab>'] = { 'select_and_accept', 'snippet_forward', 'fallback' },
        ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
        -- Disable C-p/C-n inside completion to avoid conflict with <C-p> (nvim-tree)
        ['<C-p>'] = {},
        ['<C-n>'] = {},
        ['<C-c>'] = { 'show', 'fallback' },
        ['<C-e>'] = { 'cancel', 'fallback' },
        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
      },
      -- Copilot source is wired up by the extras/ai/copilot extra via blink-copilot
      sources = {
        default = { 'lsp', 'path', 'snippets', 'ripgrep', 'copilot' },
        providers = {
          ripgrep = {
            module = 'blink-ripgrep',
            name = 'Ripgrep',
            opts = {
              backend = { use = 'gitgrep-or-ripgrep' },
            },
          },
          copilot = {
            name = 'copilot',
            module = 'blink-copilot',
            score_offset = 100,
            async = true,
          },
        },
      },
      completion = {
        accept = { auto_brackets = { enabled = true } },
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
      },
    },
  },
  {
    "zbirenbaum/copilot.lua",
    config = function(_, opts)
      opts = {
        suggestion = {
          enabled = not vim.g.ai_cmp,
          auto_trigger = true,
          hide_during_completion = vim.g.ai_cmp,
          keymap = {
            accept = false,
          },
        },
        panel = { enabled = false },
        filetypes = {
          markdown = true,
          help = true,
        },
      }
      LazyVim.cmp.actions.ai_accept = function()
        if require("copilot.suggestion").is_visible() then
          LazyVim.create_undo()
          require("copilot.suggestion").accept()
          return true
        end
      end
      require('copilot').setup(opts)
    end,
  },
}
