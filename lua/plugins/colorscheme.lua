local gh = require('config.pack').gh

vim.pack.add { gh 'navarasu/onedark.nvim' }

-- In Markdown this group only colors HTML entities (`&lt;` shown as `<`), which LSP docs use for
-- every `<`/`>` in prose; draw them as plain text. Needs an explicit fg: with none, the concealed
-- replacement character falls back to the dim 'Conceal' group. Re-applied on every colorscheme load.
vim.api.nvim_create_autocmd('ColorScheme', {
  callback = function()
    local fg = vim.api.nvim_get_hl(0, { name = 'Normal', link = false }).fg
    vim.api.nvim_set_hl(0, '@character.special.markdown_inline', { fg = fg })
  end,
})
vim.cmd.colorscheme 'onedark'
