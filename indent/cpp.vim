" Vim indent file
" Language:	C++
" Maintainer:	Eric Müller <mueller@kip.uni-heidelberg.de>
" Last Change:	2012 May 08
" License: MIT
" Version: 1.1.1
"
" Changes {{{
" 1.1.1 2012-05-08
"   Fixing template indentation.
"   Based on Konstantin Lepa's google.vim
"   (http://www.vim.org/scripts/script.php?script_id=2636).
"
" 1.1.0 2011-01-17
"   Refactored source code.
"   Some fixes.
"
" 1.0.1 2010-05-20
"   Added some changes. Thanks to Eric Rannaud <eric.rannaud@gmail.com>
"
"}}}

if exists("b:did_indent")
    finish
endif
let b:did_indent = 1


function! GoogleCppIndent()
    let l:cline_num = line('.')

    let l:orig_indent = cindent(l:cline_num)

    "if l:orig_indent == 0 | return 0 | endif

    let l:pline_num = prevnonblank(l:cline_num - 1)
    let l:pline = getline(l:pline_num)
    "if l:pline =~# '^\s*template' | return l:pline_indent | endif

    " TODO: I don't know to correct it:
    " namespace test {
    " void
    " ....<-- invalid cindent pos
    "
    " void test() {
    " }
    "
    " void
    " <-- cindent pos
    "if l:orig_indent != &shiftwidth | return l:orig_indent | endif

    let l:pline_indent = indent(l:pline_num)
    let l:cline = getline(l:cline_num)
    let l:cline_indent = cindent(l:cline_num)

    if l:cline =~# '^\s*>'
        let l:match_template = searchpair('\<template\s*<', '', '>', 'bWn')
        return indent(l:match_template)
    endif

    let l:cnt_closing = 0
    let l:in_comment = 0
    let l:pline_num = prevnonblank(l:cline_num - 1)
    while l:pline_num > -1
        let l:pline = getline(l:pline_num)
        let l:pline_indent = indent(l:pline_num)

        " in comments...?
        if l:in_comment == 0 && l:pline =~ '^.\{-}\(/\*.\{-}\)\@<!\*/'
            let l:in_comment = 1
        elseif l:in_comment == 1
            if l:pline =~ '/\*\(.\{-}\*/\)\@!'
                let l:in_comment = 0
            endif

        " template starts in previous line?
        elseif l:pline =~# '^\s*template[^>]*$'
            if l:cnt_closing > 0
                return l:pline_indent + &shiftwidth - (l:cnt_closing * &shiftwidth)
            endif
            return l:pline_indent + &shiftwidth
        elseif l:pline =~# '>'
            let l:cnt_closing += len(substitute(l:pline, '[^>]', '', 'g'))

        " other fixes... (google.vim)
        elseif l:pline_indent == 0
            if l:pline !~# '\(#define\)\|\(^\s*//\)\|\(^\s*{\)'
                if l:pline =~# '^\s*namespace.*'
                    return 0
                else
                    return l:orig_indent
                endif
            elseif l:pline =~# '\\$'
                return l:orig_indent
            endif
        else
            return l:orig_indent
        endif

        let l:pline_num = prevnonblank(l:pline_num - 1)
    endwhile

    return l:orig_indent
endfunction

setlocal shiftwidth=4
setlocal tabstop=4
setlocal softtabstop=4
setlocal noexpandtab
setlocal textwidth=80
setlocal wrap

setlocal cindent
setlocal cinoptions=(0,u0,U0,g0,l1,t0,w1,Ws

setlocal indentexpr=GoogleCppIndent()

let b:undo_indent = "setl sw< ts< sts< et< tw< wrap< cin< cino< inde<"

