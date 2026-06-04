let mapleader = " "

" ---------------------------------------------------------------
" Options
" ---------------------------------------------------------------
set nocompatible
set number
set relativenumber
set hidden
set tabstop=8
set shiftwidth=4
set softtabstop=4
set noexpandtab
set path+=**
set wildmenu
set wildoptions=fuzzy
set grepprg=rg\ --vimgrep\ --smart-case
set grepformat=%f:%l:%c:%m

filetype plugin on
syntax on

set termguicolors
colorscheme desert
highlight Normal      ctermbg=NONE guibg=NONE
highlight LineNr      ctermbg=NONE guibg=NONE
highlight SignColumn  ctermbg=NONE guibg=NONE
highlight EndOfBuffer ctermbg=NONE guibg=NONE

" ---------------------------------------------------------------
" Tabline
" ---------------------------------------------------------------
set showtabline=2

function! BuflineRender()
    let s = ''
    for buf in range(1, bufnr('$'))
        if buflisted(buf)
            let name = fnamemodify(bufname(buf), ':t')
            let name = empty(name) ? '[No Name]' : name
            let modified = getbufvar(buf, '&modified') ? '+' : ' '
            if buf == bufnr('%')
                let s .= '%#TabLineSel# ' . buf . ' ' . name . modified . ' '
            else
                let s .= '%#TabLine# ' . buf . ' ' . name . modified . ' '
            endif
        endif
    endfor
    return s . '%#TabLineFill#'
endfunction

set tabline=%!BuflineRender()

" ---------------------------------------------------------------
" Autocmds
" ---------------------------------------------------------------
augroup vimrc
    autocmd!
    autocmd BufWritePost *.c,*.h,*.cpp,*.hpp,*.go,*.py call job_start(['ctags', '-R', '.'])
    autocmd QuickFixCmdPost grep copen
    autocmd InsertLeave * normal! mI
augroup END

" ---------------------------------------------------------------
" Keymaps
" ---------------------------------------------------------------
nnoremap <Leader>b :buffers<CR>:buffer<Space>
nnoremap <Leader>n :bn<CR>
nnoremap <Leader>p :bp<CR>
nnoremap <Leader>d :bd<CR>

for i in range(1, 9)
    execute 'nnoremap <silent> <Leader>' . i . ' :' . i . 'b<CR>'
endfor

nnoremap <silent> <Leader>w :w<CR>

nnoremap          <Leader>g :silent grep!<Space>
nnoremap          <Leader>f :find<Space>
nnoremap <silent> <Esc>     :noh<CR>

vnoremap ( <ESC>`>a)<ESC>`<i(<ESC>
vnoremap [ <ESC>`>a]<ESC>`<i[<ESC>
vnoremap { <ESC>`>a}<ESC>`<i{<ESC>
vnoremap < <ESC>`>a><ESC>`<i<<ESC>
vnoremap ` <ESC>`>a`<ESC>`<i`<ESC>
vnoremap ' <ESC>`>a'<ESC>`<i'<ESC>
vnoremap " <ESC>`>a"<ESC>`<i"<ESC>

function! GotoLastInsert()
    try
        normal! `I
        startinsert!
    catch
        echo "No insert mark found"
    endtry
endfunction
nnoremap <silent> gi :call GotoLastInsert()<CR>

inoremap <C-p> <C-x><C-o>
