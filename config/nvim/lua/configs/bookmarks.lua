local status, bookmarks = pcall(require, 'bookmarks')
if not status then
  vim.notify('not found bookmarks')
  return
end

bookmarks.setup({
  save_file = vim.fn.expand('$HOME/.bookmarks'),
  keywords = {
    ['@t'] = '☑️ ',
    ['@w'] = '⚠️ ',
    ['@f'] = '⛏ ',
    ['@n'] = ' ',
  },
})
