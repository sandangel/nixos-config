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

vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("lazyvim_autoupdate", { clear = true }),
  callback = function()
    if require("lazy.status").has_updates then
      require("lazy").update({ show = false, })
    end
  end,
})


vim.api.nvim_create_autocmd({ 'BufAdd', 'BufEnter', }, {
  group = vim.api.nvim_create_augroup("buf_modified_filter", { clear = true }),
  callback = function()
    vim.t.bufs = vim.tbl_filter(function(buf)
      return vim.api.nvim_get_option_value('modified', { buf = buf, })
    end, vim.t.bufs)
  end,
})

-- Restore current cursor position
vim.api.nvim_create_autocmd('BufReadPost', {
  group = vim.api.nvim_create_augroup("buf_restore_cursor_position", { clear = true }),
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

vim.api.nvim_create_user_command("HyprNavigate", function(opts)
  local direction = opts.args
  local mappings = { l = 'h', d = 'j', u = 'k', r = 'l' }
  local flag = mappings[direction]
  if vim.fn.winnr() == vim.fn.winnr(flag) then
    vim.fn.jobstart({ 'hyprctl', 'dispatch', 'movefocus', direction })
  else
    vim.cmd('wincmd ' .. flag)
  end
end, { nargs = '?' })

-- Workaround for neovide when attaching to remote server
-- https://github.com/neovide/neovide/issues/1868
vim.api.nvim_create_autocmd("UIEnter", {
  group = vim.api.nvim_create_augroup("neovide", { clear = true }),
  pattern = '*',
  callback = function()
    if vim.g.neovide then
      local map = vim.keymap.set
      map(
        { 'i', 'c', 't' },
        '<C-v>',
        function() vim.api.nvim_paste(vim.fn.getreg('+'), true, -1) end,
        { silent = true, desc = "Neovide Paste in GUI" }
      )
      map({ 'n', 'i', 'x' }, '<C-+>', '<cmd>lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1<CR>', {
        silent = true,
        desc = 'Neovide Increase scale',
      })
      map({ 'n', 'i', 'x' }, '<C-_>', '<cmd>lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.1<CR>', {
        silent = true,
        desc = 'Neovide Decrease scale',
      })
      map({ 'n', 'i', 'x' }, '<C-)>', '<cmd>lua vim.g.neovide_scale_factor = 1<CR>', {
        silent = true,
        desc = 'Neovide Reset scale',
      })
    end
  end
})

--Use FocusGained to make sure Neovide window is created
vim.api.nvim_create_autocmd("FocusGained", {
  group = "neovide",
  pattern = '*',
  callback = function()
    if vim.g.neovide then
      local workspace_id = vim.fn.system('hyprctl activeworkspace -j | jq -r ".id"')
      local neovide_window_id = vim.fn.system('hyprctl clients -j | jq -r "first(.[] | select(.workspace.id == ' ..
        workspace_id .. ') | select(.class == \\"neovide\\")).address"')
      local master_window_id = vim.fn.system('hyprctl clients -j | jq -r "[.[] | select (.workspace.id == ' ..
        workspace_id .. ')] | min_by(.at[1]) | .address"')
      if neovide_window_id ~= master_window_id then
        vim.cmd('silent! !hyprctl dispatch swapwindow u')
      end
    end
  end
})

vim.lsp.log.set_level(vim.log.levels.OFF)
