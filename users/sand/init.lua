vim.g.mapleader = ' '

vim.o.runtimepath = vim.env.HOME .. '/.dotfiles/users/' .. vim.env.USER .. '/nvim,' .. vim.o.runtimepath

vim.g.neovide_input_use_logo = 1

vim.o.breakindent = true
vim.o.expandtab = true
vim.o.laststatus = 3
vim.o.linebreak = true
vim.o.list = true
vim.o.number = true
vim.o.scrolloff = 5
vim.o.sessionoptions = 'buffers,curdir,folds,skiprtp'
vim.o.shiftround = true
vim.o.shiftwidth = 2
vim.o.showbreak = '> '
vim.o.showcmd = false
vim.o.showmatch = true
vim.o.showmode = false
vim.o.signcolumn = 'yes:2'
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.swapfile = false
vim.o.tabstop = 2
vim.o.termguicolors = true
vim.o.undofile = true
vim.o.updatetime = 250
vim.o.virtualedit = 'all'
vim.o.writebackup = false

vim.opt.shortmess:append 'm'
vim.opt.dictionary:append '/usr/share/dict/words'
vim.opt.diffopt:append 'vertical,algorithm:patience'
vim.opt.whichwrap:append '<,>,[,]'
vim.opt.wildignore:append '.DS_Store,Icon?,*.dmg,*.git,*.pyc,*.o,*.obj,*.so,*.swp,*.zip'
vim.opt.listchars = { tab = '» ', trail = '∙', eol = '¬', nbsp = '▪', precedes = '⟨', extends = '⟩' }

vim.api.nvim_create_augroup('NeoVimUser', { clear = true })
vim.api.nvim_create_autocmd('VimResized', {
  group = 'NeoVimUser',
  pattern = '*',
  command = 'wincmd =',
})
vim.api.nvim_create_autocmd('FocusGained', {
  group = 'NeoVimUser',
  pattern = '*',
  command = "if mode() !~ '\v(c|r.?|!|t)' && getcmdwintype() == '' | checktime | endif",
})
vim.api.nvim_create_autocmd('FileChangedShellPost', {
  group = 'NeoVimUser',
  pattern = '*',
  command = 'echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None',
})

local session_dir = vim.fn.expand '~/.vim/sessions'
if vim.fn.isdirectory(session_dir) == 0 then
  vim.fn.system { 'mkdir', '-p', session_dir }
end

vim.api.nvim_create_autocmd('VimLeave', {
  group = 'NeoVimUser',
  pattern = '*',
  command = "exec 'mks! " .. vim.env.HOME
      .. "/.vim/sessions/'.substitute(substitute(getcwd(), $HOME.'/', '', ''), '/', '.', 'g').'.vim'",
})
vim.api.nvim_create_autocmd('TextYankPost', {
  group = 'NeoVimUser',
  pattern = '*',
  command = 'silent! lua vim.highlight.on_yank()',
})
-- vim.api.nvim_create_autocmd('BufWritePre', {
--   group = 'NeoVimUser',
--   pattern = { '*.js', '*.jsx', '*.md', '*.yaml', '*.yml', '*.ts', '*.tsx', '*.mjs', '*.css', '*.html' },
--   callback = function()
--     local save_pos = vim.fn.getpos '.'
--     vim.cmd 'silent %!prettier --single-quote --stdin-filepath %'
--     vim.fn.setpos('.', save_pos)
--   end
-- })

