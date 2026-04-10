return {
  {
    "echasnovski/mini.icons",
    lazy = false,
    opts = {},
    init = function() require("mini.icons").mock_nvim_web_devicons() end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = true,
      integrations = {
        blink_cmp = true,
        gitsigns = true,
        harpoon = true,
        octo = true,
        mason = true,
        lsp_trouble = true,
        which_key = true,
        telescope = {
          enabled = true,
          style = "classic",
        },
      },
    },
    init = function() vim.cmd.colorscheme("catppuccin-nvim") end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "catppuccin" },
    event = "VeryLazy",
    config = function()
      local lualine = require("lualine")
      local palette = require("catppuccin.palettes").get_palette("mocha")
      local options = require("catppuccin").options

      local bg = options.transparent_background and "transparent" or palette.mantle
      local colors = {
        bg = bg,
        fg = palette.text,
        yellow = palette.yellow,
        cyan = palette.teal,
        darkblue = palette.blue,
        green = palette.green,
        orange = palette.peach,
        violet = palette.mauve,
        magenta = palette.pink,
        blue = palette.sky,
        red = palette.red,
      }

      local mode_color = {
        n = colors.red,
        i = colors.green,
        v = colors.blue,
        [""] = colors.red,
        V = colors.blue,
        c = colors.magenta,
        no = colors.red,
        s = colors.orange,
        S = colors.orange,
        ic = colors.yellow,
        R = colors.violet,
        Rv = colors.violet,
        cv = colors.red,
        ce = colors.red,
        r = colors.cyan,
        rm = colors.cyan,
        ["r?"] = colors.cyan,
        ["!"] = colors.red,
        t = colors.red,
      }

      local function mode_fg() return { fg = mode_color[vim.fn.mode()] } end
      local function buf_not_empty() return vim.fn.empty(vim.fn.expand("%:t")) ~= 1 end
      local function wide_enough() return vim.fn.winwidth(0) > 80 end

      local cfg = {
        options = {
          component_separators = "",
          section_separators = "",
          theme = {
            normal = { c = { fg = colors.fg, bg = colors.bg } },
            inactive = { c = { fg = colors.fg, bg = colors.bg } },
          },
        },
        sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_y = {},
          lualine_z = {},
          lualine_c = {},
          lualine_x = {},
        },
      }

      local function left(c) table.insert(cfg.sections.lualine_c, c) end
      local function right(c) table.insert(cfg.sections.lualine_x, c) end

      left({ function() return "▊" end, color = mode_fg, padding = { left = 0, right = 1 } })
      left({ function() return vim.fn.mode() end, fmt = string.upper, color = mode_fg, padding = { right = 1 } })
      left({ "filename", cond = buf_not_empty, color = { fg = colors.magenta, gui = "bold" } })
      left({ "branch", icon = "", color = { fg = colors.violet, gui = "bold" } })
      left({
        "diff",
        symbols = { added = " ", modified = "󰝤 ", removed = " " },
        diff_color = {
          added = { fg = colors.green },
          modified = { fg = colors.orange },
          removed = { fg = colors.red },
        },
        cond = wide_enough,
      })

      right({
        "diagnostics",
        sources = { "nvim_diagnostic" },
        symbols = { error = " ", warn = " ", info = " " },
        diagnostics_color = {
          error = { fg = colors.red },
          warn = { fg = colors.yellow },
          info = { fg = colors.cyan },
        },
      })
      right({ "filesize", cond = buf_not_empty })
      right({ "location" })
      right({ "progress", color = { fg = colors.fg, gui = "bold" } })
      right({ "o:encoding", fmt = string.upper, cond = wide_enough, color = { fg = colors.green, gui = "bold" } })
      right({ "fileformat", fmt = string.upper, icons_enabled = false, color = { fg = colors.green, gui = "bold" } })
      right({ function() return "▊" end, color = mode_fg, padding = { left = 1 } })

      lualine.setup(cfg)
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {},
  },
  {
    "Bekaboo/dropbar.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>;", function() require("dropbar.api").pick() end, desc = "Pick winbar symbol" },
      { "[;", function() require("dropbar.api").goto_context_start() end, desc = "Go to context start" },
      { "];", function() require("dropbar.api").select_next_context() end, desc = "Select next context" },
    },
  },
}
