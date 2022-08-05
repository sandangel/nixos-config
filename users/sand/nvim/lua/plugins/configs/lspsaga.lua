local lspsaga = require 'lspsaga'
lspsaga.init_lsp_saga {
  border_style = 'single',
  --the range of 0 for fully opaque window (disabled) to 100 for fully
  --transparent background. Values between 0-30 are typically most useful.
  saga_winblend = 0,
  -- when cursor in saga window you config these to move
  move_in_saga = { prev = '<c-p>', next = '<c-n>' },
  -- Error, Warn, Info, Hint
  -- use emoji like
  -- { "🙀", "😿", "😾", "😺" }
  -- or
  -- { "😡", "😥", "😤", "😐" }
  -- and diagnostic_header can be a function type
  -- must return a string and when diagnostic_header
  -- is function type it will have a param `entry`
  -- entry is a table type has these filed
  -- { bufnr, code, col, end_col, end_lnum, lnum, message, severity, source }
  diagnostic_header = { '🙀', '😿', '😾', '😺' },
  -- show diagnostic source
  show_diagnostic_source = true,
  -- add bracket or something with diagnostic source, just have 2 elements
  diagnostic_source_bracket = { '[', ']' },
  -- preview lines of lsp_finder and definition preview
  max_preview_lines = 15,
  -- use emoji lightbulb in default
  code_action_icon = '💡',
  -- if true can press number to execute the codeaction in codeaction window
  code_action_num_shortcut = true,
  -- same as nvim-lightbulb but async
  code_action_lightbulb = {
    enable = true,
    sign = true,
    enable_in_insert = true,
    sign_priority = 20,
    virtual_text = true,
  },
  -- finder icons
  finder_icons = {
    def = '  ',
    ref = ' ',
    link = '  ',
  },
  -- custom finder title winbar function type
  -- param is current word with symbol icon string type
  -- return a winbar format string like `%#CustomFinder#Test%*`
  finder_action_keys = {
    open = '<cr>',
    vsplit = 's',
    split = 'i',
    tabe = 't',
    quit = '<esc>',
    scroll_down = '<c-f>',
    scroll_up = '<c-b>',
  },
  code_action_keys = {
    quit = '<esc>',
    exec = '<cr>',
  },
  rename_action_quit = '<esc>',
  rename_in_select = false,
  definition_preview_icon = '  ',
  -- show symbols in winbar must nightly
  symbol_in_winbar = {
    in_custom = false,
    enable = false,
    separator = '  ',
    show_file = false,
    click_support = false,
  },
  -- show outline
  show_outline = {
    win_position = 'right',
    --set special filetype win that outline window split. like NvimTree neotree
    win_with = 'NvimTree',
    win_width = 40,
    auto_enter = true,
    auto_preview = true,
    virt_text = '┃',
    jump_key = '<cr>',
    -- auto refresh when change buffer
    auto_refresh = true,
  },
  -- if you don't use nvim-lspconfig you must pass your server name and
  -- the related filetypes into this table
  -- like server_filetype_map = { metals = { "sbt", "scala" } }
  server_filetype_map = {},
}
