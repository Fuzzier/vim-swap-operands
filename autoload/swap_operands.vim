function! swap_operands#text(mode) range

   let last_search = histget('search', -1)

   if a:mode =~ 'v'

      let save_cursor = getpos("'>")

      " visual interactive :)
      if 'vi' == a:mode

         let operators = input('Pivot: ')
      else
         let comparison_ops = ['===', '!==',  '<>', '==#', '!=#',  '>#',
                              \'>=#',  '<#', '<=#', '=~#', '!~#', '==?',
                              \'!=?',  '>?', '>=?',  '<?', '<=?', '=~?',
                              \'!~?',  '==',  '!=',  '>=',  '<=',  '=~',
                              \ '~=',  '!~']
         let logical_ops    = [ '&&',  '||']
         let assignment_ops = [ '+=',  '-=',  '*=',  '/=',  '%=',  '&=',
                              \ '|=',  '^=', '<<=', '>>=']
         let scope_ops      = [ '::']
         let pointer_ops    = ['->*',  '->',  '.*']
         let bitwise_ops    = [ '<<',  '>>']
         let misc_ops       = [  '>',   '<',   '=',   '+',   '-',   '*',
                              \  '/',   '%',   '&',   '|',   '^',   '.',
                              \  '?',   ':',   ',',  "'=",  "'<",  "'>",
                              \ '!<',  '!>']

         let operators_list = comparison_ops

         " If a count is used, swap on comparison operators only
         if v:count < 1

            let operators_list += assignment_ops +
                                \ logical_ops    +
                                \ scope_ops      +
                                \ pointer_ops    +
                                \ bitwise_ops

            if exists('g:swap_custom_ops')

               " let g:swap_custom_ops = ['ope1', 'ope2', ...]
               let operators_list += g:swap_custom_ops
            endif

            let operators_list += misc_ops
         endif

         let operators = join(operators_list, '\|')
         let operators = escape(operators, '*/~.^$')
      endif

      " Obtain selected string
      let l:start = getpos("'<")
      let l:end   = getpos("'>")
      let l:lines = getline(l:start[1], l:end[1])

      if len(l:lines) == 1
          let l:lines[0] = l:lines[0][l:start[2] - 1 : l:end[2] - 1]
      else
          let l:lines[0]  = l:lines[0][l:start[2] - 1 :]
          let l:lines[-1] = l:lines[-1][: l:end[2] - 1]
      endif
      let l:selection = join(l:lines, '')

      " Search for the first operator
      let operator = matchstr(l:selection, '\(' . operators . '\)')
      if empty(operator)
          return
      endif

      " Change direction for oprators
      let reverse_op = v:false
      let operator_after = operator
      if operator !~ '<>\|<=>\|<<\|>>\|->'
          if operator =~ '<'
              let reverse_op = v:true
              let operator_after = substitute(operator, '<', '>', 'g')
          elseif operator =~ '>'
              let reverse_op = v:true
              let operator_after = substitute(operator, '>', '<', 'g')
          endif
      endif

      " Whole lines
      if 'V' ==# visualmode() ||
       \ 'v' ==# visualmode() && line("'<") != line("'>")

         if reverse_op
             " Replace the operator
             execute 'silent ' . a:firstline . ',' . a:lastline .
                \'substitute/'       .
                \'^[[:space:]]*'     .
                \'[^[:space:]].\{-}' .
                \ '[[:space:]]*\zs'  . operator . '\ze[[:space:]]*' .
                \'[^[:space:]].\{-}' .
                \'[;[:space:]]*$/'   . operator_after . '/e'
         endif

         " Swap the operands
         execute 'silent ' . a:firstline . ',' . a:lastline .
            \ 'substitute/'           .
            \   '^[[:space:]]*\zs'    .
            \ '\([^[:space:]].\{-}\)' .
            \  '\([[:space:]]*\%('    . operator_after . '\)[[:space:]]*\)' .
            \ '\([^[:space:]].\{-}\)' .
            \'\ze[;[:space:]]*$/\3\2\1/e'
      else
         if col("'<") < col("'>")

            let col_start = col("'<")

            if col("'>") >= col('$')

               let col_end = col('$')
            else
               let col_end = col("'>") + 1
            endif
         else
            let col_start = col("'>")

            if col("'<") >= col('$')

               let col_end = col('$')
            else
               let col_end = col("'<") + 1
            endif
         endif

         if reverse_op
             " Replace the operator
             execute 'silent ' . a:firstline . ',' . a:lastline .
                \'substitute/\%'     . col_start . 'c[[:space:]]*' .
                \'[^[:space:]].\{-}' .
                \ '[[:space:]]*\zs'  . operator  . '\ze[[:space:]]*' .
                \'[^[:space:]].\{-}' .
                \'[;[:space:]]*\%'   . col_end   . 'c/' . operator_after . '/e'
         endif

         " Swap the operands
         execute 'silent ' . a:firstline . ',' . a:lastline .
            \'substitute/\%'         . col_start      . 'c[[:space:]]*\zs' .
            \'\([^[:space:]].\{-}\)' .
            \ '\([[:space:]]*\%('    . operator_after . '\)[[:space:]]*\)' .
            \'\([^[:space:]].\{-}\)' .
            \'\ze[;[:space:]]*\%'    . col_end        . 'c/\3\2\1/e'
      endif

   " Swap Words
   elseif a:mode =~ 'n'

      let save_cursor = getpos(".")

      " swap with Word on the left
      if 'nl' == a:mode

         call search('[^[:space:]]\+'  .
            \'\_[[:space:]]\+'  .
            \ '[^[:space:]]*\%#', 'bW')
      endif

      " swap with Word on the right
      execute 'silent substitute/'              .
         \ '\([^[:space:]]*\%#[^[:space:]]*\)' .
         \'\(\_[[:space:]]\+\)'                .
         \ '\([^[:space:]]\+\)/\3\2\1/e'
   endif

   " Repeat
   let virtualedit_bak = &virtualedit
   set virtualedit=

   if 'nr' == a:mode

      silent! call repeat#set("\<plug>SwapSwapWithR_WORD")

   elseif 'nl' == a:mode

      silent! call repeat#set("\<plug>SwapSwapWithL_WORD")
   endif

   " Restore saved values
   let &virtualedit = virtualedit_bak

   if histget('search', -1) != last_search

      call histdel('search', -1)
   endif

   if &virtualedit == 'all' && a:mode =~ 'v'
      " wrong cursor position is better than crash
      " https://groups.google.com/forum/#!topic/vim_dev/AK_HZ-5TeuU
      set virtualedit=
      call setpos('.', save_cursor)
      set virtualedit=all
   else
      call setpos('.', save_cursor)
   endif

endfunction
