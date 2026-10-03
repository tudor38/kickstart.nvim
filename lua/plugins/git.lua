local gh = require('config.pack').gh

vim.pack.add {
  gh 'lewis6991/gitsigns.nvim',
  gh 'nvim-lua/plenary.nvim',
  gh 'kdheepak/lazygit.nvim',
}

-- Git signs in the gutter + hunk utilities
require('gitsigns').setup {
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
  on_attach = function(bufnr)
    local gitsigns = require 'gitsigns'
    local map = function(mode, l, r, desc)
      vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
    end

    map('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal { ']c', bang = true }
      else
        gitsigns.nav_hunk 'next'
      end
    end, 'Next git [c]hange')
    map('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal { '[c', bang = true }
      else
        gitsigns.nav_hunk 'prev'
      end
    end, 'Previous git [c]hange')

    map('v', '<leader>hs', function()
      gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
    end, 'Git [s]tage hunk')
    map('v', '<leader>hr', function()
      gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
    end, 'Git [r]eset hunk')
    map('n', '<leader>hs', gitsigns.stage_hunk, 'Git [s]tage hunk')
    map('n', '<leader>hr', gitsigns.reset_hunk, 'Git [r]eset hunk')
    map('n', '<leader>hS', gitsigns.stage_buffer, 'Git [S]tage buffer')
    map('n', '<leader>hR', gitsigns.reset_buffer, 'Git [R]eset buffer')
    map('n', '<leader>hp', gitsigns.preview_hunk, 'Git [p]review hunk')
    map('n', '<leader>hb', function()
      gitsigns.blame_line { full = true }
    end, 'Git [b]lame line')
    map('n', '<leader>hd', gitsigns.diffthis, 'Git [d]iff against index')
    map('n', '<leader>hD', function()
      gitsigns.diffthis '@'
    end, 'Git [D]iff against last commit')
    map('n', '<leader>tb', gitsigns.toggle_current_line_blame, '[T]oggle git [b]lame line')
    map({ 'o', 'x' }, 'ih', gitsigns.select_hunk, 'Inside git hunk')
  end,
}

vim.keymap.set('n', '<leader>lg', '<cmd>LazyGit<CR>', { desc = 'LazyGit' })
