" Peksim - improved version of peksa coloring scheme :)

" Set 'background' back to the default.  The value can't always be estimated
" and is then guessed.
hi clear Normal
set bg&

" Remove all existing highlighting and set the defaults.
hi clear

" Load the syntax highlighting defaults, if it's enabled.
if exists("syntax_on")
  syntax reset
endif

let colors_name = "peksim"

"
" GUI colors, taken from ir_black.vim
"
hi Normal           ctermfg=white        ctermbg=NONE        cterm=NONE
hi NonText          ctermfg=black       
hi Cursor           ctermfg=black       ctermbg=white       cterm=reverse
hi LineNr           ctermfg=green

"highlighting
hi Search           ctermfg=black       ctermbg=blue        cterm=BOLD
hi MatchParen       ctermfg=white       ctermbg=darkgray    
hi Visual           ctermfg=NONE        ctermbg=darkgray    

"look when splitting and using tabs
hi VertSplit        guifg=#202020     guibg=#202020     gui=NONE      ctermfg=darkgray    ctermbg=darkgrey   cterm=NONE
hi StatusLine       guifg=#CCCCCC     guibg=#202020     gui=italic    ctermfg=white       ctermbg=darkgrey   cterm=NONE
hi StatusLineNC     guifg=black       guibg=#202020     gui=NONE      ctermfg=darkgrey    ctermbg=black      cterm=NONE

hi Error            ctermfg=white       ctermbg=red         guisp=#FF6C60 " undercurl color
hi ErrorMsg         ctermfg=white       ctermbg=red         
hi WarningMsg       ctermfg=white       ctermbg=red         

hi WildMenu         ctermfg=black       ctermbg=yellow      
hi PmenuSbar        ctermfg=black       ctermbg=white       

" Message displayed in lower left, such as --INSERT--
hi ModeMsg          ctermfg=red         ctermbg=NONE        cterm=BOLD


"
" Syntax colors, modified from peksa.vim and lr_black.vim
"

hi Comment      ctermfg=grey

hi Statement    ctermfg=red
hi Function		ctermfg=green
hi PreProc      ctermfg=blue
hi Type			ctermfg=blue
hi Identifier   ctermfg=cyan

hi Number		ctermfg=magenta
hi String		ctermfg=yellow
hi Special		ctermfg=green
hi SpecialChar  ctermfg=darkgreen
hi Constant     ctermfg=darkgreen

hi link Character       String
hi link Boolean         Number
hi link Float           Number
hi link Constant        Number
hi link Repeat          Statement
hi link Label           Statement
hi link Exception       Statement
hi link Operator        SpecialChar
hi link Delimiter       SpecialChar
hi link Include         PreProc
hi link Define          PreProc
hi link Macro           PreProc
hi link PreCondit       PreProc
hi link Keyword         Type
hi link StorageClass    Type
hi link Structure       Type
hi link Typedef         Type
hi link Type            Type
hi link Tag             Special
hi link SpecialComment  Special
hi link Debug           Special
hi link cCustomFunc     Function
hi link cCustomClass    Function

