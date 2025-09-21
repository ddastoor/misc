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


def WriteListedBufferPaths()
    # Get a list of dictionaries for all listed buffers.
    # The {'buflisted': 1} argument ensures we only get buffers that
    # are in the buffer list (i.e., not unlisted or temporary).
    var buffers = getbufinfo({'buflisted': 1})
    
    # Initialize an empty list to store the file paths.
    var filePaths: list<string> = []
    
    # Iterate through the list of buffers.
    # A buffer's 'name' property is the file path.
    for buf in buffers
        # Check if the buffer has a valid file path.
        if !empty(buf.name)
            # Use fnamemodify() with the ':p' modifier to get the full path.
            # This handles both absolute and relative paths correctly.
            var fullPath = fnamemodify(buf.name, ':p')
            filePaths->add(fullPath)
        endif
    endfor
    
    # Write the list of file paths to the output file.
    # The 'w' flag ensures the file is created or overwritten.
    # This will write each path on a new line.
    writefile(filePaths, outputFile, 'w')
    
    echo "Wrote " .. len(filePaths) .. " file paths to " .. outputFile
enddef
