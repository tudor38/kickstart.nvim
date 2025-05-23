-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
  -- NOTE: Yes, you can install new plugins here!
  'mfussenegger/nvim-dap',
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    -- Creates a beautiful debugger UI
    -- 'rcarriga/nvim-dap-ui',
    { "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" } },

    -- Installs the debug adapters for you
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    'leoluz/nvim-dap-go',
    'mfussenegger/nvim-dap-python',
  },
  config = function()
    local dap = require('dap') -- launch debug adapter
    local dapui = require('dapui')

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_setup = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'delve', 'python', 'go'
      },
      automatic_installation = true,
    }

    -- Basic debugging keymaps, feel free to change to your liking!
    vim.keymap.set('n', '<M-h>', dap.continue, { desc = 'Debug: Start/Continue' })
    vim.keymap.set('n', '<leader>dc', dap.terminate, { desc = 'Debug: Terminate' })
    vim.keymap.set('n', '<M-l>', dap.step_into, { desc = 'Debug: Step Into' })
    vim.keymap.set('n', '<M-j>', dap.step_over, { desc = 'Debug: Step Over' })
    vim.keymap.set('n', '<M-k>', dap.step_out, { desc = 'Debug: Step Out' })
    vim.keymap.set('n', '<leader>dn', dap.run_to_cursor, { desc = 'Debug: Run to Cursor' })
    vim.keymap.set('n', '<leader>dh', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
    vim.keymap.set('n', '<leader>dR', dap.clear_breakpoints, { desc = 'Debug: Clear Breakpoints' })
    -- vim.keymap.set('n', '<Leader>dr', function() require('dap').repl.open() end, { desc = 'Debug: open REPL' })
    vim.keymap.set('n', '<leader>dH', function()
      dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
    end, { desc = 'Debug: Set Breakpoint' })

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
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

    vim.keymap.set({ 'n', 'v' }, '<Leader>di', function()
      require('dap.ui.widgets').hover()
    end, { desc = 'DAPUI: Hover' })
    vim.keymap.set({ 'n', 'v' }, '<Leader>dp', function()
      require('dap.ui.widgets').preview()
    end, { desc = 'DAPUI: Preview' })
    vim.keymap.set('n', '<Leader>df', function()
      local widgets = require('dap.ui.widgets')
      widgets.centered_float(widgets.frames)
    end)
    vim.keymap.set('n', '<Leader>ds', function()
      local widgets = require('dap.ui.widgets')
      widgets.centered_float(widgets.scopes)
    end)

    -- REPL Autocompletion
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
      pattern = { "dap-repl" },
      callback = function()
        require('dap.ext.autocompl').attach()
      end,
    })
    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Install golang specific config
    require('dap-go').setup()

    -- Install python specific config
    -- require('dap-python').setup('$HOME/.pyenv/versions/neovim/bin/python')
    require('dap-python').test_runner = 'pytest'
  end,
}
