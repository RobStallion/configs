" Essential settings that must be in .vimrc
set nocompatible              " Disable vi compatibility mode
filetype plugin indent on     " Enable filetype detection and plugin/indent support
syntax on                     " Enable syntax highlighting

" Sets leader key early (needed before any mappings)
let mapleader = " "

" Vim-Plug setup
call plug#begin('~/.vim/plugged')
source ~/.vim/plugins.vim
call plug#end()

" Source settings configuration files
source ~/.vim/settings/fzf.vim
" source ~/.vim/settings/lsp.vim
source ~/.vim/my-settings.vim
