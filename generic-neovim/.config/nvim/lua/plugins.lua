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
    use("folke/neodev.nvim")
    use("kyazdani42/nvim-web-devicons") -- Icon suport, prerequirement
    use("nvim-lua/plenary.nvim") -- Util, prerequirement
    use("hoob3rt/lualine.nvim") -- Status bar

    -- Treesitter
    use({
      { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" },
      "nvim-treesitter/playground",
      "nvim-treesitter/nvim-treesitter-textobjects",
      "JoosepAlviste/nvim-ts-context-commentstring",
      "windwp/nvim-ts-autotag",
      -- { "bennypowers/nvim-ts-autotag", branch = "template-tags" }, -- https://github.com/windwp/nvim-ts-autotag/pull/78
      "windwp/nvim-autopairs",
      "RRethy/nvim-treesitter-endwise",
    })

    -- Fuzzy Find
    use({
      "nvim-telescope/telescope.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
    })

    -- File explorer
    use({
      { "tamago324/lir.nvim", commit = "248f6b1da1f597e51513dd970672c7e57253f92a" },
      "tamago324/lir-git-status.nvim",
      "vifm/vifm.vim",
    })

    -- Git
    use({ "tpope/vim-fugitive", "lewis6991/gitsigns.nvim", "ruifm/gitlinker.nvim" })

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

      "hrsh7th/cmp-cmdline",
      "petertriho/cmp-git",
    })

    use("lukas-reineke/lsp-format.nvim")
    use("stevearc/dressing.nvim")
    use("kylechui/nvim-surround")
    use("numToStr/Comment.nvim")
    use("NvChad/nvim-colorizer.lua")
    use("RRethy/vim-illuminate")
    use("j-hui/fidget.nvim")
    use({ "kevinhwang91/nvim-ufo", requires = "kevinhwang91/promise-async" })
    use("folke/which-key.nvim")
    use({ "kevinhwang91/nvim-bqf", "TamaMcGlinn/quickfixdd" })
    use({ "utilyre/barbecue.nvim", requires = { "SmiteshP/nvim-navic" }, branch = "fix/E36" })
    use("dstein64/vim-startuptime")
    use({ "anuvyklack/windows.nvim", requires = { "anuvyklack/middleclass", "anuvyklack/animation.nvim" } })
    use("andrewferrier/debugprint.nvim")

    if packer_bootstrap then
      require("packer").sync()
    end
  end,
})
