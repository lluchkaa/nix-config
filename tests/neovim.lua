-- Run the real plugin configuration without downloading plugins or servers.
local configured, enabled, mason_options = {}, {}, nil
local stage = "configure"
package.preload["blink.cmp"] = function()
  return { get_lsp_capabilities = function() return { test_completion = true } end }
end
package.preload["mason"] = function()
  return { setup = function() stage = "mason" end }
end
package.preload["mason-lspconfig"] = function()
  return {
    setup = function(options)
      assert(stage == "mason", "Mason must initialize before server installation")
      mason_options = options
    end,
  }
end
vim.lsp.config = function(name, config)
  assert(stage == "configure", "Configure servers before starting installers")
  configured[name] = config
end
vim.lsp.enable = function(name) enabled[name] = true end
local plugins = dofile(arg[1])
plugins[2].config()
assert(configured.nixd and configured.zls and configured.lua_ls)
assert(configured.lua_ls.settings.Lua.completion.callSnippet == "Replace")
assert(configured.gopls.capabilities.test_completion)
assert(enabled.nixd and not enabled.zls, "Only Nix-owned servers are enabled directly")
local selected = {}
for _, name in ipairs(mason_options.ensure_installed) do
  assert(not selected[name], "Duplicate Mason installation")
  assert(not enabled[name], "An installer must not claim another installer's server")
  selected[name] = true
end
assert(selected.zls and selected.gopls and not selected.nixd)
for name in pairs(configured) do
  assert(selected[name] or enabled[name], "Unowned server: " .. name)
end
assert(vim.deep_equal(mason_options.automatic_enable.exclude, { "nixd" }))
print("Neovim ownership checks passed")
