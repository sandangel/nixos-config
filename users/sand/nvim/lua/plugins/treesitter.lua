return {
  {
    'nvim-treesitter/nvim-treesitter',
    event = 'BufRead',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = {
          'bash',
          'comment',
          'css',
          'css',
          'diff',
          'dockerfile',
          'git_rebase',
          'gitattributes',
          'gitcommit',
          'gitignore',
          'go',
          'gomod',
          'gosum',
          'hcl',
          'html',
          'javascript',
          'jsdoc',
          'json',
          'json5',
          'jsonc',
          'lua',
          'make',
          'markdown',
          'markdown_inline',
          'nix',
          'python',
          'regex',
          'rust',
          'scss',
          'sql',
          'terraform',
          'tsx',
          'typescript',
          'vim',
          'yaml',
        },
        highlight = {
          enable = true,
          use_languagetree = true,
        },
        indent = { enable = true },
      }
    end
  },
  { 'nvim-treesitter/nvim-treesitter-context', dependencies = { 'nvim-treesitter/nvim-treesitter' } },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      dofile(vim.g.base46_cache .. 'treesitter')
      dofile(vim.g.base46_cache .. 'syntax')
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
    end
  }
}
