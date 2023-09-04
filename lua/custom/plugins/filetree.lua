vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			"nvim-tree/nvim-web-devicons",
			lazy = true,
			config = function()
				require('nvim-web-devicons').setup {}
			end
		}, -- not strictly required, but recommended
		"MunifTanjim/nui.nvim",
	},
	config = function()
		require('neo-tree').setup {}
	end,
}
