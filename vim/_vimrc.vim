" Copyright 2024 Ian Lewis
"
" Licensed under the Apache License, Version 2.0 (the "License");
" you may not use this file except in compliance with the License.
" You may obtain a copy of the License at
"
"      http://www.apache.org/licenses/LICENSE-2.0
"
" Unless required by applicable law or agreed to in writing, software
" distributed under the License is distributed on an "AS IS" BASIS,
" WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
" See the License for the specific language governing permissions and
" limitations under the License.

" Local config.
if filereadable($HOME.'/.vimrc.first.local')
    source $HOME/.vimrc.first.local
endif

" Pathogen
" ----------------------------------------------------------------------------

" Install pathogen and load bundles
runtime bundle/pathogen/autoload/pathogen.vim
execute pathogen#infect()

" Housekeeping
" ----------------------------------------------------------------------------

" Set swap file directory
" Add two slashes at the end so the swap file name is
" built from the full file path.
set directory=~/.vim/swap//
" Set backup file directory
" Add two slashes at the end so the swap file name is
" built from the full file path.
set backupdir=~/.vim/backup//

set modeline
set modelines=5

" Editing
" ----------------------------------------------------------------------------
syntax on
colors desert

augroup rcconfig
    autocmd!

    " Auto set current path to the working directory
    autocmd BufEnter * silent! lcd %:p:h

    " The PC is fast enough, do syntax highlight syncing from start
    autocmd BufEnter * :syntax sync fromstart

    "Turn off automatic comment continuation
    autocmd FileType * setlocal fo-=r fo-=q fo-=o
augroup END

" new horizontal split panes show up on the bottom
set splitbelow
" new vertical split panes show up to the right
set splitright

" Use soft tabs of 4 spaces by default.
set tabstop=4
set shiftwidth=4
set expandtab

" Set backspace mode. Actually delete characters when backspace is input.
set bs=2
set backspace=2

" Turn off automatic switching to Japanese input
set iminsert=0
set imsearch=0

" Auto indentation
" Enable filetype plugins and indention
filetype plugin indent on
" set cindent
" " go with smartindent if there is no plugin indent file.
" " but don't outdent hashes
" set smartindent
" inoremap # X#
" set autoindent

" Set the fold level so that folds are open by default.
" See: http://vim.wikia.com/wiki/All_folds_open_when_opening_a_file
set foldlevelstart=20

"Turn off annoying system bell
set visualbell t_vb=

" sets leader to ',' and localleader to "\"
let mapleader=','
let maplocalleader='\'

" Don't use selectmode
set selectmode=

" Keymappings for Dvorak
noremap n j
noremap t k
noremap s l
noremap j n
noremap gn gk
noremap gt gj

noremap l n

" tab for brackets
nnoremap <tab> %
vnoremap <tab> %

" toggle between line number, relative line number and nonumber on ,l
nnoremap <leader>l :call ToggleRelativeAbsoluteNumber()<CR>
function! ToggleRelativeAbsoluteNumber()
    if &relativenumber
        set nonumber
        set norelativenumber
    else
        if &number
            set relativenumber
        else
            set number
        endif
    endif
endfunction

" File Encodings
" ----------------------------------------------------------------------------

set encoding=utf-8
set fileencoding=utf-8
set fileencodings=iso-2002-jp,utf-8,euc-jp,cp932
set fileformat=unix

" Search
" ----------------------------------------------------------------------------

set ignorecase

" incremental search
set incsearch

augroup rccomments
    autocmd!

    " Set the comment string for C++ to line comments.
    autocmd FileType cpp setlocal commentstring=//%s
augroup END

" Markdown
" ----------------------------------------------------------------------------

let g:markdown_fenced_languages = [ 'html', 'go', 'python', 'typescript', 'javascript', 'bash=sh' ]

" Omnicomplete
" ----------------------------------------------------------------------------
set ofu=syntaxcomplete#Complete

augroup rccomplete
    autocmd!

    autocmd FileType python set omnifunc=pythoncomplete#Complete
    autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
    autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
    autocmd FileType css set omnifunc=csscomplete#CompleteCSS
augroup END

" netrw
" ----------------------------------------------------------------------------

"limit netrw file list
let g:netrw_list_hide='^.*\~$,^.*\.pyc$,\.exe$,\.zip$,\.gz,\.swp,\.orig$'

