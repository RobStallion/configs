#!/bin/bash
# -A: attach to existing 'popup' session if it exists, otherwise create it
tmux new-session -A -s popup nvim --cmd 'let g:fixed_colorscheme=1' -c 'colorscheme rose-pine-dawn' ~/scratch.md
