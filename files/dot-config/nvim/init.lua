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
})

require 'mini.pick'.setup()
require 'mason'.setup()

vim.lsp.enable({ 'gopls', 'lua_ls', 'elixirls', 'phpactor' })

require 'nvim-treesitter'.install { 'elixir', 'lua', 'go', 'php' }

require 'nvim-treesitter.config'.setup {
    auto_install = true,
    ensure_installed = {
        "eex",
        "elixir",
        "erlang",
        "heex",
        'phpactor',
        'php',
    },
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    }
}

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'elixir', 'php', 'go', 'c', 'lua' },
    callback = function() vim.treesitter.start() end,
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

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('my.lsp', {}),
    callback = function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

        ---Utility for keymap creation.
        ---@param lhs string
        ---@param rhs string|function
        ---@param opts string|table
        ---@param mode? string|string[]
        local function keymap(lhs, rhs, opts, mode)
            opts = type(opts) == 'string' and { desc = opts }
                or vim.tbl_extend('error', opts --[[@as table]], { buffer = args.buf })
            mode = mode or 'n'
            vim.keymap.set(mode, lhs, rhs, opts)
        end

        ---For replacing certain <C-x>... keymaps.
        ---@param keys string
        local function feedkeys(keys)
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), 'n', true)
        end

        ---Is the completion menu open?
        local function pumvisible()
            return vim.fn.pumvisible() ~= 0
        end

        -- Enable completion and configure keybindings.
        if client:supports_method(vim.lsp.protocol.Methods.textDocument_completion, args.buf) then
            vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })

            -- Use slash to dismiss the completion menu.
            keymap('/', function()
                return pumvisible() and '<C-e>' or '/'
            end, { expr = true }, 'i')
            -- Use <C-n> to navigate to the next completion or:
            -- - Trigger LSP completion.
            -- - If there's no one, fallback to vanilla omnifunc.
            keymap('<C-n>', function()
                if pumvisible() then
                    feedkeys '<C-n>'
                else
                    if next(vim.lsp.get_clients { bufnr = 0 }) then
                        vim.lsp.completion.trigger()
                    else
                        if vim.bo.omnifunc == '' then
                            feedkeys '<C-x><C-n>'
                        else
                            feedkeys '<C-x><C-o>'
                        end
                    end
                end
            end, 'Trigger/select next completion', 'i')

            -- Buffer completions.
            keymap('<C-u>', '<C-x><C-n>', { desc = 'Buffer completions' }, 'i')

            keymap('<S-Tab>', function()
                if pumvisible() then
                    feedkeys '<C-p>'
                elseif vim.snippet.active { direction = -1 } then
                    vim.snippet.jump(-1)
                else
                    feedkeys '<S-Tab>'
                end
            end, {}, { 'i', 's' })

            -- Inside a snippet, use backspace to remove the placeholder.
            keymap('<BS>', '<C-o>s', {}, 's')
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

local orig_float_func = vim.lsp.util.open_floating_preview
vim.lsp.util.open_floating_preview = function(contents, syntax, opts)
    local buffer_id = vim.api.nvim_get_current_buf()
    local new_buffer_id, win_id = assert(orig_float_func(contents, syntax, opts))
    local win_close_func = function()
        if (vim.api.nvim_win_is_valid(win_id)) then
            vim.api.nvim_win_close(win_id, true)
        else
            vim.cmd('nohlsearch')
        end
        vim.lsp.buf.clear_references()
    end
    map('n', '<Esc>', '', {
        callback = win_close_func,
        buffer = buffer_id,
        desc = 'closes floating lsp doc window'
    })
    map('n', '<Esc>', '', {
        callback = win_close_func,
        buffer = new_buffer_id,
        desc = 'closes floating lsp doc window'
    })
end

map('n', '<leader>pc', pack_clean)
-- map({'n', 'x', 'v' }, ';', ':')
-- map({'n', 'x', 'v' }, ':', ';')
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

map('n', '<leader>y', '"+yy')
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

--alternate file stuff, figure out if I even need that, or if I am just going
--to use harpoon
-- map({ 'n', 'v', 'x' }, '<leader>s', ':e #<CR>')
-- map({ 'n', 'v', 'x' }, '<leader>S', ':sf #<CR>')

-- colors
vim.cmd('colorscheme evening')
vim.cmd('set background=dark')