" GUI Options
" ----------------------------------------------------------------------------

" Status line
set laststatus=2
if has('statusline')
    set statusline=%<%f\ %h%m%r%=%y(%{&ff})\ %{\"[\".(&fenc==\"\"?&enc:&fenc).((exists(\"+bomb\")\ &&\ &bomb)?\",B\":\"\").\"]\ \"}%k\ %-14.(%l,%c%V%)\ %P

    " Errors for syntax checking
    set statusline+=%#warningmsg#
    if exists(':SyntasticStatuslineFlag')
        set statusline+=%{SyntasticStatuslineFlag()}
    endif
    set statusline+=%*
endif

"Hide menu and toolbar
set guioptions-=T
set guioptions-=m
" Turn off cursor blinking
set gcr=a:blinkon0
" Allow more characters in console mode.
set ttyfast

" ----------------------------------------------------------------------------

" Search for selected text, forwards or backwards.
vnoremap <silent> * :<C-U>
            \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
            \gvy/<C-R><C-R>=substitute(
            \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
            \gV:call setreg('"', old_reg, old_regtype)<CR>
vnoremap <silent> # :<C-U>
            \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
            \gvy?<C-R><C-R>=substitute(
            \escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
            \gV:call setreg('"', old_reg, old_regtype)<CR>

" Terminal friendly visual block shortcut for the terminal. This is an escape
" hatch for when Ctrl-v doesn't work in some terminals.
noremap vb <C-v>

" Windows style Cut,Copy,Paste for interaction with other programs. This
" is pretty hacky but I can never remember the right paste commands.
" ----------------------------------------------------------------------------

" nmap <C-x> "+x
vmap <C-x> "+x

" nmap <C-c> "+y
vmap <C-c> "+y

nmap <C-v> "+gP
vmap <C-v> <DEL>"+gP
imap <C-v> <ESC>"+gpi

" Toggle the quick buffer by hitting semicolon twice.
nmap ;; <Plug>quickbuf

" Autoformatter
" ----------------------------------------------------------------------------
augroup autoformat
    autocmd!
    autocmd BufWrite * :Autoformat
augroup END

" Don't fall back to vim's autoindent because it breaks a lot of file types
let g:autoformat_autoindent = 0
" Override the default standard command as it's very picky about the input and
" returns an error code even with warnings.
let g:formatters_go = ['gofumpt', 'gofmt_1', 'goimports', 'gofmt_2']
let g:formatdef_gofumpt = '"gofumpt"'
let g:formatters_javascript = ['prettier']
let g:formatters_json = ['prettier']
let g:formatters_yaml = ['prettier']
let g:formatters_markdown = ['prettier']
let g:formatters_html = ['prettier']
let g:formatters_sql = ['sqlformatter']
let g:formatdef_sqlformatter = '"sql-formatter"'

" Terraform/OpenTofu
if !exists('g:formatdef_terraform_format')
    let g:formatdef_terraform_format = '"terraform fmt -"'
endif

if !exists('g:formatdef_opentofu_format')
    let g:formatdef_opentofu_format = '"tofu fmt -"'
endif

let g:formatters_terraform = ['terraform_format', 'opentofu_format']

" Syntastic
" ----------------------------------------------------------------------------
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 1

" Disable compile checking for syntastic since it's really slow with large
" projects like Kubernetes.
let g:syntastic_go_checkers = ['golint', 'govet', 'errcheck']
" Uncomment this line if setting g:syntastic_auto_loc_list = 1
" let g:syntastic_mode_map = { 'mode': 'active', 'passive_filetypes': ['go'] }

" Python syntax checking
let g:syntastic_python_checkers = ['flake8']

" YAML checking
let g:syntastic_yaml_checkers = ['yamllint']

" For java syntax checking
"let g:syntastic_java_checker = 'javac'

" Make eclim use omnifunc so that it plays well with YCM
let g:EclimCompletionMethod = 'omnifunc'

" Bp
" ----------------------------------------------------------------------------
" Closes the current buffer without closing the window.
" TODO: Support bang
map <leader>q :bp<bar>sp<bar>bn<bar>bd<CR>

" Local config.
" --------------------------------------------------
if filereadable($HOME.'/.vimrc.local')
    source $HOME/.vimrc.local
endif
