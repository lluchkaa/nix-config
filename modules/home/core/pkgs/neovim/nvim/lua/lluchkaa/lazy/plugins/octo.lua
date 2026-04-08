return {
  {
    "pwntester/octo.nvim",
    commit = "5425da2", -- pin before folds bug (efc48d4), no upstream fix yet
    enabled = true,
    cmd = "Octo",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      picker = "telescope",
      enable_builtin = true,
    },
  },
}
