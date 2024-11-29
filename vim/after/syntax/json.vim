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

" Allows comments in tsconfig.json files while still using json filetype.
augroup rcjsonc
    autocmd!
    autocmd BufEnter tsconfig.json setlocal commentstring=//%s
    autocmd BufEnter tsconfig.json syntax match Comment +\/\/.\+$+
    autocmd BufEnter tsconfig.json syntax match Comment +\/\*.\+\*\/$+
augroup END
