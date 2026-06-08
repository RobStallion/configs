vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.clipboard = "unnamedplus"
vim.opt.wrap = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.undofile = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250

-- Tab settings
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2

-- Cursor styling: force insert-mode vertical bar to use the lCursor highlight group
-- for maximum visibility across both dark and light themes (e.g. rose-pine-dawn).
vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25-lCursor,r-cr-o:hor20,t:block-blinkon500-blinkoff500-TermCursor"
