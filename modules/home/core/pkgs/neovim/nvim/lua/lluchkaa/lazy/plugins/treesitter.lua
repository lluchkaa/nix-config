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
      -- lua is bundled in neovim 0.12 but nvim-treesitter's queries override the bundled ones;
      -- install via nvim-treesitter to keep parser and queries in sync
      require("nvim-treesitter").install({
        "javascript", "typescript", "tsx",
        "go",
        "rust",
        "lua",
        "nix",
        "yaml", "json", "toml",
      })

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter-features", { clear = true }),
        callback = function()
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
