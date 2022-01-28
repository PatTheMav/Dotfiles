"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" PTM vimrc v4
"
" Version:
"       4.2.0 - 2021/11/09
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Enable viMproved features
set nocompatible

""""""""""""""""""""""""""
" Plugin settings
""""""""""""""""""""""""""

if exists('Explore')
    " Hide object files in :Explore
    let g:explHideFiles='^\.,.*\.sw[po]$,.*\.pyc$'
    " Disable help lines on top of file explorer
    let g:explDetailedHelp=0
endif

""""""""""""""""""""""""""
" General
""""""""""""""""""""""""""

" Reduce escape timeout
set timeoutlen=1000 ttimeoutlen=0
" Set amount of remembered history items if set below 1000 items
if &history < 1000
    set history=1000
endif

" Set amount of tab pages
if &tabpagemax < 50
    set tabpagemax=50
endif

" Automatically update files if changed externally
set autoread
" Backspace also works over indents, newlines
set backspace=indent,eol,start
" Minimal amount of lines to keep above and below the cursor
set scrolloff=7
" Minimal amount of lines to keep left and right of the cursor if nowrap is set
set sidescrolloff=5

" Always show current position
set ruler
" Hide buffers instead of closing them
set hidden
" Don't redraw while macros are executed (performance increase)
set lazyredraw
" Enable magic characters for regular expressions
set magic
" Deactivate Backups
set nobackup
set nowritebackup
set noswapfile
" Remember info about open files when buffers are closed
set viminfo^=%
" Always show the status line

set whichwrap+=<,>,h,l

""""""""""""""""""""""""""
" Mouse settings
""""""""""""""""""""""""""

" Enable mouse for the following modes
" n     Normal mode
" v     Visual mode
" i     Insert mode
" c     Command-line mode
" h     all previous modes when editing a help file
" a     all previous modes
set mouse=a

" Automatically activate the window the mouse enters
set mousefocus

" Set mouse model
" extend        Right mouse button extends selection
" popup         Right mouse button pops up a menu
" popup_setpos  Like popup but cursor will be placed under the mouse
set mousemodel=popup_setpos


""""""""""""""""""""""""""
" Wildmenu settings
""""""""""""""""""""""""""

" Enable wildmenu for easier selection
set wildmenu
" Set completion mode for wildmenu
set wildmode=full
" Set filetypes that should be ignored for matching in wildmenu
set wildignore=*.o,*~,*.pyc

""""""""""""""""""""""""""
" Search settings
""""""""""""""""""""""""""

" Ignore case when searching for strings
set ignorecase
" Override ignorecase when upper case characters are used in search patterns
set smartcase
" Highlight search matches during search
set hlsearch
" Update buffer position to search matches while being typed
set incsearch

" Use <C-L> to clear search highlighting
if maparg('<C-L>', 'n') ==# ''
    nnoremap <silent> <C-L> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>
endif

""""""""""""""""""""""""""
" Highlighting
""""""""""""""""""""""""""

" Show matching brackets when cursor is on one of them
set showmatch
" How long to highlight brackets
set mat=2
" No sounds or visual bells on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" Use dark background coloring
" set background=dark

""""""""""""""""""""""""""
" Formatting
""""""""""""""""""""""""""

" Default encoding is utf-8 - this is 2013!
set encoding=utf-8
" Unix file format has highest priority
set ffs=unix,dos,mac
" Spaces instead of real tabs
set expandtab
" Insert tab spaces in accordance to indents and tabstops
set smarttab
" Use 4 spaces for 1 tab
set shiftwidth=4
set tabstop=4
" Copy indent from current line when starting a new one
set autoindent
" Automatically indent when language-specific characters are used (e.g. brackets in c-like languages)
set smartindent
" Copy the structure of existing indents when autoindenting new lines
set copyindent
" Enable use of italics
highlight Comment cterm=italic

""""""""""""""""""""""""""
" Appearance
""""""""""""""""""""""""""

" Automatically break lines after 500 characters
set linebreak
set breakindent
set textwidth=500
" Enable wrapping of long lines to avoid horizontal scrolling
set wrap
" Show line numbers
set number
" When buffer is no longer displayed just hide the buffer
set bufhidden=hide
" Show partial command in the last line of the screen
set showcmd
" List mode - enable to display non-printable characters
set list
" Strings to use in list mode and for list command
if &listchars ==# 'eol:$'
    set listchars=tab:>-,trail:·,eol:<,nbsp:%,extends:>,precedes:<
endif
" Highlight the screen line of the cursor
set cursorline
" Set cursor mode in all modes to short on, long off
set gcr=a:blinkwait500-blinkon1300-blinkoff150
" Set cursor to underline in insert mode
set gcr=i:hor10
" Set cursor to block in visual mode
set gcr=v:block

" Delete comment character when joining commented lines
if v:version > 703 || v:version == 703 && has("patch541")
    set formatoptions+=j
endif

" Changes the effect of the :mkview command
" folds     manually created folds, opened/closed folds and local fold options
" options   options and mappings local to a window or buffer
" cursor    cursor position in file and in window
" unix      with Unix end-of-line format even when on Windows or DOS
" slash     backslashes in file names replaced with forward slashes
set viewoptions=folds,options,cursor,unix,slash

