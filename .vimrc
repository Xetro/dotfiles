set nocompatible	" be iMproved, required
filetype off            " required

set laststatus=2	" visual line hack

syntax enable		" enable syntax processing

filetype plugin indent on
set tabstop=4		" number of visual spaces per TAB
set softtabstop=4	" number of staces in tab when editing
set expandtab		" tabs are spaces
set shiftwidth=4

set number	" show line numbers
set showcmd	" show command in bottom bar 
set showmatch	" show matching [{(}]

set incsearch	" search as chars are entered
set hlsearch	" highligh matches

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'dylanaraps/wal.vim'
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'
Plugin 'itchyny/lightline.vim'
Plugin 'scrooloose/nerdtree'

call vundle#end()

colorscheme wal
let g:elite_mode=1

" Map ; key for fzf file search
map ; :Files<CR>

" Disable arrow movement, resize splits instead.
if get(g:, 'elite_mode')
	nnoremap <Up>    :resize +2<CR>
	nnoremap <Down>  :resize -2<CR>
	nnoremap <Left>  :vertical resize +2<CR>
	nnoremap <Right> :vertical resize -2<CR>
endif

" LightLine theme config
let g:lightline = {
	\ 'colorscheme': 'jellybeans',
	\ }

" Enable scrolling with mouse
set mouse=a

" Set syntax highlights for unkown extensions
autocmd BufNewFile,BufRead *.urdf set syntax=xml
