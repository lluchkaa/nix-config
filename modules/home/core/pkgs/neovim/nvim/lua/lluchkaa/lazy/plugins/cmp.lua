return {
  {
    "saghen/blink.cmp",
    dependencies = { "rafamadriz/friendly-snippets" },
    version = "1.*",

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = "default",
        ["<C-k>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-u>"] = { "scroll_documentation_up", "fallback" },
        ["<C-d>"] = { "scroll_documentation_down", "fallback" },
      },

      cmdline = {
        keymap = {
          preset = "default",
          ["<C-k>"] = { "show", "show_documentation", "hide_documentation" },
          ["<Tab>"] = { "show", "select_and_accept", "fallback" },
        },
      },

      completion = {
        accept = {
          auto_brackets = { enabled = false },
        },
        menu = {
          auto_show = function(ctx) return ctx.mode ~= "cmdline" end,
          draw = {
            columns = {
              { "label", "label_description", gap = 1 },
              { "kind", "source_name", gap = 1 },
            },
          },
        },
        documentation = { auto_show = true, auto_show_delay_ms = 500 },
      },

      sources = {
        default = { "lazydev", "lsp", "path", "snippets", "buffer" },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
        },
      },

      appearance = {
        nerd_font_variant = "mono",
      },

      signature = { enabled = true },
    },
    opts_extend = { "sources.default" },
  },
}
