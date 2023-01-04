return { 'windwp/nvim-autopairs', event = 'VimEnter', config = function()
  local npairs = require 'nvim-autopairs'

  npairs.setup()

  local Rule = require 'nvim-autopairs.rule'
  local conds = require 'nvim-autopairs.conds'

  npairs.add_rules {
    Rule(' ', ' ')
        :with_pair(function(opts)
          local pair = opts.line:sub(opts.col - 1, opts.col)
          return vim.tbl_contains({ '()', '{}', '[]' }, pair)
        end)
        :with_move(conds.none())
        :with_cr(conds.none())
        :with_del(function(opts)
          local col = vim.api.nvim_win_get_cursor(0)[2]
          local context = opts.line:sub(col - 1, col + 2)
          return vim.tbl_contains({ '(  )', '{  }', '[  ]' }, context)
        end),
    Rule('', ' )')
        :with_pair(conds.none())
        :with_move(function(opts)
          return opts.char == ')'
        end)
        :with_cr(conds.none())
        :with_del(conds.none())
        :use_key ')',
    Rule('', ' }')
        :with_pair(conds.none())
        :with_move(function(opts)
          return opts.char == '}'
        end)
        :with_cr(conds.none())
        :with_del(conds.none())
        :use_key '}',
    Rule('', ' ]')
        :with_pair(conds.none())
        :with_move(function(opts)
          return opts.char == ']'
        end)
        :with_cr(conds.none())
        :with_del(conds.none())
        :use_key ']',
  }
end }
