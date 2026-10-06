-- Debugging with nvim-dap (Go and Python adapters, installed through mason)
local gh = require('config.pack').gh

vim.pack.add {
  gh 'mfussenegger/nvim-dap',
  gh 'nvim-neotest/nvim-nio',
  gh 'rcarriga/nvim-dap-ui',
  gh 'mason-org/mason.nvim',
  gh 'jay-babu/mason-nvim-dap.nvim',
  gh 'leoluz/nvim-dap-go',
  gh 'mfussenegger/nvim-dap-python',
}

local dap = require 'dap'
local dapui = require 'dapui'

-- Debug adapters, as mason package names
local adapters = { 'delve', 'debugpy' }
require('config.mason').install(adapters)
require('mason-nvim-dap').setup {
  handlers = {}, -- default setup for each installed adapter
}

local map = vim.keymap.set
map('n', '<M-h>', dap.continue, { desc = 'Debug: Start/Continue' })
map('n', '<M-l>', dap.step_into, { desc = 'Debug: Step Into' })
map('n', '<M-j>', dap.step_over, { desc = 'Debug: Step Over' })
map('n', '<M-k>', dap.step_out, { desc = 'Debug: Step Out' })
map('n', '<leader>dx', dap.terminate, { desc = 'Debug: Terminate' })
map('n', '<leader>dC', dap.run_to_cursor, { desc = 'Debug: Run to Cursor' })
map('n', '<leader>db', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
map('n', '<leader>dR', dap.clear_breakpoints, { desc = 'Debug: Clear Breakpoints' })
map('n', '<leader>dB', function()
  dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
end, { desc = 'Debug: Set Conditional Breakpoint' })

map({ 'n', 'v' }, '<leader>di', function()
  require('dap.ui.widgets').hover()
end, { desc = 'DAPUI: Hover' })
map({ 'n', 'v' }, '<leader>dp', function()
  require('dap.ui.widgets').preview()
end, { desc = 'DAPUI: Preview' })
map('n', '<leader>df', function()
  local widgets = require 'dap.ui.widgets'
  widgets.centered_float(widgets.frames)
end, { desc = 'DAPUI: Frames' })
map('n', '<leader>ds', function()
  local widgets = require 'dap.ui.widgets'
  widgets.centered_float(widgets.scopes)
end, { desc = 'DAPUI: Scopes' })
-- Reopen the UI to see the last session's output (e.g. after an unhandled exception)
map('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result' })

-- Icons that work in every terminal
dapui.setup {
  icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
  controls = {
    icons = {
      pause = '⏸',
      play = '▶',
      step_into = '⏎',
      step_over = '⏭',
      step_out = '⏮',
      step_back = 'b',
      run_last = '▶▶',
      terminate = '⏹',
      disconnect = '⏏',
    },
  },
}

dap.listeners.after.event_initialized['dapui_config'] = dapui.open
dap.listeners.before.event_terminated['dapui_config'] = dapui.close
dap.listeners.before.event_exited['dapui_config'] = dapui.close

-- Completion in the DAP REPL
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter' }, {
  group = vim.api.nvim_create_augroup('dap-repl-completion', { clear = true }),
  pattern = 'dap-repl',
  callback = function()
    require('dap.ext.autocompl').attach()
  end,
})

require('dap-go').setup()
require('dap-python').test_runner = 'pytest'

return {
  ensure = function(timeout)
    return require('config.mason').sync(adapters, timeout)
  end,
}
