" ============================================
" Config of VIM Editor
" Author: Galimyanov Rustam
" Year:2015
" ============================================

" --------------
" Vundle init
" --------------
set rtp+=~/.vim/bundle/Vundle.vim " set the runtime path to include Vundle and initialize
call vundle#begin() " alternatively, pass a path where Vundle should install plugins; call vundle#begin('~/some/path/here')

" -------------
" Plugins
" -------------
Plugin 'VundleVim/Vundle.vim' " let Vundle manage Vundle, required
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'scrooloose/nerdTree'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'scrooloose/syntastic'
Plugin 'rizzatti/dash.vim'
Plugin 'bling/vim-bufferline'
Plugin 'mbbill/undotree'
Plugin 'honza/vim-snippets'
Plugin 'Raimondi/delimitMate'
Plugin 'ryanoasis/vim-devicons'
Plugin 'joshdick/onedark.vim'
Plugin 'rakr/vim-one'
call vundle#end()
filetype plugin indent on

" --------------
" Theme settings
" -------------
syntax enable " syntax highlighting
colorscheme one
set background=dark


" ---------------
" Spaces and Tabs
" ---------------
set tabstop=2 " number of visual spaces per TAB
set softtabstop=2 " number of visual spaces in tab then editing
set expandtab " tabs are spaces

" ---------------
" UI Config
" ---------------
set number " show line numbers
set showcmd " show command in bottom bar
set cursorline " highlight current line
filetype indent on " load specific filetype indent files
set wildmenu " visual autocomplete for command menu
set lazyredraw " redraw only when we need to
set showmatch "highlight matching {[()]}"
set guifont=IosevkaTerm\ Nerd\ Font:h18
" --------------
" Searching
" --------------
set incsearch " search all characters are entered
set hlsearch " highlight matches

" -------------
" Folding
" --------------
set foldenable " enable folding
set foldlevelstart=10 " open most folds by default
set foldnestmax=10 " 10 nested fold max
" space open/closes folds
nnoremap <space> za

" ----------------
" Movement
" ---------------
" move vertically by visual line
nnoremap j gj
nnoremap k gk
" move to beginning/end of line
nnoremap B ^
nnoremap E $
" $/^ doesnt do anything
nnoremap $ <nop>
nnoremap ^ <nop>
" highlight last inserted text
nnoremap gV '[v']

" ----------------
" Shortcuts
" ----------------
let mapleader="," " leader is comma
" jk is escape
inoremap jk <esc>
" toggle undotree
nnoremap <leader>u :UndotreeToggle<CR>
" save session
nnoremap <leader>s :mksession<CR>
" open ag.vim
nnoremap <leader>a :Ag
" Switch netween buffers
nnoremap <leader>b :bNext<CR>
 " turn off search highlight
nnoremap <leader><space> :nohlsearch<CR>
nmap <silent> <leader>d <Plug>DashSearch
nmap <silent> <leader>D <Plug>DashGlobalSearch

" ----------------
" Tmux
" ----------------
if exists('$TMUX')
    let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
    let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
    let &t_SI = "\<Esc>]50;CursorShape=1\x7"
    let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif

" ---------------
"  Autogroups
" ---------------
augroup configgroup
    autocmd!
    autocmd VimEnter * highlight clear SignColumn
    autocmd BufWritePre *.php,*.py,*.js,*.txt,*.hs,*.java,*.md
                 \:call <SID>StripTrailingWhitespaces()
    autocmd FileType java setlocal noexpandtab
    autocmd FileType java setlocal list
    autocmd FileType java setlocal listchars=tab:+\ ,eol:-
    autocmd FileType java setlocal formatprg=par\ -w80\ -T4
    autocmd FileType php setlocal expandtab
    autocmd FileType php setlocal list
    autocmd FileType php setlocal listchars=tab:+\ ,eol:-
    autocmd FileType php setlocal formatprg=par\ -w80\ -T4
    autocmd FileType ruby setlocal tabstop=2
    autocmd FileType ruby setlocal shiftwidth=2
    autocmd FileType ruby setlocal softtabstop=2
    autocmd FileType ruby setlocal commentstring=#\ %s
    autocmd FileType python setlocal commentstring=#\ %s
    autocmd BufEnter *.cls setlocal filetype=java
    autocmd BufEnter *.zsh-theme setlocal filetype=zsh
    autocmd BufEnter Makefile setlocal noexpandtab
    autocmd BufEnter *.sh setlocal tabstop=2
    autocmd BufEnter *.sh setlocal shiftwidth=2
    autocmd BufEnter *.sh setlocal softtabstop=2
augroup END

" ---------------
"  Backups
" ---------------
set backup
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set backupskip=/tmp/*,/private/tmp/*
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set writebackup

" ---------------
" Tuning
" --------------
set backspace=indent,eol,start

" ---------------
"  Settings for Silver Searcher 
" --------------- 
set runtimepath^=~/.vim/bundle/ag

" --------------
" Airline config
" --------------
set laststatus=2
let g:airline_theme='one'
let g:airline_powerline_fonts=1
let g:airline#extensions#tabline#enabled = 1
let g:airline_detect_modifier=1
let g:airline_detect_paste=1
let g:airline_detect_crype=1
"let g:airline_inactive_collapse=l
let g:airline#extension#branch#enabled=1
let g:airline#extension#branch#empty_message = ''
let g:airline#extensions#syntastic#enabled = 1
"let g:airline#extensions#ctrlp#color_template = 'insert' (default)
let g:airline#extensions#ctrlp#color_template = 'normal'
let g:airline#extensions#ctrlp#color_template = 'visual'
let g:airline#extensions#ctrlp#color_template = 'replace'
let g:airline#extension#bufferline#enabled = 1
let g:airline#extension#bufferline#overwrite_variables = 1
" bufferline settings
let g:bufferline_echo = 0 
let g:bufferline_active_buffer_left = '['
let g:bufferline_active_buffer_right = ']'
let g:bufferline_solo_highlight = 0
let g:bufferline_active_highlight = 'StatusLine'
let g:bufferline_inactive_highlight = 'StatusLineNC'
" let g:bufferline_rotate = 1
let g:bufferline_show_bufnr = 1
let g:bufferline_modified = '+'

" --------------
" Syntastic settings
" --------------
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" -------------
" Settings for Ctrlp
" -------------
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = 'ra'
set wildignore+=*/tmp/*,*.so,*.swp,*.zip     " MacOSX/Linux
let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
"let g:ctrlp_custom_ignore = {
"  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
"  \ 'file': '\v\.(exe|so|dll)$',
"  \ 'link': 'some_bad_symbolic_links',
"  \ 
" }
" let g:ctrlp_user_command = 'find %s -type f'
" let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']

" ----------------
" Ultisnips settings
" ----------------
"let g:UltiSnipsExpandTrigger="<tab>"
"let g:UltiSnipsJumpForwardTrigger="<c-b>"
"let g:UltiSnipsJumpBackwardTrigger="<c-z>"

