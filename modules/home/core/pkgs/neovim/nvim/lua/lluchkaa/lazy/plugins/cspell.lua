return {
  "nvimtools/none-ls.nvim",
  -- deprecate, use lsp-config with cspell_ls
  enabled = false,
  dependencies = {
    "davidmh/cspell.nvim",
  },
  config = function()
    local cspell = require("cspell")
    local null_ls = require("null-ls")

    null_ls.setup({
      sources = {
        cspell.diagnostics.with({
          method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
          diagnostics_postprocess = function(diagnostic) diagnostic.severity = vim.diagnostic.severity.HINT end,
        }),
      },
    })
  end,
}
