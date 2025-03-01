" ~/.vim/plugins.vim

" Plugin list managed by Vim-Plug

Plug 'tpope/vim-sensible'       " Sensible defaults for Vim
Plug 'tpope/vim-commentary'     " Easy commenting
Plug 'tpope/vim-surround'       " Text surrounding

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }  " Fuzzy finder (requires fzf installed on system)
Plug 'junegunn/fzf.vim'         " Vim integration for fzf

" " LSP support
" Plug 'prabirshrestha/vim-lsp'   " LSP client for Vim
" Plug 'mattn/vim-lsp-settings'   " Auto-configures language servers (optional but simplifies setup)

" Standby plugins
" Plug 'preservim/nerdtree'       " File explorer
" Plug 'vim-airline/vim-airline'  " Customizable status line with themes and useful info
" Plug 'tpope/vim-fugitive'       " Git integration
" Plug 'airblade/vim-gitgutter'   " Git diff markers in sign column
