-- Tracks the tmux pane ID of the last runner opened this session.
-- Persists across invocations so <leader>rf can kill the old pane before opening a new one.
local runner_pane_id = nil

-- Wraps `cmd filepath` in a bash invocation that keeps the pane alive after the process exits.
-- Two levels of shellescape are intentional: inner quotes filepath for bash, outer quotes the
-- whole inner string as a single argument to `bash -c`. Collapsing them breaks paths with spaces.
local function make_pane_cmd(cmd, filepath, args)
  local inner = cmd .. ' ' .. vim.fn.shellescape(filepath)
  if args and args ~= '' then
    inner = inner .. ' ' .. args
  end
  inner = inner .. '; echo; read -rn1 -p "[done — press any key]"'
  return 'bash -c ' .. vim.fn.shellescape(inner)
end

-- LSP-keyed runners are checked first. The same filetype can attach different LSPs
-- (e.g. an orphan JS file gets deno; a Node project gets vtsls), so filetype alone
-- is not sufficient to pick the right runner in those cases.
local lsp_runners = {
  deno = function(fp, args) return make_pane_cmd('deno run --allow-all', fp, args) end,
  vtsls = function(fp, args) return make_pane_cmd('node', fp, args) end,
}

-- Filetype-keyed runners are the fallback for languages with no LSP ambiguity.
local ft_runners = {
  python = function(fp, args) return make_pane_cmd('python3', fp, args) end,
  go = function(fp, args) return make_pane_cmd('go run', fp, args) end,
  elixir = function(fp, args) return make_pane_cmd('elixir', fp, args) end,
  sh = function(fp, args) return make_pane_cmd('bash', fp, args) end,
  zsh = function(fp, args) return make_pane_cmd('zsh', fp, args) end,
  lua = function(fp, args) return make_pane_cmd('lua', fp, args) end,
  bun = function(fp, args) return make_pane_cmd('bun run', fp, args) end,
}

local function resolve_runner(filepath, args)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    if lsp_runners[client.name] then
      return lsp_runners[client.name](filepath, args)
    end
  end
  local ft_runner = ft_runners[vim.bo.filetype]
  return ft_runner and ft_runner(filepath, args)
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

  vim.ui.input({ prompt = 'Args: ' }, function(args)
    if args == nil then return end  -- user cancelled with <Esc>

    local run_cmd = resolve_runner(filepath, args)

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
        'tmux split-window -v -l 30%% -P -F "#{pane_id}" %s',
        vim.fn.shellescape(run_cmd)
      ))
    )
    runner_pane_id = pane_id ~= '' and pane_id or nil
  end)
end

return { run = run }
