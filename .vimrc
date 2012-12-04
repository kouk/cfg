" vi:set ts=3:

set encoding=utf-8
set fileencodings=ucs-bom,utf-8,iso-8859-7,latin1

set directory=~/tmp//,.
set nocompatible

set makeprg=gmake

set background=dark

set cmdheight=2 

set backspace=indent,eol,start

set expandtab
set tabstop=4 
set softtabstop=4 
set shiftwidth=4 

set virtualedit=block

set showmatch
set showmode

set nowrap

set nocp

set ruler

set foldmethod=syntax
set incsearch 

set mouse=a

set modeline
set wildmenu

set hidden

let mapleader=","

imap dumper <ESC>^iwarn Data::Dumper->Dump([\<ESC>llyw$a], ['<ESC>pa']);<ESC>
map <C-TAB> :bnext!<CR>
map <C-S-TAB> :bprev!<CR>
map <C-\> :b#<CR>

set laststatus=2
let g:buftabs_in_statusline=1
let g:buftabs_only_basename=1
map <C-b> :bprev!<CR>
map <C-n> :bnext!<CR>

nnoremap <silent> <F8> :TlistToggle<CR>

let Tlist_Exit_OnlyWindow=1
let Tlist_Show_Menu=1

" map mouse scroll buttons
map <M-Esc>[62~ <MouseDown>
map! <M-Esc>[62~ <MouseDown>
map <M-Esc>[63~ <MouseUp>
map! <M-Esc>[63~ <MouseUp>
map <M-Esc>[64~ <S-MouseDown>
map! <M-Esc>[64~ <S-MouseDown>
map <M-Esc>[65~ <S-MouseUp>
map! <M-Esc>[65~ <S-MouseUp>

" Make shift-insert work like in Xterm
map <S-Insert> <MiddleMouse>
map! <S-Insert> <MiddleMouse>


" Don't use Ex mode, use Q for formatting
map Q gq

" maps for greek mode
map Α A
map Β B
map Γ G
map Δ D
map Ε E
map Ζ Z
map Η H
map Θ U
map Ι I
map Κ K
map Λ L
map Μ M
map Ν N
map Ξ J
map Ο O
map Π P
map Ρ R
map Σ S
map Τ T
map Υ Y
map Φ F
map Χ X
map Ψ C
map Ω V
map α a
map β b
map γ g
map δ d
map ε e
map ζ z
map η h
map θ u
map ι i
map κ k
map λ l
map μ m
map ν n
map ξ j
map ο o
map π p
map ρ r
map σ s
map τ t
map υ y
map φ f
map χ x
map ψ c
map ζ v
map ς w

set autoindent
set smartindent
syntax on
syntax sync fromstart
syntax spell toplevel
let c_comment_strings=1

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " For all text files set 'textwidth' to 78 characters.
  au FileType text setlocal tw=78

  " When editing a file, always jump to the last known cursor position.
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  " autocmd BufReadPost * :silent !dcop $KONSOLE_DCOP_SESSION renameSession %

  autocmd Syntax * syntax match Error "\s\+$"
  autocmd Syntax * syntax match Special "\t"
  autocmd Syntax * syntax match Error " \+\t"me=e-1
"  autocmd Syntax * highlight Special guifg=SlateBlue guibg=LightGray
"  autocmd Syntax * syntax match Error "\(^.\{79\}\)\@<=." contains=ALL containedin=ALL

endif " has("autocmd")

set spelllang=en,el
set spellfile=spell.utf-8.add,~/.vim/spell/en.utf-8.add

set guioptions-=m  "remove menu bar
set guioptions-=T  "remove toolbar
set guioptions-=r  "remove right-hand scroll bar

call init#SetupVAM()

let g:vim_addon_manager.plugin_sources["xml-nospell-syntax"] = {'type' : 'git', 'url': 'git://github.com/kouk/vim-xml-nospell-syntax.git'}

call vam#ActivateAddons([
    \ 'SudoEdit',
    \ 'Solarized',
    \ 'pathogen',
    \ 'uri-ref',
    \ 'gnupg%3645',
    \ 'vim-addon-local-vimrc',
    \ 'vcscommand',
    \ 'xml-nospell-syntax',
    \ 'bufexplorer.zip',
    \ ], {'auto_install' : 0})
call pathogen#infect() " for plugins not available with VAM

let g:solarized_termtrans=1
let g:solarized_termcolors=16
let g:solarized_visibility="high"
colorscheme solarized

let g:sudoAuth="sudo"
let g:sudoAuthArg=""

let g:local_vimrc = {'names':['.vimrc_local'],'hash_fun':'LVRHashOfFile'}
