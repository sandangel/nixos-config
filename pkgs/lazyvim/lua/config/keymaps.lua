local map = vim.keymap.set

-- ─── Wipe ALL LazyVim global defaults (lazyvim/config/keymaps.lua) ────────
local function del(modes, lhs)
  for _, m in ipairs(type(modes) == 'string' and { modes } or modes) do
    pcall(vim.keymap.del, m, lhs)
  end
end

-- window nav
del('n', '<C-h>')
del('n', '<C-j>')
del('n', '<C-k>')
del('n', '<C-l>')
-- resize
del('n', '<C-Up>')
del('n', '<C-Down>')
del('n', '<C-Left>')
del('n', '<C-Right>')
-- buffers
del('n', '<S-h>')
del('n', '<S-l>')
del('n', '[b')
del('n', ']b')
del('n', '<leader>bb')
del('n', '<leader>`')
del('n', '<leader>bd')
del('n', '<leader>bo')
del('n', '<leader>bD')
-- escape / search
del('n', '<leader>ur')
del({ 'n', 'x', 'o' }, 'n')
del({ 'n', 'x', 'o' }, 'N')
-- undo breakpoints
del('i', ',')
del('i', '.')
del('i', ';')
-- save
del({ 'i', 'x', 'n', 's' }, '<C-s>')
-- misc
del('n', '<leader>K')
del('n', 'gco')
del('n', 'gcO')
del('n', '<leader>l')
del('n', '<leader>fn')
del('n', '<leader>xl')
del('n', '<leader>xq')
-- format
del({ 'n', 'x' }, '<leader>cf')
-- diagnostics
del('n', '<leader>cd')
-- toggle ui
del('n', '<leader>uf')
del('n', '<leader>uF')
del('n', '<leader>us')
del('n', '<leader>uw')
del('n', '<leader>uL')
del('n', '<leader>ud')
del('n', '<leader>ul')
del('n', '<leader>uc')
del('n', '<leader>uA')
del('n', '<leader>uT')
del('n', '<leader>ub')
del('n', '<leader>uD')
del('n', '<leader>ua')
del('n', '<leader>ug')
del('n', '<leader>uS')
del('n', '<leader>dpp')
del('n', '<leader>dph')
del('n', '<leader>uh')
-- git hunk nav (LazyVim gitsigns on_attach; user has own on_attach so these are orphaned)
del('n', ']h')
del('n', '[h')
del('n', ']H')
del('n', '[H')
-- git
del('n', '<leader>gg')
del('n', '<leader>gG')
del('n', '<leader>gL')
del('n', '<leader>gb')
del('n', '<leader>gf')
del('n', '<leader>gl')
del({ 'n', 'x' }, '<leader>gB')
del({ 'n', 'x' }, '<leader>gY')
-- quit / inspect / changelog
del('n', '<leader>qq')
del('n', '<leader>ui')
del('n', '<leader>uI')
del('n', '<leader>L')
-- terminal
del('n', '<leader>fT')
del('n', '<leader>ft')
del({ 'n', 't' }, '<c-/>')
del({ 'n', 't' }, '<c-_>')
-- windows
del('n', '<leader>wd')
del('n', '<leader>wm')
del('n', '<leader>uZ')
del('n', '<leader>uz')
-- tabs
del('n', '<leader><tab>l')
del('n', '<leader><tab>o')
del('n', '<leader><tab>f')
del('n', '<leader><tab><tab>')
del('n', '<leader><tab>]')
del('n', '<leader><tab>d')
del('n', '<leader><tab>[')
-- lua run
del({ 'n', 'x' }, '<localleader>r')
-- mini-diff toggle overlay (set via Snacks.toggle in opts, not keys=)
del('n', '<leader>uG')

-- ─── General ───────────────────────────────────────────────────────────────

map('x', '.', '<cmd>norm.<CR>', { desc = 'Repeat' })
map('x', 'Q', "<cmd>'<,'>:normal @q<CR>", { desc = 'Replay' })
map('x', '<leader>y', '"*ygv"+y`]', { desc = 'Copy to clipboard' })
map('x', '<leader>p', '"_d"+P', { desc = 'Paste from clipboard no yank' })
map('x', 'y', 'y`]', { desc = 'Yank' })
map('x', 'p', '"_dP', { desc = 'Paste no yank' })

map('n', 'Q', '@q', { desc = 'Replay' })
map('n', 'gV', 'ggVG', { desc = 'Select all' })
map('n', 'gj', '<c-w>W', { desc = 'Move to next window' })
map('n', 'vv', 'vg_', { desc = 'Select to end of line' })
map('n', '[<leader>', 'm`O<Esc>``', { desc = 'Add empty line up' })
map('n', ']<leader>', 'm`o<Esc>``', { desc = 'Add empty line down' })
map('n', '<leader>p', '"+p', { desc = 'Paste from clipboard' })

