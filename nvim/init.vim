set modeline
set modelines=5

" Auto set current path to the working directory
" autocmd BufEnter * silent! lcd %:p:h

syntax on
colors desert

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
