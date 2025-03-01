" ~/.vim/lsp.vim

" LSP configuration for Python (pylsp)
if executable('pylsp')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'pylsp',
        \ 'cmd': {server_info->['pylsp']},
        \ 'whitelist': ['python'],
        \ })
endif

" LSP configuration for Node.js (typescript-language-server)
if executable('typescript-language-server')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'typescript-language-server',
        \ 'cmd': {server_info->['typescript-language-server', '--stdio']},
        \ 'whitelist': ['javascript', 'typescript'],
        \ })
endif

" Enable diagnostics
let g:lsp_diagnostics_enabled = 1
let g:lsp_diagnostics_echo_cursor = 1  " Show errors under cursor

" Keybindings for LSP
" Go to definition
nnoremap <leader>gd :LspDefinition<CR>
" Hover information
nnoremap <leader>h :LspHover<CR>
" Find references
nnoremap <leader>gr :LspReferences<CR>
" Rename symbol
nnoremap <leader>rn :LspRename<CR>
