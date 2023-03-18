return {
  'hrsh7th/nvim-cmp',
  event = 'VimEnter',
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-nvim-lua',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'saadparwaiz1/cmp_luasnip',
    'rafamadriz/friendly-snippets',
    'run-at-scale/vscode-terraform-doc-snippets',
    'L3MON4D3/LuaSnip',
    'lukas-reineke/cmp-rg',
    { 'NvChad/ui', branch = 'v2.0' },
  },
  config = function()
    local cmp = require 'cmp'
    dofile(vim.g.base46_cache .. 'cmp')
    local luasnip = require 'luasnip'
    local cmp_ui = require('core.utils').load_config().ui.cmp
    local cmp_style = cmp_ui.style
    local field_arrangement = {
      atom = { 'kind', 'abbr', 'menu' },
      atom_colored = { 'kind', 'abbr', 'menu' },
    }

    local formatting_style = {
      -- default fields order i.e completion word + item.kind + item.kind icons
      fields = field_arrangement[cmp_style] or { 'abbr', 'kind', 'menu' },
      format = function(_, item)
        local icons = require('nvchad_ui.icons').lspkind
        local icon = (cmp_ui.icons and icons[item.kind]) or ''

        if cmp_style == 'atom' or cmp_style == 'atom_colored' then
          icon = ' ' .. icon .. ' '
          item.menu = cmp_ui.lspkind_text and '   (' .. item.kind .. ')' or ''
          item.kind = icon
        else
          icon = cmp_ui.lspkind_text and (' ' .. icon .. ' ') or icon
          item.kind = string.format('%s %s', icon, cmp_ui.lspkind_text and item.kind or '')
        end

        return item
      end,
    }

    local function border(hl_name)
      return {
        { '╭', hl_name },
        { '─', hl_name },
        { '╮', hl_name },
        { '│', hl_name },
        { '╯', hl_name },
        { '─', hl_name },
        { '╰', hl_name },
        { '│', hl_name },
      }
    end

    require('luasnip.loaders.from_vscode').lazy_load()

    local has_words_before = function()
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match '%s' == nil
    end

    cmp.setup {
      window = {
        completion = {
          side_padding = (cmp_style ~= 'atom' and cmp_style ~= 'atom_colored') and 1 or 0,
          winhighlight = 'Normal:CmpPmenu,CursorLine:CmpSel,Search:PmenuSel',
          scrollbar = false,
          border = (cmp_style ~= 'atom' and cmp_style ~= 'atom_colored') and border 'CmpBorder' or nil
        },
        documentation = {
          border = border 'CmpDocBorder',
          winhighlight = 'Normal:CmpDoc',
        },
      },
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      formatting = formatting_style,
      mapping = cmp.mapping.preset.insert({
        ['<c-b>'] = cmp.mapping.scroll_docs( -4),
        ['<c-f>'] = cmp.mapping.scroll_docs(4),
        ['<c-c>'] = cmp.mapping.complete({ reason = 'triggerOnly' }),
        ['<tab>'] = function(fallback)
          if cmp.visible() then
            cmp.confirm { behavior = cmp.ConfirmBehavior.Replace, select = true }
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end,
        ['<s-tab>'] = function(fallback)
          if luasnip.jumpable( -1) then
            luasnip.jump( -1)
          else
            fallback()
          end
        end,
      }),
      sources = cmp.config.sources({
        { name = 'nvim_lua' },
        { name = 'nvim_lsp' },
      }, {
        { name = 'path' },
        {
          name = 'buffer',
          max_item_count = 7,
          option = {
            get_bufnrs = function()
              return vim.api.nvim_list_bufs()
            end,
          },
        },
        {
          name = 'rg',
          keyword_length = 3,
          max_item_count = 7,
        },
        { name = 'luasnip', max_item_count = 7 },
      }),
      completion = {
        completeopt = 'menu,menuone,noinsert',
      },
      experimental = {
        ghost_text = true,
      },
    }
  end
}
