" ~/.vim/lsp.vim

" Enable diagnostics
let g:lsp_diagnostics_enabled = 1
let g:lsp_diagnostics_echo_cursor = 1  " Show errors under cursor

" Keybindings for LSP
nnoremap <leader>gd :LspDefinition<CR>
nnoremap <leader>h :LspHover<CR>
nnoremap <leader>gr :LspReferences<CR>
nnoremap <leader>rs :LspRename<CR>

let g:lsp_settings = {}
let g:lsp_settings['pylsp'] = {'disabled': 1}
let g:lsp_settings['ruff']  = {'disabled': 0}
