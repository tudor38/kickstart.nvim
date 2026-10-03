local gh = require('config.pack').gh

vim.pack.add {
  gh 'MeanderingProgrammer/render-markdown.nvim',
  gh 'Thiago4532/mdmath.nvim', -- its JS renderer is installed by config/pack.lua (npm install)
}

require('render-markdown').setup {
  latex = { enabled = false }, -- mdmath renders LaTeX
}

-- Render LaTeX equations as images (needs a terminal with the kitty graphics protocol)
require('mdmath').setup {
  filetypes = { 'markdown' },
  foreground = 'Normal',
  anticonceal = true, -- show source when the cursor is on the equation
  hide_on_insert = true,
  dynamic = true,
  dynamic_scale = 1.0,
  update_interval = 400,
  internal_scale = 1.0,
}
