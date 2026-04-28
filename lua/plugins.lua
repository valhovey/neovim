return require('packer').startup(function(use)
	use 'wbthomason/packer.nvim'

	-- Editor motions and objects
	use 'tpope/vim-surround'
	use 'tpope/vim-repeat'
	use 'tomtom/tcomment_vim'
  use 'mg979/vim-visual-multi'

	-- File browsing and searching
	use {
		'nvim-telescope/telescope.nvim', tag='0.1.4',
		requires = { {'nvim-lua/plenary.nvim'} }
	}
	use 'nvim-telescope/telescope-file-browser.nvim'
  use 'psiska/telescope-hoogle.nvim'
  use 'nvim-tree/nvim-tree.lua'

	-- Language Server/AST Support
	use {
		'neoclide/coc.nvim',
		branch = 'release'
	}

  use {
    'nvim-treesitter/nvim-treesitter',
    run = function()
      local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
      ts_update()
    end,
  }
	use 'nvim-treesitter/playground'

	-- Language Support
	use 'lilydjwg/colorizer'
	use 'pbrisbin/vim-syntax-shakespeare'
	use 'alx741/yesod.vim'
  use { 'ndmitchell/ghcid', rtp = 'plugins/nvim' }
	use 'vimwiki/vimwiki'
	use 'pantharshit00/vim-prisma'
	use 'vim-latex/vim-latex'

	-- Versioning
	use 'tpope/vim-fugitive'
	use 'airblade/vim-gitgutter'
	use 'zivyangll/git-blame.vim'
	use 'kdheepak/lazygit.nvim'

	-- Color Schemes
  use 'sainnhe/gruvbox-material'
  use 'sainnhe/everforest'

	-- Visual/Information UX
	use 'lukas-reineke/indent-blankline.nvim'
  use 'famiu/feline.nvim'
  -- use {
  --   'nvim-lualine/lualine.nvim',
  --   requires = { 'nvim-tree/nvim-web-devicons', opt = true }
  -- }
	use 'ryanoasis/vim-devicons'
	use 'ruanyl/vim-gh-line'
	use 'nvim-tree/nvim-web-devicons'
  use 'mbbill/undotree'
end)
