# Vim plugin: Find my cursor
Highlight cursor position.

This plugin introduces a functiona and similar command to highlight cursor position
``` Vim Script
:FindCursor <hexColor> <timeoutMs>
:call findcursor#FindCursor(<hexColor>, <timeoutMs>)  
```
Highlight will be cleared after timeout, or "CursorMoved" event

### API
Arguments:  
`<hexColor>` - color in [hex format](https://www.w3schools.com/colors/colors_hexadecimal.asp) *[required]*   
`<timeoutMs>` - after this timeout highlight will be hidden. If `0` - it will be waiting for "CursorMoved" forever. *[optional, default = 0]*  

### USAGE
Several examples

0. Run "FindCursor" from command line
``` Vim Script
:FindCursor #CC0000 500
```

1. Bind "FindCursor" to key
``` Vim Script
nnoremap <leader>f <CMD>FindCursor #CC0000 500<CR>
```

2. Run "FindCursor" with other action
``` Vim Script
" highlight cursor on "%"-motion jump
noremap % %<CMD>FindCursor 0 500<CR>
```

3. Run "FindCursor" with other action (complex example)
``` Vim Script
" Using with 'neoclide/coc.nvim':
" 'jumpDefinition' runs asynchronously, so run 'FindCursor' after 100ms timeout
function! JumpDefinitionFindCursor() abort
    call CocAction("jumpDefinition")
    call timer_start(100, {id -> findcursor#FindCursor('#D6D8FA', 0)})
endfunction
nnoremap <silent> jd <CMD>call JumpDefinitionFindCursor()<CR>
```

3. Run "FindCursor" with other action (complex example 2)
``` Vim Script
" FindCursor on jump around search matches.
" Using with 'junegunn/vim-slash' and 'henrik/vim-indexed-search'
noremap <silent> <plug>(slash-after) <CMD>execute("FindCursor #d6d8fa 0<bar>ShowSearchIndex")<CR>
```


### DEMO

TODO: gif

---

### CONFIGURATION
##### `g:FindCursorPre`
A function to run before "FindCursor". Use for disable some other highlights if there are conflicts.
``` Vim Script
function! FindCursorHookPre() abort
    FootprintsDisable " 'axlebedev/footprints' plugin
    IlluminationDisable " 'RRethy/vim-illuminate' plugin
endfunction
let g:FindCursorPre = function('FindCursorHookPre')
```

##### `g:FindCursorPost`
Opposite to `g:FindCursorPre`: a function to run after "FindCursor" is cleared.
``` Vim Script
function! FindCursorHookPost() abort
    FootprintsEnable " 'axlebedev/footprints' plugin
    IlluminationEnablee " 'RRethy/vim-illuminate' plugin
endfunction
let g:FindCursorPost = function('FindCursorHookPost')
```

---

### CONTRIBUTIONS
If you find a bug, or have an improvement suggestion -
please place an issue in this repository.
