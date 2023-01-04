return { 'glepnir/lspsaga.nvim', branch = 'main', config = function()
  local lspsaga = require 'lspsaga'
  lspsaga.init_lsp_saga {
    debug_print = false,
    border_style = 'single',
    saga_winblend = 0,
    -- when cusor in saga float window
    -- config these keys to move
    move_in_saga = {
      prev = '<c-p>',
      next = '<c-n>',
    },
    -- Error,Warn,Info,Hint
    diagnostic_header = { '😡', '😥', '😤', '😐' },
    -- code action title icon
    code_action_icon = '💡',
    -- if true can press number to execute the codeaction in codeaction window
    code_action_num_shortcut = true,
    code_action_lightbulb = {
      enable = true,
      enable_in_insert = true,
      cache_code_action = true,
      sign = true,
      update_time = 150,
      sign_priority = 40,
      virtual_text = true,
    },
    max_preview_lines = 100,
    scroll_in_preview = {
      scroll_down = '<c-f>',
      scroll_up = '<c-b>',
    },
    finder_icons = {
      def = ' ',
      imp = ' ',
      ref = ' ',
    },
    finder_request_timeout = 1500,
    finder_action_keys = {
      open = '<cr>',
      vsplit = 's',
      split = 'i',
      tabe = 't',
      quit = '<esc>',
    },
    code_action_keys = {
      quit = '<esc>',
      exec = '<cr>',
    },
    definition_action_keys = {
      edit = '<C-c>o',
      vsplit = '<C-c>v',
      split = '<C-c>i',
      tabe = '<C-c>t',
      quit = '<esc>',
    },
    rename_action_quit = '<esc>',
    rename_in_select = false,
    -- winbar must nightly
    symbol_in_winbar = {
      in_custom = false,
      enable = false,
      separator = '  ',
      show_file = false,
      click_support = false,
    },
    show_outline = {
      win_position = 'right',
      win_with = 'neotree',
      win_width = 40,
      auto_enter = true,
      auto_preview = true,
      virt_text = '┃',
      jump_key = '<cr>',
      auto_refresh = true,
    },
    custom_kind = {},
    server_filetype_map = {},
  }
end }
