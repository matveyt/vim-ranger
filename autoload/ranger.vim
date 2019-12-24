" Vim plugin to visualize Ex-range
" Maintainer:   matveyt
" Last Change:  2019 Dec 24
" License:      VIM License
" URL:          https://github.com/matveyt/vim-ranger

let s:save_cpo = &cpo
set cpo&vim

function s:default_range(cmd)
    for l:pat in ['\=', 'dj%[ump]', 'dli%[st]', 'ds%[earch]', 'dsp%[lit]', 'exi%[t]',
        \ 'foldd%[oopen]', 'folddoc%[losed]', 'g%[lobal]', 'ha%[rdcopy]', 'ij%[ump]',
        \ 'il%[ist]', 'is%[earch]', 'isp%[lit]', 'luado', 'mz%[scheme]', 'pe%[rl]',
        \ 'perld%[o]', 'ps%[earch]', 'pydo', 'py3do', 'pyxdo', 'ret%[ab]', 'rubyd%[o]',
        \ 'sor%[t]', 'tcld%[o]', 'up%[date]', 'v%[global]', 'w%[rite]', 'wq', 'x%[it]']
        if a:cmd =~# '\v^' . l:pat . '%(\A|$)'
            return '%'
        endif
    endfor
    return ''
endfunction

function s:remove_hilite(var, ...) abort
    if exists('#' . a:var)
        execute 'autocmd!' a:var
        execute 'augroup!' a:var
    endif
    if exists('w:' . a:var) && type(w:{a:var}) == v:t_dict
        silent! call matchdelete(w:{a:var}.id)
        let l:isPrev = w:{a:var}.start == get(a:, 1) && w:{a:var}.end == get(a:, 2)
        unlet w:{a:var}
        return l:isPrev
    endif
endfunction

function s:add_hilite(var) range
    if !s:remove_hilite(a:var, a:firstline, a:lastline)
        let w:{a:var} = {'start': a:firstline, 'end': a:lastline,
            \ 'id': matchadd('Visual', printf('\%%>%dl\%%<%dl', a:firstline - 1,
                \ a:lastline + 1))}
        execute 'augroup' a:var
            execute 'autocmd! CmdlineLeave : call s:remove_hilite("' . a:var . '")'
        augroup end
    endif
    redraw
endfunction

function! ranger#plug(type, line)
    " do nothing if not on Ex-line
    if a:type !=# ':'
        return ''
    endif
    try
        " modelled after vim/src/ex_docmd.c:skip_range() w/o 'modifiers' support
        " [:[:blank:]]*
        " %([-+[:blank:][:digit:].$%,;]|\\[?/&]|'.|([/?])%(%(\\|\1@!).)*%(\1|$))*
        " [:[:blank:]]*%(\*\s*)?
        let l:colon = ':[:blank:]'
        let l:atom = '[-+[:blank:][:digit:].$%,;]'
        let l:srch = '([/?])%(%(\\|\1@!).)*%(\1|$)'
        let l:pos = matchend(a:line, printf('\v[%s]*%%(%s)*[%s]*%s',
            \ l:colon, l:atom . '|\\[?/&]|''.|' . l:srch, l:colon,
            \ (stridx(&cpo, '*') < 0) ? '%(\*\s*)?' : ''))
        let l:range = (l:pos <= 0) ? s:default_range(a:line) :
            \ (a:line[:l:pos - 1] =~# '[^' . l:colon . ']') ? a:line[:l:pos - 1] :
            \ s:default_range(a:line[l:pos:])
        execute l:range 'call s:add_hilite("ranger_match")'
    catch /^Vim(call):E/
        " catch E16 E493 etc.
        let v:errmsg = matchstr(v:exception, '\C^Vim(call):\zsE\d\+:[^:]*')
        redraw
        echohl ErrorMsg | echon v:errmsg | echohl None
        sleep
    endtry
    " make Vim redraw cmdline too
    return "\<Space>\<BS>"
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
