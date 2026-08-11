# Echo the active theme name in nvim colorscheme format (e.g. "catppuccin-latte")
# from ~/.config/theme, or empty if not set.
_theme_current() {
  local state="$HOME/.config/theme"
  [[ -f "$state" ]] && cat "$state"
}

# Catppuccin canonical format (catppuccin-mocha) → display name (Catppuccin Mocha).
# Used by BAT_THEME and Ghostty's theme.conf.
_theme_display_name() {
  case "$(_theme_current)" in
    *mocha*)     echo "Catppuccin Mocha"     ;;
    *macchiato*) echo "Catppuccin Macchiato" ;;
    *frappe*)    echo "Catppuccin Frappe"    ;;
    *latte*)     echo "Catppuccin Latte"     ;;
    *)           echo "Catppuccin Mocha"     ;;
  esac
}

# Regenerate Ghostty's theme.conf from the canonical state file.
# theme.conf is a derived artifact — never edit it directly.
_theme_sync_ghostty() {
  echo "theme = $(_theme_display_name)" > "$HOME/.config/ghostty/theme.conf"
}

# Bootstrap: sync Ghostty and BAT_THEME from the canonical theme state at shell startup.
_theme_sync_ghostty
export BAT_THEME="$(_theme_display_name)"

# Write the canonical state file and propagate to bat/Ghostty/tmux.
# family/variant are joined as-is (e.g. "catppuccin" + "mocha" → "catppuccin-mocha")
# so they must already match the nvim colorscheme naming for that family.
_theme_set() {
  local family="$1" variant="$2"
  echo "${family}-${variant}" > "$HOME/.config/theme"
  export BAT_THEME="$(_theme_display_name)"
  _theme_sync_ghostty
  touch "$HOME/.config/ghostty/config"
  pkill -USR2 Ghostty 2>/dev/null || pkill -USR2 ghostty 2>/dev/null || true
  if tmux info &>/dev/null; then
    tmux source-file ~/.config/tmux/tmux.conf 2>/dev/null || true
  fi
  echo "→ theme: ${family} ${variant}"
}

# Usage: theme <family> <variant>, e.g. `theme catppuccin mocha`.
# No args toggles catppuccin mocha ↔ latte (doesn't generalize to other families).
theme() {
  if [[ $# -eq 0 ]]; then
    local current="${$(_theme_current)##*-}"
    local variant=$([[ "$current" == "latte" ]] && echo "mocha" || echo "latte")
    _theme_set catppuccin "$variant"
    return
  fi

  if [[ $# -ne 2 ]]; then
    echo "Usage: theme <family> <variant>"
    echo "  theme catppuccin [mocha|macchiato|frappe|latte]"
    return 1
  fi

  local family="$1" variant="$2"
  case "$family" in
    catppuccin)
      case "$variant" in
        mocha|macchiato|frappe|latte) ;;
        *) echo "Usage: theme catppuccin [mocha|macchiato|frappe|latte]"; return 1 ;;
      esac
      ;;
    *)
      echo "Unknown theme family: $family (available: catppuccin)"
      return 1
      ;;
  esac

  _theme_set "$family" "$variant"
}

# Completion for theme: family first, then variants for that family.
_theme_complete() {
  local -a families
  families=(catppuccin)

  if (( CURRENT == 2 )); then
    _describe -t families 'family' families
  elif (( CURRENT == 3 )); then
    local -a variants
    case "${words[2]}" in
      catppuccin) variants=(mocha macchiato frappe latte) ;;
    esac
    _describe -t variants 'variant' variants
  fi
}
compdef _theme_complete theme
