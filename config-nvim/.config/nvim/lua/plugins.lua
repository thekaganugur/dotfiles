vim.cmd("autocmd BufWritePost plugins.lua PackerCompile") -- Auto compile when there are changes in plugins.lua
vim.cmd([[packadd packer.nvim]])

return require("packer").startup(function(use)
	use("wbthomason/packer.nvim")

	use("sainnhe/everforest") -- Theme

	---* Treesitter
	use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" })
	use({ "JoosepAlviste/nvim-ts-context-commentstring" }) -- tree-sitter based commenting
	use("windwp/nvim-ts-autotag")
	---* Treesitter

	use({ "hoob3rt/lualine.nvim", requires = "kyazdani42/nvim-web-devicons" }) -- Status bar

	---* Fuzzy Find
	use({
		"nvim-telescope/telescope.nvim",
		requires = { { "nvim-lua/popup.nvim" }, { "nvim-lua/plenary.nvim" } },
	})
	use("fannheyward/telescope-coc.nvim")
	use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })
	---* Fuzzy Find

	---* File explorer
	use({
		"tamago324/lir.nvim",
		requires = { "kyazdani42/nvim-web-devicons", "nvim-lua/plenary.nvim" },
	})
	use("tamago324/lir-git-status.nvim")
	use("is0n/fm-nvim") -- Vifm integration
	---* File explorer

	---* Git
	use("tpope/vim-fugitive")
	use({ "lewis6991/gitsigns.nvim", requires = "nvim-lua/plenary.nvim" })
	use("junegunn/gv.vim")
	---* Git

	use({ "neoclide/coc.nvim", branch = "release" })
	use("honza/vim-snippets")

	use("tpope/vim-repeat")
	use("tpope/vim-surround")
	use("tpope/vim-commentary")
	use("tpope/vim-eunuch")

	use("szw/vim-maximizer")
	use("folke/which-key.nvim")

	use("antoinemadec/FixCursorHold.nvim") --Fix CursorHold Performance.

	use("mbbill/undotree")

	-- use("metakirby5/codi.vim")
	-- use({ "0x100101/lab.nvim", run = "cd js && npm ci" })
	-- use({ "TimUntersberger/neogit", requires = "nvim-lua/plenary.nvim" })
end)
