" ===========================================================
" Cat markdown to file.
" File:     tasklog.vim
" Author:   k28 <k28@me.com>
" Version:  1.1
" Lisence:  MIT license

if &cp || exists("g:autoloaded_markdowncat")
  finish
endif
let g:autoloaded_markdowncat = '1'

let s:cpo_save = &cpo
set cpo&vim

" 出力ファイルのパスを作成する
function! s:make_output_file_path()
  let current_file_path = expand('%:h')
  let current_file_name = expand('%:t')
  let pattern = g:markdowncat_execute_file_extension . "\$"
  let output_file_name = substitute(current_file_name, pattern, 'md', "")
  let save_dir = current_file_path
  if !isdirectory(save_dir)
    call mkdir(save_dir)
  endif
  return save_dir . "/" . output_file_name
endfunction

" $includeの書式
let s:markdowncat_include_reg_format = '\v\$include\="([^"]+)"'

" file_pathのファイルを読み込んで出力する
function! s:read_file_and_write(file_path)

  " ファイル名をコメントで出力する
  let file_name = fnamemodify(a:file_path, ":t")
  call append(line('$'), '<!-- ' . file_name . ' -->')

  for line in readfile(a:file_path)
      call append(line('$'), line)
  endfor
endfunction

" lineからincludeするファイルのパスを取得する
function! s:get_include_file_path(line)
  let read_file_path = matchlist(a:line, s:markdowncat_include_reg_format)[1]
  return read_file_path
endfunction

let s:markdowncat_is_comment_block = 0
" コメント行かチェックする
function! s:is_comment(line)
  if a:line =~ "^ \*\/\/"
    return 1
  end

  if a:line =~ "^ \*\<!--"
    let s:markdowncat_is_comment_block = 1
    return 1
  end

  if a:line =~ "--\> \*$"
    let s:markdowncat_is_comment_block = 0
    " この行はコメントとして処理する
    return 1
  end

  return s:markdowncat_is_comment_block
endfunction

" file_pathのファイルを読み込んでバッファに書き込みする
function! s:make_markdowncat(file_path)
  for line in readfile(a:file_path)

    if s:is_comment(line)
      continue
    endif

    if line =~ "^$include"
      " 読み込むファイル名を取得
      let read_file_path = s:get_include_file_path(line)
      call s:read_file_and_write(read_file_path)

      " 続けて何かある時には, 後ろの空白を削除, 改行を入れて追加する
      call append(line('$'), "")
      let delete_include_token = s:markdowncat_include_reg_format . ' *'
      let remain_lin =  substitute(line, delete_include_token, '', '')
      call append(line('$'), remain_lin)
    else
      call append(line('$'), line)
    endif
  endfor
endfunction

function! s:markdowncat_find_window_by_buffer_number(buffer_number)
  return filter(range(1, winnr("$")), 'winbufnr(v:val)==' . a:buffer_number)
endfunction

function! s:markdowncat_singleton_buffer(buffer_number, split)
  let winlist = s:markdowncat_find_window_by_buffer_number(a:buffer_number)
  if empty(winlist)
    if a:split
      split
    endif
    exe "b " . a:buffer_number
  else
    exe winlist[0] . "wincmd w"
  endif
endfunction

function! markdowncat#cat()
  let file_extention = expand('%:e')
  echo file_extention
  echo g:markdowncat_execute_file_extension
  if expand('%:e') != g:markdowncat_execute_file_extension
    echo "This file extenstion(" . file_extention . ") is not support markdowncat. Please see g:markdowncat_execute_file_extension."
    return
  end

  " Make out put file
  let out_file_path = s:make_output_file_path()
  " echo out_file_path

  let current_file_path = expand('%:p')
  " echo current_file_path

  " Open new buffer
  let bufexists_flag = 0
  let buffer_name = out_file_path
  if (bufexists(buffer_name) > 0)
    let bufexists_flag = 1
  endif

  if (bufexists_flag)
    call s:markdowncat_singleton_buffer(g:markdowncat_output_buffer_nr, 1)
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
  "quit!

endfunction


let &cpo = s:cpo_save

" vim:set ft=vim ts=2 sw=2 sts=2:
