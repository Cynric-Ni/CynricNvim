local version = vim.fn.matchstr(vim.fn.execute('version'), 'NVIM v\\zs[^\\n]*')

--检查启动Neovim的时候是否带有“--noplugins和noplugin”参数
local argv = vim.api.nvim_get_vvar "argv"
local noplugin = vim.list_contains(argv, "--noplugin") or vim.list_contains(argv, "--noplugins")

local utils = {
    is_linux = vim.uv.os_uname().sysname == "Linux",
    is_mac = vim.uv.os_uname().sysname == "Darwin",
    is_windows = vim.uv.os_uname().sysname == "Windows_NT",
    is_wsl = string.find(vim.uv.os_uname().release, "WSL") ~= nil,
    noplugin = noplugin,
    version = version,
}

--检查文件是否存在
-- Checks if a file exists
---@param file string
---@return boolean
utils.file_exists = function(file)
    local fid = io.open(file, "r")
    if fid ~= nil then
        io.close(fid)
        return true
    else
        return false
    end
end

-- Maps a group of keymaps with the same opt; if no opt is provided, the default opt is used.
-- The keymaps should be in the format like below:
--     desc = { mode, lhs, rhs, [opt] }
-- For example:
--     black_hole_register = { { "n", "v" }, "\\", '"_' },
-- The desc part will automatically merged into the keymap's opt, unless one is already provided there, with the slight
-- modification of replacing "_" with a blank space.
---@param group table list of keymaps
---@param opt table | nil default opt
utils.group_map = function(group, opt)
    if not opt then
        opt = {}
    end

    for desc, keymap in pairs(group) do
        desc = string.gsub(desc, "_", " ")
        local default_option = vim.tbl_extend("force", { desc = desc, nowait = true, silent = true }, opt)
        local map = vim.tbl_deep_extend("force", { nil, nil, nil, default_option }, keymap)
        vim.keymap.set(map[1], map[2], map[3], map[4])
    end
end
