" use Vim settings, rather than Vi settings
set nocompatible


" leader customizations
" =====================

" key for custom commands, to prevent overwrite of standard commands
let mapleader = "ö"

" plugin leader commands
nnoremap <leader>n :noh<cr>
nnoremap <leader>w :StripWhitespace<cr>

" handle buffers and tabs
nnoremap <leader>o :only<cr>
nnoremap <leader>b :bd<cr>
nnoremap <leader>B :bd!<cr>
nnoremap <leader>t :tabnew<cr>
nnoremap <leader>j :tabnext<cr>
nnoremap <leader>k :tabprev<cr>

" Fast markdown
nnoremap <leader>- yyp^v$r-
nnoremap <leader>= yyp^v$r=
nnoremap <leader>* I**<Esc>A**<Esc>

" insert current date
nnoremap <leader>i "=strftime("%F")<CR>p

" git shortcuts from plugings
nnoremap <leader>g :Gstatus<cr>
nnoremap <leader>r :GitGutterUndoHunk<CR>
nnoremap <leader>d :GitGutterPreviewHunk<CR>

" other plugin leader hotkeys
nnoremap <leader>u :GundoToggle<cr>

" possibly breaking customizations
" ================================

" repeat last command and move down a line
" (this chould be a nice plugin if expanded)
noremap - mt.`tj

" allow . and Q to execute once for each line of a visual selection
vnoremap . :normal .<CR>

noremap <Cr> o<Esc>

" move to start and end of line using readline-style shortcuts
" in normal mode C-a increments number, use _ or ^
" $ is a bit annoying to type on swedish keyboards, so enable C-e in normal mode
noremap <C-e> $
inoremap <C-a> <C-o>^
inoremap <C-e> <C-o>$

" use alt j/k to move lines
nnoremap <C-j> :m .+1<CR>==
nnoremap <C-k> :m .-2<CR>==
inoremap <C-j> <Esc>:m .+1<CR>==gi
inoremap <C-k> <Esc>:m .-2<CR>==gi
vnoremap <C-j> :m '>+1<CR>gv=gv
vnoremap <C-k> :m '<-2<CR>gv=gv

" leave insert with jj
" inoremap jj <ESC>

" better handling of wrapped lines
noremap j gj
noremap k gk

" rebind arrow keys - no cheating in normal mode
" navigate between Ack-grep findinigs
noremap <up> :cp<CR>
noremap <down> :cn<CR>
" navigate between syntastic errors
noremap <left> :lprevious<CR>
noremap <right> :lnext<CR>

" faster moving between splits and tabs
noremap <C-h> :bp<CR>
noremap <C-l> :bn<CR>
inoremap <C-h> <C-o>:bp<CR>
inoremap <C-l> <C-o>:bn<CR>

" Don't copy the contents of an overwritten selection.
vnoremap p "_dP

" Make shift-tab work in reverse of tab in insert mode
inoremap <S-Tab> <C-o><<

" remap some useless or dangerous defaults
" use Q to run the macro on q
noremap Q @q
" use K to delete without writing to register
nnoremap K "_d
nnoremap KK "_dd
vnoremap K "_d

" break undo in sensible places
inoremap <CR>  <C-G>u<CR>

" cute hacks
" ==========


" Return to last cursor position when re-opening a file
function! ResCur()
 if line("'\"") <= line("$")
   normal! g`"
   return 1
 endif
endfunction

augroup resCur
 autocmd!
 autocmd BufWinEnter * call ResCur()
augroup END

" cursor color orange in insert mode hack for urxvt
if &term =~ "rxvt-unicode"
   "Set the cursor white in cmd-mode and orange in insert mode
   let &t_EI = "\<Esc>]12;white\x9c"
   let &t_SI = "\<Esc>]12;orange\x9c"
   "We normally start in cmd-mode
   "silent !echo -e "\e]12;white\x9c"
endif

" write file without write permissions
cmap w!! w !sudo tee % >/dev/null

