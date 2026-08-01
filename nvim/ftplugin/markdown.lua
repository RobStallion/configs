vim.opt_local.spell = true
vim.opt_local.spelllang = "en_gb"
-- Disable "capitalise after period" — fires false positives on abbreviations like "vs."
vim.opt_local.spellcapcheck = ""

-- Easy navigation of spelling errors (similar to n/N for search)
vim.keymap.set("n", "<C-n>", "]s", { buffer = true, desc = "Next spelling error" })
vim.keymap.set("n", "<C-p>", "[s", { buffer = true, desc = "Prev spelling error" })
