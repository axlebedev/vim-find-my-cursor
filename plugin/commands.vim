call writefile(['======================'], glob('/home/alex/.vim/bundle/where-is-cursor/log.txt'), 'a')
call writefile(['START NEW SESSION'], glob('/home/alex/.vim/bundle/where-is-cursor/log.txt'), 'a')
command! -bar -nargs=+ FindCursor call findcursor#FindCursor(<f-args>)
