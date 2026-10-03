return {
  {
    'navarasu/onedark.nvim',
    lazy = false,
    priority = 1000, -- load before other start plugins
    config = function()
      vim.cmd.colorscheme 'onedark'
    end,
  },
}
