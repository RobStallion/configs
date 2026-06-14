#!/usr/bin/env bash
# configs/install.sh — Automatic setup script for config symlinks and dependencies.
#
# Usage:
#   ./install.sh
#

set -euo pipefail

# Invariants & Setup Paths
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config_backups_$(date +%Y%m%d_%H%M%S)"

# Color variables for nice status reporting
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Starting Configs Installation ===${NC}"

# Check OS compatibility
if [[ "$OSTYPE" != "darwin"* ]]; then
  echo -e "${RED}Warning: This configuration repository is optimized for macOS.${NC}"
  read -r -p "Do you want to proceed anyway? (y/N) " confirm
  if [[ ! "$confirm" =~ ^[yY]$ ]]; then
    exit 1
  fi
fi

# Ensure backup directory will only be created on demand
backup_needed=false

# Helper function to create symlinks with backups
link_item() {
  local src="$1"
  local dest="$2"
  local description="${3:-}"

  # Expand tilde in destination path
  dest="${dest/#\~/$HOME}"

  # Check if destination already exists
  if [[ -e "$dest" || -L "$dest" ]]; then
    # Skip if it is already a symlink pointing to the correct source
    if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
      echo -e "  [Existing] $dest already linked correctly."
      return 0
    fi

    # Prepare backup directory on first need
    if [[ "$backup_needed" == "false" ]]; then
      mkdir -p "$BACKUP_DIR"
      backup_needed=true
      echo -e "${YELLOW}Backing up existing files to: $BACKUP_DIR${NC}"
    fi

    # Backup the existing file/directory
    local backup_target="$BACKUP_DIR/$(basename "$dest")"
    mv "$dest" "$backup_target"
    echo -e "  [Backup] Moved $dest to $backup_target"
  fi

  # Ensure destination parent directory exists
  mkdir -p "$(dirname "$dest")"

  # Create symlink
  ln -s "$src" "$dest"
  if [[ -n "$description" ]]; then
    echo -e "  ${GREEN}[Linked]${NC} $dest -> $src ($description)"
  else
    echo -e "  ${GREEN}[Linked]${NC} $dest -> $src"
  fi
}

echo -e "\n${GREEN}--- Linking configuration files ---${NC}"

# Define the maps of sources in REPO_DIR to targets in $HOME
# Format: link_item "source" "destination" "description"
link_item "$REPO_DIR/nvim" "~/.config/nvim" "Neovim config"
link_item "$REPO_DIR/ghostty" "~/.config/ghostty" "Ghostty Terminal config"
link_item "$REPO_DIR/zsh" "~/.config/zsh" "Zsh modules directory"
link_item "$REPO_DIR/zsh/.zshrc" "~/.zshrc" "Zsh runtime configuration"
link_item "$REPO_DIR/zsh/.zprofile" "~/.zprofile" "Zsh environment variables"
link_item "$REPO_DIR/starship" "~/.config/starship" "Starship prompt theme"
link_item "$REPO_DIR/mise/config.toml" "~/.config/mise/config.toml" "Mise CLI tools manager config"
link_item "$REPO_DIR/tmux" "~/.config/tmux" "Tmux multiplexer config"
link_item "$REPO_DIR/git/gitconfig" "~/.gitconfig" "Global Git settings"
link_item "$REPO_DIR/git/gitignore" "~/.gitignore_global" "Global Git ignore rules"
link_item "$REPO_DIR/fd/ignore" "~/.config/fd/ignore" "Global fd finder ignores"
link_item "$REPO_DIR/theme" "~/.config/theme" "Global theme state (Catppuccin)"

# ── Git Invariants ────────────────────────────────────────────────────────────
echo -e "\n${GREEN}--- Setting up local Git indexes ---${NC}"
# Set theme to skip-worktree so local runtime changes don't dirty the git status
(cd "$REPO_DIR" && git update-index --skip-worktree theme 2>/dev/null && echo "  [Git] Marked 'theme' as skip-worktree.") || true

# ── Homebrew Bundle ───────────────────────────────────────────────────────────
echo -e "\n${GREEN}--- Installing Homebrew dependencies ---${NC}"
if command -v brew >/dev/null 2>&1; then
  echo "  Running 'brew bundle --no-lock'..."
  brew bundle --no-lock --file="$REPO_DIR/Brewfile"
else
  echo -e "${YELLOW}  Warning: 'brew' not found. Skip bundle install.${NC}"
fi

# ── Claude Statusline Compilation ──────────────────────────────────────────────
echo -e "\n${GREEN}--- Compiling Claude Code statusline command ---${NC}"
if command -v cargo >/dev/null 2>&1; then
  echo "  Running 'cargo build --release'..."
  if cargo build --release --manifest-path "$REPO_DIR/claude/statusline/Cargo.toml"; then
    link_item "$REPO_DIR/claude/statusline/target/release/statusline" "~/.claude/statusline-command" "Claude statusline executable"
  else
    echo -e "${RED}  Error: Cargo build failed. Skipping binary linking.${NC}"
  fi
else
  echo -e "${YELLOW}  Warning: 'cargo' tool not found. Skip building Claude statusline.${NC}"
  echo "  (Please install Rust/Cargo, run 'cargo build --release' under claude/statusline/,"
  echo "  and link the output binary to ~/.claude/statusline-command)"
fi

# ── Completion & Tips ─────────────────────────────────────────────────────────
echo -e "\n${GREEN}=== Installation Complete! ===${NC}"
echo -e "To load the new shell configuration immediately, run:"
echo -e "  ${GREEN}source ~/.zshrc${NC}  (or use the ${GREEN}sz${NC} alias)"
echo -e "\nRefer to ${YELLOW}zsh/TIPS.md${NC} and ${YELLOW}nvim/TIPS.md${NC} for keybindings and aliases."
