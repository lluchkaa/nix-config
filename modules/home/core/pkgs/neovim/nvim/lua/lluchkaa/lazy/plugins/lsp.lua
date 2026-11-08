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
          map("[d", function() vim.diagnostic.jump({ count = -1 }) end, "Previous [D]iagnostic")
          map("]d", function() vim.diagnostic.jump({ count = 1 }) end, "Next [D]iagnostic")

          local client = vim.lsp.get_client_by_id(event.data.client_id)

          -- cspell_ls: disable sign column icons (only keep underline/virtual text)
          if client and client.name == "cspell_ls" then
            vim.diagnostic.config({ signs = false, underline = false }, vim.lsp.diagnostic.get_namespace(client.id))
          end

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

      -- Each declaration owns both settings and installation. Nix packages are
      -- provided by this Neovim module's extraPackages; zls remains Mason-owned.
      local servers = {
        gopls = { owner = "mason", config = { filetypes = { "go", "gomod" } } },
        rust_analyzer = { owner = "mason", config = { filetypes = { "rust" } } },
        ts_ls = {
          owner = "mason",
          config = { filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" } },
        },
        html = { owner = "mason", config = { filetypes = { "html" } } },
        cssls = { owner = "mason", config = { filetypes = { "css", "scss", "less" } } },
        ruff = { owner = "mason", config = { filetypes = { "python" } } },
        pyright = { owner = "mason", config = { filetypes = { "python" } } },
        clangd = { owner = "mason", config = { filetypes = { "c", "cpp", "objc", "objcpp" } } },
        zls = { owner = "mason", config = { filetypes = { "zig", "zir" } } },
        nixd = { owner = "nix", config = { filetypes = { "nix" } } },
        cspell_ls = { owner = "mason", config = {} },
        lua_ls = {
          owner = "mason",
          config = {
            filetypes = { "lua" },
            settings = { Lua = { completion = { callSnippet = "Replace" } } },
          },
        },
      }

      local mason_servers, nix_servers = {}, {}
      -- Configure every server before either installer enables it.
      for name, server in pairs(servers) do
        local config = vim.tbl_deep_extend("force", {}, server.config, {
          capabilities = capabilities,
        })
        vim.lsp.config(name, config)
        if server.owner == "nix" then
          table.insert(nix_servers, name)
        else
          assert(server.owner == "mason", "Unknown LSP installer for " .. name)
          table.insert(mason_servers, name)
        end
      end
      table.sort(mason_servers)
      table.sort(nix_servers)
      for _, name in ipairs(nix_servers) do
        vim.lsp.enable(name)
      end

      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = mason_servers,
        -- Previously installed Mason copies must not also enable Nix servers.
        automatic_enable = { exclude = nix_servers },
      })
    end,
  },
}
