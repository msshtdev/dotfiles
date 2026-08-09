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
" Append, never assign: nvim ships wildoptions=pum,tagfile by default and a
" plain assignment would silently disable the wildmenu popup. nvim reports
" v:version 801, so it needs its own arm of the guard.
if has('nvim') || v:version >= 900
    set wildoptions+=fuzzy
endif

" $* marks where :grep splices its arguments in, so the cap can sit after them.
" rg's own --max-count is per file, so a total cap has to come from head.
" The pipe MUST be escaped as \| -- with a bare | vim silently discards
" everything after it and the cap never runs.
let &grepprg = 'rg --vimgrep --smart-case $* \| head -n 100'
set grepformat=%f:%l:%c:%m

filetype plugin on
syntax on

set termguicolors
colorscheme desert
hi Normal      ctermbg=NONE guibg=NONE
hi LineNr      ctermbg=NONE guibg=NONE
hi SignColumn  ctermbg=NONE guibg=NONE
hi EndOfBuffer ctermbg=NONE guibg=NONE

" -- Autocmds
function! s:Ctags()
    if has('nvim')
	call jobstart(['ctags', '-R', '.'], {'detach': v:true})
    else
	call job_start(['ctags', '-R', '.'])
    endif
endfunction

" Open the results, and say so when 'grepprg' truncated them at the cap.
function! s:GrepPost()
    copen
    if len(getqflist()) >= 100
	" unsilent: <Leader>g runs :silent grep!, which would swallow this
	echohl WarningMsg
	unsilent echomsg 'grep: 100-match cap reached, results may be truncated'
	echohl NONE
    endif
endfunction

augroup vimrc
    autocmd!
    autocmd BufWritePost *.c,*.h,*.cpp,*.hpp,*.go,*.py call <SID>Ctags()
    autocmd QuickFixCmdPost grep call <SID>GrepPost()
augroup END

" -- Keymaps

" Buffer navigation
nnoremap          <Leader>b :buffers<CR>:buffer<Space>
nnoremap          <Leader>n :bn<CR>
nnoremap          <Leader>p :bp<CR>
nnoremap          <Leader>d :bd<CR>

" Save & Exit
" Not <silent>: :wa raises E141 on an unnamed modified buffer and the error
" has to be visible. ZZ is deliberately left as the built-in (write this
" buffer, close this window) -- it is not an "exit the editor" key.
nnoremap          <Leader>w :wa<CR>
nnoremap <silent> <Leader>q :qa!<CR>

" Clear search highlight. <Cmd> so a pending count cannot turn this into a
" range and raise E481.
nnoremap <Esc> <Cmd>noh<CR>

" Grep into the quickfix list. This is just :grep -- 'grepprg' already points
" at rg and 'grepformat' parses it, so vim does the argument quoting and the
" errorformat matching. A hand-rolled '^\(.\+\):\(\d\+\):' is greedy and
" mis-parses any hit containing 'HH:MM:SS:'. :silent avoids the hit-enter
" prompt; the QuickFixCmdPost autocmd above opens the list. The ! keeps the
" cursor in that list instead of jumping straight to the first match.
" Quote multi-word patterns:  <Leader>g "foo bar"
nnoremap <Leader>g :silent grep!<Space>

" Find files into the quickfix list, as a worklist to tick off (see s:QfEnter).
" :VFind [rg options] <pattern>  -- the last word is the glob, the rest are
" passed to rg. Every argument goes through shellescape, so a pattern holding
" $VAR, a backtick or a space is searched for literally instead of being
" evaluated by the shell.
function! s:VFind(args)
    let parts = split(trim(a:args))
    if empty(parts) | return | endif
    let pattern = remove(parts, -1)
    let glob    = pattern =~ '[*?[]' ? pattern : '*' . pattern . '*'
    let argv    = ['rg', '--files'] + parts + ['--glob', glob]
    " stderr is folded in so rg's own diagnostics surface instead of being
    " reported as 'no files found'. rg exits 1 for no matches, >=2 for errors.
    let output  = systemlist(join(map(copy(argv), 'shellescape(v:val)')) . ' 2>&1')
    if v:shell_error >= 2
	echohl ErrorMsg | echomsg 'vfind: ' . join(output[0:2], ' ') | echohl NONE
	return
    endif
    if empty(output)
	echo 'vfind: no files found'
	return
    endif
    " Cap in vimscript rather than piping to head, which would clobber v:shell_error
    if len(output) > 1000
	let output = output[0:999]
	echo 'vfind: too many results, showing first 1000'
    endif
    let items = map(copy(output), '{"filename": v:val, "lnum": 1, "col": 1, "text": v:val}')
    call setqflist([], 'r', {'title': 'vfind', 'items': items})
    copen
endfunction
command! -nargs=+ VFind call <SID>VFind(<q-args>)
nnoremap <Leader>f :VFind<Space>

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

" Quick browse current file's directory.
"
" :edit completes file names by wildcard expansion, and '*' never matches a
" leading dot, so <Tab> can never offer .config/ and friends -- fatal in a
" dotfiles repo. 'wildoptions' fuzzy does not help: it is documented as not
" applying to file and directory names. So :E completes from readdir(),
" which lists dot-entries like any other.
function! s:BrowseComplete(arglead, cmdline, cursorpos)
    let head = a:arglead =~ '/' ? fnamemodify(a:arglead, ':h') . '/' : ''
    let tail = a:arglead =~ '/' ? fnamemodify(a:arglead, ':t') : a:arglead
    let dir  = empty(head) ? '.' : head
    if !isdirectory(dir)
	return []
    endif
    let out = []
    for name in readdir(dir)
	if stridx(name, tail) == 0
	    call add(out, head . name . (isdirectory(dir . '/' . name) ? '/' : ''))
	endif
    endfor
    return sort(out)
endfunction
command! -nargs=1 -complete=customlist,<SID>BrowseComplete E
	\ execute 'edit ' . fnameescape(expand(<q-args>))

" expand('%:h') is '' for an unnamed buffer, and the old mapping appended '/'
" to it and browsed the filesystem root.
function! s:CurDir()
    let d = expand('%:h')
    return (empty(d) || d ==# '.') ? '' : d . '/'
endfunction
nnoremap <Leader>e :E <C-r>=<SID>CurDir()<CR>

" Omni-completion. Not <C-n>: that is keyword completion, and remapping it
" also breaks walking forward through an open completion popup.
" Most terminals send <C-@> for <C-Space>, so bind both.
inoremap <C-Space> <C-x><C-o>
inoremap <C-@>     <C-x><C-o>
