require("config.options")
require("config.autocmds")
require("config.diagnostic")
require("config.keymaps")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo(
			{ { "Failed to clone lazy.nvim:\n", "ErrorMsg" }, { out, "WarningMsg" }, { "\nPress any key to exit..." } },
			true,
			{}
		)
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
	spec = { { import = "plugins" } },
	checker = { enabled = true, notify = false },
	change_detection = { notify = false },
})

vim.opt.diffopt:append("vertical")

vim.api.nvim_create_autocmd("User", {
	pattern = "FugitiveIndex",
	callback = function(event)
		vim.keymap.set("n", "D", function()
			local line = vim.api.nvim_get_current_line()

			-- Matches:
			-- abc1234 Commit message
			-- pick abc1234 Commit message
			local commit = line:match("^([0-9a-f]+)%s") or line:match("^%l+%s+([0-9a-f]+)%s")

			if not commit or #commit < 4 then
				vim.notify("Fugitive: cursor is not on a commit", vim.log.levels.WARN)
				return
			end

			-- Compare the commit against its first parent.
			vim.cmd(("Git difftool -y %s^1 %s"):format(commit, commit))
		end, {
			buffer = event.buf,
			silent = true,
			desc = "Open commit as vertical diffs",
		})
	end,
})

_G.fugitive_commit_foldtext = function()
	local line = vim.fn.getline(vim.v.foldstart)

	local old_path, new_path = line:match("^diff %-%-git a/(.-) b/(.-)$")

	if old_path and new_path then
		if old_path == new_path then
			return "  " .. new_path
		end

		return ("  %s → %s"):format(old_path, new_path)
	end

	return line
end

vim.api.nvim_create_autocmd("User", {
	pattern = "FugitiveCommit",
	callback = function()
		vim.opt_local.foldmethod = "syntax"
		vim.opt_local.foldenable = true
		vim.opt_local.foldlevel = 0
		vim.opt_local.foldtext = "v:lua.fugitive_commit_foldtext()"
	end,
})

local group = vim.api.nvim_create_augroup("FugitiveCommitReview", { clear = true })

vim.api.nvim_create_autocmd("User", {
	group = group,
	pattern = "FugitiveCommit",
	callback = function(args)
		vim.keymap.set("n", "D", function()
			-- Preserve the commit view in the original tab.
			vim.cmd("tab split")

			-- Replay the working <Enter> mapping in the new tab.
			vim.schedule(function()
				local enter = vim.api.nvim_replace_termcodes("<CR>", true, false, true)

				vim.api.nvim_feedkeys(enter, "m", false)
			end)
		end, {
			buffer = args.buf,
			silent = true,
			desc = "Open selected commit file diff in new tab",
		})
	end,
})
