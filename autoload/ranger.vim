" Vim plugin to visualize :range
" Maintainer:   matveyt
" Last Change:  2021 Feb 05
" License:      VIM License
" URL:          https://github.com/matveyt/vim-ranger

let s:save_cpo = &cpo
set cpo&vim

function s:default_range(cmd) abort
    for l:pattern in ['\=', 'dj%[ump]', 'dli%[st]', 'ds%[earch]', 'dsp%[lit]', 'exi%[t]',
        \ 'foldd%[oopen]', 'folddoc%[losed]', 'g%[lobal]', 'ha%[rdcopy]', 'ij%[ump]',
        \ 'il%[ist]', 'is%[earch]', 'isp%[lit]', 'luado', 'mz%[scheme]', 'pe%[rl]',
        \ 'perld%[o]', 'ps%[earch]', 'pydo', 'py3do', 'pyxdo', 'ret%[ab]', 'rubyd%[o]',
        \ 'sor%[t]', 'tcld%[o]', 'up%[date]', 'v%[global]', 'w%[rite]', 'wq', 'x%[it]']
        if a:cmd =~# '\v^'..l:pattern..'%(\A|$)'
            return '%'
        endif
    endfor
    return ''
endfunction

function s:remove_hilite(var, ...) abort
    if exists('#'..a:var)
        execute 'autocmd!' a:var
        execute 'augroup!' a:var
    endif
    let l:match = get(w:, a:var)
    if type(l:match) == v:t_dict
        silent! call matchdelete(l:match.id)
        call remove(w:, a:var)
        return l:match.start == get(a:, 1) && l:match.end == get(a:, 2)
    endif
endfunction

function s:add_hilite(var) range abort
    if !s:remove_hilite(a:var, a:firstline, a:lastline)
        let w:[a:var] = {'start': a:firstline, 'end': a:lastline,
            \ 'id': matchadd('Visual', printf('\%%>%dl\%%<%dl', a:firstline - 1,
                \ a:lastline + 1), 0)}
        execute 'augroup' a:var
            execute printf('autocmd! CmdlineLeave : call s:remove_hilite(%s)',
                \ string(a:var))
        augroup end
    endif
    redraw
endfunction

function! ranger#plug(type, line) abort
    " do nothing if not on Ex-line
    if a:type isnot# ':'
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
