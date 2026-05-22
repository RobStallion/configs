# Echo the active Catppuccin theme string ("Catppuccin Latte") from theme.conf,
# or empty if not set. Callers that want just the variant lowercase ("latte")
# can pipe through `awk '{print tolower($NF)}'`.
_theme_current() {
  local conf="$HOME/.config/ghostty/theme.conf"
  [[ -f "$conf" ]] && grep -o 'Catppuccin \w*' "$conf" | head -1
}

# Bootstrap BAT_THEME from theme.conf at shell startup. Kept in sync at runtime
# by the `theme` function below (which exports BAT_THEME after writing the conf).
export BAT_THEME="${$(_theme_current):-Catppuccin Mocha}"

theme() {
  local variant="${1:-}"
  if [[ -z "$variant" ]]; then
    local current
    current=$(_theme_current | awk '{print tolower($NF)}')
    # any non-latte variant (mocha, macchiato, frappe) toggles to latte and back
    variant=$([[ "$current" == "latte" ]] && echo "mocha" || echo "latte")
  fi

  local theme_conf="$HOME/.config/ghostty/theme.conf"

  local ghostty_theme
  case "$variant" in
    mocha)     ghostty_theme="Catppuccin Mocha"     ;;
    macchiato) ghostty_theme="Catppuccin Macchiato" ;;
    frappe)    ghostty_theme="Catppuccin Frappe"    ;;
    latte)     ghostty_theme="Catppuccin Latte"     ;;
    *) echo "Usage: theme [mocha|macchiato|frappe|latte]"; return 1 ;;
  esac

  echo "theme = ${ghostty_theme}" > "$theme_conf"
  export BAT_THEME="$ghostty_theme"
  pkill -USR2 Ghostty 2>/dev/null || pkill -USR2 ghostty 2>/dev/null || true
  echo "→ theme: ${variant}"
}
