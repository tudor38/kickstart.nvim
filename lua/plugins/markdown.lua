local gh = require('config.pack').gh

vim.pack.add { gh 'MeanderingProgrammer/render-markdown.nvim' }

-- LaTeX is rendered as Unicode text by latex2text (`uv tool install pylatexenc`) and the latex parser
require('render-markdown').setup {
  -- Leave LSP hover / signature floats to Neovim: render-markdown resets their 'conceallevel' to the
  -- global 0, which un-hides the `\[` escapes and ``` fences in the docs.
  ignore = function(buf)
    local win = vim.fn.bufwinid(buf)
    return win ~= -1 and vim.api.nvim_win_get_config(win).relative ~= ''
  end,
}
