local COLOURSCHEME_PRIORITY = 1000

local specs = {
    {
        "rebelot/kanagawa.nvim",
        name = "kanagawa",
        commit = "bb85e4bfc8d89b0e62c8fa53ccdd13d12e2f77b3",
        config = function()
            require("kanagawa").setup({
                transparent = true,
                colors = {
                    theme = { all = { ui = { bg_gutter = "none" } } },
                },
            })
        end,
    },
    {
        "ember-theme/nvim",
        name = "ember",
        commit = "7365b8dede43a82ed1df741275b75333422e5402",
    },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        tag = "v2.0.0",
    },
    {
        "Mofiqul/dracula.nvim",
        name = "dracula",
        commit = "ae752c13e95fb7c5f58da4b5123cb804ea7568ee",
    },
    {
        "maxmx03/solarized.nvim",
        name = "solarized",
        tag = "v3.6.0",
    },
    {
        "folke/tokyonight.nvim",
        name = "tokyonight",
        tag = "v4.14.1",
    },
    {
        "rose-pine/neovim",
        name = "rose-pine",
        tag = "v3.0.2",
    },
    {
        "ellisonleao/gruvbox.nvim",
        name = "gruvbox",
        tag = "2.0.0",
    },
    {
        "ribru17/bamboo.nvim",
        name = "bamboo",
        commit = "1309bc88bffcf1bedc3e84e7fa9004de93da774a",
        config = function()
            -- The bamboo-<style> colorschemes reach straight for
            -- vim.g.bamboo_config, which only setup() creates.
            require("bamboo").setup()
        end,
    },
}

for _, spec in ipairs(specs) do
    spec.lazy = false
    spec.priority = COLOURSCHEME_PRIORITY
end

return specs
