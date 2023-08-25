vim.opt.relativenumber = true
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.cursorline = true
-- vim.o.ls = 0  -- last status
-- vim.o.ch = 0  -- command height

-- open vimrc
vim.keymap.set('n', '<leader>vv', ':e $MYVIMRC<CR> :cd %:h<CR>', { noremap = true, silent = true, desc = 'edit [V]im [R]C' })

-- escape
vim.keymap.set('i', 'fd', '<Esc>', { noremap = true, silent = true })
vim.keymap.set('i', 'jk', '<Esc>', { noremap = true, silent = true })

vim.keymap.set('n', '<leader>o', ':only<CR>', { desc = 'show [O]nly this buffer' })

-- highlight
vim.keymap.set('n', '<leader>h', ':set hlsearch!<CR>', { desc = 'toggle search highlight' })
-- send regex to new window
vim.keymap.set('n', '<F3>', [[:redir @a<CR>:g//<CR>:redir END<CR>:vnew<CR>:put! a<CR>:set hlsearch<CR>]], { desc = 'redirect to new window last regex matches', silent = true })
-- insert time
vim.keymap.set('n', '<leader>ti', [[:put =strftime('%Y-%m-%d %H:%M:%S')<cr>A ]], { desc = '[T]ime [I]nsert' })

-- save
vim.keymap.set('n', '<leader>w', ':w<CR>', { noremap = true, silent = true, desc = '[W]rite File'})

vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })

-- navigate quickfix list
vim.keymap.set('n', '<M-j>', ':cnext<CR>', { noremap = true, silent = true, desc = 'quickfix next item'})
vim.keymap.set('n', '<M-k>', ':cprevious<CR>', { noremap = true, silent = true, desc = 'quickfix previous item'})

vim.keymap.set('n', '<leader>cp', ':let @"=expand("%:p")<CR>', { noremap = true, silent = true, desc = 'copy current buffer absolute path'})

-- toggle outline
vim.keymap.set('n', '<leader>to', ':SymbolsOutline<CR>', { desc = '[t]oggle outline' })

-- nvim-telescope/telescope-dap.nvim
-- require('telescope').load_extension('dap')
-- vim.keymap.set('n', '<leader>ds', ':Telescope dap frames<CR>', { noremap = true, silent = true, desc = 'Debug Frames' })
-- -- vim.keymap.set('n', '<leader>dc', ':Telescope dap commands<CR>')
-- vim.keymap.set('n', '<leader>db', ':Telescope dap list_breakpoints<CR>', { noremap = true, silent = true, desc = 'Debug List Breakpoints' })
--
-- -- dap
-- vim.fn.sign_define('DapBreakpoint', {text = '🟥', texthl = '', linehl = '', numhl = ''})
-- vim.fn.sign_define('DapBreakpointRejected', {text = '🟦', texthl = '', linehl = '', numhl = ''})
-- vim.fn.sign_define('DapStopped', {text = '⭐️', texthl = '', linehl = '', numhl = ''})
--
-- vim.keymap.set('n', '<leader>dh', function() require"dap".toggle_breakpoint() end, { noremap = true, silent = true, desc = 'Debug Toggle Breakpoint' })
-- vim.keymap.set('n', '<leader>dH', ":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>", { noremap = true, silent = true, desc = 'Debug Set Breakpoint With Condition' })
-- vim.keymap.set({'n', 't'}, '<A-k>', function() require"dap".step_out() end, { noremap = true, silent = true, desc = 'Debug Step Out' })
-- vim.keymap.set({'n', 't'}, "<A-l>", function() require"dap".step_into() end, { noremap = true, silent = true, desc = 'Debug Step Into' })
-- vim.keymap.set({'n', 't'}, '<A-j>', function() require"dap".step_over() end, { noremap = true, silent = true, desc = 'Debug Step Over' })
-- vim.keymap.set({'n', 't'}, '<A-h>', function() require"dap".continue() end, { noremap = true, silent = true, desc = 'Debug Continue' })
-- vim.keymap.set('n', '<leader>dn', function() require"dap".run_to_cursor() end, { noremap = true, silent = true, desc = 'Debug Run To Cursor' })
-- vim.keymap.set('n', '<leader>dc', function() require"dap".terminate() end, { noremap = true, silent = true, desc = 'Debug Terminate' })
-- vim.keymap.set('n', '<leader>dR', function() require"dap".clear_breakpoints() end, { noremap = true, silent = true, desc = 'Debug Clear Breakpoints' })
-- vim.keymap.set('n', '<leader>de', function() require"dap".set_exception_breakpoints({"all"}) end, { noremap = true, silent = true, desc = 'Debug Set Exception Breakpoints' })
-- vim.keymap .set('n', '<leader>di', function() require"dap.ui.widgets".hover() end, { noremap = true, silent = true, desc = 'Debug Hover' })
-- vim.keymap.set('n', '<leader>d?', function() local widgets = require "dap.ui.widgets"; widgets.centered_float(widgets.scopes) end, { noremap = true, silent = true, desc = 'Debug Float' })
-- vim.keymap.set('n', '<leader>dk', ':lua require"dap".up()<CR>zz')
-- vim.keymap.set('n', '<leader>dj', ':lua require"dap".down()<CR>zz')
-- vim.keymap.set('n', '<leader>dr', ':lua require"dap".repl.toggle({}, "vsplit")<CR><C-w>l')
-- vim.keymap.set('n', '<leader>du', ':lua require"dapui".toggle()<CR>')
--
-- require("nvim-dap-virtual-text").setup()
--
-- -- run file as a script depending on file type
-- vim.cmd [[
--   augroup filetype_keymap
--     autocmd!
--     autocmd FileType python nmap <leader>x :w<CR>:exec "!python3" shellescape(expand(@%, 1))<CR>
--     autocmd FileType javascript nmap <leader>x :w<CR>:exec "!node" shellescape(expand(@%, 1))<CR>
--   augroup END
-- ]]
