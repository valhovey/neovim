-- lazy.nvim bootstrap. Replaced packer.nvim (archived upstream Aug 2023) on 2026-07-28.
-- Clones itself on first run; after that this is a no-op.
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({
    'git', 'clone', '--filter=blob:none', '--branch=stable',
    'https://github.com/folke/lazy.nvim.git', lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error('Failed to clone lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Nothing here declares `event`/`cmd`/`ft`/`keys`, so every plugin loads at startup --
-- lazy.nvim's default is `lazy = false`. That is deliberate: after/plugin/*.lua requires
-- these modules unconditionally, and the load order in this config is load-bearing
-- (see the vault: "nvim init.lua ordering gotcha").
local spec = {
  -- Editor motions and objects
  'tpope/vim-surround',
  'tpope/vim-repeat',
  -- tomtom/tcomment_vim removed 2026-07-28: Neovim 0.12 ships commenting itself
  -- (runtime/lua/vim/_comment.lua) and maps gc/gcc by default from vim/_core/defaults.
  -- tcomment was shadowing the built-in gcc rather than adding anything.

  -- File browsing and searching
  {
    'nvim-telescope/telescope.nvim',
    -- Was pinned to tag '0.1.4' (Oct 2023) until 2026-07-28; upstream had reached v0.2.2.
    -- Now tracks the default branch -- lazy-lock.json is what makes this reproducible, so
    -- pinning a tag as well just guarantees the same three-year drift.
    dependencies = { 'nvim-lua/plenary.nvim' },
  },
  'nvim-telescope/telescope-file-browser.nvim',
  'nvim-tree/nvim-tree.lua',

  -- Language Server/AST Support
  {
    'neoclide/coc.nvim',
    branch = 'release',
  },

  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = function()
      -- `main` branch API: update() is async and returns a handle to wait on.
      -- The old `update({ with_sync = true })()` form is a `master`-ism.
      require('nvim-treesitter').update():wait(300000)
    end,
  },

  -- Language Support
  'lilydjwg/colorizer',
  'pbrisbin/vim-syntax-shakespeare',
  'tpope/vim-rails',
  'alx741/yesod.vim',
  {
    'jpalardy/vim-slime',
    -- The g: vars this reads are set in lua/plugin-settings.lua, which init.lua now
    -- requires *before* this file. But g:slime_config_defaults lives in an autoload
    -- file that Vim only sources on the first slime#config#* call, and the python /
    -- haskell / scala ftplugins write into it at FileType time -- so source it eagerly
    -- here, once the plugin is actually on the rtp. Must be after g:slime_target.
    -- See the vault: "vim-slime autoload gotcha".
    config = function()
      vim.cmd('runtime autoload/slime/config.vim')
    end,
  },
  -- The only lazy-loaded plugin in this spec. Its plugin script calls has('python3'), which
  -- initialises the python3 provider host and cost ~57ms of a ~127ms startup. Nothing it
  -- provides is useful outside a Julia buffer, and the <Leader>jr / <Leader>jR mappings in
  -- keymap.vim only make sense there too.
  { 'mroavi/vim-julia-cell', ft = 'julia' },
  'kdheepak/JuliaFormatter.vim',
  -- 'vimwiki/vimwiki',
  'timtro/glslView-nvim',
  'tikhomirov/vim-glsl',
  'pantharshit00/vim-prisma',
  'vim-latex/vim-latex',

  -- Versioning
  'tpope/vim-fugitive',
  {
    'airblade/vim-gitgutter',
    branch = 'main',
  },
  -- zivyangll/git-blame.vim removed 2026-07-28: last upstream commit 2019, and nothing in
  -- this config ever referenced it. vim-fugitive's `:Git blame` covers it.
  'kdheepak/lazygit.nvim',

  -- Color Schemes
  'sainnhe/gruvbox-material',
  -- priority 1000: after/plugin/colors.lua calls ColorScheme(), which defaults to gruvbox,
  -- so this one has to be loaded before the others get a chance to set highlights.
  { 'ellisonleao/gruvbox.nvim', priority = 1000 },
  'sainnhe/everforest',
  { 'catppuccin/nvim', name = 'catppuccin' },
  {
    '2nthony/vitesse.nvim',
    dependencies = { 'tjdevries/colorbuddy.nvim' },
  },

  -- Visual/Information UX
  'lukas-reineke/indent-blankline.nvim',
  -- Replaced famiu/feline.nvim on 2026-07-28 -- feline was archived in Sept 2023 and its
  -- git/diagnostic providers read gitsigns and native vim.lsp, neither of which this config
  -- uses. See after/plugin/lualine.lua and the vault: "feline to lualine port".
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },
  -- ryanoasis/vim-devicons removed 2026-07-28: the vimscript predecessor of
  -- nvim-web-devicons below, which is what lualine, nvim-tree and telescope actually use.
  'ruanyl/vim-gh-line',
  'nvim-tree/nvim-web-devicons',
  'mbbill/undotree',

  -- Presentations
  'sotte/presenting.nvim',
  -- 'MeanderingProgrammer/render-markdown.nvim',
}

require('lazy').setup(spec, {
  install = { colorscheme = { 'gruvbox' } },
  change_detection = { notify = false },
  -- No plugin in this spec is a luarocks package, but lazy still probes for hererocks
  -- and reports a red ERROR in `:checkhealth lazy` when it is absent. Turn the whole
  -- subsystem off rather than install a Lua 5.1 toolchain nothing uses.
  rocks = { enabled = false },
  performance = {
    rtp = {
      -- lazy.nvim resets the runtimepath by default, which would drop
      -- ~/.local/share/nvim/site -- where nvim-treesitter `main` installs its parsers
      -- and queries (install_dir in after/plugin/treesitter.lua). Without this, every
      -- parser silently stops being found and highlighting falls back to regex syntax.
      paths = { vim.fn.stdpath('data') .. '/site' },
    },
  },
})
