" jjdescription filetype plugin
" Language:	jjdescription file
" Maintainer:	Adrià Vilanova <me@avm99963.com>
" Source: Based on ftplugin/gitcommit.vim
" Last Change:	2025 May 08

" Only do this when not done yet for this buffer
if (exists("b:did_ftplugin"))
  finish
endif

let b:did_ftplugin = 1

setlocal nomodeline tabstop=8 formatoptions+=tl textwidth=72
setlocal formatoptions-=c formatoptions-=r formatoptions-=o formatoptions-=q formatoptions+=n
setlocal formatlistpat=^\\s*\\d\\+[\\]:.)}]\\s\\+\\\|^\\s*[-*+]\\s\\+

let b:undo_ftplugin = 'setl modeline< tabstop< formatoptions< tw< com< cms< formatlistpat<'

let &l:comments = ':JJ:'
let &l:commentstring = 'JJ:%s'

if exists("g:no_jjdescription_commands")
  finish
endif

command! -bang -bar -buffer -complete=custom,s:diffcomplete -nargs=* JJDiff :call s:jjdiff(<bang>0, <f-args>)

let b:undo_ftplugin = b:undo_ftplugin . "|delc JJDiff"

function! s:diffcomplete(A, L, P) abort
  let args = ""
  if a:P <= match(a:L." -- "," -- ")+3
    let args = args . "--git\n--stat\n--summary\n-s\n--types\n"
  end
  return args
endfunction

function! s:jjdiff(bang, ...) abort
  " Extract revision from JJ comment lines
  let revision = ''
  for line in getline(1, '$')
    if line =~ '^JJ: Change \w\+'
      let revision = matchstr(line, 'Change \zs\w\+')
      break
    endif
  endfor
  
  " If no revision found, use @ (current revision)
  if empty(revision)
    let revision = '@'
  endif
  
  let name = tempname()
  if a:0
    let extra = join(map(copy(a:000), 'shellescape(v:val)'))
  else
    let extra = "--git --stat=".&columns
  endif
  call system("jj diff -r " . shellescape(revision) . " --color never --no-pager " . extra . " > " . shellescape(name))
  exe 'pedit +setlocal\ buftype=nowrite\ nobuflisted\ noswapfile\ nomodifiable\ filetype=diff' fnameescape(name)
endfunction
