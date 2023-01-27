require("plugins")
require("user.settings")
require("user.treesitter-config")
require("user.lualine-config")
require("user.lir-config")
require("user.nvim-web-devicons-config")
require("user.telescope-config")
require("user.which-key-config")
require("user.lsp")
require("user.cmp")
require("user.dressing")
require("user.autocommands")
require("user.autopairs")
require("user.illuminate")
require("user.comment")
require("user.windows")

require("colorizer").setup()
require("bqf").setup({ preview = { auto_preview = true } })
require("document-color").setup({ mode = "background" }) -- "background" | "foreground" | "single"
require("lir.git_status").setup()
require("gitsigns").setup()
require("nvim-surround").setup()
require("gitlinker").setup()
require("debugprint").setup({
	print_tag = "DEBUG",
	display_counter = false,
})

--------------
-- au FileType qf call AdjustWindowHeight(4, 8)
-- " au FileType fugitive call AdjustWindowHeight(8, 10)
-- function! AdjustWindowHeight(minheight, maxheight)
--   exe max([min([line("$"), a:maxheight]), a:minheight]) . "wincmd _"
-- endfunction
----------------

-- au BufRead,BufNewFile *.mdx setfiletype markdown
