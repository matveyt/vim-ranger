" Vim plugin to visualize Ex-range
" Maintainer:   matveyt
" Last Change:  2022 Aug 11
" License:      VIM License
" URL:          https://github.com/matveyt/vim-ranger

if exists('g:loaded_ranger')
    finish
endif
let g:loaded_ranger = 1

cnoremap <expr><plug>ranger; ranger#plug(getcmdtype(), getcmdline())
if !hasmapto('<plug>ranger;', 'c')
    cmap <unique><C-X> <plug>ranger;
endif
