return {
  'Verf/deepwhite.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    require('lualine').setup({
      options = {
        theme = 'deepwhite',
      },
    })
    --   vim.cmd([[colorscheme deepwhite]])
  end,
}
