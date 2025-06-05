-- Configuration for each individual plugin
---@diagnostic disable: need-check-nil
local config = {}
local symbols = cynric.symbols
local config_root = string.gsub(vim.fn.stdpath "config" --[[@as string]], "\\", "/")

-- Add Load event
vim.api.nvim_create_autocmd("User", {
    pattern = "cynricAfter colorscheme",
    callback = function()
        local function should_trigger()
            return vim.bo.filetype ~= "dashboard" and vim.api.nvim_buf_get_name(0) ~= ""
        end

        local function trigger()
            vim.api.nvim_exec_autocmds("User", { pattern = "cynricLoad" })
        end

        if should_trigger() then
            trigger()
            return
        end

        local cynric_load
        cynric_load = vim.api.nvim_create_autocmd("BufEnter", {
            callback = function()
                if should_trigger() then
                    trigger()
                    vim.api.nvim_del_autocmd(cynric_load)
                end
            end,
        })
    end,
})



config.bufferline = {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "User cynricLoad",
    opts = {
        options = {
            close_command = ":BufferLineClose %d", --添加关闭命令 %d自动替换成当前编号
            right_mouse_command = ":BufferLineClose %d",
            separator_style = "thin",
            --左侧让出nvimTree位置
            offsets = {
                {
                    filetype = "NvimTree",
                    text = "File Explorer",
                    highlight = "Directory",
                    text_align = "left",
                },
            },
            diagnostics = "nvim_lsp",
            diagnostics_indicator = function(_, _, diagnostics_dict, _)
                local s = " "
                for e, n in pairs(diagnostics_dict) do
                    local sym = e == "error" and symbols.Error or (e == "warning" and symbols.Warn or symbols.Info)
                    s = s .. n .. sym
                end
                return s
            end,
        },
    },
    config = function(_, opts)
        vim.api.nvim_create_user_command("BufferLineClose", function(buffer_line_opts)
            local bufnr = 1 * buffer_line_opts.args  --把参数数字化
            local buf_is_modified = vim.api.nvim_get_option_value("modified", { buf = bufnr })

            local bdelete_arg
            if bufnr == 0 then
                bdelete_arg = ""
            else
                bdelete_arg = " " .. bufnr
            end
            local command = "bdelete!" .. bdelete_arg
            if buf_is_modified then
                local option = vim.fn.confirm("File is not saved. Close anyway?", "&Yes\n&No", 2)
                if option == 1 then
                    vim.cmd(command)
                end
            else
                vim.cmd(command)
            end
        end, { nargs = 1 })

        require("bufferline").setup(opts)

        require("nvim-web-devicons").setup {
            override = {
                typ = { icon = "󰰥", color = "#239dad", name = "typst" },
            },
        }
    end,
    keys = {
        { "<leader>bc", "<Cmd>BufferLinePickClose<CR>", desc = "pick close", silent = true },
        { "<leader>bd", "<Cmd>BufferLineClose 0<CR>", desc = "close current buffer", silent = true },
        { "<leader>bh", "<Cmd>BufferLineCyclePrev<CR>", desc = "prev buffer", silent = true },
        { "<leader>bl", "<Cmd>BufferLineCycleNext<CR>", desc = "next buffer", silent = true },
        { "<leader>bo", "<Cmd>BufferLineCloseOthers<CR>", desc = "close others", silent = true },
        { "<leader>bp", "<Cmd>BufferLinePick<CR>", desc = "pick buffer", silent = true },
        { "<leader>bm", "<Cmd>IceRepeat BufferLineMoveNext<CR>", desc = "move right", silent = true },
        { "<leader>bM", "<Cmd>IceRepeat BufferLineMovePrev<CR>", desc = "move left", silent = true },
    },
}

config.dashboard = {
    "nvimdev/dashboard-nvim",
    event = "User cynricAfter colorscheme",
    opts = {
        theme = "doom",
        config = {
            -- https://patorjk.com/software/taag/#p=display&f=ANSI%20Shadow&t=icenvim
            header = {
                " ",
                "██╗ ██████╗███████╗███╗   ██╗██╗   ██╗██╗███╗   ███╗",
                "██║██╔════╝██╔════╝████╗  ██║██║   ██║██║████╗ ████║",
                "██║██║     █████╗  ██╔██╗ ██║██║   ██║██║██╔████╔██║",
                "██║██║     ██╔══╝  ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║",
                "██║╚██████╗███████╗██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║",
                "╚═╝ ╚═════╝╚══════╝╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═",
                " ",
                string.format("                      %s                       ", require("core.utils").version),
                " ",
            },
            center = {
                {
                    icon = "  ",
                    desc = "Lazy Profile",
                    action = "Lazy profile",
                },
                {
                    icon = "  ",
                    desc = "Edit preferences   ",
                    action = string.format("edit %s/lua/custom/init.lua", config_root),
                },
                {
                    icon = "  ",
                    desc = "Mason",
                    action = "Mason",
                },
                {
                    icon = "  ",
                    desc = "About IceNvim",
                    action = "IceAbout",
                },
            },
            footer = { "🧊 Hope that you enjoy using IceNvim 😀😀😀" },
        },
    },
    config = function(_, opts)
        require("dashboard").setup(opts)

        if vim.api.nvim_buf_get_name(0) == "" then
            vim.cmd "Dashboard"
        end

        -- Use the highlight command to replace instead of overriding the original highlight group
        -- Much more convenient than using vim.api.nvim_set_hl()
        vim.cmd "highlight DashboardFooter cterm=NONE gui=NONE"
    end,
}

