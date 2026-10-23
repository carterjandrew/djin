-- My minimal neovim setup

vim.opt.exrc = true
vim.opt.termguicolors = false
vim.opt.relativenumber = true
vim.opt.completeopt = { 'menuone', 'noselect', 'popup' }

vim.opt.tabstop = 2       -- Visual width of a actual tab character
vim.opt.shiftwidth = 2    -- Size of an indent (when using >>, <<, or auto-indent)
vim.opt.softtabstop = 2   -- Number of spaces that a Tab feels like while editing
vim.opt.expandtab = false -- Convert tabs to spaces (set to false if you want actual tabs)

require("config.lazy")
require("config.keys")

vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('my.lsp', {}),
	callback = function(ev)
		local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
		-- if client:supports_method('textDocument/implementation') then
		--   -- Create a keymap for vim.lsp.buf.implementation ...
		-- end

		-- Enable manual LSP completion: CTRL-Space opens the menu; CTRL-Y accepts.
		if client:supports_method('textDocument/completion') then
			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = false })
			vim.keymap.set('i', '<C-Space>', vim.lsp.completion.get, {
				buffer = ev.buf,
				desc = 'Show LSP completions',
			})
		end

		-- Auto-format ("lint") on save.
		-- Usually not needed if server supports "textDocument/willSaveWaitUntil".
		if not client:supports_method('textDocument/willSaveWaitUntil')
				and client:supports_method('textDocument/formatting') then
			vim.api.nvim_create_autocmd('BufWritePre', {
				group = vim.api.nvim_create_augroup('my.lsp', { clear = false }),
				buffer = ev.buf,
				callback = function()
					vim.lsp.buf.format({ bufnr = ev.buf, id = client.id, timeout_ms = 1000 })
				end,
			})
		end
	end,
})
