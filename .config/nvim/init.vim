let mapleader = " "

set nocompatible
filetype plugin on

set number
set hidden
syntax on

set tabstop=8
set shiftwidth=4
set softtabstop=4
set noexpandtab

set path+=**
set wildmenu
set wildoptions=fuzzy "9.0<=


" Make background transparent / use terminal background
set termguicolors
colorscheme desert
highlight Normal ctermbg=NONE guibg=NONE
highlight LineNr ctermbg=NONE guibg=NONE
highlight SignColumn ctermbg=NONE guibg=NONE
highlight EndOfBuffer ctermbg=NONE guibg=NONE

" Auto generate tags file on file write of source files
autocmd BufWritePost *.c,*.h,*.cpp,*.hpp,*.go,*.py silent! !ctags . &

" Access buffer easily
nnoremap <Leader>b :buffers<CR>:buffer<Space>
nnoremap <Leader>n :bn<CR>
nnoremap <Leader>p :bp<CR>

" Search files and words easily
autocmd QuickFixCmdPost grep  copen 
nnoremap <leader>g :silent grep!<Space>
nnoremap <leader>f :find<Space>

" Surroud when selected
vnoremap ( <ESC>`>a)<ESC>`<i(<ESC>
vnoremap [ <ESC>`>a]<ESC>`<i[<ESC>
vnoremap { <ESC>`>a}<ESC>`<i{<ESC>
