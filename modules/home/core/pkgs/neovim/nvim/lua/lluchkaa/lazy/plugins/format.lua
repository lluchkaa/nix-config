return {
  {
    "stevearc/conform.nvim",
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>f",
        function() require("conform").format({ async = true }) end,
        mode = "",
        desc = "[F]ormat buffer",
      },
    },
    opts = {
      notify_on_error = true,
      default_format_opts = {
        lsp_format = "fallback",
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

        go = { "gofmt" },
        rust = { "rustfmt" },
        python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
        nix = { "nixfmt" },
        zig = { "zigfmt" },

        ["*"] = { "injected" },
        ["_"] = { "trim_whitespace" },
      },
    },
  },
}
