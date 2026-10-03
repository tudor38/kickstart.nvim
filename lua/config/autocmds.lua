local augroup = function(name)
  return vim.api.nvim_create_augroup(name, { clear = true })
end

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = augroup 'highlight-yank',
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Run the current file as a script
local runners = { python = 'python3', javascript = 'node' }
vim.api.nvim_create_autocmd('FileType', {
  group = augroup 'run-file',
  pattern = vim.tbl_keys(runners),
  callback = function(event)
    vim.keymap.set('n', '<leader>x', function()
      vim.cmd.write()
      vim.cmd('!' .. runners[vim.bo[event.buf].filetype] .. ' ' .. vim.fn.shellescape(vim.api.nvim_buf_get_name(event.buf)))
    end, { buffer = event.buf, desc = 'E[x]ecute file' })
  end,
})
