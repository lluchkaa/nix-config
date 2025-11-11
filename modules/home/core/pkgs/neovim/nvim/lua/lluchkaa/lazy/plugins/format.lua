return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>f",
        function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
        mode = "",
        desc = "[F]ormat buffer",
      },
    },
    opts = {
      notify_on_error = true,
      formatters = {
        prettier = {
          args = function(self, ctx)
            local prettier_config = {
              ".prettierrc",
              ".prettierrc.json",
              ".prettierrc.yml",
              ".prettierrc.yaml",
              ".prettierrc.json5",
              ".prettierrc.js",
              ".prettierrc.cjs",
              ".prettierrc.mjs",
              ".prettierrc.toml",
              "prettier.config.js",
              "prettier.config.cjs",
              "prettier.config.mjs",
            }

            -- prettier file or package.json
            local check_cwd = require("conform.util").root_file({ table.unpack(prettier_config), "package.json" })

            local has_cwd = check_cwd(self, ctx) ~= nil

            if not has_cwd then
              -- find any of the files in the .ignore directory

              for _, file in ipairs(prettier_config) do
                local path = vim.fn.expand(vim.fs.joinpath(vim.fn.getcwd(), ".ignore", file))
                if vim.fn.filereadable(path) then
                  return {
                    "--stdin-filepath",
                    "$FILENAME",
                    "--config",
                    path,
                  }
                end
              end
            end

            return { "--stdin-filepath", "$FILENAME" }
          end,
        },
      },
      formatters_by_ft = {
        lua = { "stylua" },

        javascript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },

        html = { "prettierd", "prettier", stop_after_first = true },
        css = { "prettierd", "prettier", stop_after_first = true },

        go = { "gofmt", "gofumpt" },
        rust = { "rustfmt" },
        python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
        nix = { "nixfmt" },

        ["*"] = { "injected" },
        ["_"] = { "trim_whitespace" },
      },
      default_format_opts = {
        lsp_format = "fallback",
      },
    },
  },
}