local function keymap()
  local opts = { silent = true }
  vim.keymap.set('x', '.', '<cmd>norm.<cr>', opts)
  vim.keymap.set('x', 'Q', "<cmd>'<,'>:normal @q<cr>", opts)
  vim.keymap.set('n', 'Q', '@q', opts)

  vim.keymap.set('n', 'gV', 'ggVG', opts)
  vim.keymap.set('n', 'gb', '`[v`]', opts)

  vim.keymap.set('n', '<leader>w', '<cmd>wa<cr>', opts)
  vim.keymap.set('n', '<leader>-', '<cmd>split<cr>', opts)
  vim.keymap.set('n', '<leader>=', '<cmd>vsplit<cr>', opts)
  vim.keymap.set('x', '<leader>y', '"+y', opts)
  vim.keymap.set('x', '<leader>p', '"_d"+P', opts)
  vim.keymap.set('n', '<leader>p', '"+p', opts)

  vim.keymap.set('n', '[<leader>', 'm`O<esc>``', opts)
  vim.keymap.set('n', ']<leader>', 'm`o<esc>``', opts)

  vim.keymap.set('x', 'y', 'y`]', opts)
  vim.keymap.set('x', 'p', '"_dP', opts)
  vim.keymap.set('x', '>', '>gv', opts)
  vim.keymap.set('x', '<', '<gv', opts)
  vim.keymap.set('n', 'vv', 'vg_', opts)
  vim.keymap.set('n', 'gj', '<c-w><c-w>', opts)

  vim.keymap.set('i', '<a-left>', '<c-left>', opts)
  vim.keymap.set('i', '<a-right>', '<c-right>', opts)

  -- vim.keymap.set({ 'n', 'x' }, '<c-h>', '<cmd>wincmd h<cr>', opts)
  -- vim.keymap.set({ 'n', 'x' }, '<c-j>', '<cmd>wincmd j<cr>', opts)
  -- vim.keymap.set({ 'n', 'x' }, '<c-k>', '<cmd>wincmd k<cr>', opts)
  -- vim.keymap.set({ 'n', 'x' }, '<c-l>', '<cmd>wincmd l<cr>', opts)

  local c = 1
  while c <= 99 do
    vim.keymap.set('n', c .. '<leader>', '<cmd>' .. c .. 'b<cr>', opts)
    c = c + 1
  end
end

