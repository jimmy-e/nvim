# Neovim Config

Personal Neovim config. Lua-based, managed via [lazy.nvim](https://github.com/folke/lazy.nvim).
Plugin modules live in `lua/plugins/`, loaded and registered in `lua/plugins/init.lua`.

## Structure

| File/Dir | Purpose |
|---|---|
| `init.lua` | Entry point — loads options, keymaps, plugins, LSP, env-manager |
| `lua/options.lua` | Editor settings, folding, auto-save, visual options |
| `lua/keymaps.lua` | All keymaps (leader = `<Space>`) |
| `lua/lsp.lua` | LSP configuration |
| `lua/plugins/` | One file per plugin group (see below) |
| `lua/plugins/init.lua` | Bootstraps lazy.nvim, aggregates all plugin modules |

## Plugin Modules

| Module | Plugins |
|---|---|
| `ui.lua` | TokyoNight, Nightfox, lualine, nvim-web-devicons |
| `treesitter.lua` | nvim-treesitter, rainbow-delimiters, indent-blankline, treesitter-context, vim-illuminate, todo-comments, nvim-colorizer |
| `navigation.lua` | Telescope, nvim-tree |
| `git/plugins.lua` | Neogit, gitsigns |
| `lsp.lua` | nvim-lspconfig |
| `mason.lua` | mason, mason-lspconfig |
| `completion.lua` | nvim-cmp, LuaSnip |
| `formatting.lua` | conform.nvim |
| `ai.lua` | claude-code.nvim |
| `debugger.lua` | nvim-dap, nvim-dap-ui |
| `testing.lua` | neotest |
| `harpoon.lua` | harpoon2 |
| `undotree.lua` | undotree |
| `zen.lua` | zen-mode.nvim |
| `markdown.lua` | render-markdown or similar |
| `csv.lua` / `csvview.lua` | CSV viewing |
| `popnav.lua` | Custom popup navigation |

## Theme

Active theme is set at the top of `lua/plugins/ui.lua`:
```lua
local ACTIVE_THEME = "tokyonight-night"
```
Options: `tokyonight-night`, `tokyonight-storm`, `tokyonight-moon`, `tokyonight-day`, `nightfox`, `duskfox`, `carbonfox`.

Treesitter capture groups and LSP semantic tokens are all custom-colored in `ui.lua`'s `on_highlights` callback.

## Key Keymaps (leader = `<Space>`)

| Keymap | Action |
|---|---|
| `<leader>e` | Toggle file tree (nvim-tree) |
| `<leader>ff` | Find files (Telescope) |
| `<leader>fg` | Live grep (Telescope) |
| `<leader>fb` | Buffers (Telescope) |
| `<leader>gs` | Neogit status |
| `<leader>\` | Toggle floating terminal |
| `<leader>w` / `<leader>q` | Save / Quit |
| `<leader>ta` | Toggle auto-save |
| `<leader>at` | Toggle Claude Code (session picker on first open) |
| `<leader>aa` | Send visual selection to Claude |
| `<leader>ab` | Add current file to Claude context |
| `<leader>dc/dn/di/do/db` | DAP: continue/step over/into/out/breakpoint |
| `<leader>du` | DAP UI toggle |
| `<leader>df` | Debug FastAPI via AWS profile picker |
| `<leader>z` | Zen mode |
| `<leader>mp` | Markdown preview popup |
| `<leader>cv` | CSV table view toggle |
| `<leader>sr` | SSH remote host picker |
| `<leader>?` | Cheat sheet |
| `<leader><up/down>` | Collapse / expand all folds |
| `<leader>j/k` | Move line/selection down/up |
| `<leader>J/K` | Jump 20 lines down/up |

## Treesitter

Configured in `lua/plugins/treesitter.lua`. Uses the new nvim-treesitter v1 API (`require("nvim-treesitter").install(...)`).

Highlighting is enabled by default for all filetypes via a `BufReadPost *` autocmd using `pcall(vim.treesitter.start)` — silently skips filetypes without an installed parser.

Diagnostic command: `:TSStatus` — reports filetype, parser status, and highlighter status for the current buffer.

Debug keymaps: `<leader>th` (test highlights), `<leader>tf` (force refresh), `<leader>tc` (check active highlighter).

## File Tree (nvim-tree)

nvim-tree opens automatically on `VimEnter` via an autocmd in `lua/plugins/navigation.lua`. It opens without stealing focus (`focus = false`) and highlights the current file if one was passed (`find_file = true`). The autocmd skips special buffers (diffs, fugitive, etc.) — only triggers for real files or a bare `nvim` launch.

Toggle manually with `<leader>e` or `Cmd+1`.

**iTerm2 Cmd+1 setup:** iTerm2 intercepts `Cmd+1` natively, so it must be remapped to forward to neovim. In iTerm2 → Settings → Profiles → Keys → Key Mappings → `+`: set shortcut `Cmd+1`, action `Send Escape Sequence`, value `[57P`. Neovim then binds `\x1b[57P` to `:NvimTreeToggle`.

## Notes & Decisions

- **Auto-save** is on by default (1s inactivity). Toggle with `<leader>ta`.
- **Folding** uses `foldmethod=indent` with all folds open by default (`foldlevel=99`).
- **Clipboard** is synced with system clipboard (`unnamedplus`).
- Invisible characters are shown (`tab`, `trail`, `nbsp`).
- Claude Code sessions: first `<leader>at` shows a picker (new/continue/resume); subsequent toggles skip the picker until `<leader>as` resets it.
