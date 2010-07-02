set nocompatible
filetype plugin indent on
set expandtab
set autoindent
set smartindent
set shiftwidth=4
set tabstop=4
set whichwrap=[,]
set foldenable
set foldmethod=marker
set backspace=indent,eol,start

" Ctrl+y giver yank til system clipboard
" Ctrl+p giver paste fra systemboard
nnoremap <C-y> :%y +<CR>
vnoremap <C-y> "+y
nnoremap <C-p> o<Esc>"+p
inoremap <C-p> ☃<Esc>x"+pa
