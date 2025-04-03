-- https://github.com/David-Kunz/gen.nvim
return {
	'David-Kunz/gen.nvim',
	config = function()
		require("gen").model = 'deepseek-r1:14b'
	end,
}
