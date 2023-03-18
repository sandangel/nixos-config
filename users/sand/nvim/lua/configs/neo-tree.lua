return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'main',
  event = 'VimEnter',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
  },
  config = function()
    vim.api.nvim_create_augroup('NeoTreeUser', { clear = true })

    vim.api.nvim_create_autocmd({ 'FocusLost' }, {
      group = 'NeoTreeUser',
      pattern = '*',
      callback = function()
        if vim.bo.filetype == 'neo-tree' then
          vim.cmd 'wincmd w'
        end
      end,
    })

    vim.api.nvim_create_autocmd({ 'FocusGained' }, {
      group = 'NeoTreeUser',
      pattern = '*',
      callback = function()
        require('neo-tree.sources.manager').refresh 'filesystem'
      end,
    })

    local config = {
      -- If a user has a sources list it will replace this one.
      -- Only sources listed here will be loaded.
      -- You can also add an external source by adding it's name to this list.
      -- The name used here must be the same name you would use in a require() call.
      sources = {
        'filesystem',
      },
      add_blank_line_at_top = false, -- Add a blank line at the top of the tree.
      close_if_last_window = false, -- Close Neo-tree if it is the last window left in the tab
      -- popup_border_style is for input and confirmation dialogs.
      -- Configurtaion of floating window is done in the individual source sections.
      -- "NC" is a special style that works well with NormalNC set
      close_floats_on_escape_key = true,
      default_source = 'filesystem',
      enable_diagnostics = false,
      enable_git_status = true,
      enable_modified_markers = true, -- Show markers for files with unsaved changes.
      enable_refresh_on_write = true, -- Refresh the tree when a file is written. Only used if `use_libuv_file_watcher` is false.
      git_status_async = true,
      -- These options are for people with VERY large git repos
      git_status_async_options = {
        batch_size = 1000, -- how many lines of git status results to process at a time
        batch_delay = 10, -- delay in ms between batches. Spreads out the workload to let other processes run.
        max_lines = 10000, -- How many lines of git status results to process. Anything after this will be dropped.
        -- Anything before this will be used. The last items to be processed are the untracked files.
      },
      hide_root_node = false, -- Hide the root node.
      retain_hidden_root_indent = false, -- IF the root node is hidden, keep the indentation anyhow.
      -- This is needed if you use expanders because they render in the indent.
      log_level = 'info', -- "trace", "debug", "info", "warn", "error", "fatal"
      log_to_file = false, -- true, false, "/path/to/file.log", use :NeoTreeLogs to show the file
      open_files_in_last_window = true, -- false = open files in top left window
      popup_border_style = 'rounded', -- "double", "none", "rounded", "shadow", "single" or "solid"
      resize_timer_interval = 500, -- in ms, needed for containers to redraw right aligned and faded content
      -- set to -1 to disable the resize timer entirely
      --                           -- NOTE: this will speed up to 50 ms for 1 second following a resize
      sort_case_insensitive = false, -- used when sorting files and directories in the tree
      sort_function = nil, -- uses a custom function for sorting files and directories in the tree
      use_popups_for_input = true, -- If false, inputs will use vim.ui.input() instead of custom floats.
      use_default_mappings = false,
      default_component_configs = {
        container = {
          enable_character_fade = true,
          width = '100%',
          right_padding = 2,
        },
        indent = {
          indent_size = 2,
          padding = 2,
          -- indent guides
          with_markers = true,
          indent_marker = '│',
          last_indent_marker = '└',
          highlight = 'NeoTreeIndentMarker',
          -- expander config, needed for nesting files
          with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
          expander_collapsed = '',
          expander_expanded = '',
          expander_highlight = 'NeoTreeExpander',
        },
        icon = {
          folder_closed = '',
          folder_open = '',
          folder_empty = '',
          -- The next two settings are only a fallback, if you use nvim-web-devicons and configure default icons there
          -- then these will never be used.
          default = '',
          highlight = 'NeoTreeFileIcon'
        },
        modified = {
          symbol = '[+]',
          highlight = 'NeoTreeModified',
        },
        name = {
          trailing_slash = false,
          use_git_status_colors = true,
          highlight = 'NeoTreeFileName',
        },
        git_status = {
          symbols = {
            -- Change type
            added     = '✚', -- NOTE: you can set any of these to an empty string to not show them
            deleted   = '',
            modified  = '',
            renamed   = '➜',
            -- Status type
            untracked = '★',
            ignored   = '◌',
            unstaged  = '',
            staged    = '✓',
            conflict  = '',
          },
          align = 'right',
        },
      },
      renderers = {
        directory = {
          { 'indent' },
          { 'icon' },
          { 'current_filter' },
          {
            'container',
            content = {
              { 'name',        zindex = 10 },
              -- {
              --   "symlink_target",
              --   zindex = 10,
              --   highlight = "NeoTreeSymbolicLinkTarget",
              -- },
              { 'clipboard',   zindex = 10 },
              { 'diagnostics', errors_only = true, zindex = 20,     align = 'right',          hide_when_expanded = true },
              { 'git_status',  zindex = 20,        align = 'right', hide_when_expanded = true },
            },
          },
        },
        file = {
          { 'indent' },
          { 'icon' },
          {
            'container',
            content = {
              {
                'name',
                zindex = 10
              },
              -- {
              --   "symlink_target",
              --   zindex = 10,
              --   highlight = "NeoTreeSymbolicLinkTarget",
              -- },
              { 'clipboard',   zindex = 10 },
              { 'bufnr',       zindex = 10 },
              { 'modified',    zindex = 20, align = 'right' },
              { 'diagnostics', zindex = 20, align = 'right' },
              { 'git_status',  zindex = 20, align = 'right' },
            },
          },
        },
        message = {
          { 'indent', with_markers = false },
          { 'name',   highlight = 'NeoTreeMessage' },
        },
        terminal = {
          { 'indent' },
          { 'icon' },
          { 'name' },
          { 'bufnr' }
        }
      },
      nesting_rules = {},
      window = { -- see https://github.com/MunifTanjim/nui.nvim/tree/main/lua/nui/popup for
        -- possible options. These can also be functions that return these options.
        position = 'left', -- left, right, top, bottom, float, current
        width = 40, -- applies to left and right positions
        height = 15, -- applies to top and bottom positions
        auto_expand_width = false, -- expand the window when file exceeds the window width. does not work with position = "float"
        popup = { -- settings that apply to float position only
          size = {
            height = '80%',
            width = '50%',
          },
          position = '50%', -- 50% means center it
          -- you can also specify border here, if you want a different setting from
          -- the global popup_border_style.
        },
        same_level = true, -- Create and paste/move files/directories on the same level as the directory under cursor (as opposed to within the directory under cursor).
        insert_as = 'sibling', -- Affects how nodes get inserted into the tree during creation/pasting/moving of files if the node under the cursor is a directory:
        -- "child":   Insert nodes as children of the directory under cursor.
        -- "sibling": Insert nodes  as siblings of the directory under cursor.
        -- Mappings for tree window. See `:h neo-tree-mappings` for a list of built-in commands.
        -- You can also create your own commands by providing a function instead of a string.
        mapping_options = {
          noremap = true,
          nowait = true,
        },
        mappings = {
          ['o'] = 'open',
          ['<cr>'] = 'open',
          ['P'] = { 'toggle_preview', config = { use_float = true } },
          ['S'] = 'open_split',
          ['s'] = 'open_vsplit',
          ['t'] = 'open_tabnew',
          ['w'] = 'open_with_window_picker',
          ['C'] = 'close_node',
          ['z'] = 'close_all_nodes',
          ['R'] = 'refresh',
          ['a'] = {
            'add',
            -- some commands may take optional config options, see `:h neo-tree-mappings` for details
            config = {
              show_path = 'relative' -- "none", "relative", "absolute"
            }
          },
          ['A'] = 'add_directory', -- also accepts the config.show_path and config.insert_as options.
          ['d'] = 'delete',
          ['r'] = 'rename',
          ['y'] = function(state)
            local path = state.tree:get_node():get_id()
            print('Copied to clipboard: ' .. vim.fn.fnameescape(vim.fn.fnamemodify(path, ':~:.')))
            vim.fn.system('wl-copy', vim.fn.fnameescape(vim.fn.fnamemodify(path, ':~:.')))
          end,
          ['Y'] = function(state)
            local path = state.tree:get_node():get_id()
            print('Copied to clipboard: ' .. vim.fn.fnameescape(path))
            vim.fn.system('wl-copy', vim.fn.fnameescape(path))
          end,
          ['c'] = 'copy_to_clipboard',
          ['x'] = 'cut_to_clipboard',
          ['p'] = 'paste_from_clipboard',
          ['e'] = 'toggle_auto_expand_width',
          ['q'] = 'close_window',
          ['?'] = 'show_help',
        },
      },
      filesystem = {
        commands = {
          delete = function(state)
            local inputs = require 'neo-tree.ui.inputs'
            local path = state.tree:get_node().path
            local msg = 'Are you sure you want to delete ' .. path
            inputs.confirm(msg, function(confirmed)
              if not confirmed then return end
              vim.fn.system { 'trash', vim.fn.fnameescape(path) }
              require('neo-tree.sources.manager').refresh(state.name)
            end)
          end,
        },
        window = {
          mappings = {
            ['H'] = 'toggle_hidden',
            ['/'] = 'fuzzy_finder',
            ['<esc>'] = 'clear_filter',
            ['h'] = 'navigate_up',
            ['l'] = 'set_root',
            ['[c'] = 'prev_git_modified',
            [']c'] = 'next_git_modified',
          }
        },
        async_directory_scan = 'auto', -- "auto"   means refreshes are async, but it's synchronous when called from the Neotree commands.
        -- "always" means directory scans are always async.
        -- "never"  means directory scans are never async.
        scan_mode = 'shallow', -- "shallow": Don't scan into directories to detect possible empty directory a priori
        -- "deep": Scan into directories to detect empty or grouped empty directories a priori.
        bind_to_cwd = true, -- true creates a 2-way binding between vim's cwd and neo-tree's root
        cwd_target = {
          sidebar = 'tab', -- sidebar is when position = left or right
          current = 'window' -- current is when position = current
        },
        -- The renderer section provides the renderers that will be used to render the tree.
        --   The first level is the node type.
        --   For each node type, you can specify a list of components to render.
        --       Components are rendered in the order they are specified.
        --         The first field in each component is the name of the function to call.
        --         The rest of the fields are passed to the function as the "config" argument.
        filtered_items = {
          visible = false, -- when true, they will just be displayed differently than normal items
          force_visible_in_empty_folder = false, -- when true, hidden files will be shown if the root folder is otherwise empty
          show_hidden_count = true, -- when true, the number of hidden items in each folder will be shown as the last entry
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_hidden = true, -- only works on Windows for hidden files/directories
          hide_by_name = {
            '.DS_Store',
            'thumbs.db',
            'node_modules',
            '.git',
          },
          hide_by_pattern = { -- uses glob style patterns
            --"*.meta",
            --"*/src/*/tsconfig.json"
          },
          always_show = { -- remains visible even if other settings would normally hide it
            --".gitignored",
          },
          never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
            '.DS_Store',
            'thumbs.db',
            '.git',
          },
          never_show_by_pattern = { -- uses glob style patterns
            --".null-ls_*",
          },
        },
        find_by_full_path_words = false, -- `false` means it only searches the tail of a path.
        -- `true` will change the filter into a full path
        -- search with space as an implicit ".*", so
        -- `fi init`
        -- will match: `./sources/filesystem/init.lua
        --find_command = "fd", -- this is determined automatically, you probably don't need to set it
        --find_args = {  -- you can specify extra args to pass to the find command.
        --  fd = {
        --  "--exclude", ".git",
        --  "--exclude",  "node_modules"
        --  }
        --},
        ---- or use a function instead of list of strings
        --find_args = function(cmd, path, search_term, args)
        --  if cmd ~= "fd" then
        --    return args
        --  end
        --  --maybe you want to force the filter to always include hidden files:
        --  table.insert(args, "--hidden")
        --  -- but no one ever wants to see .git files
        --  table.insert(args, "--exclude")
        --  table.insert(args, ".git")
        --  -- or node_modules
        --  table.insert(args, "--exclude")
        --  table.insert(args, "node_modules")
        --  --here is where it pays to use the function, you can exclude more for
        --  --short search terms, or vary based on the directory
        --  if string.len(search_term) < 4 and path == "/home/cseickel" then
        --    table.insert(args, "--exclude")
        --    table.insert(args, "Library")
        --  end
        --  return args
        --end,
        group_empty_dirs = false, -- when true, empty folders will be grouped together
        search_limit = 50, -- max number of search results when using filters
        follow_current_file = true, -- This will find and focus the file in the active buffer every time
        -- the current file is changed while the tree is open.
        hijack_netrw_behavior = 'open_default', -- netrw disabled, opening a directory opens neo-tree
        -- in whatever position is specified in window.position
        -- "open_current",-- netrw disabled, opening a directory opens within the
        -- window like netrw would, regardless of window.position
        -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
        use_libuv_file_watcher = false, -- This will use the OS level file watchers to detect changes
        -- instead of relying on nvim autocmd events.
      },
    }

    vim.g.neo_tree_remove_legacy_commands = 1
    require('neo-tree').setup(config)
    vim.keymap.set('n', '<c-p>', '<cmd>Neotree toggle reveal<cr>', { silent = true })
  end
}
