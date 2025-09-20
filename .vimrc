syntax on
set backspace=indent,eol,start
nnoremap <del> dd
nnoremap <C-s> :w<cr>

set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab

nnoremap <C-Down> 10j
nnoremap <C-Up> 10k


inoremap <C-s> <esc>:w<cr>
set number
set relativenumber
colorscheme evening
set guifont=Consolas:h11
set lines=40 columns=130

def PSListToQuickfix()
    var pat = input('Input the file filter: ')
    var pscmd = printf('Get-ChildItem -Path . -Recurse -Filter "*%s*" | Select-Object -ExpandProperty FullName', pat)
    var cmd = printf("powershell -C \"%s\"", pscmd)
    var lines = systemlist(cmd)
    var qflist = []
    var line2 = ""
    for line in lines
      line2 = line->substitute("
$", "", "")
      #qflist->add({'filename': line2, 'lnum': 1})
      qflist->add({'filename': line2})
    endfor
   setqflist(qflist, 'r')
    copen
enddef

" This command sets the background to a red color and the foreground to white for the active tab.
" The gui=bold makes the text bold.
highlight TabLineSel guifg=#FFFFFF guibg=#FF0000 gui=bold

" This command sets the background for inactive tabs to a dark gray and the foreground to a lighter gray.
highlight TabLine guifg=#808080 guibg=#303030

" This command sets the background for the empty space to the same as the inactive tabs.
highlight TabLineFill guifg=#808080 guibg=#303030


