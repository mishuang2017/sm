set ruler

set hidden

set hlsearch
set nohlsearch

set background=dark
" set background=dark

set tabstop=8

set softtabstop=4
set shiftwidth=4
set softtabstop=2
set softtabstop=8
set shiftwidth=2
set shiftwidth=8

set encoding=utf-8
" set cindent
" set autoindent
" set textwidth=80
" set smartindent
syntax off
syntax on

set winwidth=80
" set ignorecase
set nowrap
set wrap
set autowrite

" imap { {<CR>}<ESC>O

map <C-J> :previous<CR>
map <C-K> :next<CR>

map <F2> :set number!<CR>
map <F3> :call CComment2()<CR>
map <F4> :call SComment()<CR>

map <F7> :!make<CR>:!make run<CR>
imap <F7> <ESC>:!make<CR>:!make run<CR>
map <F8> :!make<CR>
imap <F8> <ESC>:w<ESC>:!make<CR>
map <F9> :w<CR>:!make run<CR>

map <F10> :!make clean<CR>
map <F11> :call Syn()<CR>
map <F12> :set hlsearch!<CR>

map <c-w><c-o> <c-w><c-p>
map <c-w>o <c-w><c-p>

function Syn()
	:color default
	:set bg=dark
endfunc

function CComment()
	let line = getline(".")
	if line[0][0] == "/"
		:s/\/\/ //
	else
		:s/^/\/\/ /
	endif
endfunc

function CComment2()
	let line = getline(".")
	if line[0][0] == "/"
		:s/\/\* //
		:s/ \*\///
	else
		:s/^/\/\* /
		:s/$/ \*\//
	endif
endfunc

function SComment()
	let line = getline(".")
	if line[0][0] == "#"
		:s/^# //
	else
		:s/^/# /
	endif
endfunc

" colorscheme darkZ
" colorscheme dark-ruby
" colorscheme c

set vb t_vb=     " no visual bell & flas
