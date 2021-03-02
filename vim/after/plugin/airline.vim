if exists('g:airline#init#vim_async')
    " AIRLINE
    " Enable tabline by default
    let g:airline#extensions#tabline#enabled = 1
    " Enable tabline formatter
    let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
    " Enable airline caching
    let g:airline_highlighting_cache = 1

    " Set powerline symbols
    if !exists('g:airline_symbols')
        let g:airline_symbols = {}
    endif

    let g:airline_powerline_fonts = 1

    let g:airline_symbols.paste = 'ρ'
    let g:airline_symbols.whitespace = 'Ξ'

    if g:airline_powerline_fonts == 1
        let g:airline_left_sep = ''
        let g:airline_left_alt_sep = ''
        let g:airline_right_sep = ''
        let g:airline_right_alt_sep = ''
        let g:airline_symbols.branch = ''
        let g:airline_symbols.readonly = ''
        let g:airline_symbols.colnr = ' ℅:'
        "let g:airline_symbols.linenr = ' :'
        let g:airline_symbols.linenr = ' ㏑'
        let g:airline_symbols.maxlinenr = '☰ '
        let g:airline_symbols.dirty=' ⚡'
    else
        let g:airline_left_sep = ''
        let g:airline_left_alt_sep = ''
        let g:airline_right_sep = ''
        let g:airline_right_alt_sep = ''
        let g:airline_symbols.colnr = ' ℅:'
        let g:airline_symbols.branch = '⎇'
        let g:airline_symbols.readonly = '✖︎'
        let g:airline_symbols.linenr = ' ㏑'
        let g:airline_symbols.maxlinenr = '☰ '
    end

    " Set airline theme
    let g:airline_theme='base16_oceanicnext'

    set noshowmode
else
    set showmode
    set cmdheight=2
    set laststatus=2
    " Set options for shortening on screen messages
    " f     use (3 of 5)    instead of (file 3 of 5)
    " i     use [noeol]     instead of [Incomplete last line]
    " l     use 999L, 888C  instead of 999 lines, 888 characters
    " m     use [+]         instead of [Modified]
    " n     use [New]       instead of [New File]
    " r     use [RO]        instead of [readonly]
    " x     use [dos]       instead of [dos format], etc
    " o     overwrite message for writing a file with subsequent message for reading
    " O     Also for quickfix message
    " t     truncate file message at the start if it is too long
    " T     truncate other messages in the middle if their are too long for command line
    set shortmess+=filmnrxoOtT
    set statusline=
    set statusline+=%1*\ %-3.3n\ %*
    set statusline+=%4*\ %<%F%*
    set statusline+=%2*%h%m%r%w%*
    set statusline+=%=%<
    set statusline+=%5*(%{&fileformat})%*
    set statusline+=%3*[%{strlen(&ft)?&ft:'none'}%*
    set statusline+=%3*\ →%{strlen(&fenc)?&fenc:&enc}]%*
    set statusline+=%1*%5.P%*
    set statusline+=%(%1*%5l%*%2*/%L%)\ %*
    set statusline+=%1*%4v\ %*
    set statusline+=%2*0x%04B\ %*
    hi statusline ctermfg=15 ctermbg=0
    " hi User1 guifg=#eea040 guibg=#222222 ctermfg=Brown ctermbg=0
    " hi User2 guifg=#dd3333 guibg=#222222 ctermfg=DarkRed ctermbg=0
    " hi User3 guifg=#ff66ff guibg=#222222 ctermfg=DarkMagenta ctermbg=0
    " hi User4 guifg=#a0ee40 guibg=#222222 ctermfg=DarkGreen ctermbg=0
    " hi User5 guifg=#eeee40 guibg=#222222 ctermfg=LightGreen ctermbg=0
end