config["indent-blankline"] = {
    "lukas-reineke/indent-blankline.nvim",
    event = "User cynricAfter nvim-treesitter",
    main = "ibl",
    opts = {
        exclude = {
            filetypes = { "dashboard", "terminal", "help", "log", "markdown", "TelescopePrompt" },
        },
        indent = {
            highlight = {
                "IblIndent",
                "RainbowDelimiterRed",
                "RainbowDelimiterYellow",
                "RainbowDelimiterBlue",
                "RainbowDelimiterOrange",
                "RainbowDelimiterGreen",
                "RainbowDelimiterViolet",
                "RainbowDelimiterCyan",
            },
        },
    },
}

config.lualine = {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "User cynricLoad",
    main = "lualine",
    opts = {
        options = {
            theme = "auto",
            component_separators = { left = "", right = "" },
            section_separators = { left = "", right = "" },
            disabled_filetypes = { "undotree", "diff" },
        },
        extensions = { "nvim-tree" },
        sections = {
            lualine_b = { "branch", "diff" },
            lualine_c = {
                "filename",
            },
            lualine_x = {
                "filesize",
                {
                    "fileformat",
                    symbols = { unix = symbols.Unix, dos = symbols.Dos, mac = symbols.Mac },
                },
                "encoding",
                "filetype",
            },
        },
    },
}

config["markdown-preview"] = {
    "iamcco/markdown-preview.nvim",
    ft = "markdown",
    config = function()
        vim.g.mkdp_filetypes = { "markdown" }
        vim.g.mkdp_auto_close = 0
    end,
    build = "cd app && yarn install",
    keys = {
        {
            "<A-b>",
            "<Cmd>MarkdownPreviewToggle<CR>",
            desc = "markdown preview",
            ft = "markdown",
            silent = true,
        },
    },
}

config["nvim-autopairs"] = {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    main = "nvim-autopairs",
    opts = {},
}


config["nvim-tree"] = {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
        on_attach = function(bufnr)
            local api = require "nvim-tree.api"
            local opt = { buffer = bufnr, silent = true }

            api.config.mappings.default_on_attach(bufnr)

            require("core.utils").group_map({
                edit = {
                    "n",
                    "<CR>",
                    function()
                        local node = api.tree.get_node_under_cursor()
                        if node.name ~= ".." and node.fs_stat.type == "file" then
                            -- Taken partially from:
                            -- https://support.microsoft.com/en-us/windows/common-file-name-extensions-in-windows-da4a4430-8e76-89c5-59f7-1cdbbc75cb01
                            --
                            -- Not all are included for speed's sake
                            -- stylua: ignore start
                            local extensions_opened_externally = {
                                "avi", "bmp", "doc", "docx", "exe", "flv", "gif", "jpg", "jpeg", "m4a", "mov", "mp3",
                                "mp4", "mpeg", "mpg", "pdf", "png", "ppt", "pptx", "psd", "pub", "rar", "rtf", "tif",
                                "tiff", "wav", "xls", "xlsx", "zip",
                            }
                            -- stylua: ignore end
                            if table.find(extensions_opened_externally, node.extension) then
                                api.node.run.system()
                                return
                            end
                        end

                        api.node.open.edit()
                    end,
                },
                vertical_split = { "n", "V", api.node.open.vertical },
                horizontal_split = { "n", "H", api.node.open.horizontal },
                toggle_hidden_file = { "n", ".", api.tree.toggle_hidden_filter },
                reload = { "n", "<F5>", api.tree.reload },
                create = { "n", "a", api.fs.create },
                remove = { "n", "d", api.fs.remove },
                rename = { "n", "r", api.fs.rename },
                cut = { "n", "x", api.fs.cut },
                copy = { "n", "y", api.fs.copy.node },
                paste = { "n", "p", api.fs.paste },
                system_run = { "n", "s", api.node.run.system },
                show_info = { "n", "i", api.node.show_info_popup },
            }, opt)
        end,
        git = {
            enable = false,
        },
        update_focused_file = {
            enable = true,
        },
        filters = {
            dotfiles = false,
            custom = { "node_modules", "^.git$" },
            exclude = { ".gitignore" },
        },
        respect_buf_cwd = true,
        view = {
            width = 30,
            side = "left",
            number = false,
            relativenumber = false,
            signcolumn = "yes",
        },
        actions = {
            open_file = {
                resize_window = true,
                quit_on_open = true,
            },
        },
    },
    keys = {
        { "<leader>uf", "<Cmd>NvimTreeToggle<CR>", desc = "toggle nvim tree", silent = true },
    },
}

