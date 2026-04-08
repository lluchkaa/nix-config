return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      -- eagerly install parsers for languages used daily so they're ready on first open
      require("nvim-treesitter").install({
        "lua",
        "javascript",
        "typescript",
        "tsx",
        "go",
        "rust",
        "python",
        "nix",
        "yaml",
        "json",
        "toml",
        "c",
        "zig",
      })

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter-features", { clear = true }),
        callback = function(args)
          -- auto-install parser for any other filetype on first open
          local lang = vim.treesitter.language.get_lang(args.match)
          local l = lang and lang:lower()
          local skip = l and (l == "oil" or l:find("telescope") or l:find("sidekick"))
          if lang and not skip then require("nvim-treesitter").install({ lang }) end

          local ok = pcall(vim.treesitter.start)
          if not ok then return end
          vim.wo[0][0].foldmethod = "expr"
          vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
          vim.wo[0][0].foldtext = "v:lua.vim.treesitter.foldtext()"
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    opts = { multiwindow = true, max_lines = 8 },
  },
}
