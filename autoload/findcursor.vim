let s:FindCursorPre = get(g:, 'FindCursorPre', { -> 0 })
let s:FindCursorPost = get(g:, 'FindCursorPost', { -> 0 })

let s:savedSettingsByWinnr = {}
let s:savedCursorlineBg = ''
let s:savedCursorcolumnBg = ''
let s:isActivated = 0
let s:timer_id = 0

" Like windo but restore focus to current window after work.
function! WinDo(command)
    let currwin=winnr()
    execute 'windo ' . a:command
    execute currwin . 'wincmd w'
endfunction
com! -nargs=+ -complete=command Windo call WinDo(<q-args>)

function! s:ReturnHighlightTerm(group, term) abort
    " Store output of group to variable
    let output = execute('hi ' . a:group)

    " Find the term we're looking for
    return matchstr(output, a:term.'=\zs\S*')
endfunction

function! s:SaveSettings() abort
    call s:FindCursorPre()
    let s:isActivated = 1

    Windo let s:savedSettingsByWinnr[winnr()] = { 'cursorline': &cursorline, 'cursorcolumn': &cursorcolumn }
    let s:savedCursorlineBg = s:ReturnHighlightTerm('CursorLine', 'guibg')
    let s:savedCursorcolumnBg = s:ReturnHighlightTerm('CursorColumn', 'guibg')

    Windo let &cursorline = 0
    Windo let &cursorcolumn = 0
endfunction

function! s:RestoreSettings(...) abort
    call timer_stop(s:timer_id)
    let s:timer_id = 0
    if (s:isActivated)
        let s:isActivated = 0
        Windo let &cursorline = s:savedSettingsByWinnr[winnr()].cursorline
        Windo let &cursorcolumn = s:savedSettingsByWinnr[winnr()].cursorcolumn
        execute 'highlight CursorLine guibg='.s:savedCursorlineBg
        execute 'highlight CursorColumn guibg='.s:savedCursorcolumnBg
        augroup findcursor
            autocmd!
        augroup END
        call s:FindCursorPost()
    endif
endfunction

function! findcursor#FindCursor(color, autoClearTimeoutMs) abort
    if (!s:isActivated)
        call s:SaveSettings()
    endif

    setlocal cursorline
    setlocal cursorcolumn
    if (a:color[0] == '#')
        execute 'highlight CursorLine guibg='.a:color
        execute 'highlight CursorColumn guibg='.a:color
    endif

    augroup findcursor
        autocmd!
        autocmd CursorMoved,CursorMovedI * call s:RestoreSettings()
    augroup END

    if (a:autoClearTimeoutMs > 0)
        let s:timer_id = timer_start(a:autoClearTimeoutMs, {id -> s:RestoreSettings()})
    endif
endfunction
