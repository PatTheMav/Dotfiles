" ==============================================================================
"   Name:        Mariana
"   Author:      Patrick Heyer <PatTheMav@users.noreply.github.com>
"   Url:         https://github.com/patthemav/dotfiles
"   License:     The MIT License (MIT)
"
"   Dark vim color theme based on colors used in Sublime Text's Mariana theme
"   using One Half Dark by Son A. Pham <sp@sonpham.me> as its baseline.
"
"   One Half Dark available at https://github.com/sonph/onehalf
"
" ==============================================================================

set background=dark
highlight clear
syntax reset

let g:colors_name="mariana"
let colors_name="mariana"

" Terminal ANSI colors
let s:black          = { "gui": "#303841", "cterm": "59" }
let s:red            = { "gui": "#EC5F66", "cterm": "203" }
let s:green          = { "gui": "#99C794", "cterm": "114" }
let s:orange         = { "gui": "#F9AE58", "cterm": "215" }
let s:blue           = { "gui": "#6699CC", "cterm": "68" }
let s:pink           = { "gui": "#C695C6", "cterm": "176" }
let s:cyan           = { "gui": "#5FB4B4", "cterm": "73" }
let s:white          = { "gui": "#A6ACB9", "cterm": "145" }
let s:bright_black   = { "gui": "#4A5560", "cterm": "59" }
let s:bright_red     = { "gui": "#F67C82", "cterm": "210" }
let s:bright_green   = { "gui": "#C6E7C3", "cterm": "188" }
let s:bright_orange  = { "gui": "#FACD99", "cterm": "215" }
let s:bright_blue    = { "gui": "#92BAE3", "cterm": "110" }
let s:bright_pink    = { "gui": "#E1BAE1", "cterm": "182" }
let s:bright_cyan    = { "gui": "#8BD6D7", "cterm": "116" }
let s:bright_white   = { "gui": "#D8DEE9", "cterm": "188" }

let s:foreground    = s:bright_white
let s:background    = s:black
let s:caret         = s:orange
let s:line_bar      = { "gui": "#4D5864", "cterm": "59" }
let s:line_number   = { "gui": "#BEC5D1", "cterm": "152" }
let s:gutter_fg     = { "gui": "#828B96", "cterm": "102" }
let s:gutter_bg     = s:background

let s:popup_bg      = { "gui": "#3B424A", "cterm": "59" }
let s:popup_fg      = s:foreground
let s:popup_sel_bg  = { "gui": "#62686E", "cterm": "59" }
let s:popup_sel_fg  = s:foreground
let s:popup_scroll  = s:popup_bg
let s:popup_bug     = { "gui": "#5C5E5F", "cterm": "59" }

let s:tab_bar       = { "gui": "#72787E", "cterm": "66" }
let s:tab_bg        = s:tab_bar
let s:tab_fg        = { "gui": "#FBFBFB", "cterm": "231" }
let s:tab_active_bg = { "gui": "#3A424A", "cterm": "59" }
let s:tab_active_fg = s:bright_white

let s:non_print     = { "gui": "#68707A", "cterm": "60" }
let s:column_mark   = { "gui": "#454D56", "cterm": "59" }
let s:vert_split    = s:tab_bar

let s:fold_fg       = { "gui": "#505766", "cterm": "59" }
let s:fold_bg       = s:background

let s:sign_fg        = s:bright_white
let s:sign_bg        = s:background

let s:incsearch_fg   = { "gui": "#524A3A", "cterm": "59" }
let s:incsearch_bg   = { "gui": "#FAC761", "cterm": "221" }
let s:search_fg      = { "gui": "#5FB4B4", "cterm": "73" }

let s:status_bar_bg  = s:line_bar
let s:status_bar_fg  = { "gui": "#A6ACB9", "cterm": "145" }
let s:status_alt_fg  = s:fold_fg

let s:selection      = s:line_bar

let s:wildmenu_fg    = s:line_bar
let s:wildmenu_bg    = { "gui": "#F7F7F7", "cterm": "231" }

let s:comment        = s:status_bar_fg

if exists('g:mariana_transparent_bg') && mariana_transparent_bg ==? 1
  let s:background = 'NONE'
  let s:gutter_bg = 'NONE'
  let s:fold_bg = 'NONE'
  let s:sign_bg = 'NONE'
endif

if has("terminal")
    let g:terminal_ansi_colors = [
        \ s:black.gui,
        \ s:red.gui,
        \ s:green.gui,
        \ s:orange.gui,
        \ s:blue.gui,
        \ s:pink.gui,
        \ s:cyan.gui,
        \ s:white.gui,
        \ s:bright_black.gui,
        \ s:bright_red.gui,
        \ s:bright_green.gui,
        \ s:bright_orange.gui,
        \ s:bright_blue.gui,
        \ s:bright_pink.gui,
        \ s:bright_cyan.gui,
        \ s:bright_white.gui
        \ ]
endif

