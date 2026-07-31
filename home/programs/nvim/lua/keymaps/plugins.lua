local map = require('utils.keymap').set

map('n', '<A-e>', function()
  require('oil').open_float()
end, { desc = '打开文件浏览器' })
