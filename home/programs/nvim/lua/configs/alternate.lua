local status, alternate = pcall(require, 'alternate-toggler')
if not status then
  vim.notify('not found alternate')
  return
end

alternate.setup({
  alternates = {
    ['true'] = 'false',
    ['True'] = 'False',
    ['TRUE'] = 'FALSE',
    ['Yes'] = 'No',
    ['YES'] = 'NO',
    ['1'] = '0',
    ['<'] = '>',
    ['('] = ')',
    ['['] = ']',
    ['{'] = '}',
    ['"'] = "'",
    ['""'] = "''",
    ['+'] = '-',
    ['==='] = '!==',
  },
})
