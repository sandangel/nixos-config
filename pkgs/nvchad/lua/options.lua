vim.o.breakindent = true
vim.o.clipboard = ''
vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
vim.o.linebreak = true
vim.o.list = true
vim.o.scrolloff = 5
vim.o.sessionoptions = 'buffers,curdir,folds,skiprtp'
vim.o.shiftround = true
vim.o.showbreak = '> '
vim.o.showcmd = false
vim.o.showmatch = true
vim.o.signcolumn = 'yes:2'
vim.o.swapfile = false
vim.o.virtualedit = 'all'
vim.o.writebackup = false
vim.wo.foldenable = false
vim.wo.foldmethod = 'expr'

vim.opt.dictionary:append '/usr/share/dict/words'
vim.opt.diffopt:append 'vertical,algorithm:patience'
vim.opt.listchars = { tab = '» ', trail = '∙', eol = '¬', nbsp = '▪', precedes = '⟨', extends = '⟩', }
vim.opt.wildignore:append '.DS_Store,Icon?,*.dmg,*.git,*.pyc,*.o,*.obj,*.so,*.swp,*.zip'

vim.api.nvim_create_augroup('NeoVimUser', { clear = true, })
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

local session_dir = vim.env.HOME .. '/.vim/sessions'
if vim.fn.isdirectory(session_dir) == 0 then
  vim.fn.system { 'mkdir', '-p', session_dir, }
end

vim.api.nvim_create_autocmd('VimLeave', {
  group = 'NeoVimUser',
  pattern = '*',
  command = "exec 'mks! " ..
      vim.env.HOME .. "/.vim/sessions/'.substitute(substitute(getcwd(), $HOME.'/', '', ''), '/', '.', 'g').'.vim'",
})
vim.api.nvim_create_autocmd('TextYankPost', {
  group = 'NeoVimUser',
  pattern = '*',
  command = 'silent! lua vim.highlight.on_yank({ higroup="IncSearch", timeout=700 })',
})

local enable_providers = {
  'python3_provider',
  'node_provider',
}

for _, plugin in pairs(enable_providers) do
  vim.g['loaded_' .. plugin] = nil
  vim.cmd('runtime ' .. plugin)
end

vim.api.nvim_create_autocmd({ 'BufAdd', 'BufEnter', }, {
  callback = function()
    vim.t.bufs = vim.tbl_filter(function(buf)
      return vim.api.nvim_get_option_value('modified', { buf = buf, })
    end, vim.t.bufs)
  end,
})

-- Restore current cursor position
vim.api.nvim_create_autocmd('BufReadPost', {
  pattern = '*',
  callback = function()
    local line = vim.fn.line "'\""
    if
        line > 1
        and line <= vim.fn.line '$'
        and vim.bo.filetype ~= 'commit'
        and vim.fn.index({ 'xxd', 'gitrebase', }, vim.bo.filetype) == -1
    then
      vim.cmd 'normal! g`"'
    end
  end,
})

if vim.g.neovide then
  vim.opt.guifont = { 'Comic Code Ligatures', 'Symbols Nerd Font', ':h11', }
  vim.g.neovide_transparency = 0.8
  vim.g.neovide_padding_top = 10
end