-- Override LazyVim's <leader>w (windows group) with save all
map('n', '<leader>w', '<cmd>wa<CR>', { desc = 'Save all' })

-- Override LazyVim's <leader>q (quit/session group) with Sayonara
map('n', '<leader>q', '<cmd>Sayonara<CR>', { desc = 'Quit buffer/window' })

map('i', '<C-v>', '<cmd>norm! "+p<CR>', { desc = 'Paste from clipboard' })

map('t', '<C-v>', vim.api.nvim_replace_termcodes('<C-\\><C-n>', true, true, true) .. '"+pi',
  { desc = 'Paste from clipboard' })
map('t', '<Esc>', vim.api.nvim_replace_termcodes('<C-\\><C-n>', true, true, true), { desc = 'Escape terminal mode' })

-- ─── Window navigation with compositor passthrough ────────────────────────
-- HyprNavigate/NiriNavigate (defined in autocmds.lua) handle the edge case:
-- at a Neovim split edge they pass the focus request to the compositor.
-- Fall back to plain <C-w>hjkl when neither compositor is running.

local function nav(hypr_dir, niri_dir, wincmd)
  return function()
    if vim.env.HYPRLAND_INSTANCE_SIGNATURE then
      vim.cmd('HyprNavigate ' .. hypr_dir)
    elseif vim.env.NIRI_SOCKET then
      vim.cmd('NiriNavigate ' .. niri_dir)
    else
      vim.cmd('wincmd ' .. wincmd)
    end
  end
end

map({ 'n', 't' }, '<C-h>', nav('l', 'column-left', 'h'), { desc = 'Window left' })
map({ 'n', 't' }, '<C-l>', nav('r', 'column-right', 'l'), { desc = 'Window right' })
map({ 'n', 't' }, '<C-j>', nav('d', 'window-down', 'j'), { desc = 'Window down' })
map({ 'n', 't' }, '<C-k>', nav('u', 'window-up', 'k'), { desc = 'Window up' })

-- ─── FzfLua ────────────────────────────────────────────────────────────────
-- The fzf extra provides: <leader>ff/fr/fg, <leader>g* group, <leader>s* group.
-- Override specific keys to match user's muscle memory.

-- Override <leader>l (LazyVim: :Lazy) → buffer lines
map('n', '<leader>l', function() require('fzf-lua').blines() end, { desc = 'FzfLua Grep buffer lines' })
-- Override <leader>s (LazyVim: search group) → recent files
map('n', '<leader>s', function() require('fzf-lua').oldfiles() end, { desc = 'FzfLua Recent files' })
-- Override <leader>f (LazyVim: file/find group) → grep project
map('n', '<leader>f', function() require('fzf-lua').grep_project() end, { desc = 'FzfLua Grep project' })
-- Override <leader>g (LazyVim: git group) → git status
map('n', '<leader>g', function() require('fzf-lua').git_status() end, { desc = 'FzfLua Git status' })
-- Override <leader>d (LazyVim: debug group) → grep word under cursor
map('n', '<leader>d', function()
  require('fzf-lua').grep_project { fzf_opts = { ['--query'] = vim.fn.expand('<cword>') } }
end, { desc = 'FzfLua Grep word' })

map('n', '<leader>F', function() require('fzf-lua').grep_project { cwd = vim.fn.expand('%:p:h') } end,
  { desc = 'FzfLua Grep CWD' })
map('n', '<leader>j', function() require('fzf-lua').files() end, { desc = 'FzfLua Project files' })
map('n', '<leader>J', function() require('fzf-lua').files { cwd = vim.fn.expand('%:p:h') } end,
  { desc = 'FzfLua CWD files' })
map('n', '<leader>D', function()
  require('fzf-lua').grep_project { fzf_opts = { ['--query'] = vim.fn.expand('<cword>') }, cwd = vim.fn.expand('%:p:h') }
end, { desc = 'FzfLua Grep CWD word' })
map('n', '<leader>k', function()
  require('fzf-lua').blines { fzf_opts = { ['--query'] = vim.fn.expand('<cword>') } }
end, { desc = 'FzfLua Grep buffer word' })

-- Override <leader>cc (LazyVim: run codelens, fzf extra: git commits via <leader>gc) → git commits
map('n', '<leader>cc', function() require('fzf-lua').git_commits() end, { desc = 'FzfLua Git commits' })

-- gL / gq: fzf extra uses <leader>sl and <leader>sq, but keep user's g-prefixed ones too
map('n', 'gL', '<cmd>FzfLua loclist<CR>', { desc = 'FzfLua Location list' })
map('n', 'gq', '<cmd>FzfLua quickfix<CR>', { desc = 'FzfLua Quick fix' })

map('x', '<leader>d', function()
  require('fzf-lua').grep_project {
    fzf_opts = { ['--query'] = vim.fn.shellescape(require('fzf-lua.utils').get_visual_selection()) }
  }
end, { desc = 'FzfLua Grep selection' })
map('x', '<leader>D', function()
  require('fzf-lua').grep_project {
    fzf_opts = { ['--query'] = vim.fn.shellescape(require('fzf-lua.utils').get_visual_selection()) },
    cwd = vim.fn.expand('%:p:h'),
  }
end, { desc = 'FzfLua Grep CWD selection' })
map('x', '<leader>k', function()
  require('fzf-lua').blines {
    fzf_opts = { ['--query'] = vim.fn.shellescape(require('fzf-lua.utils').get_visual_selection()) }
  }
end, { desc = 'FzfLua Grep buffer selection' })

-- ─── LSP ───────────────────────────────────────────────────────────────────
-- fzf extra overrides: gd→lsp_definitions, gr→lsp_references, gy→lsp_typedefs
-- User wants: K=noop, gh=hover, gd=lsp_finder, gr=rename, gf=format, gA=code action

map('n', 'K', '', { desc = '' }) -- disable K (LazyVim/fzf-extra: hover)
map('n', 'gh', function() vim.lsp.buf.hover() end, { desc = 'LSP Hover' })
-- Override fzf extra's gd (goto definition) with fzf lsp_finder
map('n', 'gd', '<cmd>FzfLua lsp_finder<CR>', { desc = 'LSP Finder' })
-- Override fzf extra's gr (references) with rename
map('n', 'gr', function() vim.lsp.buf.rename() end, { desc = 'LSP Rename' })
-- Override vim's gf (goto file) with format
map('n', 'gf', function() vim.lsp.buf.format { async = true } end, { desc = 'LSP Format file' })
map('x', 'gf', function() vim.lsp.buf.range_formatting() end, { desc = 'LSP Format range' })
-- gA: code actions (LazyVim uses <leader>ca; keep user's gA shortcut)
map('n', 'gA', '<cmd>FzfLua lsp_code_actions<CR>', { desc = 'LSP Code action' })
map('x', 'gA', '<cmd>FzfLua lsp_code_actions<CR>', { desc = 'LSP Code action' })
-- Diagnostic shortcuts (gw/gW/gl supplement LazyVim's <leader>cd, <leader>xd etc.)
map('n', 'gw', '<cmd>FzfLua lsp_document_diagnostics<CR>', { desc = 'LSP Document diagnostics' })
map('n', 'gW', '<cmd>FzfLua lsp_workspace_diagnostics<CR>', { desc = 'LSP Workspace diagnostics' })
map('n', 'gl', function() vim.diagnostic.open_float { border = 'rounded' } end, { desc = 'LSP Floating diagnostic' })

-- Remove neovim 0.10 default gr* mappings (handled by LazyVim, but belt-and-suspenders)
vim.schedule(function()
  for _, lhs in ipairs({ 'grn', 'gra', 'grr' }) do
    if vim.fn.maparg(lhs, 'n') ~= '' then
      pcall(vim.keymap.del, 'n', lhs)
    end
  end
end)

-- ─── UndoTree ──────────────────────────────────────────────────────────────

map('n', '<F2>', '<cmd>UndotreeToggle<CR>', { desc = 'UndoTree Toggle' })

-- ─── Abolish ───────────────────────────────────────────────────────────────

map('n', 'crm', '<Plug>(abolish-coerce-word)m', { noremap = false, desc = 'Abolish Coerce MixedCase' })
map('n', 'crs', '<Plug>(abolish-coerce-word)s', { noremap = false, desc = 'Abolish Coerce snake_case' })
map('n', 'crc', '<Plug>(abolish-coerce-word)c', { noremap = false, desc = 'Abolish Coerce camelCase' })
map('n', 'cru', '<Plug>(abolish-coerce-word)u', { noremap = false, desc = 'Abolish Coerce UPPER_CASE' })
map('n', 'cr-', '<Plug>(abolish-coerce-word)-', { noremap = false, desc = 'Abolish Coerce dash-case' })
map('n', 'cr.', '<Plug>(abolish-coerce-word).', { noremap = false, desc = 'Abolish Coerce dot.case' })
