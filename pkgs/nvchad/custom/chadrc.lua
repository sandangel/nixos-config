---@type ChadrcConfig
local M = {}

local highlights = require 'custom.highlights'

local function stbufnr()
  return vim.api.nvim_win_get_buf(vim.g.statusline_winid)
end

local function gen_block(icon, txt, sep_l_hlgroup, iconHl_group, txt_hl_group)
  return sep_l_hlgroup ..
      '█' .. iconHl_group .. icon .. ' ' .. txt_hl_group .. ' ' .. txt .. '%#St_sep_r#' .. '█' .. ' %#ST_EmptySpace#'
end

M.ui = {
  theme = 'onedark',
  transparency = true,
  lsp_semantic_tokens = false,
  extended_integrations = {
    'notify',
  },

  statusline = {
    theme = 'minimal',
    separator_style = 'default',
    overriden_modules = function(modules)
      modules[2] = (function()
        local icon = '󰈚'
        local path = vim.api.nvim_buf_get_name(stbufnr())
        local name = (path == '' and 'Empty ') or path:match '([^/\\]+)[/\\]*$'

        if name ~= 'Empty' then
          local devicons_present, devicons = pcall(require, 'nvim-web-devicons')

          if devicons_present then
            local ft_icon = devicons.get_icon(name)
            icon = (ft_icon ~= nil and ft_icon) or icon
          end
        end

        return gen_block(icon, name, '%#St_file_sep#', '%#St_file_bg#', '%#St_file_txt#')
      end)()
      modules[3] = (function()
        if not vim.b[stbufnr()].gitsigns_head or vim.b[stbufnr()].gitsigns_git_status then
          return ''
        end

        local git_status = vim.b[stbufnr()].gitsigns_status_dict

        local added = (git_status.added and git_status.added ~= 0) and
            (gen_block('+', git_status.added, '%#St_lsp_sep#', '%#St_lsp_bg#', '%#St_lsp_txt#')) or ''
        local changed = (git_status.changed and git_status.changed ~= 0) and
            (gen_block('~', git_status.changed, '%#St_Pos_sep#', '%#St_Pos_bg#', '%#St_Pos_txt#')) or
            ''
        local removed = (git_status.removed and git_status.removed ~= 0) and
            (gen_block('-', git_status.removed, '%#St_file_sep#', '%#St_file_bg#', '%#St_file_txt#')) or
            ''
        local branch_name = gen_block('', git_status.head, '%#St_InsertModeSep#', '%#St_InsertMode#',
          '%#St_InsertModeText#')

        return branch_name .. added .. changed .. removed
      end)()
    end,
  },

  hl_override = highlights.override,
}

-- Settings in v3
-- M.base46 = {
--   integrations = {
--     'cmp',
--     'defaults',
--     'devicons',
--     'git',
--     'lsp',
--     'notify',
--     'nvcheatsheet',
--     'nvimtree',
--     'statusline',
--     'syntax',
--     'tbline',
--     'telescope',
--     'treesitter',
--     'whichkey',
--   },
-- }

M.plugins = 'custom.plugins'

-- check core.mappings for table structure
M.mappings = require 'custom.mappings'

-- avoid writing lock file to the config folder because of nix store
M.lazy_nvim = {
  lockfile = vim.fn.stdpath('data') .. '/lazy-lock.json',
  checker = {
    -- automatically check for plugin updates
    enabled = true,
    frequency = 3600 * 2, -- check for updates every 2 hours
  },
}

return M
