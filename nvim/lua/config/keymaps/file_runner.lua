-- Tracks the tmux pane ID of the last runner opened this session.
-- Persists across invocations so <leader>rf can kill the old pane before opening a new one.
local runner_pane_id = nil

-- Wraps `cmd filepath` in a bash invocation that keeps the pane alive after the process exits.
-- Two levels of shellescape are intentional: inner quotes filepath for bash, outer quotes the
-- whole inner string as a single argument to `bash -c`. Collapsing them breaks paths with spaces.
local function make_pane_cmd(cmd, filepath)
  local inner = cmd .. ' ' .. vim.fn.shellescape(filepath) .. '; echo; read -rn1 -p "[done — press any key]"'
  return 'bash -c ' .. vim.fn.shellescape(inner)
end

-- LSP-keyed runners are checked first. The same filetype can attach different LSPs
-- (e.g. an orphan JS file gets deno; a Node project gets vtsls), so filetype alone
-- is not sufficient to pick the right runner in those cases.
local lsp_runners = {
  deno = function(fp) return make_pane_cmd('deno run --allow-all', fp) end,
}

-- Filetype-keyed runners are the fallback for languages with no LSP ambiguity.
local ft_runners = {
  python = function(fp) return make_pane_cmd('python3', fp) end,
}

local function resolve_runner(filepath)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    if lsp_runners[client.name] then
      return lsp_runners[client.name](filepath)
    end
  end
  local ft_runner = ft_runners[vim.bo.filetype]
  return ft_runner and ft_runner(filepath)
end

local function run()
  if not vim.env.TMUX then
    vim.notify('RunFile: not inside tmux', vim.log.levels.WARN)
    return
  end

  if vim.fn.expand('%') == '' then
    vim.notify('RunFile: buffer has no file', vim.log.levels.WARN)
    return
  end

  local filepath = vim.fn.expand('%:p')
  local run_cmd = resolve_runner(filepath)

  if not run_cmd then
    vim.notify('RunFile: no runner configured for this buffer', vim.log.levels.WARN)
    return
  end

  vim.cmd('silent write')

  if runner_pane_id then
    vim.fn.system('tmux kill-pane -t ' .. runner_pane_id .. ' 2>/dev/null')
  end

  -- -v: split below; -l 30%: new pane takes 30% of window height; -d: keep focus in nvim
  -- -P -F "#{pane_id}": print the new pane's ID so we can kill it on the next invocation
  local pane_id = vim.fn.trim(
    vim.fn.system(string.format(
      'tmux split-window -v -l 30%% -d -P -F "#{pane_id}" %s',
      vim.fn.shellescape(run_cmd)
    ))
  )
  runner_pane_id = pane_id ~= '' and pane_id or nil
end

return { run = run }
