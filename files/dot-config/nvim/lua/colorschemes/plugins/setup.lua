-- Get the path to the current directory
local colorschemes_path = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':h')

-- Find all Lua files in the directory, excluding `setup.lua`
local files = vim.fn.glob(colorschemes_path .. '/*.lua', false, true)

-- Container for all plugin specifications
local plugins = {}

-- Iterate over the files and load each as a Lua module
for _, file in ipairs(files) do
    local file_name = vim.fn.fnamemodify(file, ':t:r') -- Extract filename without extension
    if file_name ~= 'setup' then -- Skip `setup.lua`
        local success, spec = pcall(require, 'colorschemes.plugins.' .. file_name)
        if success then
            vim.list_extend(plugins, spec) -- Append plugin specs
        else
            vim.notify('Error loading colorscheme plugin: ' .. file_name, vim.log.levels.ERROR)
        end
    end
end

-- Return the aggregated plugins list
return plugins
