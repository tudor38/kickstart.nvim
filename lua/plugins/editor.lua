return {
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

  { -- Show pending keybinds
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
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
    },
  },

  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  { -- Small independent modules
    'echasnovski/mini.nvim',
    config = function()
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
    end,
  },

  { -- Jump anywhere on screen
    'https://codeberg.org/andyg/leap.nvim',
    keys = {
      { '<leader>j', '<Plug>(leap)', mode = { 'n', 'x', 'o' }, desc = 'Leap' },
      { '<leader>J', '<Plug>(leap-from-window)', desc = 'Leap to other window' },
    },
  },

  { -- Symbol outline sidebar
    'hedyhli/outline.nvim',
    cmd = { 'Outline', 'OutlineOpen' },
    keys = {
      { '<leader>a', '<cmd>Outline<CR>', desc = 'Toggle outline' },
    },
    opts = {},
  },
}
