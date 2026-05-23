# Echo the active theme name in nvim colorscheme format (e.g. "catppuccin-latte")
# from ~/.config/theme, or empty if not set.
_theme_current() {
  local state="$HOME/.config/theme"
  [[ -f "$state" ]] && cat "$state"
}

# Maps the state file format (catppuccin-mocha) to the bat theme format (Catppuccin Mocha).
_theme_bat() {
  case "$(_theme_current)" in
    *mocha*)     echo "Catppuccin Mocha"     ;;
    *macchiato*) echo "Catppuccin Macchiato" ;;
    *frappe*)    echo "Catppuccin Frappe"    ;;
    *latte*)     echo "Catppuccin Latte"     ;;
    *)           echo "Catppuccin Mocha"     ;;
  esac
}

# Bootstrap BAT_THEME from the canonical theme state at shell startup.
# Kept in sync at runtime by the `theme` function below.
export BAT_THEME="${$(_theme_bat):-Catppuccin Mocha}"

theme() {
  local variant="${1:-}"
  if [[ -z "$variant" ]]; then
    local current="${$(_theme_current)##*-}"
    # any non-latte variant (mocha, macchiato, frappe) toggles to latte and back
    variant=$([[ "$current" == "latte" ]] && echo "mocha" || echo "latte")
  fi

  local state_file="$HOME/.config/theme"
  local theme_conf="$HOME/.config/ghostty/theme.conf"

  local ghostty_theme
  case "$variant" in
    mocha)     ghostty_theme="Catppuccin Mocha"     ;;
    macchiato) ghostty_theme="Catppuccin Macchiato" ;;
    frappe)    ghostty_theme="Catppuccin Frappe"    ;;
    latte)     ghostty_theme="Catppuccin Latte"     ;;
    *) echo "Usage: theme [mocha|macchiato|frappe|latte]"; return 1 ;;
  esac

  echo "catppuccin-${variant}" > "$state_file"
  echo "theme = ${ghostty_theme}" > "$theme_conf"
  export BAT_THEME="$ghostty_theme"
  pkill -USR2 Ghostty 2>/dev/null || pkill -USR2 ghostty 2>/dev/null || true
  echo "→ theme: ${variant}"
}
