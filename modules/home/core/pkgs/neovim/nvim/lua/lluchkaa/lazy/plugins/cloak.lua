return {
  {
    "laytan/cloak.nvim",
    enabled = false,
    opts = {
      enabled = false,
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
