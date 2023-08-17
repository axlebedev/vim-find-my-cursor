let s:FindCursorPre = get(g:, 'FindCursorPre', { -> 0 })
let s:FindCursorPost = get(g:, 'FindCursorPost', { -> 0 })
let s:FindCursorDefaultColor = get(g:, 'FindCursorDefaultColor', '#FF00FF')

let s:isActivated = 0
let s:timer_id = 0

function! s:ReturnHighlightTerm(group, term) abort
    " Store output of group to variable
    let output = execute('hi ' . a:group)

    " Find the term we're looking for
    return matchstr(output, a:term.'=\zs\S*')
endfunction

function! s:SaveWindowLocalSettings() abort
    for bufn in tabpagebuflist()
    " this check was previously, but seems useless.
    " TODO: if it remains useless until 01.03.2023 - remove it
    " if (&buftype != 'popup' && !exists("w:savedSettings"))
        let winn = bufwinnr(bufn)
        call setwinvar(winn, 'savedSettings', {
            \ 'cursorline': getwinvar(winn, '&cursorline'),
            \ 'cursorcolumn': getwinvar(winn, '&cursorcolumn'),
        \ })
        call setwinvar(winn, '&cursorline', 0)
        call setwinvar(winn, '&cursorcolumn', 0)
    endfor
endfunction

function! s:SaveSettings() abort
    call s:FindCursorPre()
    let s:isActivated = 1

    call s:SaveWindowLocalSettings()
    if (!exists("s:savedCursorlineBg"))
        let s:savedCursorlineBg = s:ReturnHighlightTerm('CursorLine', 'guibg')
    endif
    if (!exists("s:savedCursorcolumnBg"))
        let s:savedCursorcolumnBg = s:ReturnHighlightTerm('CursorColumn', 'guibg')
    endif
endfunction

function! s:RestoreWindowLocalSettings() abort
    for bufn in tabpagebuflist()
        let winn = bufwinnr(bufn)
        let savedSettings = getwinvar(winn, 'savedSettings')
        call setwinvar(winn, '&cursorline', savedSettings.cursorline)
        call setwinvar(winn, '&cursorcolumn', savedSettings.cursorcolumn)
    endfor
endfunction

function! s:RestoreSettings(...) abort
    let currentMode = mode('.')
    call timer_stop(s:timer_id)
    let s:timer_id = 0
    if (s:isActivated)
        let s:isActivated = 0
        execute 'highlight CursorLine guibg='.s:savedCursorlineBg
        execute 'highlight CursorColumn guibg='.s:savedCursorcolumnBg
        unlet s:savedCursorlineBg
        unlet s:savedCursorcolumnBg
        call s:RestoreWindowLocalSettings()
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
        " BufNew - shoots before 'WinDo not allowed in popup window' error 
        autocmd BufNew,CursorMoved,CursorMovedI,BufLeave,CmdlineEnter,InsertEnter,InsertLeave * call s:RestoreSettings()
    augroup END

    if (autoClearTimeoutMs > 0)
        let s:timer_id = timer_start(autoClearTimeoutMs, {id -> s:RestoreSettings()})
    endif
endfunction
