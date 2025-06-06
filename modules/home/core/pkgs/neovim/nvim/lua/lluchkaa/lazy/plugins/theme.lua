return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = true,
      integrations = {
        blink_cmp = true,
        fidget = true,
        harpoon = true,
        mason = true,
        octo = true,
        lsp_trouble = true,
        which_key = true,
        telescope = {
          enabled = true,
          style = "nvchad",
        },
      },
    },
    init = function() vim.cmd.colorscheme("catppuccin") end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "catppuccin", "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    config = function()
      local lualine = require("lualine")
      local palette = require("catppuccin.palettes").get_palette("mocha")
      local options = require("catppuccin").options

      local colors = {
        bg = options.transparent_background and "transparent" or palette.mantle,
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

      local conditions = {
        buffer_not_empty = function() return vim.fn.empty(vim.fn.expand("%:t")) ~= 1 end,
        hide_in_width = function() return vim.fn.winwidth(0) > 80 end,
        check_git_workspace = function()
          local filepath = vim.fn.expand("%:p:h")
          local gitdir = vim.fn.finddir(".git", filepath .. ";")
          return gitdir and #gitdir > 0 and #gitdir < #filepath
        end,
      }

      -- Config
      local config = {
        options = {
          -- Disable sections and component separators
          component_separators = "",
          section_separators = "",
          theme = {
            -- We are going to use lualine_c an lualine_x as left and
            -- right section. Both are highlighted by c theme .  So we
            -- are just setting default looks o statusline
            normal = { c = { fg = colors.fg, bg = colors.bg } },
            inactive = { c = { fg = colors.fg, bg = colors.bg } },
          },
        },
        sections = {
          -- these are to remove the defaults
          lualine_a = {},
          lualine_b = {},
          lualine_y = {},
          lualine_z = {},
          -- These will be filled later
          lualine_c = {},
          lualine_x = {},
        },
        -- inactive_sections = {
        --   -- these are to remove the defaults
        --   lualine_a = {},
        --   lualine_b = {},
        --   lualine_y = {},
        --   lualine_z = {},
        --   lualine_c = {},
        --   lualine_x = {},
        -- },
      }

      local mode_color = {
        n = colors.red,
        i = colors.green,
        v = colors.blue,
        [""] = colors.blue,
        V = colors.blue,
        c = colors.magenta,
        no = colors.red,
        s = colors.orange,
        S = colors.orange,
        [""] = colors.orange,
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

      -- Inserts a component in lualine_c at left section
      local function ins_left(component) table.insert(config.sections.lualine_c, component) end

      -- Inserts a component in lualine_x at right section
      local function ins_right(component) table.insert(config.sections.lualine_x, component) end

      ins_left({
        function() return "▊" end,
        color = function()
          -- auto change color according to neovims mode
          return { fg = mode_color[vim.fn.mode()] }
        end,
        padding = { left = 0, right = 1 }, -- We don't need space before this
      })

      ins_left({
        -- mode component
        function() return vim.fn.mode() end,
        -- make sure there are 2 symbols and add space if necessary
        fmt = string.upper,
        color = function()
          -- auto change color according to neovims mode
          return { fg = mode_color[vim.fn.mode()] }
        end,
        padding = { right = 1 },
      })

      ins_left({
        "filename",
        cond = conditions.buffer_not_empty,
        color = { fg = colors.magenta, gui = "bold" },
      })

      ins_left({
        "branch",
        icon = "",
        color = { fg = colors.violet, gui = "bold" },
      })

      ins_left({
        "diff",
        -- Is it me or the symbol for modified us really weird
        symbols = { added = " ", modified = "󰝤 ", removed = " " },
        diff_color = {
          added = { fg = colors.green },
          modified = { fg = colors.orange },
          removed = { fg = colors.red },
        },
        cond = conditions.hide_in_width,
      })

      ins_right({
        "diagnostics",
        sources = { "nvim_diagnostic" },
        symbols = { error = " ", warn = " ", info = " " },
        diagnostics_color = {
          error = { fg = colors.red },
          warn = { fg = colors.yellow },
          info = { fg = colors.cyan },
        },
      })

      ins_right({
        -- filesize component
        "filesize",
        cond = conditions.buffer_not_empty,
      })

      ins_right({ "location" })

      ins_right({ "progress", color = { fg = colors.fg, gui = "bold" } })

      -- Add components to right sections
      ins_right({
        "o:encoding", -- option component same as &encoding in viml
        fmt = string.upper, -- I'm not sure why it's upper case either ;)
        cond = conditions.hide_in_width,
        color = { fg = colors.green, gui = "bold" },
      })

      ins_right({
        "fileformat",
        fmt = string.upper,
        icons_enabled = false, -- I think icons are cool but Eviline doesn't have them. sigh
        color = { fg = colors.green, gui = "bold" },
      })

      ins_right({
        function() return "▊" end,
        color = function()
          -- auto change color according to neovims mode
          return { fg = mode_color[vim.fn.mode()] }
        end,
        padding = { left = 1 },
      })

      -- Now don't forget to initialize lualine
      lualine.setup(config)
    end,
  },
  {
    "folke/todo-comments.nvim",
    event = "VimEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {},
  },
  {
    "utilyre/barbecue.nvim",
    name = "barbecue",
    version = "*",
    dependencies = {
      "SmiteshP/nvim-navic",
      -- "nvim-tree/nvim-web-devicons", -- optional dependency
    },
    opts = {
      theme = "catppuccin",
    },
  },
}
