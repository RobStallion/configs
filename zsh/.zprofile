# .zprofile — login shell only
#
# This file runs once when Ghostty opens a new window (login shell).
# Everything here is an environment variable (PATH and friends) — these are
# inherited by all child processes automatically, so tmux panes, sub-shells,
# and scripts all get them without re-running this file.
#
# Rule: PATH changes and exported env vars live here.
#       Aliases, functions, and prompt config live in .zshrc.

# ── Homebrew ──────────────────────────────────────────────────────────────────
# brew shellenv sets PATH, FPATH, MANPATH, INFOPATH, and HOMEBREW_* vars.
# Without it, nothing installed via brew would be found (on Apple Silicon,
# brew lives at /opt/homebrew, which isn't on the default PATH).
#
# We cache the output to a file so we don't spawn a subprocess on every shell
# start. The cache is regenerated automatically whenever brew itself is updated
# (detected by comparing file modification times with -nt).
_brew_cache="$HOME/.cache/zsh_brew_env"
if [[ ! -f "$_brew_cache" || /opt/homebrew/bin/brew -nt "$_brew_cache" ]]; then
  # Either no cache yet, or brew was updated — regenerate it
  mkdir -p "$HOME/.cache"
  /opt/homebrew/bin/brew shellenv > "$_brew_cache"
fi
source "$_brew_cache"   # load the cached env vars into this shell
unset _brew_cache       # clean up — no reason for this var to leak into the environment

# ── deno ──────────────────────────────────────────────────────────────────────
# Adds ~/.deno/bin to PATH so the `deno` binary can be found.
[ -f "$HOME/.deno/env" ] && . "$HOME/.deno/env"

# ── bun ───────────────────────────────────────────────────────────────────────
# BUN_INSTALL is where bun lives. We export it so other tools can reference it,
# then add its bin/ dir to PATH.
# The case block is a guard — prevents duplicating the PATH entry if this file
# is somehow sourced more than once.
export BUN_INSTALL="$HOME/.bun"
case ":${PATH}:" in
    *:"$BUN_INSTALL/bin":*)
        ;;  # already on PATH, do nothing
    *)
        export PATH="$BUN_INSTALL/bin:$PATH"
        ;;
esac

# ── mise ──────────────────────────────────────────────────────────────────────
# cpython 3.13.0 predates mise's attestation support; disable for installs.
# Safe to remove when Python is upgraded to a version that has attestations.
export MISE_PYTHON_GITHUB_ATTESTATIONS=false

# ── cargo (Rust) ──────────────────────────────────────────────────────────────
# Adds ~/.cargo/bin to PATH so Rust-installed binaries (e.g. ripgrep, bat) are found.
# Appended rather than prepended so brew versions of tools (rg, bat) win — they're
# kept up to date by `brew upgrade`, whereas cargo-installed binaries are not.
case ":${PATH}:" in
    *:"$HOME/.cargo/bin":*)
        ;;  # already on PATH, do nothing
    *)
        export PATH="$PATH:$HOME/.cargo/bin"
        ;;
esac

# ── uv (Python) ───────────────────────────────────────────────────────────────
# Adds ~/.local/bin to PATH so the `uv` binary can be found.
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# ── Editor ────────────────────────────────────────────────────────────────────
# Used by git commit (no -m), kubectl edit, crontab -e, Ctrl+X+E in zsh, etc.
# Without this, those tools fall back to system vi, not nvim.
export EDITOR=nvim
export VISUAL=nvim
export MANPAGER='nvim +Man!'

# ── starship ──────────────────────────────────────────────────────────────────
# Starship looks for ~/.config/starship.toml by default. Our config lives in
# ~/.config/starship/starship.toml (whole dir symlinked from the repo), so
# point STARSHIP_CONFIG at it explicitly.
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
