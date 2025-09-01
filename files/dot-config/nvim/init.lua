-- globals
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.editorconfig = true

-- options
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = 'a'
vim.o.list = true
vim.o.swapfile = false
vim.o.termguicolors = true
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.listchars = "tab:» ,trail:·,nbsp:␣"
vim.o.winborder = 'rounded'
vim.o.undofile = true
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.colorcolumn = '80'
vim.o.cursorcolumn = false
vim.o.cursorline = true
vim.o.guicursor = ''
vim.o.wrap = true
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.signcolumn = 'yes'
vim.o.smartcase = true
vim.o.updatetime = 500
vim.o.inccommand = 'split'
vim.o.scrolloff = 8
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.shortmess:append "c"
vim.cmd('syntax enable')
vim.cmd('filetype plugin indent on')

vim.api.nvim_create_autocmd({'TextYankPost'}, {
    group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
    callback = function()
        vim.hl.on_yank { timeout = 100 }
    end,
})

vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufEnter" }, {
    group = vim.api.nvim_create_augroup("ScrollOffEOF", {}),
    callback = function()
        local window_height = vim.api.nvim_win_get_height(0)
        local scrolloff = vim.o.scrolloff
        local distance = vim.fn.line "$" - vim.fn.line "."
        local remaining = vim.fn.line "w$" - vim.fn.line "w0" + 1
        if distance < scrolloff and window_height - remaining + distance < scrolloff then
            local view = vim.fn.winsaveview()
            view.topline = view.topline + scrolloff - (window_height - remaining + distance)
            vim.fn.winrestview(view)
        end
    end,
})

-- more patterns for env files, as the naming conventions of some
-- frameworks don't work with the default patterns
vim.filetype.add({
    pattern = {
        ['%.env%..*'] = 'sh',
        ['.*%.env'] = 'sh',
    },
})

-- plugins
vim.pack.add({
    { src = 'https://github.com/shaunsingh/nord.nvim' },
    { src = 'https://github.com/echasnovski/mini.pick' },
    -- treesitter switched to calling it main, but left the master as the default on github
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
    { src = 'https://github.com/neovim/nvim-lspconfig' },
    { src = 'https://github.com/mason-org/mason.nvim' },
    { src = 'https://github.com/Saghen/blink.cmp' },
})

require'mini.pick'.setup()
require'mason'.setup()

local lsps = {'gopls', 'lua_ls', 'elixirls', 'phpactor'}
vim.lsp.enable(lsps)

local capabilities = vim.tbl_deep_extend(
  'force',
  vim.lsp.protocol.make_client_capabilities(),
  require('blink.cmp').get_lsp_capabilities()
)

require'lspconfig'.elixirls.setup({
    capabilities = capabilities,
    cmd = {vim.fn.stdpath('data')..'/mason/bin/elixir-ls'}
})

require'lspconfig'.phpactor.setup({
    capabilities = capabilities,
    cmd = {vim.fn.stdpath('data')..'/mason/bin/phpactor'}
})

require'nvim-treesitter'.install { 'elixir', 'lua', 'go', 'php' }

require'nvim-treesitter.config'.setup {
    auto_install = true,
    -- ensure_installed = {
    --     "eex",
    --     "elixir",
    --     "erlang",
    --     "heex",
    -- },
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    }
}

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'elixir' },
  callback = function() vim.treesitter.start() end,
})

-- build blink.cmps fuzzy finder
local blink_path = vim.fn.stdpath('data')..'/site/pack/core/opt/blink.cmp'
if vim.fn.getftype(blink_path..'/target') == '' then
    vim.cmd('!cargo +nightly build --manifest-path '..blink_path..'/Cargo.toml --release')
end

require'blink.cmp'.setup({
    fuzzy = {
        implementation = 'prefer_rust'
    },
    completion = {
        documentation = {
            auto_show = true,
            auto_show_delay_ms = 0,
            treesitter_highlighting = true,
        },
    }
})

-- keymaps
local map = vim.keymap.set
map('n', '<Esc>', '<cmd>nohlsearch<CR>')
map('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
map('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
map('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
map('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

--TODO: add another one like this, to grep entire project for the selected word
-- with mini.pick or something
map('n', '<leader>sn', function()
    local word = vim.fn.expand '<cword>'
    vim.fn.setreg('/', word)
    vim.cmd 'normal! n'
end, { desc = 'Search the current word' })

map('n', '<leader>sf', '<cmd>Pick files<CR>')
map('n', '<leader>sg', '<cmd>Pick grep_live<CR>')
map('n', '<leader>sh', '<cmd>Pick help<CR>')

-- I don't really like these binds that much
map('n', '<leader>ww', ':write<CR>')
map('n', '<leader>wa', ':wa<CR>')
map('n', '<leader>wq', ':wq<CR>')
map('n', '<leader>q',  ':quit<CR>')

map('n', '<leader>y', '"+yy')
map({ 'v', 'x' }, '<leader>y', '"+y')
-- map('n', '<leader>d', '"+dd')
-- map({ 'v', 'x' }, '<leader>d', '"+d')
map('n', '<leader>de', vim.diagnostic.open_float)
map({'v','n'}, "<leader>dn", function()
  vim.diagnostic.jump({ count = 1 })
end, { desc = "Go to next diagnostic" })
map({'v','n'}, "<leader>dp", function()
  vim.diagnostic.jump({ count = -1 })
end, { desc = "Go to previous diagnostic" })
map({'v','n','x'}, "<leader>df", vim.lsp.buf.format)

--alternate file stuff, figure out if I even need that, or if I am just going
--to use harpoon
-- map({ 'n', 'v', 'x' }, '<leader>s', ':e #<CR>')
-- map({ 'n', 'v', 'x' }, '<leader>S', ':sf #<CR>')

-- colors
vim.cmd('colorscheme nord')
vim.cmd('set background=dark')
