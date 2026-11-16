-- nvim-treesitter `main` branch API (the post-rewrite one).
-- The old `require('nvim-treesitter.configs').setup{ ensure_installed, highlight, ... }`
-- form only exists on the `master` branch and errors out here.
require('nvim-treesitter').setup {
  install_dir = vim.fn.stdpath('data') .. '/site',
}

-- Parsers are installed explicitly now; there is no `ensure_installed` key.
-- No-op for parsers already present. Runs asynchronously.
require('nvim-treesitter').install {
  'javascript', 'typescript', 'tsx',
  'c', 'lua', 'vim', 'vimdoc', 'query', 'svelte',
  'elm', 'julia', 'haskell', 'markdown', 'rust', 'json', 'glsl', 'python',
}

-- Highlighting is no longer a plugin option -- Neovim owns it, and it is enabled
-- per-buffer with vim.treesitter.start(). pcall because this fires for every
-- filetype, including ones with no parser installed.
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('user_treesitter', { clear = true }),
  callback = function(ev)
    pcall(vim.treesitter.start, ev.buf)
  end,
})
