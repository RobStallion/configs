# Personal Configurations & Dotfiles

A modular, highly optimized, and version-controlled configuration workspace for macOS, Ghostty, Zsh, Neovim 0.11+, Tmux, and Mise.

---

## 🛠️ The Tech Stack

This repository coordinates the following tools into a cohesive development environment:

*   **Terminal:** [Ghostty](https://ghostty.org/) (with custom keybindings, terminal-features, and dynamic theme hot-reloading).
*   **Shell:** Zsh (using a modular structure, lazy completion loading, and startup command execution caching).
*   **Prompt:** [Starship](https://starship.rs/) (configured with right-aligned git stats, context-aware Kubernetes modules, and palette syncing).
*   **Multiplexer:** Tmux (integrated with smart-splits cursor routing, float popup scratchpads, and a custom background Google Calendar agenda chip).
*   **Editor:** Neovim 0.11+ (running a custom config leveraging native `vim.lsp.config`, `blink.cmp` autocomplete, `fzf-lua` search, and visual formatting hooks).
*   **Version Manager:** [Mise](https://mise.jdx.dev/) (managing runtimes shimlessly via directory-specific PATH injection on `cd`).

---

## 🚀 Quick Start & Installation

To set up this configuration on a new macOS machine:

1.  **Clone the repository** to your code directory:
    ```bash
    mkdir -p ~/code/personal
    git clone https://github.com/RobStallion/configs.git ~/code/personal/configs
    cd ~/code/personal/configs
    ```

2.  **Run the installation script** to symlink configurations and build binary utilities:
    ```bash
    ./install.sh
    ```

    The script creates symlinks under `~/.config/` and your home directory, runs a `git update-index --skip-worktree` on local theme switches, and compiles the custom Claude Code statusline command.

3.  **Source your shell** or open a new terminal session:
    ```bash
    source ~/.zshrc
    ```

---

## 📦 Key Dependencies

While the configurations degrade gracefully if tools are missing, the setup works best with the following tools installed:

### Homebrew Utilities
```bash
brew install eza bat git-delta fzf fd ripgrep gcalcli starship tmux
```

### Neovim LSP Binaries & Formatters
Binaries are managed shimlessly via [Mise](file:///Users/robertfrancis/code/personal/configs/mise/config.toml):
*   Language Servers: `vtsls`, `deno`, `pyright`, `ruff-lsp`, `gopls`, `vscode-json-languageserver`.
*   Formatters/Linters: `jq` (JSON), `rumdl` (Markdown).

---

## 🎨 System Theme & Hot-Reloading

The repository implements a dynamic theme system built around [Catppuccin](https://github.com/catppuccin/catppuccin) variants (Latte, Frappe, Macchiato, Mocha).

*   **Canonical state location:** `~/.config/theme` (git-ignored via `skip-worktree` to avoid dirtying git commits).
*   **Changing themes:** Run the shell helper command `theme <variant>` (e.g. `theme latte` or `theme mocha`).
*   **Hot-reloading behavior:**
    *   **Ghostty:** Hot-reloads immediately by rewriting `theme.conf` and sending a `USR2` signal.
    *   **Tmux:** Hot-reloads by re-reading `@catppuccin_flavor` and re-applying status-bar templates.
    *   **Neovim:** Detects the change and updates the active color scheme automatically upon regaining focus (`FocusGained`).

---

## 🤖 Claude Code & MCP Gating

To avoid LiteLLM bloating the LLM prompt context window at session start with unused JSON-RPC MCP schemas (described in [ADR-007](file:///Users/robertfrancis/code/personal/configs/adr/007-claude-mcp-profile-wrapper.md)):

*   The raw `claude` command is wrapped by the shell function `c` (defined in [zsh/claude-wrapper.zsh](file:///Users/robertfrancis/code/personal/configs/zsh/claude-wrapper.zsh)).
*   **MCP profiles** are kept in `~/.mcp-profiles/<profile-name>.json` (outside the repo to protect access tokens).
*   Run `c <profile-name>` to merge the profile configuration dynamically and launch Claude Code in strict configuration mode.
*   A compiled Rust helper ([claude/statusline/src/main.rs](file:///Users/robertfrancis/code/personal/configs/claude/statusline/src/main.rs)) feeds diagnostic metrics (actual served model, running costs, rate limits, caveman plugin status) to the interactive statusline.

---

## 📝 Reference Guides

For specific keybindings, shell aliases, and editor shortcuts, refer to:
*   [Zsh Cheat Sheet & Globbing Tips](file:///Users/robertfrancis/code/personal/configs/zsh/TIPS.md)
*   [Neovim Native LSP & Text Objects](file:///Users/robertfrancis/code/personal/configs/nvim/TIPS.md)
*   [Tmux Keymaps & Scratchpads](file:///Users/robertfrancis/code/personal/configs/tmux/CHEATSHEET.md)
*   [Architectural Decisions Index](file:///Users/robertfrancis/code/personal/configs/adr/README.md)
