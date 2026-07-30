local status, comment = pcall(require, 'Comment')
if not status then
  vim.notify('not found Comment')
  return
end

comment.setup({
  padding = true,
  sticky = true,
  toggler = {
    line = 'gcc',
    block = 'gbc',
  },
  opleader = {
    line = 'gc',
    block = 'gb',
  },
  extra = {
    above = 'gcO',
    below = 'gco',
    eol = 'gcA',
  },
  mappings = {
    basic = true,
    extra = true,
  },
})
