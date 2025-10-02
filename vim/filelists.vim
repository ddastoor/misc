vim9script
var root_dir = 'c:/users/abc/documents'
var filelist_map: dict<list<string>> = {}


def GetFilelistPath(filelist_name: string): string
    return root_dir .. '/' .. filelist_name .. '.fl'
enddef

# Helper function to ensure uniqueness in a list
def UniqueList(items: list<string>): list<string>
    var seen: dict<bool> = {}
    var result: list<string> = []
    for item in items
        if !has_key(seen, item)
            seen[item] = true
            add(result, item)
        endif
    endfor
    return result
enddef

# Create a new filelist
export def Flcreate(filelist_name: string)

    if has_key(filelist_map, filelist_name)
      return
    endif

    var filepath = GetFilelistPath(filelist_name)
    
    if filereadable(filepath)
        echomsg 'Filelist "' .. filelist_name .. '" already exists'
        return
    endif
    
    writefile([], filepath)
    filelist_map[filelist_name] = []
    echomsg 'Created filelist: ' .. filelist_name
enddef

export def Fldestroy(filelist_name: string)
    var filepath = GetFilelistPath(filelist_name)
    
    if has_key(filelist_map, filelist_name)
        for file in filelist_map[filelist_name]
            if bufexists(file)
                execute 'bdelete ' .. fnameescape(file)
            endif
        endfor
        
        remove(filelist_map, filelist_name)
    endif
    
    if filereadable(filepath)
        delete(filepath)
    endif
    
    echomsg 'Destroyed filelist: ' .. filelist_name
enddef

export def FLAddCurrentFile2filelist(filelist_name: string)
    var current_file = expand('%:p')
    
    if empty(current_file)
        return
    endif
    
    if !has_key(filelist_map, filelist_name)
        filelist_map[filelist_name] = []
    endif
    
    if index(filelist_map[filelist_name], current_file) == -1
        add(filelist_map[filelist_name], current_file)
    endif
enddef

# Delete current file from filelist and buffer
export def FLDelCurrentFile2filelist(filelist_name: string)
    var current_file = expand('%:p')
    
    if empty(current_file)
        echoerr 'No file in current buffer'
        return
    endif
    
    if !has_key(filelist_map, filelist_name)
        echoerr 'Filelist not found: ' .. filelist_name
        return
    endif
    
    var idx = index(filelist_map[filelist_name], current_file)
    if idx != -1
        remove(filelist_map[filelist_name], idx)
        echomsg 'Removed "' .. current_file .. '" from filelist: ' .. filelist_name
    endif
    
    if bufexists(current_file)
        execute 'bdelete ' .. fnameescape(current_file)
    endif
enddef

# Load all files from a filelist into buffers
export def FLLoadFilelist(filelist_name: string)
    if !has_key(filelist_map, filelist_name)
        echoerr 'Filelist not found: ' .. filelist_name
        return
    endif
    
    for file in filelist_map[filelist_name]
        if filereadable(file)
            execute 'badd ' .. fnameescape(file)
        else
            echomsg 'Warning: File not found: ' .. file
        endif
    endfor
enddef

# Unload all files from a filelist (delete buffers)
export def FLUnLoadFilelist(filelist_name: string)
    if !has_key(filelist_map, filelist_name)
        echoerr 'Filelist not found: ' .. filelist_name
        return
    endif
    
    for file in filelist_map[filelist_name]
        if bufexists(file)
            execute 'bdelete ' .. fnameescape(file)
        endif
    endfor
    
    echomsg 'Unloaded files from: ' .. filelist_name
enddef

# Load filelist from disk into memory and add buffers
export def FlLoadFileListFromDisk(filelist_name: string)
    var filepath = GetFilelistPath(filelist_name)
    
    if !filereadable(filepath)
        echoerr 'Filelist file not found: ' .. filepath
        return
    endif
    
    # Read file entries
    var lines = readfile(filepath)
    var files = filter(lines, 'v:val !~ "^\\s*$"')  # Remove empty lines
    
    # Ensure uniqueness and update map
    filelist_map[filelist_name] = UniqueList(files)
    
    # Add all files as buffers
    for file in filelist_map[filelist_name]
        if filereadable(file)
            execute 'badd ' .. fnameescape(file)
        else
            echomsg 'Warning: File not found: ' .. file
        endif
    endfor
    
    echomsg 'Loaded ' .. len(filelist_map[filelist_name]) .. ' files from disk: ' .. filelist_name
enddef

# Save filelist from memory to disk
export def FlSaveFileListToDisk(filelist_name: string)
    if !has_key(filelist_map, filelist_name)
        echoerr 'Filelist not found in memory: ' .. filelist_name
        return
    endif
    
    var filepath = GetFilelistPath(filelist_name)
    
    # Ensure uniqueness before saving
    var unique_files = UniqueList(filelist_map[filelist_name])
    filelist_map[filelist_name] = unique_files
    
    # Write to disk
    writefile(unique_files, filepath)
    
    echomsg 'Saved ' .. len(unique_files) .. ' files to disk: ' .. filelist_name
enddef

 
