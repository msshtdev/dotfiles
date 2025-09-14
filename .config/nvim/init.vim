set nocompatible
filetype plugin on

set number
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
