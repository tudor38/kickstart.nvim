-- -- run file as a script depending on file type
vim.cmd [[
  augroup filetype_keymap
    autocmd!
    autocmd FileType python nmap <leader>x :w<CR>:exec "!python3" shellescape(expand(@%, 1))<CR>
    autocmd FileType javascript nmap <leader>x :w<CR>:exec "!node" shellescape(expand(@%, 1))<CR>
  augroup END
]]

return {
	'tpope/vim-repeat',
	'tpope/vim-surround',
	'tpope/vim-obsession',
	-- 'ggandor/leap.nvim',
	-- 'simrat39/symbols-outline.nvim',
}
