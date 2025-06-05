cynric = {}

require "core.init"
require "plugins.init"


-- Define keymap
local keymap = cynric.keymap.general
require("core.utils").group_map(keymap)

for filetype, config in pairs(cynric.ft) do
    require("core.utils").ft(filetype, config)
end

-- Only load plugins and colorscheme when --noplugin arg is not present
if not require("core.utils").noplugin then
    -- Load plugins
    require("lazy").setup(vim.tbl_values(cynric.plugins), cynric.lazy)  --vim.tbl_values获取字典中的元素
    
    --创建用户verylazy事件的回调函数 回调函数的作用是扫描plugin文件夹并且
    --在verylazy事件后（所有插件加载完毕）扫描plugin文件夹是否有.vim脚本如果有创建cmd自动
    --执行
     vim.api.nvim_create_autocmd("User", {
        once = true,
        pattern = "VeryLazy",
        callback = function()
            local rtp_plugin_path = vim.opt.packpath:get()[1] .. "/plugin"
            local dir = vim.uv.fs_scandir(rtp_plugin_path)
            if dir ~= nil then
                while true do
                    local plugin = vim.uv.fs_scandir_next(dir)
                    if plugin == nil then
                        break
                    else
                        vim.cmd(string.format("source %s/%s", rtp_plugin_path, plugin))
                    end
                end
            end
            --并且附带plugins里的keymap
            require("core.utils").group_map(cynric.keymap.plugins)

            -- Define colorscheme
            if not cynric.colorscheme then
                local colorscheme_cache = vim.fn.stdpath "data" .. "/colorscheme"
                if require("core.utils").file_exists(colorscheme_cache) then
                    local colorscheme_cache_file = io.open(colorscheme_cache, "r")
                    ---@diagnostic disable: need-check-nil
                    local colorscheme = colorscheme_cache_file:read "*a"
                    colorscheme_cache_file:close()
                    cynric.colorscheme = colorscheme
                else
                    cynric.colorscheme = "tokyonight"
                end
            end

            require("plugins.utils").colorscheme(cynric.colorscheme)
        end,
    })
end
