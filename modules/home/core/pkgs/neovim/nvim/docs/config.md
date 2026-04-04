# Neovim Config — State & Decisions

Target: **Neovim 0.12**, macOS (nix-darwin / home-manager).

---

## Structure

```
lua/lluchkaa/
  core/
    constants.lua   — shared constants (tab_width = 2)
    set.lua         — options
    remap.lua       — global keymaps
    autocmd.lua     — global autocommands
    commands.lua    — user commands
    init.lua        — loads all core modules
  lazy/
    init.lua        — lazy.nvim bootstrap
    plugins/        — one file per concern
```

---

## Core Options (set.lua)

- Tab width: 2 (sourced from `constants.lua`)
- Folds: enabled, `foldlevel = 99` (all open by default), managed by treesitter via FileType autocmd
- Undo: persistent, stored at `stdpath("cache")/undo`
- Spell: enabled globally, disabled per-filetype in autocmd.lua
- Diagnostics: `virtual_text`, `severity_sort`, no update in insert mode
- Smooth scroll: enabled (`smoothscroll = true`)
- `splitkeep = "screen"` — cursor stays stable when opening splits

---

## Key Decisions

### LSP

- Uses **mason-org/mason.nvim** + **mason-org/mason-lspconfig.nvim** (repos moved from `williamboman/` in 2025)
- Migrated to **Neovim 0.11+ native LSP API**: `vim.lsp.config()` + `vim.lsp.enable()` — `lspconfig[server].setup{}` is deprecated
- mason-lspconfig v2 auto-enables installed servers; no `handlers` needed
- Capabilities provided by `blink.cmp.get_lsp_capabilities()`
- Built-in keymaps used (0.11+): `grn` (rename), `gra` (code action), `grr` (references), `gri` (implementation), `gO` (document symbols)
- Spell checking via `cspell_ls` (Mason: `:MasonInstall cspell-lsp`) — no plugin needed
- `stylua` must be installed manually: `:MasonInstall stylua`

### Completion (blink.cmp)

- Pinned to `version = "1.*"` — v2 is in development and will be breaking
- `auto_brackets` disabled — use `mini.pairs` when re-enabled instead of nvim-autopairs (no official blink integration)
- `path` source is built-in, no extra plugin needed
- `lazydev` provides Lua/Neovim API completions including `Snacks.*` globals

### Treesitter

- Uses **main branch** (`branch = "main"`) — master branch is frozen
- `require("nvim-treesitter").install({...})` is the new API (main branch only)
- `lazy = false` required — main branch does not support lazy loading
- Lua parser explicitly installed despite being bundled in Neovim — nvim-treesitter's queries override bundled ones; keeping them in sync prevents query errors
- Highlighting and folding set via `FileType` autocmd using `vim.treesitter.start()` and `vim.wo[0][0]`
- `tree-sitter` CLI required (in `pkgs.tree-sitter`) for compiling parsers

### Colorscheme (catppuccin)

- **Keep the plugin** — Neovim 0.12 bundles a minimal `catppuccin.vim` (Vimscript, 2 flavors only, no transparent bg, no Lua API, no integrations)
- Colorscheme name: `catppuccin-nvim` (not `catppuccin`) — avoids loading the built-in version
- `transparent_background = true`
- Integrations: blink_cmp, gitsigns, harpoon, octo (ready), mason, lsp_trouble, which_key, telescope

### File Explorer

- **fyler.nvim** active, **oil.nvim** disabled (kept for comparison)
- `-` opens fyler at current file's directory (oil parity)
- `default_explorer = true` replaces netrw natively
- `follow_current_file = true` — highlights current file on open
- Window picker: snacks

### Snacks.nvim

Enabled snacks: `bigfile`, `quickfile`, `image`, `lazygit`, `zen`, `gitbrowse`

- `image` — requires Ghostty (Kitty Graphics Protocol support)
- `zen` — no keymap by design; trigger via `:lua Snacks.zen()`
- `gitbrowse` replaces gitlinker (`<leader>gB`)
- `lazygit` float (`<leader>gg`)
- `scroll` was removed (user preference)

### Git

- gitsigns: unstaged signs (`┃`/`▼`/`▲`), staged signs (`▎`/`▾`/`▴`) — catppuccin colors them automatically
- `current_line_blame = true` always on
- fugitive lazy-loaded via `cmd = { "Git", "G" }`

### Winbar

- **dropbar.nvim** replaces archived barbecue (archived Jan 2025)
- No catppuccin integration — uses `DropBar*` highlight groups from base theme
- `lazy = false` not needed — auto-initializes via `plugin/dropbar.lua`

### Which-key Groups

| Prefix | Group |
|--------|-------|
| `<leader>a` | AI |
| `<leader>c` | Code |
| `<leader>d` | Document |
| `<leader>g` | Git |
| `<leader>h` | Harpoon |
| `<leader>r` | Rename |
| `<leader>s` | Search |
| `<leader>w` | Workspace |
| `<leader>x` | Diagnostics |

### Disabled Plugins (kept for reference)

| File | Plugin | Reason disabled |
|------|--------|-----------------|
| autopairs.lua | mini.pairs | blink.cmp auto_brackets conflict; re-enable together |
| cloak.lua | cloak.nvim | On-demand; enable when screen sharing .env files |
| octo.lua | octo.nvim | Ready to enable — just set `enabled = true` |
| dap.lua | nvim-dap | Enable when debugging needed |
| oil.nvim | oil.nvim | Testing fyler; swap back by toggling `enabled` |

---

## Important Notes

- **`<leader>d`** is visual-mode only for blackhole delete — normal mode would intercept `<leader>ds`, `<leader>D` etc.
- **`]h`/`[h`** navigate hunks (gitsigns) — these were conflicting with vim-unimpaired which was removed
- **Telescope** requires `plenary.nvim` as a dependency even on v0.2.x
- **mason** must be set up before mason-lspconfig in the config function (order matters)
- **sidekick.nvim NES** (Next Edit Suggestions) requires GitHub Copilot — Claude only works via the CLI integration (`<leader>ac`)
- **blink.cmp `<C-k>`** toggles documentation in insert mode — does not conflict with vim-tmux-navigator's `<C-k>` (normal mode only)
