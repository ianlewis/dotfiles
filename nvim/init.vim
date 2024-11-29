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

lua require('init')

" Editing {{{
" ----------------------------------------------------------------------------

syntax on
colors desert

set modeline
set modelines=5

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

" Auto set current path to the working directory
augroup rcpath
    autocmd!
    autocmd BufEnter * silent! lcd %:p:h
augroup END

" }}}

" Keymappings {{{
" ----------------------------------------------------------------------------

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

set foldenable
set foldmethod=marker

" }}}

" File Encodings {{{
" ----------------------------------------------------------------------------

set encoding=utf-8
set fileencoding=utf-8
set fileencodings=iso-2002-jp,utf-8,euc-jp,cp932
set fileformat=unix

" }}}

" Status line {{{
" ----------------------------------------------------------------------------
"
set laststatus=2
if has('statusline')
    set statusline=%<%f\ %h%m%r%=%y(%{&ff})\ %{\"[\".(&fenc==\"\"?&enc:&fenc).((exists(\"+bomb\")\ &&\ &bomb)?\",B\":\"\").\"]\ \"}%k\ %-14.(%l,%c%V%)\ %P
endif

" }}}

" Search {{{
" ----------------------------------------------------------------------------

set ignorecase
set incsearch

" }}}

" File Types {{{
" ----------------------------------------------------------------------------

" Markdown {{{
" ----------------------------------------------------------------------------
let g:markdown_fenced_languages = [ 'html', 'go', 'python', 'typescript', 'javascript', 'bash=sh', 'shell=sh' ]
" }}}

" }}}
