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
-- vim.o.winborder = 'rounded'
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
vim.o.scrolloff = 5
vim.opt.completeopt = { "menu", "menuone", "noinsert" }
vim.opt.shortmess:append "c"
vim.cmd('syntax enable')
vim.cmd('filetype plugin indent on')

vim.api.nvim_create_autocmd({ 'TextYankPost' }, {
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
    { src = 'https://github.com/vim-scripts/cmdalias.vim' },
})

require 'mini.pick'.setup()
require 'mason'.setup()

vim.lsp.enable({ 'gopls', 'lua_ls', 'elixirls', 'phpactor' })

-- require 'nvim-treesitter'.install { 'elixir', 'lua', 'go', 'php' }

require 'nvim-treesitter.config'.setup {
    auto_install = true,
    ensure_installed = {
        "eex",
        "elixir",
        "erlang",
        "heex",
        "php",
        "go",
    },
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
}

vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(args)
        vim.cmd('TSUpdate');
    end
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'elixir', 'php', 'go', 'c', 'lua' },
    callback = function()
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        vim.treesitter.start()
    end,
})

-- build blink.cmps fuzzy finder
-- local blink_path = vim.fn.stdpath('data') .. '/site/pack/core/opt/blink.cmp'
-- if vim.fn.getftype(blink_path .. '/target') == '' then
--     vim.cmd('!cargo +nightly build --manifest-path ' .. blink_path .. '/Cargo.toml --release')
-- end
--
-- require 'blink.cmp'.setup({
--     fuzzy = {
--         implementation = 'prefer_rust'
--     },
--     completion = {
--         documentation = {
--             auto_show = true,
--             auto_show_delay_ms = 0,
--             treesitter_highlighting = true,
--         },
--     }
-- })

-- turn off highlighting when using K lsp command
vim.api.nvim_create_autocmd('ColorScheme', {
    callback = function()
        vim.api.nvim_set_hl(0, 'LspReferenceTarget', {})
    end,
})

local orig_float_func = vim.lsp.util.open_floating_preview
vim.lsp.util.open_floating_preview = function(contents, syntax, opts)
    local buffer_id = vim.api.nvim_get_current_buf()
    local new_buffer_id, win_id = assert(orig_float_func(contents, syntax, opts))
    local win_close_func = function()
        if (vim.api.nvim_win_is_valid(win_id)) then
            vim.api.nvim_win_close(win_id, true)
        end
    end
    vim.keymap.set('n', '<Esc>', '', {
        callback = win_close_func,
        buffer = buffer_id,
        desc = 'closes floating lsp doc window'
    })
    vim.keymap.set('n', '<Esc>', '', {
        callback = win_close_func,
        buffer = new_buffer_id,
        desc = 'closes floating lsp doc window'
    })
end

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('my.lsp', {}),
    callback = function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

        if client:supports_method('textDocument/completion') then
            -- Optional: trigger autocompletion on EVERY keypress. May be slow!
            local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
            client.server_capabilities.completionProvider.triggerCharacters = chars
            vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
        end
    end,
})

local function pack_clean()
    local unused_plugins = {}

    for _, plugin in ipairs(vim.pack.get()) do
        if not plugin.active then
            table.insert(unused_plugins, plugin.spec.name)
        end
    end

    if #unused_plugins == 0 then
        print("No unused plugins.")
        return
    end

    local choice = vim.fn.confirm("Remove unused plugins?", "&Yes\n&No", 2)
    if choice == 1 then
        vim.pack.del(unused_plugins)
    end
end

-- keymaps
local map = vim.keymap.set
map('n', '<leader>pc', pack_clean)
-- map({'n', 'x', 'v' }, ';', ':')
-- map({'n', 'x', 'v' }, ':', ';')
map('n', '<leader>pc', pack_clean)
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

map('n', '<leader>yy', '"+yy')
map({ 'v', 'x' }, '<leader>y', '"+y')
map('n', '<leader>de', vim.diagnostic.open_float)
map('n', '<leader>rn', vim.lsp.buf.rename)
map({ 'v', 'n' }, "<leader>dn",
    function() vim.diagnostic.jump({ count = 1 }) end,
    { desc = "Go to next diagnostic" }
)
map({ 'v', 'n' }, "<leader>dp",
    function() vim.diagnostic.jump({ count = -1 }) end,
    { desc = "Go to previous diagnostic" }
)
map({ 'v', 'n', 'x' }, "<leader>df", vim.lsp.buf.format)
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        vim.fn.call("CmdAlias", { 'qw', 'wq' })
    end,
})

--alternate file stuff, figure out if I even need that, or if I am just going
--to use harpoon
-- map({ 'n', 'v', 'x' }, '<leader>s', ':e #<CR>')
-- map({ 'n', 'v', 'x' }, '<leader>S', ':sf #<CR>')

-- colors
vim.cmd('colorscheme evening')
vim.cmd('set background=dark')
vim.cmd('hi ColorColumn ctermbg=Black guibg=Black')
