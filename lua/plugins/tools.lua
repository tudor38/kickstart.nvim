local gh = require('config.pack').gh

-- emmet: expand HTML/CSS abbreviations, only in web filetypes. Its prefix is <C-z>
-- (default <C-y> would collide with accepting completions).
vim.g.user_emmet_install_global = 0
vim.g.user_emmet_leader_key = '<C-z>'

vim.pack.add {
  gh 'David-Kunz/gen.nvim', -- prompt local LLMs through Ollama
  gh 'mattn/emmet-vim',
}

require('gen').model = 'gemma3n'
vim.keymap.set({ 'n', 'x' }, '<leader>g', ':Gen<CR>', { desc = '[G]en: prompt LLM' })

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('emmet', { clear = true }),
  pattern = { 'html', 'css', 'scss', 'javascriptreact', 'typescriptreact', 'vue', 'svelte' },
  command = 'EmmetInstall',
})
