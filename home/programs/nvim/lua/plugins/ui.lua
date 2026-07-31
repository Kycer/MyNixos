return {
  {
    'stevearc/oil.nvim',
    lazy = false,
    dependencies = {
      { 'echasnovski/mini.icons', opts = {} },
    },
    config = function()
      require('configs.oil')
    end,
  },
}
