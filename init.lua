-- Leader has to be set before plugins load. Under lazy.nvim the plugins' own plugin/
-- scripts are sourced during require('plugins'), which is *before* keymap.vim runs -- so
-- anything mapping <leader> at source time would bind to `\` if this were left to
-- keymap.vim alone. (Under packer those scripts ran after init.lua, which hid this.)
vim.g.mapleader = ' '

-- Order matters here, in two separate ways.
--
-- 1. plugin-settings and options before plugins: lazy.nvim sources each plugin's plugin/
--    scripts during setup, and several of them inspect state at that moment --
--    vim-gitgutter reads g:gitgutter_enabled, vim-latex reads most of g:Tex_*, and
--    vim-julia-cell calls has('python3'), which is false until options.lua has set
--    g:python3_host_prog (it echoes "julia-cell requires py >= 2.7 or py3" otherwise).
--    Under packer these scripts were sourced after init.lua finished, which hid all of
--    this. The one line that genuinely needs the plugin already on the rtp -- vim-slime's
--    `runtime autoload/slime/config.vim` -- lives in the vim-slime spec's config().
-- 2. everything before editor.vim: editor.vim runs `syntax on`, which fires
--    BufReadPost/FileType autocommands immediately -- including plugin ftplugins. Those
--    ftplugins read globals defined above, so opening `nvim foo.py` errors during startup
--    if this is reordered.
require('plugin-settings')
require('options')
require('plugins')

vim.cmd('source ~/.config/nvim/editor.vim')
vim.cmd('source ~/.config/nvim/keymap.vim')
