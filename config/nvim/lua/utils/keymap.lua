local M = {}

local default_opts = {
  noremap = true,
  silent = true,
}

function M.set(mode, lhs, rhs, opts)
  opts = vim.tbl_extend('force', default_opts, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

function M.buf_set(bufnr, mode, lhs, rhs, opts)
  opts = vim.tbl_extend('force', opts or {}, { buffer = bufnr })
  M.set(mode, lhs, rhs, opts)
end

function M.del(mode, lhs, opts)
  vim.keymap.del(mode, lhs, opts)
end

function M.buf_del(bufnr, mode, lhs)
  M.del(mode, lhs, { buffer = bufnr })
end

return M
