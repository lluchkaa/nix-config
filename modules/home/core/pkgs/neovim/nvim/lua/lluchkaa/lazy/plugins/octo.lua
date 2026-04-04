return {
  {
    "pwntester/octo.nvim",
    enabled = false,
    cmd = "Octo",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      picker = "telescope",
    },
  },
}
