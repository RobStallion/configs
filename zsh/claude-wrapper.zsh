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
  tmp="$(mktemp "${TMPDIR:-/tmp}/claude-mcp.XXXXXX")" || return 1
  mv -- "${tmp}" "${tmp}.json"
  tmp="${tmp}.json"
  trap "rm -f -- '${tmp}'" EXIT INT TERM HUP

  local base='{"mcpServers": {}}'
  local git_root dir mcp_json=""
  git_root="$(git rev-parse --show-toplevel 2>/dev/null)"
  dir="${PWD}"
  while true; do
    if [[ -f "${dir}/.mcp.json" ]]; then
      base="$(cat -- "${dir}/.mcp.json")"
      mcp_json="${dir}/.mcp.json"
      break
    fi
    [[ -z "${git_root}" || "${dir}" == "${git_root}" || "${dir}" == "/" ]] && break
    dir="${dir:h}"
  done
  printf '%s' "${base}" > "${tmp}"

  local -a profile_args claude_args attached
  local parsing_profiles=true
  local arg
  for arg in "$@"; do
    if [[ "${arg}" == -* ]]; then
      claude_args+=("${arg}")
    elif [[ "$parsing_profiles" == "true" && -f "${HOME}/.mcp-profiles/${arg}.json" ]]; then
      profile_args+=("${arg}")
      local pfile="${HOME}/.mcp-profiles/${arg}.json"
      local merged
      merged="$(jq -s '.[0] * .[1]' "${tmp}" "${pfile}")" || return 1
      printf '%s' "${merged}" > "${tmp}"
      attached+=("${arg}")
    else
      parsing_profiles=false
      if [[ -z "${attached}" && ! "${arg}" =~ " " && "${arg}" != "help" ]]; then
        print -u2 "c: warning: '${arg}' is not a known profile; treating as prompt."
      fi
      claude_args+=("${arg}")
    fi
  done

  local summary="(no MCP servers)"
  if (( ${#attached[@]} > 0 )) && [[ -n "${mcp_json}" ]]; then
    summary=".mcp.json + ${(j:, :)attached}"
  elif (( ${#attached[@]} > 0 )); then
    summary="${(j:, :)attached}"
  elif [[ -n "${mcp_json}" ]]; then
    summary=".mcp.json"
  fi
  print -u2 "c: ${summary}"

  command claude --mcp-config "${tmp}" --strict-mcp-config "${claude_args[@]}"
}
