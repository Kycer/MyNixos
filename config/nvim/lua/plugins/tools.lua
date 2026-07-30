return {
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {
      disable_filetype = { 'markdown' },
      check_ts = true,
    },
  },
  {
    'stevearc/aerial.nvim',
    event = 'VeryLazy',
    opts = {},
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
  },
  {
    'lewis6991/gitsigns.nvim',
    event = 'VeryLazy',
    opts = {},
  },
  {
    'folke/trouble.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {},
  },
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {},
  },
  {
    'rmagatti/alternate-toggler',
    event = 'VeryLazy',
    config = function()
      require('configs.alternate')
    end,
  },
  {
    'tomasky/bookmarks.nvim',
    event = 'VeryLazy',
    config = function()
      require('configs.bookmarks')
    end,
  },
  {
    'jake-stewart/multicursor.nvim',
    event = 'VeryLazy',
    opts = {},
  },
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {
      label = {
        uppercase = false,
      },
    },
  },
  {
    'rmagatti/auto-session',
    lazy = false,
    opts = {
      suppressed_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
      auto_restore_last_session = false,
    },
  },
  {
    'MagicDuck/grug-far.nvim',
    opts = {},
  },
  {
    'keaising/im-select.nvim',
    opts = {},
  },
}
