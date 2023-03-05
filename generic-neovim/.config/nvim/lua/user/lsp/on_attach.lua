vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    require("user.lsp.keymaps")(bufnr)
    if require("user.lsp.utils").get_format_allowed(client, bufnr) then
      require("lsp-format").on_attach(client)
    end
  end,
})
