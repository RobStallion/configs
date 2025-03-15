-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Set leader key before lazy
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Initialize lazy.nvim
require("lazy").setup("plugins")

-- Basic Settings
vim.opt.number = true
vim.opt.relativenumber = false

-- Indentation
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true

-- Search improvements
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Performance and UX
vim.opt.updatetime = 300
vim.opt.timeoutlen = 500

-- Some extra quality of life improvements
vim.opt.hidden = true        -- Allow switching buffers without saving
vim.opt.termguicolors = true -- Enable 24-bit RGB colors
vim.opt.cursorline = true    -- Highlight the current line
vim.opt.signcolumn = "yes"   -- Always show the signcolumn
