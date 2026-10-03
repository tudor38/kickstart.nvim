local gh = require('config.pack').gh

vim.pack.add {
  gh 'David-Kunz/gen.nvim', -- prompt local LLMs through Ollama
  gh 'mattn/emmet-vim', -- HTML/CSS abbreviation expansion
  { src = gh 'mikesmithgh/kitty-scrollback.nvim', version = vim.version.range '4' }, -- open kitty's scrollback in Neovim
}

require('gen').model = 'gemma3n'
vim.keymap.set({ 'n', 'x' }, '<leader>g', ':Gen<CR>', { desc = '[G]en: prompt LLM' })

require('kitty-scrollback').setup {
  search = {
    callbacks = {
      after_ready = function()
        vim.api.nvim_feedkeys('?', 'n', false)
      end,
    },
  },
}
