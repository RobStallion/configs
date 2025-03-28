" Function to format the current file with uvx ruff format
function! FormatWithRuff()
    " Save the current view (cursor position, etc.) to restore later
    let view = winsaveview()

    " Get the current buffer content as a single string
    let buffer_content = join(getline(1, '$'), "\n")

    " Run ruff format, passing the buffer content via stdin
    let cmd = 'uvx ruff format -'
    let formatted_output = system(cmd, buffer_content)

    " Check if the command was successful
    if v:shell_error == 0
        " Split the formatted output into lines
        let lines = split(formatted_output, '\n')

        " Replace the buffer content with the formatted lines
        call setline(1, lines)

        " If the new content has fewer lines, delete the extras
        if len(lines) < line('$')
            execute (len(lines)+1) . ',$delete _'
        endif

        " Restore the cursor position
        call winrestview(view)
    else
        " Display an error message if formatting fails
        echohl ErrorMsg
        echom "Error formatting file: " . formatted_output
        echohl None
    endif
endfunction

" Optional: Autoformat on save for Python files
autocmd BufWritePre *.py call FormatWithRuff()

" attempt at go to def using RG
nnoremap <leader>gd :RG def\s+<C-R><C-W>\b<CR>
