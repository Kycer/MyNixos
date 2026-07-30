local status, oil = pcall(require, 'oil')
if not status then
  vim.notify('not found oil.nvim')
  return
end

local detail = false

oil.setup({
  default_file_explorer = true,
  float = {
    padding = 2,
    max_width = 0.8,
    max_height = 0.8,
    border = 'rounded',
  },
  keymaps = {
    ['<C-h>'] = false,
    ['<C-l>'] = false,
    ['<C-k>'] = false,
    ['<C-j>'] = false,
    ['<C-r>'] = 'actions.refresh',
    ['<leader>y'] = 'actions.yank_entry',
    ['g.'] = false,
    ['zh'] = 'actions.toggle_hidden',
    ['\\'] = { 'actions.select', opts = { horizontal = true } },
    ['|'] = { 'actions.select', opts = { vertical = true } },
    ['q'] = 'actions.close',
    ['<leader>e'] = 'actions.close',
    ['`'] = 'actions.parent',
    ['gd'] = {
      desc = 'Toggle file detail view',
      callback = function()
        detail = not detail
        if detail then
          require('oil').set_columns({ 'icon', 'permissions', 'size', 'mtime' })
        else
          require('oil').set_columns({ 'icon' })
        end
      end,
    },
  },
})
