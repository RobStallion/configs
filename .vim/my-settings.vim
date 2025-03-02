" ~/.vim/settings.vim

" Display settings
set number                    " Show line numbers
set ruler                     " Show cursor position in status line
set showmatch                 " Highlight matching brackets
set laststatus=2              " Always show status line
set showcmd                   " Show partial commands in status line
set showmode                  " Show current mode in status line
" colorscheme desert          " Uncomment if you want a specific colorscheme

" Search settings
set incsearch                 " Show search results as you type
set hlsearch                  " Highlight search results
set ignorecase                " Case-insensitive search by default
set smartcase                 " Override ignorecase when search contains uppercase

" Indentation settings
set tabstop=4                 " Set tab width to 4 spaces
set shiftwidth=4              " Set indentation width to 4 spaces
set expandtab                 " Convert tabs to spaces
set autoindent                " Automatically indent new lines
set smartindent               " Smarter auto-indenting

" UI and usability
set backspace=indent,eol,start " Make backspace work as expected
set wildmenu                  " Enhanced command-line completion
set wildmode=list:longest,full " Set completion behavior
set mouse=a                   " Enable mouse support in all modes
set clipboard=unnamed         " Use system clipboard
set history=1000              " Increase command history
set undolevels=1000           " Increase undo levels

" Navigate split windows with Ctrl+hjkl
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" Remap ; to : in normal mode
nnoremap ; :

" Make search results appear in the middle of the screen
nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz
nnoremap # #zz

" Add mapping to quickly stop search highlighting
nnoremap <C-h> :nohlsearch<CR>

" Add shortcuts for save, quit, and save-quit operations
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>wq :wq<CR>wq<CR>
