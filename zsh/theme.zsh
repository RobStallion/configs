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

theme() {
  local variant="${1:-}"
  if [[ -z "$variant" ]]; then
    local current="${$(_theme_current)##*-}"
    variant=$([[ "$current" == "latte" ]] && echo "mocha" || echo "latte")
  fi

  case "$variant" in
    mocha|macchiato|frappe|latte) ;;
    *) echo "Usage: theme [mocha|macchiato|frappe|latte]"; return 1 ;;
  esac

  echo "catppuccin-${variant}" > "$HOME/.config/theme"
  export BAT_THEME="$(_theme_display_name)"
  _theme_sync_ghostty
  pkill -USR2 Ghostty 2>/dev/null || pkill -USR2 ghostty 2>/dev/null || true
  echo "→ theme: ${variant}"
}
