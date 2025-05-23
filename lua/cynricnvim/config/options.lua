--声明命名空间
local g = vim.g
local opt = vim.opt

--
vim.cmd ([[
language en_US.UTF-8
syntax off
]])

g.encoding = "UTF-8"
opt.fileencoding = "UTF-8"

opt.number = true
opt.relativenumber = true

opt.cursorline = true --高亮选中行

opt.tabstop = 4
opt.shiftwidth = 0
opt.expandtab = true

opt.wrap = false

--搜索时大小写不敏感，但是开启大写就会敏感
opt.ignorecase = true
opt.smartcase = true

opt.hlsearch = false --查找高亮取消

--Add mouse support for all modes
opt.mouse = "a"
opt.mousemodel = "extend"

--开启垂直和水平窗口分屏模式
opt.splitbelow = true
opt.splitright = true

opt.autoread = true --自动更新缓存区

opt.clipboard = "unnamedplus" --系统粘贴吧板开启
