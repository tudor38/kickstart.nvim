local gh = require('config.pack').gh

vim.pack.add {
  gh 'tpope/vim-sleuth', -- detect tabstop and shiftwidth automatically
  gh 'folke/which-key.nvim',
  gh 'nvim-lua/plenary.nvim',
  gh 'folke/todo-comments.nvim',
  gh 'nvim-mini/mini.nvim',
  'https://codeberg.org/andyg/leap.nvim',
  gh 'hedyhli/outline.nvim',
}

-- Show pending keybinds
require('which-key').setup {
  delay = 1000,
  icons = {
    mappings = vim.g.have_nerd_font,
    keys = vim.g.have_nerd_font and {} or {
      Up = '<Up> ',
      Down = '<Down> ',
      Left = '<Left> ',
      Right = '<Right> ',
      C = '<C-…> ',
      M = '<M-…> ',
      D = '<D-…> ',
      S = '<S-…> ',
      CR = '<CR> ',
      Esc = '<Esc> ',
      ScrollWheelDown = '<ScrollWheelDown> ',
      ScrollWheelUp = '<ScrollWheelUp> ',
      NL = '<NL> ',
      BS = '<BS> ',
      Space = '<Space> ',
      Tab = '<Tab> ',
      F1 = '<F1>',
      F2 = '<F2>',
      F3 = '<F3>',
      F4 = '<F4>',
      F5 = '<F5>',
      F6 = '<F6>',
      F7 = '<F7>',
      F8 = '<F8>',
      F9 = '<F9>',
      F10 = '<F10>',
      F11 = '<F11>',
      F12 = '<F12>',
    },
  },
  spec = {
    { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
    { '<leader>d', group = '[D]ebug', mode = { 'n', 'v' } },
    { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
    { '<leader>i', group = '[I]nsert' },
    { '<leader>s', group = '[S]earch' },
    { '<leader>t', group = '[T]oggle' },
    { '<leader>y', group = '[Y]ank' },
    { 'gr', group = 'LSP' },
  },
}

require('todo-comments').setup { signs = false }

-- Small independent modules
-- File icons for everything (statusline, render-markdown, which-key); also stands in for
-- nvim-web-devicons so Telescope gets icons without a second icon plugin
if vim.g.have_nerd_font then
  require('mini.icons').setup()
  MiniIcons.mock_nvim_web_devicons()
end

-- Better around/inside textobjects, e.g. va), yinq, ci'
require('mini.ai').setup {
  -- Keep an/in free for Neovim 0.12's built-in incremental selection (`:help treesitter-incremental-selection`)
  mappings = { around_next = 'aa', inside_next = 'ii' },
  n_lines = 500,
}
-- Add/delete/replace surroundings, e.g. saiw), sd', sr)'
require('mini.surround').setup()

local statusline = require 'mini.statusline'
statusline.setup { use_icons = vim.g.have_nerd_font }
---@diagnostic disable-next-line: duplicate-set-field
statusline.section_location = function()
  return '%2l:%-2v'
end

require('mini.files').setup()
vim.keymap.set('n', '<leader>n', MiniFiles.open, { desc = 'Open file [N]avigation' })
require('mini.pairs').setup()

-- Jump anywhere on screen
vim.keymap.set({ 'n', 'x', 'o' }, '<leader>j', '<Plug>(leap)', { desc = 'Leap' })
vim.keymap.set('n', '<leader>J', '<Plug>(leap-from-window)', { desc = 'Leap to other window' })

-- Symbol outline sidebar
require('outline').setup {}
vim.keymap.set('n', '<leader>a', '<cmd>Outline<CR>', { desc = 'Toggle outline' })
