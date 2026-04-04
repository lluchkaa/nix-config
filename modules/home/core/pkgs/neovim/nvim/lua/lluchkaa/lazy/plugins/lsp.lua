return {
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "snacks.nvim", words = { "Snacks" } },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "mason-org/mason.nvim", config = true },
      "mason-org/mason-lspconfig.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          -- Telescope pickers (no built-in equivalent)
          map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
          map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
          map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
          map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

          -- grn, gra, grr, gri, gO are built-in since 0.11
          map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

          -- Diagnostics
          map("<leader>xe", vim.diagnostic.open_float, "Show [E]rror float")
          map("[d", vim.diagnostic.goto_prev, "Previous [D]iagnostic")
          map("]d", vim.diagnostic.goto_next, "Next [D]iagnostic")

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = event2.buf })
              end,
            })
          end

          if client and client.server_capabilities.inlayHintProvider then
            map(
              "<leader>th",
              function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })) end,
              "[T]oggle Inlay [H]ints"
            )
          end
        end,
      })

      local capabilities = require("blink.cmp").get_lsp_capabilities()

      local servers = {
        gopls = { filetypes = { "go", "gomod" } },
        rust_analyzer = { filetypes = { "rust" } },
        ts_ls = { filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" } },
        html = { filetypes = { "html" } },
        ruff = { filetypes = { "python" } },
        pyright = { filetypes = { "python" } },

        cspell_ls = {},

        lua_ls = {
          filetypes = { "lua" },
          settings = {
            Lua = {
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        },
      }

      -- Configure each server before mason-lspconfig enables them
      for server_name, config in pairs(servers) do
        config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, config.capabilities or {})
        vim.lsp.config(server_name, config)
      end

      require("mason").setup()

      -- stylua must be installed manually: :MasonInstall stylua
      -- mason-lspconfig v2 auto-enables installed servers via vim.lsp.enable()
      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(servers),
      })
    end,
  },
}