" highlight word under cursor
" from: http://stackoverflow.com/questions/1551231/highlight-variable-under-cursor-in-vim-like-in-netbeans
func! HighlightUnderCursor()
    " naive assumption, if we have syntax highlighting, we also want variable highlight
    if &syntax != ''
        " may want to swap 'Search' for 'IncSearch' depending on colorscheme
        exe printf('match Search /\V\<%s\>/', escape(expand('<cword>'), '/\'))
    endif
endfunc
autocmd CursorMoved * :call HighlightUnderCursor()

function! s:DiffWithSaved()
    let filetype=&ft
    diffthis
    vnew | r # | normal! 1Gdd
    diffthis
    exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction
com! DiffSaved call s:DiffWithSaved()

" check if file has changed when changing buffer or file
au FocusGained,BufEnter * :silent! !

" default color settings
" ======================


if !empty($COLORTERM) || $TERM == "xterm-256color" || $TERM == "screen-256color"
    set t_Co=256
endif

" default to colorscheme, then let plugins override
try
    colorscheme peksim
catch
    set background=dark
    " use default colors
endtry


" plugins
" =======


" some basic security
" do not run plugins when using sudo / sudoedit
" also only run if vundle is installed
if $USER != 'root' && !exists($SUDO_USER) && isdirectory($HOME . '/.vim/bundle/vundle')
    " use vundle for plugins
    filetype off " required for vundle on older vim versions
    set rtp+=~/.vim/bundle/vundle/
    call vundle#rc()
    Bundle 'gmarik/vundle'

    " improve f and t commands
    Bundle 'svermeulen/vim-extended-ft'

    " highlight bad trailing whitespace
    Plugin 'ntpeters/vim-better-whitespace'

    " open files with fuzzy search
    " use with <C-p>
    Bundle 'kien/ctrlp.vim'

    " git / github commands, diff, blame, etc
    Bundle 'tpope/vim-fugitive'

    " visualize undo tree, and revert to previous states
    Bundle 'sjl/gundo.vim'

    " syntax error highlights and descriptions
    Bundle 'scrooloose/syntastic'
    let g:syntastic_check_on_open=1
    let g:syntastic_enable_signs=1
    let g:syntastic_always_populate_loc_list = 1

    " filetree visualization and selection
    Bundle 'scrooloose/nerdtree'
    noremap <C-n> :NERDTreeToggle<cr>

    " search code with ag from vim
    Bundle 'rking/ag.vim'
    noremap <C-g> :Ag

    " colorscheme for vim
    Bundle 'nanotech/jellybeans.vim'
	let g:jellybeans_background_color_256 = 'none'
    let g:jellybeans_overrides = { 'SignColumn': { '256ctermbg': 'NONE' }, }
    try
        colorscheme jellybeans
    catch
        set background=dark
        " use default colors
    endtry

    " fancier status line, with git integration etc
    Bundle 'bling/vim-airline'
    set laststatus=2 " always show statusline
    let g:airline#extensions#whitespace#enabled = 0 " no warning for trailing whitespace
    let g:airline#extensions#tabline#enabled = 1
    let g:airline#extensions#tabline#left_sep = ' '
    let g:airline#extensions#tabline#left_alt_sep = '|'

    " simple separators for bottom powerline, avoid font installation etc
    let g:airline_powerline_fonts = 0
    let g:airline_left_sep=' '
    let g:airline_right_sep=' '

    let g:airline_theme='dark'
    let g:airline_theme_patch_func = 'AirlineThemePatch' " nicer colors
    function! AirlineThemePatch(palette)
        " calm blue instead of ugly yellow for normal mode
        let normalColor = [ '#eeeeee', '#005faf', 255, 25, ]
        let a:palette.normal.airline_a = normalColor
        let a:palette.normal.airline_z = normalColor

        " bright yellow from visual mode used for insert instead
        " will also mark changed files bright yellow on tabline (side effect)
        let a:palette.insert = copy(a:palette.visual)

        " subtle green for visual mode
        let a:palette.visual = copy(a:palette.normal)
        let visualColor = [ '#eeeeee', '#005f00', 255, 22, ]
        let a:palette.visual.airline_a = visualColor
        let a:palette.visual.airline_z = visualColor
    endfunction

    " show + - in the gutter for uncommited git change
    " jumo with [c ]c and operate on text object ic
    Bundle "airblade/vim-gitgutter"

    " better session handling
    Bundle 'tpope/vim-obsession'
    command Obs Obsession .vimsession

    " enable dsb, cs'" and ysiw<div> syntax for changing surrounding elements
    Bundle "tpope/vim-surround"
    Bundle "tpope/vim-repeat"
endif

command BundleSetup !git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle

" reenable filetype after plugin init
filetype plugin indent on


" plain old boring settings
" =========================


" encryption should be strong
if exists("+cryptmethod")
    try
        set cryptmethod=blowfish2
    catch
        set cryptmethod=blowfish
    endtry
endif

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

syntax enable

" linenumbers
set number
" set relativenumber

" better search
set ignorecase
set smartcase
set incsearch
set hlsearch
set showmatch
if exists("+wildignorecase")
    set wildignorecase
endif

" assume the /g flag on :s substitutions to replace all matches in a line:
set gdefault


" tab = spaces
set expandtab
set smarttab

" indentation
set tabstop=4
set shiftwidth=4
set softtabstop=4
set smartindent
set autoindent
set shiftround

" regular tabs for makefiles
autocmd FileType make setlocal noexpandtab

" don't store swapfiles in the current directory
set directory-=.

" few options that just make things better
set encoding=utf-8
set scrolloff=3
set showcmd
set ruler
set ttyfast
set visualbell
set noerrorbells

set tabpagemax=20

" Command line tab completion
set wildmenu
set wildmode=list:longest
set wildignore=*.swp,*.bak,*.pyc,*.class

" Allow hidden buffers with unsaved changes and undo history
set hidden

" Allow backspacing over autoindent, line breaks and start of insert action
set backspace=indent,eol,start

" persistent undo
if exists("+undofile")
    set undofile
    set undodir=~/.vim_undo//
    set undolevels=1000
    set undoreload=10000
endif

" Tell vim to remember certain things when we exit
"  '10  :  marks will be remembered for up to 10 previously edited files
"  "100 :  will save up to 100 lines for each register
"  :20  :  up to 20 lines of command-line history will be remembered
"  %    :  saves and restores the buffer list
"  n... :  where to save the viminfo files
set viminfo='10,\"100,:20,%,n~/.viminfo

" modelines seldom used and possible security risk
set modelines=0

set nobackup
set nowritebackup
