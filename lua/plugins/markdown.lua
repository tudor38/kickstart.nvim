local gh = require('config.pack').gh

vim.pack.add { gh 'MeanderingProgrammer/render-markdown.nvim' }

-- LaTeX is rendered as Unicode text by latex2text (`uv tool install pylatexenc`) and the latex parser
require('render-markdown').setup {}