config["nvim-treesitter"] = {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = { "hiphish/rainbow-delimiters.nvim" },
    event = "User IceAfter colorscheme",
    branch = "main",
    opts = {
        -- Preserved for compatibility concerns
        -- stylua: ignore start
        ensure_installed = {
            "bash", "c", "c_sharp", "cpp", "css", "go", "html", "javascript", "json", "lua", "markdown",
            "markdown_inline", "python", "query", "rust", "toml", "typescript", "typst", "tsx", "vim", "vimdoc",
        },
        -- stylua: ignore end
    },
    config = function(_, opts)
        local nvim_treesitter = require "nvim-treesitter"
        nvim_treesitter.setup()

        local pattern = {}
        for _, parser in ipairs(opts.ensure_installed) do
            local has_parser, _ = pcall(vim.treesitter.language.inspect, parser)

            if not has_parser then
                -- Needs restart to take effect
                nvim_treesitter.install(parser)
            else
                vim.list_extend(pattern, vim.treesitter.language.get_filetypes(parser))
            end
        end

        local group = vim.api.nvim_create_augroup("NvimTreesitterFt", { clear = true })
        vim.api.nvim_create_autocmd("FileType", {
            group = group,
            pattern = pattern,
            callback = function(ev)
                local max_filesize = 100 * 1024
                local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(ev.buf))
                if not (ok and stats and stats.size > max_filesize) then
                    vim.treesitter.start()
                    if vim.bo.filetype ~= "dart" then
                        -- Conflicts with flutter-tools.nvim, causing performance issues
                        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end
            end,
        })

        local rainbow_delimiters = require "rainbow-delimiters"

        vim.g.rainbow_delimiters = {
            strategy = {
                [""] = rainbow_delimiters.strategy["global"],
                vim = rainbow_delimiters.strategy["local"],
            },
            query = {
                [""] = "rainbow-delimiters",
                lua = "rainbow-blocks",
            },
            highlight = {
                "RainbowDelimiterRed",
                "RainbowDelimiterYellow",
                "RainbowDelimiterBlue",
                "RainbowDelimiterOrange",
                "RainbowDelimiterGreen",
                "RainbowDelimiterViolet",
                "RainbowDelimiterCyan",
            },
        }
        rainbow_delimiters.enable()

        -- In markdown files, the rendered output would only display the correct highlight if the code is set to scheme
        -- However, this would result in incorrect highlight in neovim
        -- Therefore, the scheme language should be linked to query
        vim.treesitter.language.register("query", "scheme")

        vim.api.nvim_exec_autocmds("User", { pattern = "cynricAfter nvim-treesitter" })
        vim.api.nvim_exec_autocmds("FileType", { group = "NvimTreesitterFt" })
    end,
}

config.telescope = {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && "
                .. "cmake --build build --config Release && "
                .. "cmake --install build --prefix build",
        },
    },
    -- ensure that other plugins that use telescope can function properly
    cmd = "Telescope",
    opts = {
        defaults = {
            initial_mode = "insert",
            mappings = {
                i = {
                    ["<C-j>"] = "move_selection_next",
                    ["<C-k>"] = "move_selection_previous",
                    ["<C-n>"] = "cycle_history_next",
                    ["<C-p>"] = "cycle_history_prev",
                    ["<C-c>"] = "close",
                    ["<C-u>"] = "preview_scrolling_up",
                    ["<C-d>"] = "preview_scrolling_down",
                },
            },
        },
        pickers = {
            find_files = {
                winblend = 20,
            },
        },
        extensions = {
            fzf = {
                fuzzy = true,
                override_generic_sorter = true,
                override_file_sorter = true,
                case_mode = "smart_case",
            },
        },
    },
    config = function(_, opts)
        local telescope = require "telescope"
        telescope.setup(opts)
        telescope.load_extension "fzf"
    end,
    keys = {
        { "<leader>tf", "<Cmd>Telescope find_files<CR>", desc = "find file", silent = true },
        { "<leader>t<C-f>", "<Cmd>Telescope live_grep<CR>", desc = "live grep", silent = true },
    },
}

-- Colorschemes
config["github"] = { "projekt0n/github-nvim-theme", lazy = true }
config["gruvbox"] = { "ellisonleao/gruvbox.nvim", lazy = true }
config["kanagawa"] = { "rebelot/kanagawa.nvim", lazy = true }
config["miasma"] = { "xero/miasma.nvim", lazy = true }
config["nightfox"] = { "EdenEast/nightfox.nvim", lazy = true }
config["tokyonight"] = { "folke/tokyonight.nvim", lazy = true }

cynric.plugins = config
