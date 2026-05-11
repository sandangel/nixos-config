-- LazyVim already handles: VimResized, FocusGained checktime, TextYankPost,
-- BufReadPost cursor restore. Only add what's not covered.

-- Warn when file changes on disk (LazyVim silently reloads, user wants a message)
vim.api.nvim_create_autocmd('FileChangedShellPost', {
  group = vim.api.nvim_create_augroup('NeoVimUser', { clear = true }),
  pattern = '*',
  command = 'echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None',
})

-- Hyprland / Niri window navigation commands
vim.api.nvim_create_user_command('HyprNavigate', function(opts)
  local direction = opts.args
  local mappings = { l = 'h', d = 'j', u = 'k', r = 'l' }
  local flag = mappings[direction]
  if vim.fn.winnr() == vim.fn.winnr(flag) then
    vim.fn.jobstart({ 'hyprctl', 'dispatch', 'movefocus', direction })
  else
    vim.cmd('wincmd ' .. flag)
  end
end, { nargs = '?' })

vim.api.nvim_create_user_command('NiriNavigate', function(opts)
  local direction = opts.args
  local mappings = { ['column-left'] = 'h', ['window-down'] = 'j', ['window-up'] = 'k', ['column-right'] = 'l' }
  local flag = mappings[direction]
  if vim.fn.winnr() == vim.fn.winnr(flag) then
    vim.fn.jobstart({ 'niri', 'msg', 'action', 'focus-' .. direction })
  else
    vim.cmd('wincmd ' .. flag)
  end
end, { nargs = '?' })

-- Neovide
vim.api.nvim_create_autocmd('UIEnter', {
  group = vim.api.nvim_create_augroup('neovide', { clear = true }),
  pattern = '*',
  callback = function()
    if vim.g.neovide then
      local map = vim.keymap.set
      map({ 'n', 'i', 'x' }, '<C-+>', '<cmd>lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1<CR>',
        { silent = true, desc = 'Neovide Increase scale' })
      map({ 'n', 'i', 'x' }, '<C-_>', '<cmd>lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.1<CR>',
        { silent = true, desc = 'Neovide Decrease scale' })
      map({ 'n', 'i', 'x' }, '<C-)>', '<cmd>lua vim.g.neovide_scale_factor = 1<CR>',
        { silent = true, desc = 'Neovide Reset scale' })
    end
  end,
})

vim.api.nvim_create_autocmd('FocusGained', {
  group = 'neovide',
  pattern = '*',
  callback = function()
    if vim.g.neovide then
      vim.cmd('silent! !niri msg action move-column-to-first')
    end
  end,
})
