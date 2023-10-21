local M = {}

M.treesitter = {
  ensure_installed = 'all',
}

M.mason = {
  ensure_installed = {
    'lua-language-server',
    'rnix-lsp',
    'ruff-lsp',
    'ruff',
    'pyright',
    'typescript-language-server',
    'json-lsp',
    'dockerfile-language-server',
    'docker-compose-language-service',
    'yaml-language-server',
    'flake8',
    'isort',
    'actionlint',
    'black',
    'gopls',
    'lua-language-server',
    'mypy',
    'pylint',
    'python-lsp-server',
    'rust-analyzer',
    'terraform-ls',
    'tflint',
    'tfsec',
    'yamlfmt',
    'yamllint',
  },
}

-- git support in nvimtree
M.nvimtree = {
  on_attach = function(bufnr)
    local api = require 'nvim-tree.api'
    local notify = require 'nvim-tree.notify'
    local utils = require 'nvim-tree.utils'
    local core = require 'nvim-tree.core'

    local function wrap_node(f)
      return function(node, ...)
        node = node or require('nvim-tree.lib').get_node_at_cursor()
        f(node, ...)
      end
    end

    local function copy_to_clipboard(content)
      vim.fn.setreg('"', content)
      -- setreg * and + does not work
      vim.api.nvim_command('silent !echo -n "' .. content .. '" | wl-copy')
      return notify.info(string.format('Copied %s to system clipboard!', content))
    end

    local function copy_filename(node)
      return copy_to_clipboard(node.name)
    end

    local function copy_path(node)
      local absolute_path = node.absolute_path
      local relative_path = utils.path_relative(absolute_path, core.get_cwd())
      local content = node.nodes ~= nil and utils.path_add_trailing(relative_path) or relative_path
      return copy_to_clipboard(content)
    end

    local function copy_absolute_path(node)
      local absolute_path = node.absolute_path
      local content = node.nodes ~= nil and utils.path_add_trailing(absolute_path) or absolute_path
      return copy_to_clipboard(content)
    end

    local function opts(desc)
      return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    vim.keymap.set('n', 'h', api.tree.change_root_to_parent, opts 'Up')
    vim.keymap.set('n', 'l', api.tree.change_root_to_node, opts 'CD')
    vim.keymap.set('n', 'd', api.fs.trash, opts 'Trash')
    vim.keymap.set('n', 'D', api.fs.remove, opts 'Delete')
    vim.keymap.set('n', 'I', api.tree.toggle_gitignore_filter, opts 'Toggle Git Ignore')
    vim.keymap.set('n', 'H', api.tree.toggle_hidden_filter, opts 'Toggle Dotfiles')
    vim.keymap.set('n', 'R', api.tree.reload, opts 'Refresh')
    vim.keymap.set('n', 'a', api.fs.create, opts 'Create')
    vim.keymap.set('n', 'r', api.fs.rename, opts 'Rename')
    vim.keymap.set('n', 'x', api.fs.cut, opts 'Cut')
    vim.keymap.set('n', 'c', api.fs.copy.node, opts 'Copy')
    vim.keymap.set('n', 'p', api.fs.paste, opts 'Paste')
    vim.keymap.set('n', '<CR>', api.node.open.edit, opts 'Open')
    vim.keymap.set('n', 'o', api.node.open.edit, opts 'Open')
    vim.keymap.set('n', 'x', api.fs.cut, opts 'Cut')
    vim.keymap.set('n', 'c', api.fs.copy.node, opts 'Copy')
    vim.keymap.set('n', 'p', api.fs.paste, opts 'Paste')
    vim.keymap.set('n', 'y', wrap_node(copy_filename), opts 'Copy Name')
    vim.keymap.set('n', 'Y', wrap_node(copy_path), opts 'Copy Relative Path')
    vim.keymap.set('n', 'gy', wrap_node(copy_absolute_path), opts 'Copy Absolute Path')
    vim.keymap.set('n', '[c', api.node.navigate.git.prev, opts 'Prev Git')
    vim.keymap.set('n', ']c', api.node.navigate.git.next, opts 'Next Git')
    vim.keymap.set('n', '.', api.node.run.system, opts 'Run System')
    vim.keymap.set('n', 'f', api.live_filter.start, opts 'Filter')
    vim.keymap.set('n', 'F', api.live_filter.clear, opts 'Clean Filter')
    vim.keymap.set('n', 'q', api.tree.close, opts 'Close')
    vim.keymap.set('n', '?', api.tree.toggle_help, opts 'Help')
  end,
  git = {
    enable = true,
  },
  renderer = {
    highlight_git = true,
    icons = {
      git_placement = 'after',
      show = {
        git = true,
      },
      glyphs = {
        folder = {
          default = '',
          open = '',
          empty = '',
          empty_open = '',
          symlink = '',
          symlink_open = '',
        },
      }
    },
  },
}

return M
