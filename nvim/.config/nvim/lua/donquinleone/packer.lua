vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
	use 'wbthomason/packer.nvim'

    use { "catppuccin/nvim", as = "catppuccin",
        config = function()
            vim.cmd([[colorscheme catppuccin-mocha]])
        end
    }
end)

