return {
	'echasnovski/mini.nvim',
	version = false,
	config = function()
		require('mini.align').setup()
		require('mini.files').setup()
		require('mini.cursorword').setup()
	end
}
