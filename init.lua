-- Neovim config. Originally based on kickstart.nvim (https://github.com/nvim-lua/kickstart.nvim).
--
--   lua/config/   core options, keymaps, autocommands, plugin manager (vim.pack) setup
--   lua/plugins/  one module per topic; each adds its plugins with vim.pack.add() and configures them

-- Must be set before plugins load
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

require 'config.options'
require 'config.keymaps'
require 'config.autocmds'
local pack = require 'config.pack' -- build hooks must exist before the first vim.pack.add()

pack.load(pack.modules.startup)
vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    vim.schedule(function()
      pack.load(pack.modules.deferred)
    end)
  end,
})

-- vim: ts=2 sts=2 sw=2 et
