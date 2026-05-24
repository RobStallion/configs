#!/bin/bash
tmux attach-session -t popup 2>/dev/null || \
  tmux new-session -s popup nvim -c 'colorscheme rose-pine-dawn' ~/scratch.md
