return {
  'https://codeberg.org/andyg/leap.nvim',
  config = function()
    -- require('leap').set_default_mappings()
    vim.keymap.set({ 'n', 'x', 'o' }, '<leader>j', '<Plug>(leap)')
    vim.keymap.set('n', '<leader>J', '<Plug>(leap-from-window)')
  end,
}
