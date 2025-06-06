local symbols = cynric.symbols

cynric.plugins["flutter-tools"] = {
    "akinsho/flutter-tools.nvim",
    ft = "dart",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "stevearc/dressing.nvim",
    },
    main = "flutter-tools",
    opts = {
        ui = {
            border = "rounded",
        },
        decorations = {
            statusline = {
                app_version = true,
                device = true,
            },
        },
    },
    enabled = function()
        return cynric.lsp.flutter.enabled == true
    end,
}

cynric.plugins.rustaceanvim = {
    "mrcjkb/rustaceanvim",
    ft = "rust",
    enabled = function()
        return cynric.lsp.rust.enabled == true
    end,
}

cynric.plugins["typst-preview"] = {
    "chomosuke/typst-preview.nvim",
    ft = "typst",
    build = function()
        require("typst-preview").update()
    end,
    opts = {},
    keys = {
        { "<A-b>", "<Cmd>TypstPreviewToggle<CR>", desc = "typst preview toggle", ft = "typst", silent = true },
    },
    enabled = function()
        return cynric.lsp.tinymist.enabled == true
    end,
}

cynric.plugins.mason = {
    "mason-org/mason.nvim",
    dependencies = {
        "neovim/nvim-lspconfig",
        "mason-org/mason-lspconfig.nvim",
    },
    event = "User cynricLoad",
    cmd = "Mason",
    opts = {
        ui = {
            icons = {
                package_installed = symbols.Affirmative,
                package_pending = symbols.Pending,
                package_uninstalled = symbols.Negative,
            },
        },
    },
    config = function(_, opts)
        require("mason").setup(opts)

        local registry = require "mason-registry"
        local function install(package)
            local s, p = pcall(registry.get_package, package)
            if s and not p:is_installed() then
                p:install()
            end
        end

        local lspconfig = require "lspconfig"
        local mason_lspconfig_mapping = require("mason-lspconfig").get_mappings().package_to_lspconfig

        local installed_packages = registry.get_installed_package_names()

        for lsp, config in pairs(cynric.lsp) do
            if not config.enabled then
                goto continue
            end

            local formatter = config.formatter
            install(lsp)
            install(formatter)

            if not vim.tbl_contains(installed_packages, lsp) then
                goto continue
            end

            lsp = mason_lspconfig_mapping[lsp]
            if not config.managed_by_plugin and lspconfig[lsp] ~= nil then
                local setup = config.setup
                if type(setup) == "function" then
                    setup = setup()
                elseif setup == nil then
                    setup = {}
                end

                local blink_capabilities = require("blink.cmp").get_lsp_capabilities()
                blink_capabilities.textDocument.foldingRange = {
                    dynamicRegistration = false,
                    lineFoldingOnly = true,
                }
                setup = vim.tbl_deep_extend("force", setup, {
                    capabilities = blink_capabilities,
                })

                lspconfig[lsp].setup(setup)
            end
            ::continue::
        end

        vim.diagnostic.config {
            update_in_insert = true,
            severity_sort = true, -- necessary for lspsaga's show_line_diagnostics to work
            virtual_text = true,
        }
        local signs = {
            Error = symbols.Error,
            Warn = symbols.Warn,
            Hint = symbols.Hint,
            Info = symbols.Info,
        }
        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
        end

        vim.lsp.inlay_hint.enable()

        vim.cmd "LspStart"
    end,
}
