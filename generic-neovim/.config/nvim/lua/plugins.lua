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
		use("folke/neodev.nvim")

		-- Treesitter
		use({
			{ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" },
			"nvim-treesitter/playground",
			"nvim-treesitter/nvim-treesitter-textobjects",
			"nvim-treesitter/nvim-treesitter-context",
			"JoosepAlviste/nvim-ts-context-commentstring",
			-- "windwp/nvim-ts-autotag",
			{ "bennypowers/nvim-ts-autotag", branch = "template-tags" }, -- https://github.com/windwp/nvim-ts-autotag/pull/78
			"windwp/nvim-autopairs",
			"RRethy/nvim-treesitter-endwise",
		})

		-- Fuzzy Find
		use({
			{ "nvim-telescope/telescope.nvim", requires = "nvim-lua/plenary.nvim" },
			{ "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
		})

		-- File explorer
		use({
			{ "tamago324/lir.nvim", "tamago324/lir-git-status.nvim", requires = { "nvim-lua/plenary.nvim" } },
			"vifm/vifm.vim",
		})

		-- Git
		use({
			"tpope/vim-fugitive",
			"lewis6991/gitsigns.nvim",
			{ "ruifm/gitlinker.nvim", requires = "nvim-lua/plenary.nvim" },
		})

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

		use("lukas-reineke/lsp-format.nvim")
		use("stevearc/dressing.nvim")
		use("kylechui/nvim-surround")
		use("numToStr/Comment.nvim")
		use("norcalli/nvim-colorizer.lua")
		use("mrshmllow/document-color.nvim")
		use("RRethy/vim-illuminate")
		use("j-hui/fidget.nvim")
		use({ "kevinhwang91/nvim-ufo", requires = "kevinhwang91/promise-async" })

		use("folke/which-key.nvim")
		use({ "kevinhwang91/nvim-bqf", "TamaMcGlinn/quickfixdd" })
		use("dstein64/vim-startuptime")
		use({
			"anuvyklack/windows.nvim",
			requires = {
				"anuvyklack/middleclass",
				"anuvyklack/animation.nvim",
			},
		})

		use("andrewferrier/debugprint.nvim")

		if packer_bootstrap then
			require("packer").sync()
		end
	end,
})
