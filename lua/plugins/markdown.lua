return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = { latex = { enabled = false } }, -- mdmath renders LaTeX
  },

  { -- Render LaTeX equations as images (needs a terminal with the kitty graphics protocol)
    'Thiago4532/mdmath.nvim',
    opts = {
      filetypes = { 'markdown' },
      foreground = 'Normal',
      anticonceal = true, -- show source when the cursor is on the equation
      hide_on_insert = true,
      dynamic = true,
      dynamic_scale = 1.0,
      update_interval = 400,
      internal_scale = 1.0,
    },
  },
}
