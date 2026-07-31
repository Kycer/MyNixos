local map = require('utils.keymap').set

map('i', 'jj', '<cmd>stopinsert<cr>', { desc = '退出 INSERT 模式' })
map('n', '<C-a>', '<cmd>normal! ggVG<cr>', { desc = '全选' })
map({ 'n', 'i', 'x', 's' }, '<C-s>', '<cmd>write<cr>', { desc = '保存文件' })
map('n', '<Esc>', '<cmd>nohlsearch<cr>', { desc = '清除搜索高亮' })

map('n', '<C-h>', '<C-w>h', { desc = '移动到左侧窗口' })
map('n', '<C-j>', '<C-w>j', { desc = '移动到下方窗口' })
map('n', '<C-k>', '<C-w>k', { desc = '移动到上方窗口' })
map('n', '<C-l>', '<C-w>l', { desc = '移动到右侧窗口' })

map({ 'n', 'v' }, '<A-h>', '^', { desc = '移动到行首' })
map({ 'n', 'v' }, '<A-l>', '$', { desc = '移动到行尾' })

map('n', '<leader>wv', '<cmd>vsplit<cr>', { desc = '垂直分屏' })
map('n', '<leader>ws', '<cmd>split<cr>', { desc = '水平分屏' })
map('n', '<leader>wd', '<C-w>c', { desc = '关闭窗口' })

map('n', 'bh', '<cmd>bprevious<cr>', { desc = '上一个 Buffer' })
map('n', 'bl', '<cmd>bnext<cr>', { desc = '下一个 Buffer' })

map('x', 'J', ":move '>+1<cr>gv=gv", { desc = '向下移动选中内容' })
map('x', 'K', ":move '<-2<cr>gv=gv", { desc = '向上移动选中内容' })
