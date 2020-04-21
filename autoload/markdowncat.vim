" ===========================================================
" Cat markdown to file.
" File:     tasklog.vim
" Author:   k28 <k28@me.com>
" Version:  1.0
" Lisence:  VIM LICENSE

" TODO 再読み込み防止プラグインが完成したら元に戻す
" if &cp || exists("g:autoloaded_markdowncat")
"   finish
" endif
" let g:autoloaded_markdowncat = '1'

let s:cpo_save = &cpo
set cpo&vim

function! s:make_output_file_path()
  let current_file_path = expand('%:h')
  let current_file_name = expand('%:t')
  let save_dir = current_file_path . "/out"
  if !isdirectory(save_dir)
    call mkdir(save_dir)
  endif
  return save_dir . "/" . current_file_name
endfunction

" lineからincludeするファイルのパスを取得する
function! s:get_include_file_path(line)
  let read_file_path = matchlist(a:line, '\v\$include\="([^"]+)"')[1]
  return read_file_path
endfunction

" file_pathのファイルを読み込んでバッファに書き込みする
function! s:make_markdowncat(file_path)
  for line in readfile(a:file_path)
    if line =~ "$include"
      " 読み込むファイル名を取得
      let read_file_path = s:get_include_file_path(line)
      call s:make_markdowncat(read_file_path)
    else
      call append(line('$'), line)
    endif
  endfor
endfunction

function! markdowncat#cat()
  " Make out put file
  let out_file_path = s:make_output_file_path()
  "echo out_file_path

  let current_file_path = expand('%:p')
  "echo current_file_path

  " Open new buffer
  let bufexists_flag = 0
  let buffer_name = "markdowncat"
  if (bufexists(buffer_name) > 0)
    let bufexists_flag = 1
  endif

  if (bufexists_flag)
    split
    execute "b " . g:markdowncat_output_buffer_nr
  else
    vnew `=buffer_name`
    let g:markdowncat_output_buffer_nr = bufnr("%")
    setlocal noswapfile
  endif

  execute "%delete"
  setlocal write
  call s:make_markdowncat(current_file_path)

  " save buffert to file
  execute "write! " . out_file_path
  quit!

endfunction


let &cpo = s:cpo_save

" vim:set ft=vim ts=2 sw=2 sts=2:
