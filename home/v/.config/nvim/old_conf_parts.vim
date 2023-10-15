"    <Netrw>
"let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 0
let g:netrw_winsize = 20

function! OpenToRight()
  :normal v
  let g:path=expand('%:p')
  :q!
  execute 'belowright vnew' g:path
  :normal <C-l>
endfunction

function! OpenBelow()
  :normal v
  let g:path=expand('%:p')
  :q!
  execute 'belowright new' g:path
  :normal <C-l>
endfunction

function! NetrwMappings()
  " Hack fix to make ctrl-l work properly
  noremap <buffer> <C-l> <C-w>l
  noremap <silent> <C-f> :call ToggleNetrw()<CR>
  noremap <buffer> V :call OpenToRight()<cr>
  noremap <buffer> H :call OpenBelow()<cr>
endfunction

augroup netrw_mappings
  autocmd!
  autocmd filetype netrw call NetrwMappings()
augroup END

function! ToggleNetrw()
  if g:NetrwIsOpen
    let i = bufnr("S")
    while (i >= 1)
      if (getbufvar(i, "&filetype") ==# "netrw")
        silent exe "bwipeout " . i
        endif
        let i-=1
    endwhile
     let g:NetrwIsOpen=0
  else
    let g:NetrwIsOpen=1
    silent Lexplore
  endif
endfunction

"Close Netrw if it's the only buffer open
autocmd WinEnter * if winnr('$') == 1 && getbufvar(winbufnr(winnr()), "&filetype") == "netrw" || &buftype == 'quickfix' |q|endif

"Make netrw act like a project Draw
augroup ProjectDrawer
  autocmd!
  autocmd WinEnter * :call ToggleNetrw()
augroup END

let g:NetrwIsOpen=0
"    <\Netrw>

