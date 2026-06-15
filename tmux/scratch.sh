#!/bin/bash
# -A: attach to existing 'scratch_popup' session if it exists, otherwise create it
tmux new-session -A -s scratch_popup -c ~/scratch nvim --cmd 'let g:fixed_colorscheme=1' -c 'colorscheme rose-pine-dawn' todo.md
