" Vim plugin to visualize Ex-range
" Maintainer:   matveyt
" Last Change:  2019 Dec 24
" License:      VIM License
" URL:          https://github.com/matveyt/vim-ranger

if exists('g:loaded_ranger') || &cp
    finish
endif
let g:loaded_ranger = 1

cnoremap <expr><plug>Ranger ranger#plug(getcmdtype(), getcmdline())
if !hasmapto('<plug>Ranger', 'c')
    cmap <unique><C-X> <plug>Ranger
endif
