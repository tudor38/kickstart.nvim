-- Run the current file as a script (buffer-local so it doesn't leak to other filetypes)
local runners = { python = 'python3', javascript = 'node' }
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('run-file', { clear = true }),
  pattern = vim.tbl_keys(runners),
  callback = function(event)
    vim.keymap.set('n', '<leader>x', function()
      vim.cmd.write()
      vim.cmd('!' .. runners[vim.bo[event.buf].filetype] .. ' ' .. vim.fn.shellescape(vim.api.nvim_buf_get_name(event.buf)))
    end, { buffer = event.buf, desc = 'E[x]ecute file' })
  end,
})

return {}
