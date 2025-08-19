require('lazy').setup({
  spec = {
    -- require 'kickstart.plugins.debug',
    -- require 'kickstart.plugins.indent_line',
    -- require 'kickstart.plugins.lint',
    -- require 'kickstart.plugins.autopairs',
    -- require 'test/plugins/lspconfig',

    require 'colorschemes/plugins/setup',
    { import = 'plugins' },
    --
    -- For additional information with loading, sourcing and examples see `:help lazy.nvim-🔌-plugin-spec`
    -- In normal mode type `<space>sh` then write `lazy.nvim-plugin`
    -- you can continue same window with `<space>sr` which resumes last telescope search
  },
    ui = {
        icons = vim.g.have_nerd_font and {} or {
            cmd = '⌘ ',
            config = '🛠',
            event = '📅',
            ft = '📂',
            init = '⚙ ',
            keys = '🗝',
            plugin = '🔌',
            runtime = '💻',
            require = '🌙',
            source = '📄',
            start = '🚀 ',
            task = '📌',
            lazy = '💤 ',
        },
    },
})

-- vim: ts=2 sts=2 sw=2 et
