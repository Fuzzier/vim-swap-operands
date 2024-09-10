" Easy swapping of text
"
" Author: Dimitar Dimitrov (mitkofr@yahoo.fr), kurkale6ka
"
" Latest version at:
" https://github.com/kurkale6ka/vim-swap
"
" Todo: rightleft
" Todo: repeat.vim for visual mode
" Todo: re-position the cursor using cursor()
"       Position of cursor in the visual area?

if exists('g:loaded_swap_operands') || &compatible || v:version < 700

   if &compatible && &verbose
      echo "Swap is not designed to work in compatible mode."
   elseif v:version < 700
      echo "Swap needs Vim 7.0 or above to work correctly."
   endif

   finish
endif

let g:loaded_swap_operands = 1

let s:savecpo = &cpoptions
set cpoptions&vim

xmap <silent> <plug>SwapSwapOperands      :     call swap_operands#text('v' )<cr>
xmap <silent> <plug>SwapSwapPivotOperands :     call swap_operands#text('vi')<cr>
nmap <silent> <plug>SwapSwapWithR_WORD    :<c-u>call swap_operands#text('nr')<cr>
nmap <silent> <plug>SwapSwapWithL_WORD    :<c-u>call swap_operands#text('nl')<cr>

""" default keymappings
" If g:swap_operands_no_default_key_mappings has been defined, then quit immediately.
if !exists('g:swap_operands_no_default_key_mappings')

    function! s:map(mode, lhs, rhs)

        if !hasmapto(a:rhs, a:mode)
            execute a:mode . 'map ' . a:lhs . ' ' . a:rhs
        endif

    endfunction

    call s:map('x', '<leader>x', '<plug>SwapSwapOperands')
    call s:map('x', '<leader>cx', '<plug>SwapSwapPivotOperands')
    call s:map('n', '<leader>x', '<plug>SwapSwapWithR_WORD')
    call s:map('n', '<leader>X', '<plug>SwapSwapWithL_WORD')

endif

let &cpoptions = s:savecpo
unlet s:savecpo
