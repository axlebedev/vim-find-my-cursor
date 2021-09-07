let s:FindCursorPre = get(g:, 'FindCursorPre', { -> 0 })
let s:FindCursorPost = get(g:, 'FindCursorPost', { -> 0 })

let s:cursorline = 0
let s:cursorcolumn = 0
let s:cursorlineBg = ''
let s:cursorcolumnBg = ''
let s:isActivated = 0
let s:timer_id = 0

" Like windo but restore the current window.
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
    let s:cursorline = &cursorline
    let s:cursorcolumn = &cursorcolumn
    let s:cursorlineBg = s:ReturnHighlightTerm('CursorLine', 'guibg')
    let s:cursorcolumnBg = s:ReturnHighlightTerm('CursorColumn', 'guibg')

    Windo let &cursorline = 0
    Windo let &cursorcolumn = 0
endfunction

function! s:RestoreSettings(...) abort
    call timer_stop(s:timer_id)
    let s:timer_id = 0
    if (s:isActivated)
        let s:isActivated = 0
        Windo let &cursorline = s:cursorline
        Windo let &cursorcolumn = s:cursorcolumn
        execute 'highlight CursorLine guibg='.s:cursorlineBg
        execute 'highlight CursorColumn guibg='.s:cursorcolumnBg
        augroup findcursor
            autocmd!
        augroup END
        call s:FindCursorPost()
    endif
endfunction

function! findcursor#FindCursor(color, autoClear) abort
    if (s:timer_id == 0)
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

    if (a:autoClear)
        let s:timer_id = timer_start(500, {id -> s:RestoreSettings()})
    endif
endfunction
