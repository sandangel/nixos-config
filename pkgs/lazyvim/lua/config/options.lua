-- Only overrides of LazyVim defaults or settings LazyVim doesn't set

vim.o.breakindent = true
vim.o.softtabstop = 2
vim.o.showbreak = '> '
vim.o.showcmd = false
vim.o.showmatch = true
vim.o.relativenumber = false  -- LazyVim enables this; NvChad didn't
vim.o.swapfile = false
vim.o.virtualedit = 'all'  -- LazyVim sets 'block'
vim.o.writebackup = false

vim.opt.dictionary:append '/usr/share/dict/words'
vim.opt.diffopt:append 'vertical,algorithm:patience'
vim.opt.listchars = { tab = '» ', trail = '∙', eol = '¬', nbsp = '▪', precedes = '⟨', extends = '⟩' }
vim.opt.wildignore:append '.DS_Store,Icon?,*.dmg,*.git,*.pyc,*.o,*.obj,*.so,*.swp,*.zip'

vim.lsp.log.set_level(vim.log.levels.OFF)

vim.g.neovide_opacity = 0.9
vim.g.neovide_normal_opacity = 0.9

-- Use fzf-lua as the LazyVim picker (also set in init.lua spec, belt-and-suspenders)
vim.g.lazyvim_picker = 'fzf'
