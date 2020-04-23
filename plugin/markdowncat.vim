" ===========================================================
" Markdownファイルをcat(結合)してファイルに出力する
" File:     markdowncat.vim
" Author:   k28 <k28@me.com>
" Version:  0.1
" Lisence:  MIT license

if exists('g:loaded_markdown_cat')
  finish
endif
let g:loaded_markdown_cat = 1

let s:save_cpo = &cpo
set cpo&vim

if !exists('g:markdowncat_execute_file_extension')
  let g:markdowncat_execute_file_extension = "mdcat"
endif

command! -nargs=0 MarkdownCat :call markdowncat#cat()

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set ft=vim ts=2 sw=2 sts=2:
