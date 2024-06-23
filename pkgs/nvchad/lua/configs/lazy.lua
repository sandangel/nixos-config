return vim.tbl_deep_extend('force', require 'nvchad.configs.lazy_nvim', {
  lockfile = vim.fn.stdpath 'data' .. '/lazy-lock.json',
  checker = {
    -- automatically check for plugin updates
    enabled = true,
    frequency = 3600 * 2, -- check for updates every 2 hours
    notify = false,
  },
})
