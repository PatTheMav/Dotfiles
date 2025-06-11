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

let g:airline#themes#mariana#palette = {}

let s:airline_a_bg       = { "gui": "#A6ACB9", "cterm": "145" }
let s:airline_a_fg       = { "gui": "#4D5864", "cterm": "59" }
let s:airline_b_bg       = { "gui": "#72787E", "cterm": "66" }
let s:airline_b_fg       = { "gui": "#FBFBFB", "cterm": "66" }
let s:airline_c_bg       = { "gui": "#4D5864", "cterm": "59" }
let s:airline_c_fg       = { "gui": "#A6ACB9", "cterm": "145" }

let s:black          = { "gui": "#303841", "cterm": "59" }
let s:red            = { "gui": "#EC5F66", "cterm": "203" }
let s:green          = { "gui": "#99C794", "cterm": "114" }
let s:orange         = { "gui": "#F9AE58", "cterm": "215" }
let s:blue           = { "gui": "#6699CC", "cterm": "68" }
let s:pink           = { "gui": "#C695C6", "cterm": "176" }
let s:cyan           = { "gui": "#5FB4B4", "cterm": "73" }
let s:white          = { "gui": "#A6ACB9", "cterm": "145" }
let s:bright_white   = { "gui": "#D8DEE9", "cterm": "188" }

let s:normal_a      = [s:airline_a_fg.gui, s:airline_a_bg.gui, s:airline_a_fg.cterm, s:airline_a_bg.cterm]
let s:normal_b      = [s:airline_b_fg.gui, s:airline_b_bg.gui, s:airline_b_fg.cterm, s:airline_b_bg.cterm]
let s:normal_c      = [s:airline_c_fg.gui, s:airline_c_bg.gui, s:airline_c_fg.cterm, s:airline_c_bg.cterm]
let s:normal_mod    = [s:bright_white.gui, s:airline_c_bg.gui, s:bright_white.cterm, s:airline_c_bg.cterm]
let g:airline#themes#mariana#palette.normal = airline#themes#generate_color_map(s:normal_a, s:normal_b, s:normal_c)
let g:airline#themes#mariana#palette.normal_modified = {'airline_c' : s:normal_mod}

let s:insert_a     = [s:airline_a_fg.gui, s:green.gui, s:airline_a_fg.cterm, s:green.cterm]
let s:insert_b     = [s:airline_b_fg.gui, s:airline_b_bg.gui, s:airline_b_fg.cterm, s:airline_b_bg.cterm]
let s:insert_c     = [s:airline_b_fg.gui, s:airline_c_bg.gui, s:airline_b_fg.cterm, s:airline_c_bg.cterm]
let s:insert_mod   = [s:bright_white.gui, s:airline_c_bg.gui, s:bright_white.cterm, s:airline_c_bg.cterm]
let g:airline#themes#mariana#palette.insert = airline#themes#generate_color_map(s:insert_a, s:insert_b, s:insert_c)
let g:airline#themes#mariana#palette.insert_modified = {'airline_c' : s:insert_mod}

let s:replace_a     = [s:airline_a_fg.gui, s:pink.gui, s:airline_a_fg.cterm, s:pink.cterm]
let s:replace_b     = [s:airline_b_fg.gui, s:airline_b_bg.gui, s:airline_b_fg.cterm, s:airline_b_bg.cterm]
let s:replace_c     = [s:airline_b_fg.gui, s:airline_c_bg.gui, s:airline_b_fg.cterm, s:airline_c_bg.cterm]
let s:replace_mod   = [s:bright_white.gui, s:airline_c_bg.gui, s:bright_white.cterm, s:airline_c_bg.cterm]
let g:airline#themes#mariana#palette.replace = airline#themes#generate_color_map(s:replace_a, s:replace_b, s:replace_c)
let g:airline#themes#mariana#palette.replace_modified = {'airline_c' : s:replace_mod}

let s:visual_a     = [s:airline_a_fg.gui, s:orange.gui, s:airline_a_fg.cterm, s:orange.cterm]
let s:visual_b     = [s:airline_b_fg.gui, s:airline_b_bg.gui, s:airline_b_fg.cterm, s:airline_b_bg.cterm]
let s:visual_c     = [s:airline_b_fg.gui, s:airline_c_bg.gui, s:airline_b_fg.cterm, s:airline_c_bg.cterm]
let s:visual_mod   = [s:bright_white.gui, s:airline_c_bg.gui, s:bright_white.cterm, s:airline_c_bg.cterm]
let g:airline#themes#mariana#palette.visual = airline#themes#generate_color_map(s:visual_a, s:visual_b, s:visual_c)
let g:airline#themes#mariana#palette.visual_modified = {'airline_c' : s:visual_mod}

let s:inactive_a     = [s:airline_a_fg.gui, s:airline_c_bg.gui, s:airline_a_fg.cterm, s:airline_c_bg.cterm]
let s:inactive_b     = [s:airline_b_fg.gui, s:airline_c_bg.gui, s:airline_b_fg.cterm, s:airline_c_bg.cterm]
let s:inactive_c     = [s:airline_c_fg.gui, s:airline_c_bg.gui, s:airline_b_fg.cterm, s:airline_c_bg.cterm]
let s:inactive_mod   = [s:bright_white.gui, s:airline_c_bg.gui, s:bright_white.cterm, s:airline_c_bg.cterm]
let g:airline#themes#mariana#palette.inactive = airline#themes#generate_color_map(s:inactive_a, s:inactive_b, s:inactive_c)
let g:airline#themes#mariana#palette.inactive_modified = {'airline_c' : s:inactive_mod}
