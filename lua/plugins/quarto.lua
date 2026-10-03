-- Quarto documents. Based on https://github.com/jmbuhr/quarto-nvim-kickstarter
local gh = require('config.pack').gh

vim.pack.add {
  gh 'quarto-dev/quarto-nvim',
  gh 'jmbuhr/otter.nvim', -- LSP features inside code cells
  gh 'HakonHarnes/img-clip.nvim',
  gh 'jbyuki/nabla.nvim',
}

require('quarto').setup {}

-- Paste an image from the clipboard or drag-and-drop
local image_template = {
  url_encode_path = true,
  template = '![$CURSOR]($FILE_PATH)',
  drag_and_drop = { download_images = false },
}
require('img-clip').setup {
  default = { dir_path = 'img' },
  filetypes = { markdown = image_template, quarto = image_template },
}
vim.keymap.set('n', '<leader>ii', '<cmd>PasteImage<CR>', { desc = '[I]nsert [I]mage from clipboard' })

-- Preview equations as ASCII art
vim.keymap.set('n', '<leader>tm', function()
  require('nabla').toggle_virt()
end, { desc = '[T]oggle [M]ath preview' })
