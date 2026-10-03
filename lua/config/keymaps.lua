-- General keymaps. Plugin-specific keymaps live with their plugin spec in lua/plugins/.
local map = vim.keymap.set

map('n', '<Esc>', '<cmd>nohlsearch<CR>')
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
map('i', 'jk', '<Esc>')

map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Windows
map('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
map('n', '<leader>o', '<cmd>only<CR>', { desc = 'Show [O]nly this window' })

-- Files
map('n', '<leader>w', '<cmd>write<CR>', { desc = '[W]rite file' })
map('n', '<leader>vv', '<cmd>edit $MYVIMRC | cd %:h<CR>', { desc = 'Edit [V]im config' })
map('n', '<leader>yp', '<cmd>let @" = expand("%:p")<CR>', { desc = '[Y]ank file [P]ath' })

-- Misc
map('n', '<leader>ti', [[:put =strftime('%Y-%m-%d %H:%M:%S')<CR>A ]], { desc = '[T]ime [I]nsert' })
map('n', '<F3>', [[:redir @a<CR>:g//<CR>:redir END<CR>:vnew<CR>:put! a<CR>:set hlsearch<CR>]], {
  desc = 'Show last search matches in a new window',
  silent = true,
})