local function expr_keymap()
  local opts = { silent = true, expr = true }
  vim.keymap.set('n', 'j', [[v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj']], opts)
  vim.keymap.set('n', 'k', [[v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk']], opts)
  vim.keymap.set('i', 'jj', function()
    if vim.fn.pumvisible() == 0 then
      return '<esc>'
    else
      return '<c-e>'
    end
  end, opts)
  vim.keymap.set('i', 'jk', function()
    if vim.fn.pumvisible() == 0 then
      return '<esc>'
    else
      return '<c-e>'
    end
  end, opts)
end

keymap()
expr_keymap()

local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.system {
    'git',
    'clone',
    '--depth',
    '1',
    'https://github.com/wbthomason/packer.nvim',
    install_path,
  }
end

require('packer').startup(function(use)
  use { 'wbthomason/packer.nvim', config = function()
    vim.api.nvim_create_augroup('PackerNvimUser', { clear = true })
    vim.api.nvim_create_autocmd('BufWritePost', {
      group = 'PackerNvimUser',
      pattern = '*.lua',
      callback = function()
        vim.api.nvim_command('luafile ' .. vim.env.MYVIMRC)
        vim.api.nvim_command 'PackerCompile'
      end,
    })
  end }

  use { 'navarasu/onedark.nvim', config = function()
    require('onedark').setup {
      style = 'dark',
      code_style = {
        comments = 'italic',
        keywords = 'italic',
        functions = 'italic',
        strings = 'none',
        variables = 'italic',
      },
    }
    require('onedark').load()
  end }

  use { 'kyazdani42/nvim-web-devicons', config = [[ require 'plugins.configs.icons' ]] }

  use { 'rust-lang/rust.vim', ft = 'rust', setup = function()
    vim.g.rustfmt_autosave = 1
  end }

  use { 'hashivim/vim-terraform', ft = 'terraform', setup = function()
    vim.g.terraform_align = 1
    vim.g.terraform_fold_section = 1
    vim.g.terraform_fmt_on_save = 1
  end }

  use { 'nvim-treesitter/nvim-treesitter', event = 'BufRead', run = ':TSUpdate',
    config = [[ require 'plugins.configs.nvim-treesitter' ]],
  }

  use { 'norcalli/nvim-colorizer.lua', event = 'BufRead', config = [[ require('plugins.configs.others').colorizer() ]] }

  use 'markonm/traces.vim'
  use { 'romainl/vim-cool', setup = function()
    vim.g.CoolTotalMatches = 1
  end }

  use { 'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' },
    config = [[ require 'plugins.configs.gitsigns' ]],
  }

  use { 'akinsho/toggleterm.nvim', keys = { 'n', '<leader>cl' }, config = function()
    local Terminal = require('toggleterm.terminal').Terminal
    local lazygit = Terminal:new {
      cmd = 'lazygit',
      direction = 'float',
      close_on_exit = true,
      float_opts = {
        border = 'single',
      },
      hidden = true,
      on_open = function()
        vim.cmd 'startinsert!'
      end,
    }
    vim.keymap.set('n', '<leader>cl', function()
      lazygit:toggle()
    end, { silent = true })
  end }

  use { 'nvim-neo-tree/neo-tree.nvim', branch = 'v2.x',
    requires = {
      'nvim-lua/plenary.nvim',
      'kyazdani42/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    config = [[ require 'plugins.configs.neo-tree' ]],
  }

  use { 'feline-nvim/feline.nvim', requires = { 'kyazdani42/nvim-web-devicons' },
    config = [[ require 'plugins.configs.statusline' ]],
  }

  use { 'romgrk/barbar.nvim', requires = { 'kyazdani42/nvim-web-devicons' },
    config = [[ require 'plugins.configs.barbar' ]],
  }

  use { 'mbbill/undotree', cmd = 'UndotreeToggle', setup = function()
    vim.g.undotree_WindowLayout = 4
    vim.g.undotree_SplitWidth = 60
    vim.keymap.set('n', '<F2>', '<cmd>UndotreeToggle<cr>', { silent = true })
  end }

  use { 'tyru/open-browser.vim', keys = '<leader>u', config = function()
    local opts = { silent = true, remap = true }
    vim.keymap.set('n', '<leader>u', '<Plug>(openbrowser-smart-search)', opts)
    vim.keymap.set('x', '<leader>u', '<Plug>(openbrowser-smart-search)', opts)
  end }

  use { 'ibhagwan/fzf-lua', requires = { 'kyazdani42/nvim-web-devicons' }, event = 'VimEnter',
    config = [[ require 'plugins.configs.fzf' ]],
  }

  use { 'mhinz/vim-sayonara', cmd = 'Sayonara', setup = function()
    vim.keymap.set('n', '<leader>q', '<cmd>Sayonara<cr>', { silent = true })
  end }

  use { 'windwp/nvim-autopairs', config = [[ require 'plugins.configs.nvim-autopairs' ]] }

  use { 'junegunn/vim-easy-align', config = function()
    local opts = { silent = true, remap = true }
    vim.keymap.set('x', 'ga', '<Plug>(EasyAlign)', opts)
    vim.keymap.set('n', 'ga', '<Plug>(EasyAlign)', opts)
  end }

  use { 'psliwka/vim-smoothie', event = 'VimEnter', setup = function()
    vim.g.smoothie_no_default_mappings = true
    vim.g.smoothie_update_interval = 10
    vim.g.smoothie_speed_linear_factor = 25
    vim.g.smoothie_speed_constant_factor = 25
    vim.g.smoothie_speed_exponentiation_factor = 0.99
    local opts = { silent = true, remap = true }
    vim.keymap.set({ 'x', 'n', 'i' }, '<PageDown>', '<Plug>(SmoothieForwards)', opts)
    vim.keymap.set({ 'x', 'n', 'i' }, '<PageUp>', '<Plug>(SmoothieBackwards)', opts)
  end }

  use { 'ggandor/leap.nvim', config = function()
    require('leap').set_default_keymaps()
  end }

  use { 'knubie/vim-kitty-navigator', run = 'cp ./*.py ~/.config/kitty/' }

  use { 'echasnovski/mini.nvim', config = [[ require 'plugins.configs.mini' ]] }

  use 'wellle/targets.vim'
  use 'matze/vim-move'
  use 'machakann/vim-textobj-delimited'
  use 'tpope/vim-surround'
  use 'tpope/vim-rsi'
  use 'tpope/vim-repeat'
  use 'tpope/vim-abolish'

  use { 'hrsh7th/nvim-cmp',
    requires = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lua',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'dcampos/nvim-snippy',
      'dcampos/cmp-snippy',
    },
    config = function()
      require 'plugins.configs.cmp'
    end,
  }

  use 'ray-x/lsp_signature.nvim'

  use { 'neovim/nvim-lspconfig', config = [[ require 'plugins.configs.lspconfig' ]] }
end)
