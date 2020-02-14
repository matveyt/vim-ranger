" Vim plugin to visualize Ex-range
" Maintainer:   matveyt
" Last Change:  2020 Feb 12
" License:      VIM License
" URL:          https://github.com/matveyt/vim-ranger

if exists('g:loaded_ranger')
    finish
endif
let g:loaded_ranger = 1

cnoremap <expr><plug>Ranger ranger#plug(getcmdtype(), getcmdline())
if !exists('g:no_plugin_maps') && !exists('g:no_ranger_maps')
    cmap <unique><C-X> <plug>Ranger
endif
