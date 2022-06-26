local lspsaga = require 'lspsaga'
lspsaga.init_lsp_saga {
  debug = false,
  -- Error,Warn,Info,Hint
  diagnostic_header = { ' ', ' ', ' ', ' ' },
  show_diagnostic_source = true,
  diagnostic_source_bracket = { '❴', '❵' },
  -- code action title icon
  code_action_icon = '💡',
  -- if true can press number to execute the codeaction in codeaction window
  code_action_num_shortcut = true,
  code_action_lightbulb = {
    enable = true,
    sign = true,
    sign_priority = 40,
    virtual_text = true,
  },
  finder_separator = '  ',
  max_preview_lines = 10,
  finder_action_keys = {
    open = '<cr>',
    vsplit = 's',
    split = 'i',
    quit = '<esc>',
    scroll_down = '<c-f>',
    scroll_up = '<c-b>',
  },
  code_action_keys = {
    quit = '<esc>',
    exec = '<cr>',
  },
  rename_action_quit = '<esc>',
  definition_preview_icon = '  ',
  border_style = 'single',
  server_filetype_map = {}
}
