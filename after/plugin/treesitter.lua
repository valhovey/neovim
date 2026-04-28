require'nvim-treesitter.configs'.setup {
  ensure_installed = { "javascript", "typescript", "tsx", "c", "lua", "vim", "vimdoc", "query", "elm", "julia", "haskell", "markdown", "rust", "json" },
  sync_install = false,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}
