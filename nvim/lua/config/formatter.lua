local M = {}

-- Helper to format markdown reflow via stdin
local function format_markdown_reflow(lines, start_line, end_line)
  local content = table.concat(lines, "\n")
  local filename = vim.api.nvim_buf_get_name(0)
  local cmd = {
    "rumdl", "fmt", "--stdin",
    "--config", "MD013.reflow = true",
    "--config", "MD013.enabled = true",
  }
  if filename ~= "" then
    table.insert(cmd, "--stdin-filename")
    table.insert(cmd, filename)
  end

  local obj = vim.system(cmd, { stdin = content }):wait()
  if obj.code == 0 and obj.stdout and obj.stdout ~= "" then
    local formatted = vim.split(obj.stdout, "\r?\n")
    if formatted[#formatted] == "" then table.remove(formatted) end
    vim.api.nvim_buf_set_lines(0, start_line, end_line, false, formatted)
    return true
  end
  return false
end

-- Helper to format JSON via jq
local function format_json(lines, start_line, end_line)
  local content = table.concat(lines, "\n")
  local obj = vim.system({ "jq", "." }, { stdin = content }):wait()
  if obj.code == 0 and obj.stdout and obj.stdout ~= "" then
    local formatted = vim.split(obj.stdout, "\r?\n")
    if formatted[#formatted] == "" then table.remove(formatted) end
    vim.api.nvim_buf_set_lines(0, start_line, end_line, false, formatted)
    return true
  end
  return false
end

-- Format the entire file
function M.format_file()
  if vim.bo.filetype == 'markdown' then
    if format_markdown_reflow(vim.api.nvim_buf_get_lines(0, 0, -1, false), 0, -1) then
      vim.notify("Markdown reflowed successfully!", vim.log.levels.INFO)
    else
      vim.notify("Markdown reflow failed", vim.log.levels.ERROR)
    end
  else
    vim.lsp.buf.format({ async = true })
  end
end

-- Format the visually selected fragment
function M.format_selection()
  -- Exit visual mode to save '< and '> marks
  vim.cmd('normal! \x1b')
  
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_line = start_pos[2] - 1
  local end_line = end_pos[2]
  
  if start_line < 0 or end_line < 0 then
    vim.notify("No visual selection found", vim.log.levels.WARN)
    return
  end
  
  local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
  if #lines == 0 then return end
  
  local content = table.concat(lines, "\n")
  
  -- Auto-detect JSON
  if content:match("^%s*[{%[]") then
    if format_json(lines, start_line, end_line) then
      vim.notify("Formatted selection as JSON", vim.log.levels.INFO)
      return
    end
  end
  
  -- Fallback interactive selector
  vim.ui.select({
    "JSON (jq)",
    "Markdown (rumdl)",
    "LSP / Standard Format",
    "Cancel"
  }, {
    prompt = "Format selection as:"
  }, function(choice)
    if choice == "JSON (jq)" then
      if format_json(lines, start_line, end_line) then
        vim.notify("Formatted selection as JSON", vim.log.levels.INFO)
      else
        vim.notify("JSON formatting failed", vim.log.levels.ERROR)
      end
    elseif choice == "Markdown (rumdl)" then
      if format_markdown_reflow(lines, start_line, end_line) then
        vim.notify("Formatted selection as Markdown", vim.log.levels.INFO)
      else
        vim.notify("Markdown formatting failed", vim.log.levels.ERROR)
      end
    elseif choice == "LSP / Standard Format" then
      local range = {
        start = { start_pos[2], start_pos[3] },
        ["end"] = { end_pos[2], end_pos[3] }
      }
      vim.lsp.buf.format({ range = range, async = true })
    end
  end)
end

return M
