vim.keymap.set('n', '<leader>f', function()
	vim.lsp.buf.format()
end, { desc = 'Format current buffer' })

vim.keymap.set('v', '<leader>y', '"+y', { desc = 'Paste into userland clipboard' })

vim.keymap.set('i', '<C-BS>', '<C-o>vbd', { desc = 'Delete word backward' })

-- telescope keys
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
