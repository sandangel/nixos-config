return {
  { 'nvim-treesitter/nvim-treesitter', event = 'BufRead', build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = {
          'bash',
          'css',
          'dockerfile',
          'go',
          'hcl',
          'html',
          'javascript',
          'jsdoc',
          'json',
          'json5',
          'jsonc',
          'lua',
          'markdown',
          'markdown_inline',
          'nix',
          'python',
          'regex',
          'rust',
          'scss',
          'sql',
          'tsx',
          'typescript',
          'vim',
          'yaml',
        },
        highlight = {
          enable = true,
        },
      }
    end },
  { 'nvim-treesitter/nvim-treesitter-context', dependencies = { 'nvim-treesitter/nvim-treesitter' } },
  { 'nvim-treesitter/nvim-treesitter-textobjects', dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require 'nvim-treesitter.configs'.setup {
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
            },
            include_surrounding_whitespace = true,
          },
        },
      }
    end }
}
