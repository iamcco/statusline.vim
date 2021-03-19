" check if statusline is already running
if exists('g:statusline_running')
  finish
endif
let g:statusline_running = 1

" mode flag to string mapping
let s:modes = {
    \   'n':        'NORMAL',
    \   'no':       'NORMAl',
    \   'nov':      'NORMAL',
    \   'noV':      'NORMAL',
    \   'noCTRL-V': 'NORMAL',
    \   'no':     'NORMAL',
    \   'niI':      'NORMAL',
    \   'niR':      'NORMAL',
    \   'niV':      'NORMAL',
    \   'v':        'VISUAL',
    \   'V':        'VISUAL',
    \   '':       'VISUAL',
    \   'CTRL-V':   'VISUAL',
    \   's':        'SELECT',
    \   'S':        'SELECT',
    \   'CTRL-S':   'SELECT',
    \   '':       'SELECT',
    \   'i':        'INSERT',
    \   'ic':       'INSERT',
    \   'ix':       'INSERT',
    \   'R':        'REPLACE',
    \   'Rc':       'REPLACE',
    \   'Rv':       'REPLACE',
    \   'Rx':       'REPLACE',
    \   'c':        'COMMAND',
    \   'cv':       'COMMAND',
    \   'ce':       'COMMAND',
    \   'r':        'PROMPT',
    \   'rm':       'PROMPT',
    \   'r?':       'PROMPT',
    \   '!':        'SHELL',
    \   't':        'TERMINAL'
    \ }


function! s:init_highlight() abort
  " highlight StlModeNORMAL       guibg=#98c379 guifg=#282c34 ctermbg=114 ctermfg=235
  " highlight StlModeINSERT       guibg=#61afef guifg=#282c34 ctermbg=39  ctermfg=235
  " highlight StlModeVISUAL       guibg=#c678dd guifg=#282c34 ctermbg=170 ctermfg=235
  " highlight StlModeREPLACE      guibg=#e06c75 guifg=#282c34 ctermbg=204 ctermfg=235
  " highlight StlSection          guibg=#3e4452 guifg=#abb2bf ctermbg=237 ctermfg=145
  " highlight StlNormalUnmodified guibg=#282c34 guifg=#67727f ctermbg=235 ctermfg=241
  " highlight StlNormalModified   guibg=#3e3452 guifg=#78828f ctermbg=235 ctermfg=241
  " highlight StlWarning          guibg=#e5c07b guifg=#484848 ctermbg=180 ctermfg=239
  " highlight StlError            guibg=#e06c75 guifg=#282828 ctermbg=204 ctermfg=235
  highlight link       StlModeNORMAL       Normal
  highlight link       StlModeINSERT       Normal
  highlight link       StlModeVISUAL       Normal
  highlight link       StlModeREPLACE      Normal
  highlight link       StlSection          Normal
  highlight link       StlNormalUnmodified Normal
  highlight link       StlNormalModified   Normal
  highlight StlWarning guibg=#e5c07b       guifg=#484848 ctermbg=180 ctermfg=239
  highlight StlError   guibg=#e06c75       guifg=#282828 ctermbg=204 ctermfg=235

  highlight link StlModeCOMMAND  StlModeNORMAL
  highlight link StlModePROMPT   StlModeNORMAL
  highlight link StlModeSHELL    StlModeNORMAL
  highlight link StlModeTERMINAL StlModeNORMAL
  highlight link StlModeSELECT   StlModeVISUAL
  highlight link StlMode         StlModeNORMAL
  highlight link StlNormal       StlNormalUnmodified
endfunction

" pad string with space
function! Statusline_pad(item) abort
  let l:info = trim(a:item)
  if l:info !=# ''
    let l:info = ' ' . l:info . ' '
  endif
  return l:info
endfunction

" vim mode
function! Statusline_mode(...) abort
  let l:mode = get(a:, '1', s:modes[mode()])
  execute 'highlight! link StlMode StlMode' . l:mode
  return l:mode
endfunction

" git info from coc-git
function! Statusline_git() abort
  let l:info = trim(get(g:, 'coc_git_status', '') . ' ' . trim(get(b:, 'coc_git_status', '')))
  if l:info !=# ''
    let l:info = substitute(' ' . trim(l:info) . ' ', '●', '•', 'g')
  endif
  return l:info
endfunction

function! Statusline_file() abort
  let l:info = substitute(fnamemodify(expand('%:p'), ':p'), '\v^.*\/([^ \/]+\/[^ \/]+)$' , '\1', 'i')
  if &modified
    highlight link StlNormal StlNormalModified
  else
    highlight link StlNormal StlNormalUnmodified
  endif
  return l:info
endfunction

" diagnostics from coc
function! Statusline_diagnostics(type) abort
  let l:info = ''
  let l:count = get(get(b:, 'coc_diagnostic_info', {}), a:type, 0)
  if l:count !=# 0
    let l:info = ' ' . l:count . ' '
  endif
  if a:type ==# 'error' && l:info !=# '' && trim(get(g:, 'coc_status', ''), '') !=# ''
    let l:info = ' ' . l:info
  endif
  if a:type ==# 'warning' && l:info !=# '' && get(get(b:, 'coc_diagnostic_info', {}), 'error', 0) !=# 0
    let l:info = ' ' . l:info
  elseif a:type ==# 'warning' && l:info !=# '' && trim(get(g:, 'coc_status', ''), '') !=# ''
    let l:info = ' ' . l:info
  endif
  return l:info
endfunction

" set current buffer statusline
function! Statusline_update(...) abort
  if &filetype ==# '' && &buftype ==# 'nofile'
    return
  endif
  let l:type = get(a:, '1', 'active')
  let l:status = ''
  " get statusline of filetype from g:statusline
  if exists('g:statusline["' . &filetype . '"]')
    let l:status = get(g:statusline[&filetype], l:type, v:false)
  else
    let l:status = get(g:statusline['_'], l:type, v:false)
  endif
  if l:status !=# v:false
    execute 'setlocal statusline=' . l:status
  endif
endfunction

if !exists('g:statusline')
  let g:statusline = {}
endif

if !exists('g:statusline["_"]')
  let g:statusline['_'] = {
    \   'active': join([
    \         '%#StlMode#\ %{Statusline_mode()}\ %*',
    \         '%#StlSection#%{Statusline_git()}%*',
    \         '%#StlNormal#%<\ %{Statusline_file()}\ ',
    \         '%=%*',
    \         '%#StlSection#%{Statusline_pad(get(g:,\"coc_status\",\"\"))}%*',
    \         '%#StlError#%{Statusline_diagnostics(\"error\")}%*',
    \         '%#StlWarning#%{Statusline_diagnostics(\"warning\")}%*',
    \      ], ''),
    \   'deactive': '%F'
    \ }
endif

augroup StatuslineAug
  autocmd!
  autocmd VimEnter,WinEnter,BufDelete,BufNew,BufNewFile,FileType,TabNewEntered,CursorHold * call Statusline_update('active')
  autocmd WinLeave * call Statusline_update('deactive')
  autocmd ColorScheme * call <SID>init_highlight()
augroup END

call s:init_highlight()
