local ensure_packer = function()
	local fn = vim.fn
	local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
	if fn.empty(fn.glob(install_path)) > 0 then
		fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
		vim.cmd([[packadd packer.nvim]])
		return true
	end
	return false
end
local packer_bootstrap = ensure_packer()

vim.cmd("autocmd BufWritePost plugins.lua PackerCompile") -- Auto compile when there are changes in plugins.lua
vim.cmd([[packadd packer.nvim]])

return require("packer").startup({
	function(use)
		use("wbthomason/packer.nvim")

		use("sainnhe/everforest")

		---* Treesitter
		use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" })
		use("nvim-treesitter/nvim-treesitter-textobjects") -- Additional textobjects for treesitter
		use({
			"JoosepAlviste/nvim-ts-context-commentstring",
			"windwp/nvim-ts-autotag",
			"RRethy/nvim-treesitter-endwise",
		})
		---* Treesitter

		use({ "hoob3rt/lualine.nvim", requires = "kyazdani42/nvim-web-devicons" }) -- Status bar

		---* Fuzzy Find
		use({
			"nvim-telescope/telescope.nvim",
			requires = { "nvim-lua/popup.nvim", "nvim-lua/plenary.nvim" },
		})
		use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })
		---* Fuzzy Find

		---* File explorer
		use({
			"tamago324/lir.nvim",
			requires = { "kyazdani42/nvim-web-devicons", "nvim-lua/plenary.nvim" },
		})
		use("tamago324/lir-git-status.nvim")
		---* File explorer

		---* Git
		use("tpope/vim-fugitive")
		use({ "lewis6991/gitsigns.nvim", requires = "nvim-lua/plenary.nvim" })
		---* Git

		use("szw/vim-maximizer")
		use("folke/which-key.nvim")

		use({
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"neovim/nvim-lspconfig",
		})
		use("jose-elias-alvarez/null-ls.nvim")
		use("folke/lua-dev.nvim")

		use({
			"hrsh7th/nvim-cmp",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"saadparwaiz1/cmp_luasnip",
		})

		-- Snippets
		use("L3MON4D3/LuaSnip")
		use("rafamadriz/friendly-snippets")
		use("onsails/lspkind.nvim")

		use("windwp/nvim-autopairs")

		use("RRethy/vim-illuminate")

		use("ray-x/lsp_signature.nvim")
		use("stevearc/dressing.nvim")

		use("kylechui/nvim-surround")

		use("numToStr/Comment.nvim")
		-- use("f-person/auto-dark-mode.nvim")
		use("norcalli/nvim-colorizer.lua")

		use("j-hui/fidget.nvim")
		use("kevinhwang91/nvim-bqf")
		use("TamaMcGlinn/quickfixdd")

		use("mrshmllow/document-color.nvim")

		use("kwkarlwang/bufresize.nvim")

		use("dstein64/vim-startuptime")
		if packer_bootstrap then
			require("packer").sync()
		end
	end,
	config = {
		display = {
			open_fn = require("packer.util").float,
		},
	},
})
