---@type MappingsTable
local M = {}

M.general = {
  x = {
    ['.'] = { '<cmd>norm.<CR>', 'Repeat' },
    ['Q'] = { "<cmd>'<,'>:normal @q<CR>", 'Replay' },
    ['<leader>y'] = { '"*ygv"+y`]', 'Copy to clipboard' },
    ['<leader>p'] = { '"_d"+P', 'Paste from clipboard no yank' },
    ['y'] = { 'y`]', 'Yank' },
    ['p'] = { '"_dP', 'Paste no yank' },
  },
  n = {
    ['j'] = {
      [[v:count || mode(1)[0:1] == 'no' ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj']],
      'Move down',
      opts = { expr = true }
    },
    ['k'] = {
      [[v:count || mode(1)[0:1] == 'no' ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk']],
      'Move up',
      opts = { expr = true }
    },
    -- nvim default key map which does not have desc
    ['gO'] = { 'gO', 'Show TOC' },
    ['Q'] = { '@q', 'Replay' },
    ['gV'] = { 'ggVG', 'Select all' },
    ['gj'] = { '<c-w>W', 'Move to next window' },
    ['vv'] = { 'vg_', 'Select to end of line' },
    ['<leader>-'] = { '<cmd>split<CR>', 'Split horizontal' },
    ['<leader>='] = { '<cmd>vsplit<CR>', 'Split vertical' },
    ['<leader>p'] = { '"+p', 'Paste from clipboard' },
    ['[<leader>'] = { 'm`O<Esc>``', 'Add empty line up' },
    [']<leader>'] = { 'm`o<Esc>``', 'Add empty line down' },
    ['<leader>q'] = { '<cmd>Sayonara<CR>', 'Quit buffer/window' },
    ['<leader>w'] = { '<cmd>wa<CR>', 'Save all' },
  },
  i = {
    ['<A-left>'] = { '<C-left>', 'Move one word left' },
    ['<A-right>'] = { '<C-right>', 'Move one word right' },
  },
  t = {
    ['<A-left>'] = { '<C-left>', 'Move one word left' },
    ['<A-right>'] = { '<C-right>', 'Move one word right' },
    ['<Esc>'] = { vim.api.nvim_replace_termcodes('<C-\\><C-n>', true, true, true), 'Escape terminal mode' },
  },
}

M.notify = {
  n = {
    ['<leader>nd'] = {
      function()
        require('notify').dismiss({ silent = true, pending = true })
      end,
      'Delete all notifications',
    }
  }
}

M.telescope = {
  plugin = true,
  n = {
    -- theme switcher
    ['<leader>th'] = { '<cmd>Telescope themes<CR>', 'Nvchad themes' },
  },
}

M.undotree = {
  n = {
    ['<F2>'] = { '<cmd>UndotreeToggle<CR>', 'Toggle undotree' },
  }
}

M.smart_splits = {
  i = {
    ['<C-h>'] = { function() require('smart-splits').move_cursor_left() end, 'Window left' },
    ['<C-l>'] = { function() require('smart-splits').move_cursor_right() end, 'Window right' },
    ['<C-j>'] = { function() require('smart-splits').move_cursor_down() end, 'Window down' },
    ['<C-k>'] = { function() require('smart-splits').move_cursor_up() end, 'Window up' },
  },
  n = {
    ['<C-h>'] = { function() require('smart-splits').move_cursor_left() end, 'Window left' },
    ['<C-l>'] = { function() require('smart-splits').move_cursor_right() end, 'Window right' },
    ['<C-j>'] = { function() require('smart-splits').move_cursor_down() end, 'Window down' },
    ['<C-k>'] = { function() require('smart-splits').move_cursor_up() end, 'Window up' },
  },
  t = {
    ['<C-h>'] = { function() require('smart-splits').move_cursor_left() end, 'Window left' },
    ['<C-l>'] = { function() require('smart-splits').move_cursor_right() end, 'Window right' },
    ['<C-j>'] = { function() require('smart-splits').move_cursor_down() end, 'Window down' },
    ['<C-k>'] = { function() require('smart-splits').move_cursor_up() end, 'Window up' },
  },
}

M.noice = {
  n = {
    ['<C-f>'] = {
      function()
        if not require('noice.lsp').scroll(4) then
          return '<C-f>'
        end
      end,
      'Scroll lsp down',
      opts = { silent = true, expr = true },
    },
    ['<C-b>'] = {
      function()
        if not require('noice.lsp').scroll(-4) then
          return '<C-b>'
        end
      end,
      'Scroll lsp up',
      opts = { silent = true, expr = true },
    },
  },
}

M.fzf_lua = {
  n = {
    ['gL'] = { '<cmd>FzfLua loclist<CR>', 'Location list' },
    ['gq'] = { '<cmd>FzfLua quickfix<CR>', 'Quick fix' },
    ['<leader>cc'] = { function() require('fzf-lua').git_commits() end, 'Git commits' },
    ['<leader>bc'] = { function() require('fzf-lua').git_bcommits() end, 'Git buffer commits' },
    ['<leader>hc'] = { function() require('fzf-lua').command_history() end, 'Command history' },
    ['<leader>hs'] = { function() require('fzf-lua').search_history() end, 'Search history' },
    ['<leader>s'] = { function() require('fzf-lua').oldfiles() end, 'Recent files' },
    ['<leader>j'] = { function() require('fzf-lua').files() end, 'Project files' },
    ['<leader>J'] = { function() require('fzf-lua').files({ cwd = vim.fn.expand '%:p:h' }) end, 'CWD files' },
    ['<leader>g'] = { function() require('fzf-lua').git_status() end, 'Git status' },
    ['<leader>f'] = { function() require('fzf-lua').grep_project() end, 'Grep project' },
    ['<leader>F'] = { function() require('fzf-lua').grep_project({ cwd = vim.fn.expand '%:p:h' }) end, 'Grep CWD' },
    ['<leader>l'] = { function() require('fzf-lua').blines() end, 'Grep buffer lines' },
    ['<leader>d'] = { function() require('fzf-lua').grep_project { fzf_opts = { ['--query'] = vim.fn.expand '<cword>' } } end,
      'Grep word' },
    ['<leader>D'] = { function()
      require('fzf-lua').grep_project { fzf_opts = { ['--query'] = vim.fn.expand '<cword>' }, cwd =
          vim.fn.expand '%:p:h' }
    end, 'Grep CWD word' },
    ['<leader>k'] = { function() require('fzf-lua').blines({ fzf_opts = { ['--query'] = vim.fn.expand '<cword>' } }) end,
      'Grep buffer word' },
  },
  x = {
    ['<leader>d'] = { function()
      require('fzf-lua').grep_project { fzf_opts = {
        ['--query'] = vim.fn.shellescape(require('fzf-lua.utils').get_visual_selection()) } }
    end, 'Grep selection' },
    ['<leader>D'] = { function()
      require('fzf-lua').grep_project { fzf_opts = {
        ['--query'] = vim.fn.shellescape(require('fzf-lua.utils').get_visual_selection()) }, cwd = vim.fn.expand '%:p:h' }
    end,
      'Grep CWD selection' },
    ['<leader>k'] = { function()
      require('fzf-lua').blines({
        fzf_opts = { ['--query'] = vim.fn.shellescape(require('fzf-lua.utils').get_visual_selection()) } })
    end,
      'Grep buffer selection' },
  }
}

M.lspconfig = {
  plugin = true,
  n = {
    ['gw'] = { '<cmd>FzfLua lsp_document_diagnostics<CR>', 'LSP document diagnostics' },
    ['gW'] = { '<cmd>FzfLua lsp_workspace_diagnostics<cr>', 'LSP workspace diagnostics' },
    ['gf'] = { function() vim.lsp.buf.format { async = true } end, 'Format file' },
    ['gA'] = { '<cmd>FzfLua lsp_code_actions<CR>', 'LSP code action' },
    ['gd'] = { '<cmd>FzfLua lsp_finder<CR>', 'LSP Finder' },
    ['gh'] = {
      function()
        vim.lsp.buf.hover()
      end,
      'LSP hover',
    },
    ['gr'] = {
      function()
        require('nvchad.renamer').open()
      end,
      'LSP rename',
    },
    ['gl'] = {
      function()
        vim.diagnostic.open_float { border = 'rounded' }
      end,
      'Floating diagnostic',
    },
    ['K'] = { '' },
    ['[d'] = {
      function()
        vim.diagnostic.goto_prev { float = { border = 'rounded' }, severity = vim.diagnostic.severity.ERROR }
      end,
      'Goto prev diagnostic',
    },

    [']d'] = {
      function()
        vim.diagnostic.goto_next { float = { border = 'rounded' }, severity = vim.diagnostic.severity.ERROR }
      end,
      'Goto next diagnostic',
    },
  },
  x = {
    ['gA'] = { '<cmd>FzfLua lsp_code_actions<CR>', 'LSP code action' },
    ['gf'] = {
      function()
        vim.lsp.buf.range_formatting()
      end,
      'Format range',
    },
  },
}

M.nvimtree = {
  plugin = true,
  n = {
    ['<C-p>'] = { '<cmd>NvimTreeToggle<CR>', 'Toggle nvimtree' },
  },
}

M.neoclip = {
  n = {
    ['gy'] = { '<cmd>Telescope neoclip<CR>', 'Yank history' },
  },
}

M.gitsigns = {
  plugin = true,
  n = {
    ['<leader>cp'] = {
      function()
        require('gitsigns').preview_hunk()
      end,
      'Preview hunk',
    },

    ['<leader>cr'] = {
      function()
        require('gitsigns').reset_hunk()
      end,
      'Reset hunk',
    },

    [']c'] = {
      function()
        if vim.wo.diff then
          return ']c'
        end
        vim.schedule(function()
          require('gitsigns').next_hunk({ preview = true })
        end)
        return '<Ignore>'
      end,
      'Jump to next hunk',
      opts = { expr = true },
    },

    ['[c'] = {
      function()
        if vim.wo.diff then
          return '[c'
        end
        vim.schedule(function()
          require('gitsigns').prev_hunk({ preview = true })
        end)
        return '<Ignore>'
      end,
      'Jump to prev hunk',
      opts = { expr = true },
    },

    ['<leader>cb'] = {
      function()
        require('gitsigns').toggle_current_line_blame()
      end,
      'Toggle blame line',
    },
    ['<leader>cu'] = {
      function()
        require('gitsigns').reset_buffer()
      end,
      'Reset buffer',
    },
  },
}

M.spectre = {
  n = {
    ['<leader>S'] = { '<cmd>lua require("spectre").toggle()<CR>', 'Toggle Spectre' },
  }
}

M.abolish = {
  n = {
    ['crm'] = { '<Plug>(abolish-coerce-word)m', 'Coerce MixedCase', opts = { noremap = false } },
    ['crs'] = { '<Plug>(abolish-coerce-word)s', 'Coerce snake_case', opts = { noremap = false } },
    ['crc'] = { '<Plug>(abolish-coerce-word)c', 'Coerce camelCase', opts = { noremap = false } },
    ['cru'] = { '<Plug>(abolish-coerce-word)u', 'Coerce UPPER_CASE', opts = { noremap = false } },
    ['cr-'] = { '<Plug>(abolish-coerce-word)-', 'Coerce dash-case', opts = { noremap = false } },
    ['cr.'] = { '<Plug>(abolish-coerce-word).', 'Coerce dot.case', opts = { noremap = false } },
  }
}

-- Disable all default key maps
M.disabled = {}

for _, section in pairs(require('core.mappings')) do
  for mode, keys in pairs(section) do
    if mode == 'n' or mode == 't' or mode == 'v' or mode == 'x' or mode == 'i' then
      for key, _ in pairs(keys) do
        if M.disabled[mode] == nil then
          M.disabled[mode] = {}
        end
        M.disabled[mode][key] = ''
      end
    end
  end
end

return M
