set nocompatible

" Blandet auto-indenterings-gøjl
filetype plugin indent on
set expandtab
set autoindent
set smartindent

" Ændrer hvilke tegn der wrapper en linje
set whichwrap=[,]

" Slår folding til
set foldenable
set foldmethod=marker

" Gør så backspace kan slette indentering mm
set backspace=indent,eol,start

" Ctrl+y giver yank til system clipboard
" Ctrl+p giver paste fra systemboard
nnoremap <C-y> :%y +<CR>
vnoremap <C-y> "+y
nnoremap <C-p> o<Esc>"+p
inoremap <C-p> ☃<Esc>x"+pa

" Funktion til at sætte TabWidth til en bestemt vidde
fun! TabWidth(size)
    execute "set shiftwidth=" . a:size
    execute "set tabstop=" . a:size
endfun

" Jeg foretrækker indentering 4
call TabWidth(4)

" Men ikke i html og php-filer
autocmd FileType html call TabWidth(2)
autocmd FileType xhtml call TabWidth(2)
autocmd FileType php call TabWidth(2)

" I TeX skal linjerne ikke være mere end 80 tegn
autocmd FileType tex set tw=80

" Formatter et afsnit i tex med ctrl+f.
" Kræver at par er installeret (med apt-get)
set formatprg=par\ -w80\ -p0\ -s0
nnoremap <C-f> i☃<Esc>{V}gq/☃<CR>x
inoremap <C-f> ☃<Esc>{V}gq/☃<CR>xi
