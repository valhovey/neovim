syntax on " Syntax highlighting
filetype plugin indent on " Enable indenting and filetype detection

set errorformat=%C%*\\s•\ %m,
               \%-C\ %.%#,
               \%A%f:%l:%c:\ %t%.%#

let g:ale_linters = { 'haskell':    ['hlint'] }
let g:ale_fixers =  { 'haskell':    ['ormolu'] }
let g:ale_haskell_hlint_options = '--refactor'
let g:ale_haskell_ormolu_executable="fourmolu"
let g:ale_fix_on_save = 1
