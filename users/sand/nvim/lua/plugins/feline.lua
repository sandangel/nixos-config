return { 'feline-nvim/feline.nvim', event = 'VimEnter', dependencies = { 'kyazdani42/nvim-web-devicons' },
  config = function()
    local colors = require('configs.colors').get()
    local lsp = require 'feline.providers.lsp'
    local lsp_severity = vim.diagnostic.severity

    local icon_styles = {
      default = {
        left = '',
        right = ' ',
        main_icon = '  ',
        vi_mode_icon = ' ',
        position_icon = ' ',
      },
      arrow = {
        left = '',
        right = '',
        main_icon = '  ',
        vi_mode_icon = ' ',
        position_icon = ' ',
      },

      block = {
        left = ' ',
        right = ' ',
        main_icon = '   ',
        vi_mode_icon = '  ',
        position_icon = '  ',
      },

      round = {
        left = '',
        right = '',
        main_icon = '  ',
        vi_mode_icon = ' ',
        position_icon = ' ',
      },

      slant = {
        left = ' ',
        right = ' ',
        main_icon = '  ',
        vi_mode_icon = ' ',
        position_icon = ' ',
      },
    }

    local mode_colors = {
      ['n'] = { 'NORMAL', colors.red },
      ['no'] = { 'N-PENDING', colors.red },
      ['i'] = { 'INSERT', colors.dark_purple },
      ['ic'] = { 'INSERT', colors.dark_purple },
      ['t'] = { 'TERMINAL', colors.green },
      ['v'] = { 'VISUAL', colors.cyan },
      ['V'] = { 'V-LINE', colors.cyan },
      [''] = { 'V-BLOCK', colors.cyan },
      ['R'] = { 'REPLACE', colors.orange },
      ['Rv'] = { 'V-REPLACE', colors.orange },
      ['s'] = { 'SELECT', colors.nord_blue },
      ['S'] = { 'S-LINE', colors.nord_blue },
      [''] = { 'S-BLOCK', colors.nord_blue },
      ['c'] = { 'COMMAND', colors.pink },
      ['cv'] = { 'COMMAND', colors.pink },
      ['ce'] = { 'COMMAND', colors.pink },
      ['r'] = { 'PROMPT', colors.teal },
      ['rm'] = { 'MORE', colors.teal },
      ['r?'] = { 'CONFIRM', colors.teal },
      ['!'] = { 'SHELL', colors.green },
    }

    local config = {
      -- show short statusline on small screens
      shortline = true,
      -- default, round , slant , block , arrow
      style = 'default',
    }
    -- statusline style
    local statusline_style = icon_styles[config.style]

    -- show short statusline on small screens
    local shortline = config.shortline == false and true

    -- Initialize the components table
    local components = {
      active = {},
    }

    local default = {}

    default.main_icon = {
      provider = statusline_style.main_icon,

      hl = {
        fg = colors.statusline_bg,
        bg = colors.nord_blue,
      },

      right_sep = {
        str = statusline_style.right,
        hl = {
          fg = colors.nord_blue,
          bg = colors.lightbg,
        },
      },
    }

    default.file_name = {
      provider = function()
        local filename = vim.fn.expand '%:t'
        local extension = vim.fn.expand '%:e'
        local icon = require('nvim-web-devicons').get_icon(filename, extension)
        local status = ''
        if icon == nil then
          icon = ' '
          return icon
        end
        local buf = vim.api.nvim_get_current_buf()
        if vim.bo[buf].modified then
          status = '[+]'
        end
        return status .. ' ' .. icon .. ' ' .. filename .. ' '
      end,
      enabled = shortline or function(winid)
        return vim.api.nvim_win_get_width(tonumber(winid) or 0) > 70
      end,
      hl = {
        fg = colors.vibrant_green,
        bg = colors.lightbg,
      },

      right_sep = { str = statusline_style.right, hl = { fg = colors.lightbg, bg = colors.lightbg2 } },
    }

    default.dir_name = {
      provider = function()
        local dir_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
        return ' ' .. dir_name .. ' '
      end,

      enabled = shortline or function(winid)
        return vim.api.nvim_win_get_width(tonumber(winid) or 0) > 80
      end,

      hl = {
        fg = colors.cyan,
        bg = colors.lightbg2,
      },
      right_sep = {
        str = statusline_style.right,
        hi = {
          fg = colors.lightbg2,
          bg = colors.statusline_bg,
        },
      },
    }

    default.diff = {
      add = {
        provider = 'git_diff_added',
        hl = {
          fg = colors.green,
          bg = colors.statusline_bg,
        },
        icon = '   ',
      },
      change = {
        provider = 'git_diff_changed',
        hl = {
          fg = colors.yellow,
          bg = colors.statusline_bg,
        },
        icon = '  ',
      },
      remove = {
        provider = 'git_diff_removed',
        hl = {
          fg = colors.red,
          bg = colors.statusline_bg,
        },
        icon = '  ',
      },
    }

    default.git_branch = {
      provider = 'git_branch',
      enabled = shortline or function(winid)
        return vim.api.nvim_win_get_width(tonumber(winid) or 0) > 70
      end,
      hl = {
        fg = colors.sun,
        bg = colors.statusline_bg,
      },
      icon = ' ',
    }

    default.diagnostic = {
      error = {
        provider = 'diagnostic_errors',
        enabled = function()
          return lsp.diagnostics_exist(lsp_severity.ERROR)
        end,

        hl = { fg = colors.red },
        icon = '  ',
      },
      warning = {
        provider = 'diagnostic_warnings',
        enabled = function()
          return lsp.diagnostics_exist(lsp_severity.WARN)
        end,
        hl = { fg = colors.yellow },
        icon = '  ',
      },
      hint = {
        provider = 'diagnostic_hints',
        enabled = function()
          return lsp.diagnostics_exist(lsp_severity.HINT)
        end,
        hl = { fg = colors.blue },
        icon = '  ',
      },
      info = {
        provider = 'diagnostic_info',
        enabled = function()
          return lsp.diagnostics_exist(lsp_severity.INFO)
        end,
        hl = { fg = colors.green },
        icon = '  ',
      },
    }

    default.lsp_progress = {
      provider = function()
        local Lsp = vim.lsp.util.get_progress_messages()[1]

        if Lsp then
          local msg = Lsp.message or ''
          local percentage = Lsp.percentage or 0
          local title = Lsp.title or ''
          local spinners = {
            '',
            '',
            '',
          }

          local success_icon = {
            '',
            '',
            '',
          }

          local ms = vim.loop.hrtime() / 1000000
          local frame = math.floor(ms / 120) % #spinners

          if percentage >= 70 then
            return string.format(' %%<%s %s %s (%s%%%%) ', success_icon[frame + 1], title, msg, percentage)
          end

          return string.format(' %%<%s %s %s (%s%%%%) ', spinners[frame + 1], title, msg, percentage)
        end

        return ''
      end,
      enabled = shortline or function(winid)
        return vim.api.nvim_win_get_width(tonumber(winid) or 0) > 80
      end,
      hl = { fg = colors.vibrant_green },
    }

    default.lsp_icon = {
      provider = function()
        if next(vim.lsp.get_active_clients()) ~= nil then
          return '  LSP'
        else
          return ''
        end
      end,
      enabled = shortline or function(winid)
        return vim.api.nvim_win_get_width(tonumber(winid) or 0) > 70
      end,
      hl = { fg = colors.vibrant_green, bg = colors.statusline_bg },
    }

    default.empty_space = {
      provider = ' ' .. statusline_style.left,
      hl = {
        fg = colors.one_bg2,
        bg = colors.statusline_bg,
      },
    }

    default.empty_spaceColored = {
      provider = statusline_style.left,
      hl = function()
        return {
          fg = mode_colors[vim.fn.mode()][2],
          bg = colors.one_bg2,
        }
      end,
    }

    default.mode_icon = {
      provider = statusline_style.vi_mode_icon,
      hl = function()
        return {
          fg = colors.statusline_bg,
          bg = mode_colors[vim.fn.mode()][2],
        }
      end,
    }

    default.empty_space2 = {
      provider = function()
        return ' ' .. mode_colors[vim.fn.mode()][1] .. ' '
      end,
      hl = function()
        return {
          fg = mode_colors[vim.fn.mode()][2],
          bg = colors.one_bg,
        }
      end,
    }

    default.separator_right = {
      provider = statusline_style.left,
      enabled = shortline or function(winid)
        return vim.api.nvim_win_get_width(tonumber(winid) or 0) > 90
      end,
      hl = {
        fg = colors.grey,
        bg = colors.one_bg,
      },
    }

    default.separator_right2 = {
      provider = statusline_style.left,
      enabled = shortline or function(winid)
        return vim.api.nvim_win_get_width(tonumber(winid) or 0) > 90
      end,
      hl = {
        fg = colors.green,
        bg = colors.grey,
      },
    }

    default.position_icon = {
      provider = statusline_style.position_icon,
      enabled = shortline or function(winid)
        return vim.api.nvim_win_get_width(tonumber(winid) or 0) > 90
      end,
      hl = {
        fg = colors.black,
        bg = colors.green,
      },
    }

    default.current_line = {
      provider = function()
        local current_line = vim.fn.line '.'
        local total_line = vim.fn.line '$'

        if current_line == 1 then
          return ' Top '
        elseif current_line == vim.fn.line '$' then
          return ' Bot '
        end
        local result, _ = math.modf((current_line / total_line) * 100)
        return ' ' .. result .. '%% '
      end,

      enabled = shortline or function(winid)
        return vim.api.nvim_win_get_width(tonumber(winid) or 0) > 90
      end,

      hl = {
        fg = colors.green,
        bg = colors.one_bg,
      },
    }

    default.left = {}
    default.middle = {}
    default.right = {}

    -- left
    table.insert(default.left, default.main_icon)
    table.insert(default.left, default.file_name)
    table.insert(default.left, default.dir_name)
    table.insert(default.left, default.git_branch)
    table.insert(default.left, default.diff.add)
    table.insert(default.left, default.diff.change)
    table.insert(default.left, default.diff.remove)

    -- middle
    table.insert(default.middle, default.lsp_progress)

    -- right
    table.insert(default.right, default.diagnostic.error)
    table.insert(default.right, default.diagnostic.warning)
    table.insert(default.right, default.diagnostic.hint)
    table.insert(default.right, default.diagnostic.info)
    table.insert(default.right, default.lsp_icon)
    table.insert(default.right, default.empty_space)
    table.insert(default.right, default.empty_spaceColored)
    table.insert(default.right, default.mode_icon)
    table.insert(default.right, default.empty_space2)
    table.insert(default.right, default.separator_right)
    table.insert(default.right, default.separator_right2)
    table.insert(default.right, default.position_icon)
    table.insert(default.right, default.current_line)

    components.active[1] = default.left
    components.active[2] = default.middle
    components.active[3] = default.right

    require('feline').setup {
      theme = {
        bg = colors.statusline_bg,
        fg = colors.fg,
      },
      components = components,
      disable = {
        filetypes = {
          '^NvimTree$',
          '^neo-tree$',
          '^packer$',
          '^startify$',
          '^fugitive$',
          '^fugitiveblame$',
          '^qf$',
          '^help$',
        },
        buftypes = {
          '^terminal$',
          '^nofile$',
        },
        bufnames = {},
      },
    }

  end
}
