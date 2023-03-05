require("plugins")
require("user.settings")
require("user.treesitter-config")
require("user.lualine-config")
require("user.lir-config")
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

require("nvim-web-devicons").setup({ default = true })
require("colorizer").setup({ user_default_options = { tailwind = true } })
require("bqf").setup({ preview = { auto_preview = true } })
require("lir.git_status").setup()
require("gitsigns").setup()
require("nvim-surround").setup()
require("gitlinker").setup()
require("debugprint").setup({
  print_tag = "DEBUG",
  display_counter = false,
})
require("barbecue").setup({
  show_dirname = false,
  kinds = require("lspkind").symbol_map,
})
