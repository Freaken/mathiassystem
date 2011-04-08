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

" Sætter tags filen
set tags=./tags,./../tags,./../../tags,./../../../tags,tags

" F12 giver yank til system clipboard
" Insert giver paste fra systemboard
nnoremap <F12> :%y +<CR>
vnoremap <F12> "+y
nnoremap <Insert> o<Esc>"+p
inoremap <Insert> ☃<Esc>x"+pa

" Redetect filetype
noremap <F5> :filetype detect<CR>

" Funktion til at sætte TabWidth til en bestemt vidde
fun! TabWidth(size)
    execute "set shiftwidth=" . a:size
    execute "set tabstop=" . a:size
endfun

" Jeg foretrækker indentering 4
call TabWidth(4)

" Men ikke i alle filtyper
autocmd FileType html,xhtml,php,xml,xsl,sh call TabWidth(2)

" I TeX skal linjerne ikke være mere end 80 tegn
autocmd FileType tex set tw=80

" Formatter et afsnit i tex med ctrl+f.
" Kræver at par er installeret (med apt-get)
set formatprg=par\ -w80\ -p0\ -s0
nnoremap <F4> i☃<Esc>{V}gq/☃<CR>x
inoremap <F4> ☃<Esc>{V}gq/☃<CR>xi

let g:closetag_html_style=1
source ~/.vim/scripts/closetag.vim

