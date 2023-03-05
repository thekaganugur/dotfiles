local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  "wbthomason/packer.nvim",

  "sainnhe/everforest", -- Colorscheme
  "folke/neodev.nvim",
  "kyazdani42/nvim-web-devicons", -- Icon suport, prerequirement
  "nvim-lua/plenary.nvim", -- Util, prerequirement
  "hoob3rt/lualine.nvim", -- Status bar

  -- Treesitter
  {
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
    "nvim-treesitter/playground",
    "nvim-treesitter/nvim-treesitter-textobjects",
    "JoosepAlviste/nvim-ts-context-commentstring",
    "windwp/nvim-ts-autotag",
    -- { "bennypowers/nvim-ts-autotag", branch = "template-tags" }, -- https://github.com/windwp/nvim-ts-autotag/pull/78
    "windwp/nvim-autopairs",
    "RRethy/nvim-treesitter-endwise",
  },

  -- Fuzzy Find
  {
    "nvim-telescope/telescope.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },

  -- File explorer
  {
    { "tamago324/lir.nvim", commit = "248f6b1da1f597e51513dd970672c7e57253f92a" },
    "tamago324/lir-git-status.nvim",
    "vifm/vifm.vim",
  },

  -- Git
  { "tpope/vim-fugitive",    "lewis6991/gitsigns.nvim",              "ruifm/gitlinker.nvim" },

  {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    "jose-elias-alvarez/null-ls.nvim",
    "jayp0521/mason-null-ls.nvim",
  },

  {
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "saadparwaiz1/cmp_luasnip",
    "L3MON4D3/LuaSnip",
    "rafamadriz/friendly-snippets",
    "onsails/lspkind.nvim", -- vscode-like icon for lsp completion items

    "hrsh7th/cmp-cmdline",
    "petertriho/cmp-git",
  },

  "lukas-reineke/lsp-format.nvim",
  "stevearc/dressing.nvim",
  "kylechui/nvim-surround",
  "numToStr/Comment.nvim",
  "NvChad/nvim-colorizer.lua",
  "RRethy/vim-illuminate",
  "j-hui/fidget.nvim",
  { "kevinhwang91/nvim-ufo", dependencies = "kevinhwang91/promise-async" },
  "folke/which-key.nvim",
  { "kevinhwang91/nvim-bqf", "TamaMcGlinn/quickfixdd" },
  { "utilyre/barbecue.nvim", dependencies = { "SmiteshP/nvim-navic" }, branch = "fix/E36" },
  "dstein64/vim-startuptime",
  { "anuvyklack/windows.nvim", dependencies = { "anuvyklack/middleclass", "anuvyklack/animation.nvim" } },
  "andrewferrier/debugprint.nvim",
})
