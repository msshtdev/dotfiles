set nocompatible
filetype plugin on

set number
set hidden
syntax on

set tabstop=8
set shiftwidth=4
set softtabstop=4
set noexpandtab


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

" Include sub-directories to search path
set path=.,*/**,
