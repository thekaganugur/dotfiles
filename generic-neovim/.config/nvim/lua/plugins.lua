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

		use("sainnhe/everforest") -- Colorscheme
		use("kyazdani42/nvim-web-devicons") -- Icon suport
		use("hoob3rt/lualine.nvim") -- Status bar

		---* Treesitter
		use({
			"nvim-treesitter/nvim-treesitter",
			"nvim-treesitter/playground",
			"nvim-treesitter/nvim-treesitter-textobjects",
			"JoosepAlviste/nvim-ts-context-commentstring",
			-- "windwp/nvim-ts-autotag",
			"RRethy/nvim-treesitter-endwise",
			run = ":TSUpdate",
		})

		use({ "bennypowers/nvim-ts-autotag", branch = "template-tags" })
		---* Treesitter

		---* Fuzzy Find
		use({ "nvim-telescope/telescope.nvim", requires = "nvim-lua/plenary.nvim" })
		use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })
		---* Fuzzy Find

		---* File explorer
		use({ "tamago324/lir.nvim", "tamago324/lir-git-status.nvim", requires = { "nvim-lua/plenary.nvim" } })
		use("vifm/vifm.vim")
		---* File explorer

		---* Git
		use("tpope/vim-fugitive")
		use({ "lewis6991/gitsigns.nvim", requires = "nvim-lua/plenary.nvim" })
		---* Git

		use("folke/which-key.nvim")
		use("folke/neodev.nvim")

		use({
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"neovim/nvim-lspconfig",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			"jose-elias-alvarez/null-ls.nvim",
			"jayp0521/mason-null-ls.nvim",
		})

		use({
			"hrsh7th/nvim-cmp",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"saadparwaiz1/cmp_luasnip",
			"L3MON4D3/LuaSnip",
			"rafamadriz/friendly-snippets",
			"onsails/lspkind.nvim", -- vscode-like icon for lsp completion items
		})

		use("windwp/nvim-autopairs")

		use("RRethy/vim-illuminate")

		use("lukas-reineke/lsp-format.nvim")
		use("stevearc/dressing.nvim")

		use("kylechui/nvim-surround")

		use("numToStr/Comment.nvim")
		-- use("f-person/auto-dark-mode.nvim")
		use("norcalli/nvim-colorizer.lua")
		use("mrshmllow/document-color.nvim")

		use("j-hui/fidget.nvim")

		use({ "kevinhwang91/nvim-bqf", "TamaMcGlinn/quickfixdd" })

		use("dstein64/vim-startuptime")

		use({
			"anuvyklack/windows.nvim",
			requires = {
				"anuvyklack/middleclass",
				"anuvyklack/animation.nvim",
			},
		})

		-- use({
		-- 	"vuki656/package-info.nvim",
		-- 	requires = "MunifTanjim/nui.nvim",
		-- 	config = function()
		-- 		require("package-info").setup()
		-- 	end,
		-- })
		if packer_bootstrap then
			require("packer").sync()
		end
	end,
})
