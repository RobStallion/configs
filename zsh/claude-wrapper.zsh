# c — Claude Code launcher with profile-based MCP server selection.
# See ADR-007. Profiles live in ~/.mcp-profiles/.
#
# Usage:
#   c                            # no MCP servers
#   c linear                     # + linear
#   c bigquery notion            # + two servers
#   c linear --resume            # flags pass through
c() {
  emulate -L zsh
  local tmp
  tmp="$(mktemp -t claude-mcp.XXXXXX.json)" || return 1
  trap "rm -f -- '${tmp}'" EXIT INT TERM HUP

  printf '%s' '{"mcpServers": {}}' > "${tmp}"

  local -a profile_args claude_args attached
  local arg
  for arg in "$@"; do
    if [[ "${arg}" == -* ]]; then
      claude_args+="${arg}"
    else
      profile_args+="${arg}"
    fi
  done

  for arg in "${profile_args[@]}"; do
    local pfile="${HOME}/.mcp-profiles/${arg}.json"
    if [[ ! -f "${pfile}" ]]; then
      print -u2 "c: no profile '${arg}' at ${pfile}"
      return 1
    fi
    local merged
    merged="$(jq -s '.[0] * .[1]' "${tmp}" "${pfile}")" || return 1
    printf '%s' "${merged}" > "${tmp}"
    attached+="${arg}"
  done

  local summary="(no MCP servers)"
  (( ${#attached[@]} > 0 )) && summary="${(j:, :)attached}"
  print -u2 "c: ${summary}"

  command claude --mcp-config "${tmp}" --strict-mcp-config "${claude_args[@]}"
}