function! s:h(group, fg, bg, attr)
  if type(a:fg) == type({})
    exec "hi " . a:group . " guifg=" . a:fg.gui . " ctermfg=" . a:fg.cterm
  else
    exec "hi " . a:group . " guifg=NONE ctermfg=NONE"
  endif

  if type(a:bg) == type({})
    exec "hi " . a:group . " guibg=" . a:bg.gui . " ctermbg=" . a:bg.cterm
  else
    exec "hi " . a:group . " guibg=NONE ctermbg=NONE"
  endif

  if a:attr != ""
    exec "hi " . a:group . " gui=" . a:attr . " cterm=" . a:attr
  else
    exec "hi " . a:group . " gui=NONE cterm=NONE"
  endif
endfunction

let s:fixme         = { "gui": "#e642f5", "cterm": "171" }

call s:h("Normal", s:foreground, s:background, "")
call s:h("Bold", "", "", "bold")
call s:h("Underlined", "", "", "underline")
call s:h("NonText", s:non_print, "", "")
call s:h("Cursor", s:caret, s:background, "inverse")
call s:h("CursorColumn", "", s:line_bar, "")
call s:h("CursorLine", "", s:line_bar, "")
call s:h("LineNr", s:gutter_fg, s:gutter_bg, "")
call s:h("CursorLineNr", s:line_number, s:line_bar, "")
call s:h("ColorColumn", "", s:column_mark, "")
call s:h("VertSplit", s:vert_split, s:gutter_bg, "")
call s:h("Folded", s:fold_fg, s:fold_bg, "")
call s:h("CursorLineFold", s:fold_fg, s:fold_bg, "")
call s:h("FoldColumn", s:fold_fg, s:fold_bg, "")
call s:h("CursorLineSign", s:sign_fg, s:line_bar, "")
call s:h("SignColumn", s:sign_fg, s:sign_bg, "")
call s:h("IncSearch", s:incsearch_fg, s:incsearch_bg, "")
call s:h("Search", s:search_fg, "", "underline")
call s:h("StatusLine", s:status_bar_fg, s:status_bar_bg, "")
call s:h("StatusLineNC", s:status_alt_fg, s:status_bar_bg, "")
call s:h("TabLine", s:tab_fg, s:tab_bg, "")
call s:h("TabLineFill", s:tab_bar, s:tab_bar, "")
call s:h("TabLineSel", s:tab_active_fg, s:tab_active_bg, "bold")
call s:h("Visual", "", s:selection, "")
call s:h("Pmenu", s:popup_fg, s:popup_bg, "")
call s:h("PmenuSel", s:popup_sel_fg, s:popup_sel_bg, "")
call s:h("PmenuSbar", "", s:popup_scroll, "")
call s:h("PmenuThumb", "", s:popup_bug, "")
call s:h("Title", s:blue, "", "")
call s:h("WildMenu", s:wildmenu_fg, s:wildmenu_bg, "")
call s:h("MatchParen", s:blue, "", "underline")
call s:h("SpecialKey", s:blue, "", "")
" call s:h("Special", s:blue, "", "")
call s:h("Directory", s:blue, "", "bold")

call s:h("ErrorMsg", s:red, s:background, "")
call s:h("ModeMsg", s:green, "", "")
call s:h("MoreMsg", s:green, "", "")
call s:h("WarningMsg", s:orange, "", "")
call s:h("Question", s:blue, "", "")

call s:h("Boolean", s:red, "", "italic")
call s:h("Character", s:green, "", "")
call s:h("Comment", s:comment, "", "")
call s:h("Conditional", s:pink, "", "")
call s:h("Constant", s:red, "", "")
call s:h("Debug", s:red, "", "bold")
call s:h("Error", s:background, s:red, "")
call s:h("Exception", s:red, "", "")
call s:h("Define", s:orange, "", "")
call s:h("Delimiter", s:foreground, "", "")
call s:h("Float", s:orange, "", "")
call s:h("Function", s:blue, "", "")
call s:h("Identifier", s:foreground, "", "")
call s:h("Ignore", s:foreground, "", "")
call s:h("Include", s:pink, "", "")
call s:h("Keyword", s:red, "", "")
call s:h("Label", s:pink, "", "")
call s:h("Macro", s:pink, "", "")
call s:h("Number", s:orange, "", "")
call s:h("Operator", s:red, "", "")
call s:h("PreCondit", s:pink, "", "")
call s:h("PreProc", s:pink, "", "")
call s:h("Repeat", s:pink, "", "")
call s:h("SpecialChar", s:blue, "", "bold")
call s:h("SpecialComment", s:blue, "", "bold")
call s:h("StorageClass", s:red, "", "")
call s:h("Statement", s:pink, "", "")
call s:h("String", s:green, "", "")
call s:h("Structure", s:pink, "", "italic")
call s:h("Tag", s:blue, "", "bold")
call s:h("Todo", s:foreground, s:background, "bold")
call s:h("Type", s:pink, "", "italic")
call s:h("Typedef", s:orange, "", "")
call s:h("Whitespace", s:non_print, "", "")

call s:h("DiffAdd", s:green, "", "")
call s:h("DiffChange", s:orange, "", "")
call s:h("DiffDelete", s:red, "", "")
call s:h("DiffText", s:blue, "", "")

delfunction s:h
