set nocompatible
filetype plugin indent on
set expandtab
set autoindent
set smartindent
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

fun! TabWidth(size)
    execute "set shiftwidth=" . a:size
    execute "set tabstop=" . a:size
endfun

call TabWidth(4)

autocmd FileType html call TabWidth(2)
autocmd FileType php call TabWidth(2)
autocmd FileType tex set tw=80

" Formatter et afsnit i tex med ctrl+f.
" Kræver at par er installeret (med apt-get)
set formatprg=par\ -w80\ -p0\ -s0
nnoremap <C-f> i☃<Esc>{V}gq/☃<CR>x
inoremap <C-f> ☃<Esc>{V}gq/☃<CR>xi
