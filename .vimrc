let mapleader = " "

" -- Options
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
if v:version >= 900
    set wildoptions=fuzzy
endif

set grepprg=rg\ --vimgrep\ --smart-case
set grepformat=%f:%l:%c:%m

filetype plugin on
syntax on

set termguicolors
colorscheme desert
hi Normal      ctermbg=NONE guibg=NONE
hi LineNr      ctermbg=NONE guibg=NONE
hi SignColumn  ctermbg=NONE guibg=NONE
hi EndOfBuffer ctermbg=NONE guibg=NONE

" -- Bufline
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
set showtabline=2
set tabline=%!BuflineRender()

" -- Autocmds
augroup vimrc
    autocmd!
    autocmd BufWritePost *.c,*.h,*.cpp,*.hpp,*.go,*.py call job_start(['ctags', '-R', '.'])
    autocmd QuickFixCmdPost grep copen
    autocmd InsertLeave * normal! mI
augroup END

" -- Keymaps

" Buffer navigation
nnoremap          <Leader>b :buffers<CR>:buffer<Space>
nnoremap          <Leader>n :bn<CR>
nnoremap          <Leader>p :bp<CR>
nnoremap          <Leader>d :bd<CR>

for s:i in range(1, 9)
    execute 'nnoremap <silent> <Leader>' . s:i . ' :' . s:i . 'b<CR>'
endfor

" Save & Exit
nnoremap <silent> <Leader>w :w<CR>
nnoremap <silent> ZZ        :q!<CR>

" Clear search highlight
nnoremap <silent> <Esc> :noh<CR>

" Helper: collect valid directories from 'path' for rg
function! s:SearchDirs()
    let dirs = []
    let seen = {}
    for p in split(&path, ',')
	let d = (p == '' || p == '.') ? '.' : p
	if d !~ '\*' && d !~ '^/' && !has_key(seen, d)
	    let seen[d] = 1
	    call add(dirs, shellescape(d))
	endif
    endfor
    return len(dirs) > 0 ? dirs : ['.']
endfunction

function! s:VGrep()
    let args = input('grep> ')
    if args == '' | return | endif
    let dirs   = join(s:SearchDirs(), ' ')
    let cmd    = 'rg --vimgrep --smart-case ' . args . ' ' . dirs . ' 2>/dev/null | head -n 1000'
    let output = systemlist(cmd)
    if len(output) == 0
	echo 'grep: no matches found'
	return
    endif
    if len(output) >= 1000
	echo 'grep: too many results, showing first 1000'
    endif
    let items = []
    for line in output
	let m = matchlist(line, '^\(.\+\):\(\d\+\):\(\d\+\):\(.*\)$')
	if len(m) > 0
	    call add(items, {'filename': m[1], 'lnum': str2nr(m[2]), 'col': str2nr(m[3]), 'text': m[4]})
	endif
    endfor
    call setqflist([], 'r', {'title': 'grep', 'items': items})
    copen
endfunction
nnoremap <silent> <Leader>g :call <SID>VGrep()<CR>

function! s:VFind()
    let input = input('vfind> ')
    if input == '' | return | endif
    let parts   = split(trim(input), '\s\+')
    let pattern = remove(parts, -1)
    let rg_args = join(parts, ' ')
    let glob    = pattern =~ '[*?[]' ? pattern : '*' . pattern . '*'
    let dirs    = join(s:SearchDirs(), ' ')
    let cmd     = 'rg --files ' . rg_args . ' --glob ' . shellescape(glob) . ' ' . dirs . ' 2>/dev/null | head -n 1000'
    let output  = systemlist(cmd)
    if len(output) == 0
	echo 'vfind: no files found'
	return
    endif
    if len(output) >= 1000
	echo 'vfind: too many results, showing first 1000'
    endif
    let items = []
    for f in output
	call add(items, {'filename': f, 'lnum': 1, 'col': 1, 'text': f})
    endfor
    call setqflist([], 'r', {'title': 'vfind', 'items': items})
    copen
endfunction
nnoremap <silent> <Leader>f :call <SID>VFind()<CR>

" Quickfix <CR>: open file; in vfind lists also removes the entry
function! s:QfEnter()
    let idx  = line('.')
    let info = getqflist({'title': 1})
    if info.title ==# 'vfind'
	let qflist = getqflist()
	let item   = qflist[idx - 1]
	call remove(qflist, idx - 1)
	call setqflist([], 'r', {'title': 'vfind', 'items': qflist})
	if !empty(item) && item.bufnr > 0
	    wincmd p
	    execute 'buffer ' . item.bufnr
	    call setbufvar(item.bufnr, '&buflisted', 1)
	endif
	cclose
    else
	execute 'cc ' . idx
	cclose
    endif
endfunction

augroup QuickfixMap
    autocmd!
    autocmd FileType qf nnoremap <buffer> <silent> <CR> :call <SID>QfEnter()<CR>
augroup END

" Surround visual selection
vnoremap (  <ESC>`>a)<ESC>`<i(<ESC>
vnoremap [  <ESC>`>a]<ESC>`<i[<ESC>
vnoremap {  <ESC>`>a}<ESC>`<i{<ESC>
vnoremap ``  <ESC>`>a`<ESC>`<i`<ESC>
vnoremap ''  <ESC>`>a'<ESC>`<i'<ESC>
vnoremap "" <ESC>`>a"<ESC>`<i"<ESC>

" gi: jump to last insert position (mark I) and resume insert
function! s:GotoLastInsert()
    try
	normal! `I
	startinsert!
    catch
	echo 'No insert mark found'
    endtry
endfunction
nnoremap <silent> gi :call <SID>GotoLastInsert()<CR>

" Quick browse current file's directory
nnoremap <Leader>e :e <C-r>=expand('%:h').'/'<CR>

" Omni-completion
inoremap <C-n> <C-x><C-o>
