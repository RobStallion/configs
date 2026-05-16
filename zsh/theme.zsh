theme() {
  local theme_conf="$HOME/.config/ghostty/theme.conf"

  local variant="${1:-}"
  if [[ -z "$variant" ]]; then
    local current=""
    [[ -f "$theme_conf" ]] && current=$(grep -o 'Catppuccin \w*' "$theme_conf" | awk '{print tolower($NF)}')
    # any non-latte variant (mocha, macchiato, frappe) toggles to latte and back
    variant=$([[ "$current" == "latte" ]] && echo "mocha" || echo "latte")
  fi

  local ghostty_theme
  case "$variant" in
    mocha)     ghostty_theme="Catppuccin Mocha"     ;;
    macchiato) ghostty_theme="Catppuccin Macchiato" ;;
    frappe)    ghostty_theme="Catppuccin Frappe"    ;;
    latte)     ghostty_theme="Catppuccin Latte"     ;;
    *) echo "Usage: theme [mocha|macchiato|frappe|latte]"; return 1 ;;
  esac

  echo "theme = ${ghostty_theme}" > "$theme_conf"
  pkill -USR2 Ghostty 2>/dev/null || pkill -USR2 ghostty 2>/dev/null || true
  echo "→ theme: ${variant}"
}
