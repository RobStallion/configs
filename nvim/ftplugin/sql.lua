vim.opt_local.path:append("dbt/models/**")
vim.opt_local.suffixesadd:prepend(".sql")

local function dbt_open(cmd)
  local line = vim.api.nvim_get_current_line()
  local model = line:match('dynamic_ref%("([^"]+)"')
  if model then
    local file = vim.fn.findfile(model .. ".sql", vim.o.path)
    if file ~= "" then
      vim.cmd(cmd .. " " .. file)
    else
      vim.notify("dbt model not found: " .. model, vim.log.levels.WARN)
    end
  else
    vim.cmd("normal! " .. (cmd == "edit" and "gf" or cmd == "vsplit" and "\x17vgf" or "\x17f"))
  end
end

vim.keymap.set("n", "gf",  function() dbt_open("edit")   end, { buffer = true, desc = "Go to dbt model" })
vim.keymap.set("n", "gvf", function() dbt_open("vsplit")  end, { buffer = true, desc = "Go to dbt model (vsplit)" })
vim.keymap.set("n", "gsf", function() dbt_open("split")   end, { buffer = true, desc = "Go to dbt model (split)" })
