vim.g.neovide_input_use_logo = 1
vim.g.python3_host_prog = vim.env.HOME .. '/.nix-profile/bin/python'

vim.o.breakindent = true
vim.o.expandtab = true
vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
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
vim.o.showtabline = false
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
vim.wo.foldenable = false
vim.wo.foldmethod = 'expr'

vim.opt.dictionary:append '/usr/share/dict/words'
vim.opt.diffopt:append 'vertical,algorithm:patience'
vim.opt.listchars = { tab = '» ', trail = '∙', eol = '¬', nbsp = '▪', precedes = '⟨', extends = '⟩' }
vim.opt.shortmess:append 'm'
vim.opt.whichwrap:append '<,>,[,]'
vim.opt.wildignore:append '.DS_Store,Icon?,*.dmg,*.git,*.pyc,*.o,*.obj,*.so,*.swp,*.zip'

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
  command = 'silent! lua vim.highlight.on_yank({ higroup="IncSearch", timeout=700 })',
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
  vim.keymap.set('n', 'gj', '<c-w>W', opts)

  vim.keymap.set({ 'i', 't' }, '<a-left>', '<c-left>', opts)
  vim.keymap.set({ 'i', 't' }, '<a-right>', '<c-right>', opts)

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
