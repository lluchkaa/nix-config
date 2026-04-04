return {
  {
    "laytan/cloak.nvim",
    enabled = false,
    opts = {
      patterns = {
        {
          file_pattern = { ".env", ".env.*" },
          cloak_pattern = "=.*",
          replace = nil,
        },
      },
    },
  },
}
