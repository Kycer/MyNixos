local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    '--single-branch',
    'https://github.com/folke/lazy.nvim.git',
    lazypath,
  })
end

vim.opt.runtimepath:prepend(lazypath)

require('lazy').setup('plugins', {
  root = vim.fn.stdpath('data') .. '/lazy',
  defaults = {
    lazy = false,
    version = nil,
  },
  lockfile = vim.fn.stdpath('config') .. '/lazy-lock.json',
  install = {
    missing = true,
    colorscheme = { 'habamax' },
  },
  checker = {
    enabled = false,
  },
  change_detection = {
    enabled = true,
    notify = true,
  },
  ui = {
    border = 'none',
    backdrop = 60,
    size = { width = 0.8, height = 0.8 },
  },
})
