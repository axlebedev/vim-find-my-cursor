let s:FindCursorPre = get(g:, 'FindCursorPre', { -> 0 })
let s:FindCursorPost = get(g:, 'FindCursorPost', { -> 0 })
let s:FindCursorDefaultColor = get(g:, 'FindCursorDefaultColor', '#FF00FF')

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

function! s:SaveWindowLocalSettings() abort
    if (!exists("w:savedSettings"))
        let w:savedSettings = { 'cursorline': &cursorline, 'cursorcolumn': &cursorcolumn }
    endif
endfunction

function! s:SaveSettings() abort
    call s:FindCursorPre()
    let s:isActivated = 1

    Windo call s:SaveWindowLocalSettings()
    if (!exists("s:savedCursorlineBg"))
        let s:savedCursorlineBg = s:ReturnHighlightTerm('CursorLine', 'guibg')
    endif
    if (!exists("s:savedCursorcolumnBg"))
        let s:savedCursorcolumnBg = s:ReturnHighlightTerm('CursorColumn', 'guibg')
    endif

    Windo let &cursorline = 0
    Windo let &cursorcolumn = 0
endfunction

function! s:RestoreWindowLocalSettings() abort
    if (exists('w:savedSettings'))
        call setwinvar(winnr(), '&cursorline', w:savedSettings.cursorline)
        call setwinvar(winnr(), '&cursorcolumn', w:savedSettings.cursorcolumn)
        unlet w:savedSettings
    endif
endfunction

function! s:RestoreSettings(...) abort
    call timer_stop(s:timer_id)
    let s:timer_id = 0
    if (s:isActivated)
        let s:isActivated = 0
        execute 'highlight CursorLine guibg='.s:savedCursorlineBg
        execute 'highlight CursorColumn guibg='.s:savedCursorcolumnBg
        unlet s:savedCursorlineBg
        unlet s:savedCursorcolumnBg
        Windo call s:RestoreWindowLocalSettings()
        augroup findcursor
            autocmd!
        augroup END
        call s:FindCursorPost()
    endif

    augroup findcursor
        autocmd!
    augroup END
endfunction

function! findcursor#FindCursor(...) abort
    let color = get(a:, 1, s:FindCursorDefaultColor)
    let autoClearTimeoutMs = get(a:, 2, 0)
    if (!s:isActivated)
        call s:SaveSettings()
        setlocal cursorline
        setlocal cursorcolumn
    endif

    if (color[0] == '#')
        execute 'highlight CursorLine guibg='.color
        execute 'highlight CursorColumn guibg='.color
    endif

    augroup findcursor
        autocmd!
        autocmd CursorMoved,CursorMovedI,BufLeave,CmdlineEnter * call s:RestoreSettings()
    augroup END

    if (autoClearTimeoutMs > 0)
        let s:timer_id = timer_start(autoClearTimeoutMs, {id -> s:RestoreSettings()})
    endif
endfunction
