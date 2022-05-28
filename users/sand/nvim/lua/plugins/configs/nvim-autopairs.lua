local npairs = require 'nvim-autopairs'

npairs.setup {}

local keymap_opts = { expr = true, silent = true }

vim.keymap.set('i', '<cr>', function()
  if vim.fn.pumvisible() == 0 then
    return npairs.autopairs_cr()
  else
    return '<c-e>' .. npairs.autopairs_cr()
  end
end, keymap_opts)
vim.keymap.set('i', '<bs>', function()
  if vim.fn.pumvisible() == 0 then
    return npairs.autopairs_bs()
  else
    return '<c-e>' .. npairs.autopairs_bs()
  end
end, keymap_opts)

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
