# Claude Code env vars.
# Auth tokens + base URL live in .zsh_secrets (gitignored).

# export CLAUDE_CODE_EFFORT_LEVEL='max'

# Opt out of experimental betas — they were intermittently breaking Claude Code.
# Re-evaluate when a feature ships stable.
export CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1

# Caveman plugin: off by default, invoke manually with /caveman.
export CAVEMAN_DEFAULT_MODE=off
