-- Minimal Neovim initialization for testing
vim.opt.runtimepath:append(".")
vim.opt.packpath:append(".")
vim.opt.termguicolors = true

-- Mock vim.g.vscode for VSCode tests
vim.g.vscode = false
