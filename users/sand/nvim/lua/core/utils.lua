local M = {}

M.load_config = function()
  return {
    ui = {
      hl_add = {},
      hl_override = {},
      changed_themes = {},
      theme_toggle = { 'onedark', 'one_light' },
      theme = 'onedark',
      transparency = false,
      statusline = {
        theme = 'minimal',
        separator_style = 'default',
        overriden_modules = nil,
      },
      telescope = {
        style = 'borderless',
      },
      cmp = {
        icons = true,
        lspkind_text = true,
        style = 'default',
        border_color = 'grey_fg',
        selected_item_bg = 'colored',
      },
      cheatsheet = {
        theme = 'grid',
      },
      lsp = {
        signature = {
          disabled = false,
          silent = true, -- silences 'no signature help available' message from appearing
        },
      },
    }
  }
end

return M