" Enable placing the cursor one character 'behind' end of lines
set virtualedit=onemore

if has("gui_running")
    colorscheme base16-oceanicnext

    if has("mac") || has("macunix")
        set guifont=SF_Mono_PTM:h10
        set shell=/usr/local/bin/zsh
    elseif has("win16") || has("win32")
        set guifont=SF_Mono_PTM:h10:cANSI:qDRAFT
        set rop=type:directx,renmode:5,taamode:2
    elseif has("linux")
        set guifont=SF_Mono_PTM:h10
        set shell=/bin/zsh
    endif

    if has("gui_macvim")
        set fuoptions=maxvert,maxhorz
        " autocmd GUIEnter * set fullscreen
    endif

    set guioptions+=aemTrRlL
    set guioptions-=mTrRlL
    " set t_Co=256
    set guitablabel=%M\ %t
else
    if exists('$BASE16_THEME') && (!exists('g:colors_name') || g:colors_name != 'base16-$BASE16_THEME')
        let base16colorspace=256
        colorscheme base16-$BASE16_THEME
    else
        colorscheme base16-mariana
        " As long as Terminal.app doesn't properly support
        " setting colors in the color space, 'termguicolors'
        " won't work with Terminal.app. If another terminal is
        " mainly used, uncomment.
        if (has("termguicolors") && has("linux"))
            set termguicolors
            let base16colorspace=256
        endif
    endif
endif


""""""""""""""""""""""""""
" Folding and Syntax
""""""""""""""""""""""""""

if has('syntax') && !exists('g:syntax_on')
    syntax enable
endif
" Enable folding by syntax highlighting
set foldmethod=syntax
" Sets the maximum nesting of folds for indent and syntax methods
set foldnestmax=10
" Automatically have all folds open
set nofoldenable
" Sets the fold level - folds with a higher level will be closed
set foldlevel=1
" Define commands that open folds
set foldopen=block,insert,jump,mark,percent,quickfix,search,tag,undo
" If editing files of type 'html' xml closing tags will be xhtml compatible
" e.g. <hr> becomes <hr />
let xml_use_xhtml=1
" Enable syntax folding for xml file types
let xml_syntax_folding=1
" Enable SQL syntax highlighting inside PHP strings
let php_sql_query=1
" Enable HTML syntax highlighting inside PHP strings
let php_htmlInStrings=1
" Enable folding for classes and functions
let php_folding=1
" Enable opening/closing folds by pressing space in normal mode (only when inside a fold)
nnoremap <silent> <Space> @=(foldlevel('.')?'za':'l')<CR>
" Enable opening/closing folds by pressing space in visual mode
vnoremap <Space> zf

""""""""""""""""""""""""""
" Shortcuts
""""""""""""""""""""""""""

" Define leader
let mapleader=","
" Define leader character in GUI version
let g:mapleader=","
" Define leader for local buffer
let localmapleader="\\"
" Quick command to edit vimrc
map <leader>e :e! ~/.vimrc<CR>
" Macro to enable sudo writing a file opened for editing
cmap <silent> w!! w !sudo tee > /dev/null %

if version >= 700
    map <C-Tab> <Esc>:bn<CR>
    map <C-S-Tab> <Esc>:bp<CR>

    map <silent> <C-h> :wincmd h<CR>
    map <silent> <C-j> :wincmd j<CR>
    map <silent> <C-k> :wincmd k<CR>
    map <silent> <C-l> :wincmd l<CR>
endif

noremap <leader>m mmHmt:%s/<C-V><CR>//ge<CR>'tzt'm
map <silent> <leader>pp :setlocal paste!<CR>
map <silent> <leader>cd :cd %:p:h<CR>:pwd<CR>

""""""""""""""""""""""""""
" Autocommands
""""""""""""""""""""""""""

" Automatically reload vimrc if file is written
autocmd! bufwritepost .vimrc source ~/.vimrc     "Reload VIMrc before editing

if exists('+autochdir')
    set autochdir
else
    autocmd BufEnter * silent! lcd %:p:h:gs/ /\\ /
endif

" filetype on
if has('autocmd')
    filetype plugin on
    filetype indent on
    augroup filetypes
        autocmd!
        autocmd FileType php set omnifunc=phpcomplete#CompletePHP
        autocmd FileType python set omnifunc=pythoncomplete#Complete
        autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
        autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
        autocmd FileType css set omnifunc=csscomplete#CompleteCSS
        autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags
        autocmd FileType xml setlocal equalprg=xmllint\ --format\ --recover\ -\ 2>/dev/null
        autocmd FileType c set omnifunc=ccomplete#Complete
    augroup end
endif

" Restore cursor position when reopening files
augroup cursorrestore
    autocmd!
    if exists(':mkview')
        autocmd BufWritePost,BufLeave,BufWinLeave *.* mkview
        autocmd BufWinEnter *.* silent loadview
    endif
augroup end

let &t_SI.="\e[5 q" "SI = INSERT mode
let &t_SR.="\e[4 q" "SR = REPLACE mode
let &t_EI.="\e[1 q" "EI = NORMAL mode (ELSE)
