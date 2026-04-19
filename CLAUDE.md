# Neovim Config

Personal Neovim config. Lua-based, managed via [lazy.nvim](https://github.com/folke/lazy.nvim).
Plugin modules live in `lua/plugins/`, loaded and aggregated in `lua/plugins/init.lua`.

Neovim version: **0.12.1** (important — some APIs behave differently, see Notes).

---

## File Structure

| File/Dir | Purpose |
|---|---|
| `init.lua` | Entry point — loads options, keymaps, plugins, LSP, env-manager |
| `lua/options.lua` | Editor settings (indentation, folding, auto-save, visuals) |
| `lua/keymaps.lua` | All global keymaps (leader = `<Space>`) |
| `lua/lsp.lua` | Native Neovim 0.11+ LSP config (`vim.lsp.config` / `vim.lsp.enable`) |
| `lua/env-manager.lua` | Auto-loads `.env` on startup; floating editor to edit env vars |
| `lua/floating_terminal.lua` | Persistent floating terminal implementation |
| `lua/cheatsheet.lua` | Floating cheatsheet popup |
| `lua/markdown_preview.lua` | Markdown preview in a floating popup |
| `lua/plugins/` | One file per plugin group |
| `lua/plugins/init.lua` | Bootstraps lazy.nvim, aggregates all plugin modules |
| `lua/debug/fastapi_aws.lua` | FastAPI + debugpy + AWS SSO debug workflow |
| `lua/ssh_remote/` | SSH session manager (Telescope picker + floating terminal) |
| `lua/plugins/git/menu.lua` | GitLens-style git action popup |

---

## All Plugins

### UI (`lua/plugins/ui.lua`)
| Plugin | Purpose |
|---|---|
| `folke/tokyonight.nvim` | Primary colorscheme family |
| `EdenEast/nightfox.nvim` | Alternate colorscheme family |
| `nvim-lualine/lualine.nvim` | Statusline |
| `nvim-tree/nvim-web-devicons` | File icons (dependency for many plugins) |

### Treesitter (`lua/plugins/treesitter.lua`)
| Plugin | Purpose |
|---|---|
| `nvim-treesitter/nvim-treesitter` | Syntax highlighting (v1 API) |
| `HiPhish/rainbow-delimiters.nvim` | Rainbow bracket coloring |
| `lukas-reineke/indent-blankline.nvim` | Indent guides |
| `nvim-treesitter/nvim-treesitter-context` | Shows current function/class at top of screen |
| `RRethy/vim-illuminate` | Highlights all references to symbol under cursor |
| `folke/todo-comments.nvim` | Colorful TODO/FIXME/NOTE/HACK/WARN markers |
| `norcalli/nvim-colorizer.lua` | Inline color swatches for hex/rgb/css values |

**Installed parsers:** python, lua, vim, vimdoc, json, markdown, markdown_inline, bash, typescript, tsx, javascript, html, css, yaml, toml, sql, dockerfile, regex, comment.

### Navigation (`lua/plugins/navigation.lua`)
| Plugin | Purpose |
|---|---|
| `nvim-tree/nvim-tree.lua` | File tree (auto-opens on VimEnter, width=35) |
| `nvim-telescope/telescope.nvim` | Fuzzy finder (files, grep, buffers, LSP refs) |

### Git (`lua/plugins/git/plugins.lua`)
| Plugin | Purpose |
|---|---|
| `lewis6991/gitsigns.nvim` | Inline git hunks, blame, diff signs in gutter |
| `NeogitOrg/neogit` | Full git UI (VSCode-style vsplit) |
| `sindrets/diffview.nvim` | Diff viewer + file history (neogit dependency) |

### LSP
| Plugin | Purpose |
|---|---|
| `neovim/nvim-lspconfig` | LSP config helpers (used alongside native API) |
| `williamboman/mason.nvim` | LSP/DAP/linter installer |
| `williamboman/mason-registry` | Mason package registry |

**Auto-installed via Mason on first launch:** pyright, typescript-language-server, lua-language-server, yaml-language-server, debugpy.

**Configured language servers** (native `vim.lsp.config` in `lua/lsp.lua`):
- `pyright` — Python (type checking: basic, openFilesOnly; auto-detects `.venv`)
- `ts_ls` — TypeScript/JavaScript
- `lua_ls` — Lua (configured for Neovim's LuaJIT runtime)
- `yamlls` — YAML

### Completion (`lua/plugins/completion.lua`)
| Plugin | Purpose |
|---|---|
| `hrsh7th/nvim-cmp` | Completion engine |
| `L3MON4D3/LuaSnip` | Snippet engine |
| `hrsh7th/cmp-nvim-lsp` | LSP completion source |
| `hrsh7th/cmp-path` | Filepath completion source |
| `hrsh7th/cmp-buffer` | Buffer word completion source |
| `zbirenbaum/copilot.lua` | GitHub Copilot (suggestions routed through cmp) |
| `zbirenbaum/copilot-cmp` | Copilot as nvim-cmp source (`[AI]`) |

**Completion source priority:** Copilot (1000) > LSP (750) > Path (500) > Buffer (250).
**Keymaps:** `<CR>` or `<Tab>` to confirm, `<S-Tab>` for previous, `<C-Space>` to trigger, `<C-e>` to abort.

### Formatting (`lua/plugins/formatting.lua`)
| Plugin | Purpose |
|---|---|
| `stevearc/conform.nvim` | Format on save |

**Formatters:**
- Python → `black` (via `~/.pyenv/versions/3.13.3/bin/black`, bypasses pyenv shim)
- JS/TS/JSON/YAML/Markdown → `prettier`

Format runs on `BufWritePre` with 5s timeout, LSP fallback enabled.

### AI (`lua/plugins/ai.lua`)
| Plugin | Purpose |
|---|---|
| `coder/claudecode.nvim` | Claude Code integration |
| `folke/snacks.nvim` | Terminal provider for Claude Code |

Claude runs as: `/opt/homebrew/bin/claude --model claude-opus-4-6`
Terminal: floating window, 85% width × 80% height, rounded border.

### Debugger (`lua/plugins/debugger.lua`)
| Plugin | Purpose |
|---|---|
| `mfussenegger/nvim-dap` | Debug Adapter Protocol core |
| `rcarriga/nvim-dap-ui` | DAP UI panels (auto-opens/closes with debug session) |
| `mfussenegger/nvim-dap-python` | Python DAP adapter (uses Mason's debugpy) |
| `nvim-neotest/nvim-nio` | Async I/O (dap-ui dependency) |

**Python DAP configs:**
- `Debug: Current File` — launches `${file}` with debugpy
- `FastAPI (uvicorn: app:fast_app --reload)` — launches uvicorn module

**FastAPI debug workflow** (`<leader>df`): Telescope picks an AWS profile → runs `ae <profile>`, `start`, then `python -Xfrozen_modules=off -m debugpy --listen 5678 --wait-for-client -m uvicorn app:fast_app --port 8000` in a persistent bottom terminal → auto-attaches DAP after 5s.

### Testing (`lua/plugins/testing.lua`)
| Plugin | Purpose |
|---|---|
| `nvim-neotest/neotest` | Test runner framework |
| `nvim-neotest/neotest-python` | pytest adapter (uses `.venv/bin/python` if present) |
| `nvim-neotest/neotest-jest` | Jest adapter (`npx jest`) |

### Other Plugins
| Plugin | File | Purpose |
|---|---|---|
| `ThePrimeagen/harpoon` (harpoon2) | `harpoon.lua` | Quick-mark and jump between files |
| `mbbill/undotree` | `undotree.lua` | Undo history visualizer |
| `folke/zen-mode.nvim` | `zen.lua` | Distraction-free writing (120-wide, hides lualine/gitsigns/nvim-tree) |
| `folke/trouble.nvim` | `trouble.lua` | Diagnostic list (`:Trouble`) |
| `Jpifer13/popnav.nvim` | `popnav.lua` | Custom popup navigator (Terminal, Cheatsheet, Claude) |
| CSV plugins | `csv.lua` / `csvview.lua` | CSV table viewing |
| Markdown plugin | `markdown.lua` | Markdown rendering/preview |

---

## Theme

Active theme is set at the top of `lua/plugins/ui.lua`:
```lua
local ACTIVE_THEME = "tokyonight-night"
```
Options: `tokyonight-night`, `tokyonight-storm`, `tokyonight-moon`, `tokyonight-day`, `nightfox`, `duskfox`, `carbonfox`.

All Treesitter capture groups (`@keyword`, `@function`, `@variable`, etc.) and LSP semantic tokens (`@lsp.type.*`, `@lsp.typemod.*`) are explicitly overridden in `ui.lua`'s `on_highlights` callback for maximum color. This is intentional — the config is tuned for highly colorful Python/TypeScript highlighting.

---

## Editor Options (`lua/options.lua`)

| Setting | Value |
|---|---|
| Line numbers | absolute only (`relativenumber = false`) |
| Cursor line | on |
| Line wrap | off |
| Tab/indent | 2 spaces, `expandtab`, `smartindent` |
| Search | `ignorecase` + `smartcase` |
| Clipboard | `unnamedplus` (system clipboard) |
| Fold method | `indent`, `foldlevel=99` (all open by default) |
| Fold column | `"1"` (visible) |
| Auto-save | 1s inactivity (`CursorHold`/`InsertLeave`), toggleable |
| Invisible chars | shown: `tab=→`, `trail=·`, `nbsp=␣` |
| Yank highlight | 150ms flash on yank |
| Scroll offset | `scrolloff=8` |

---

## Motion Layout

Custom IJKL-style layout (replaces default hjkl). Implemented with `vim.cmd("nnoremap ...")` — not `vim.keymap.set` (see Notes).

| Key | Normal mode action |
|---|---|
| `i` | Up (was `k`) |
| `k` | Down (was `j`) |
| `j` | Left (was `h`) |
| `l` | Right (unchanged) |
| `h` | Enter insert mode (was `i`) |

**Operator-pending mode is untouched** — `ciw`, `di"`, `yip`, `vis`, etc. all work normally because `i` retains its meaning as "inner" in that context.

**Visual mode:** `i`/`k`/`j` remapped the same way via `xnoremap`.

**Window navigation** (mirrors motion layout):

| Key | Action |
|---|---|
| `<C-h>` | Window up (`<C-i>` unavailable — same escape code as Tab) |
| `<C-j>` | Window left |
| `<C-k>` | Window down |
| `<C-l>` | Window right |

---

## LSP Keymaps (buffer-local, set on LspAttach)

| Keymap | Action |
|---|---|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gt` | Go to type definition |
| `gr` | References (Telescope if available) |
| `K` | Hover documentation |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>f` | Format buffer (LSP) |
| `<leader>de` | Open diagnostics float |
| `[d` / `]d` | Previous / next diagnostic |

**LSP commands:** `:LspInfo`, `:LspRestart`, `:LspPythonPath`

---

## All Keymaps (leader = `<Space>`)

### Core
| Keymap | Action |
|---|---|
| `<leader>w` | Save |
| `<leader>q` | Quit |
| `<leader>ta` | Toggle auto-save |

### File Tree / Telescope
| Keymap | Action |
|---|---|
| `<leader>e` | Toggle nvim-tree |
| `<F1>` / `Cmd+1` | Toggle focus: tree ↔ editor |
| `<F2>` / `Cmd+Shift+1` | Toggle nvim-tree show/hide |
| `<F3>` / `Cmd+Shift+O` | Find files (Telescope, smart) |
| `<leader>fg` | Live grep (Telescope) |
| `<leader>fb` | Buffers (Telescope) |

**nvim-tree buffer keymaps (local to tree):**
| Keymap | Action |
|---|---|
| `l` / `<Right>` | Open folder / file |
| `j` / `<Left>` | Close directory (collapse) |

### Git (gitsigns — buffer-local)
| Keymap | Action |
|---|---|
| `]c` / `[c` | Next / prev hunk |
| `<leader>gb` | Toggle inline blame |
| `<leader>gB` | Full blame for current line |
| `<leader>gh` | Preview hunk |
| `<leader>gr` | Reset hunk |
| `<leader>gd` | Diff this |
| `<leader>gk` | Toggle hover blame (CursorHold) |
| `<leader>gm` | Git action menu popup |

### Git (neogit / diffview)
| Keymap | Action |
|---|---|
| `<leader>gs` | Neogit status |
| `<leader>go` | Diffview open |
| `<leader>gq` | Diffview close |
| `<leader>gF` | Repo file history |
| `<leader>gf` | Current file history |

### Debugger
| Keymap | Action |
|---|---|
| `<leader>dc` | Continue |
| `<leader>dn` | Step over |
| `<leader>di` | Step into |
| `<leader>do` | Step out |
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `<leader>dr` | REPL open |
| `<leader>dl` | Run last |
| `<leader>dq` | Terminate |
| `<leader>du` | Toggle DAP UI |
| `<leader>df` | Debug FastAPI (AWS profile picker) |

### Testing (neotest)
| Keymap | Action |
|---|---|
| `<leader>ae` | AWS SSO login picker (sets `AWS_PROFILE` env) |
| `<leader>nr` | Run nearest test |
| `<leader>nf` | Run file tests |
| `<leader>ns` | Toggle summary panel |
| `<leader>no` | Toggle output panel |
| `<leader>np` | Output popup |
| `<leader>nd` | Debug nearest test (DAP) |
| `<leader>nl` | Run last test |
| `<leader>nx` | Stop test |
| `<leader>nw` | Watch file |
| `[n` / `]n` | Prev / next failed test |

### Harpoon
| Keymap | Action |
|---|---|
| `<leader>ha` | Add current file |
| `<leader>hh` | Toggle menu |
| `<leader>h1`–`h4` | Jump to file 1–4 |
| `<leader>hn` / `hp` | Next / prev |
| `<leader>hc` | Clear all |

### Popnav (Terminal / Cheatsheet / Claude popup manager)
| Keymap | Action |
|---|---|
| `<leader>pp` | Popnav menu |
| `<leader>pn` | Next popup |
| `<leader>pP` | Prev popup |
| `<leader>px` | Close all popups |
| `<leader>p1`–`p4` | Select popup 1–4 |

### Claude Code (AI)
| Keymap | Action |
|---|---|
| `<leader>at` | Toggle Claude (session picker on first open) |
| `<leader>as` | Reset session (shows picker next open) |
| `<leader>af` | Focus Claude panel |
| `<leader>aa` | Send visual selection to Claude |
| `<leader>ab` | Add current file to Claude context |
| `<leader>am` | Select Claude model |

### Folding
| Keymap | Action |
|---|---|
| `<leader><up>` | Collapse all folds (`zM`) |
| `<leader><down>` | Expand all folds (`zR`) |
| `<leader>fc` | Close fold under cursor |
| `<leader>fo` | Open fold under cursor |
| `<leader>ft` | Toggle fold under cursor |
| `<leader><Space>` | Toggle fold |
| `<leader>fd` | Debug fold settings |

### Line Movement
| Keymap | Action |
|---|---|
| `<leader>j` | Move line/selection down |
| `<leader>k` | Move line/selection up |
| `<leader>J` | Jump 20 lines down |
| `<leader>K` | Jump 20 lines up |

### Misc
| Keymap | Action |
|---|---|
| `<leader>\` | Toggle floating terminal (normal + terminal mode) |
| `<leader>z` | Zen mode |
| `<leader>mp` | Markdown preview popup |
| `<leader>cv` | CSV table view toggle |
| `<leader>sr` | SSH remote host picker |
| `<leader>?` | Cheatsheet |
| `<leader>en` | Edit `.env` vars (floating editor) |
| `<leader>rp` | Run current Python file with `.venv/bin/python` |

### Treesitter debug
| Keymap | Action |
|---|---|
| `<leader>th` | Test Treesitter highlights |
| `<leader>tf` | Force Treesitter refresh |
| `<leader>tc` | Check active highlighter |

---

## Treesitter

Uses the new nvim-treesitter v1 API (`require("nvim-treesitter").install(...)`). Highlighting is enabled globally via a `BufReadPost *` autocmd with `pcall(vim.treesitter.start)` — silently skips filetypes without parsers.

Diagnostic command: `:TSStatus` — reports filetype, parser status, and highlighter status for current buffer.

---

## File Tree (nvim-tree)

nvim-tree auto-opens on `VimEnter` via autocmd. Opens without stealing focus (`focus = false`), highlights current file (`find_file = true`). Skips special buffers (diffs, fugitive, etc.).

**Custom keymaps** (set via `on_attach`, local to the tree buffer): `l` / `<Right>` opens a folder or file; `j` / `<Left>` closes the current directory. These override the global IJKL motion remaps inside the tree only.

**iTerm2 Cmd+1 setup:** iTerm2 intercepts `Cmd+1` natively — remap in iTerm2 → Settings → Profiles → Keys → `+`: shortcut `Cmd+1`, action `Send Escape Sequence`, value `[57P`. Neovim receives `\x1b[57P`, translates to `<F1>`, keymap toggles focus between tree and editor.

**iTerm2 Cmd+Shift+1 setup:** Same approach — shortcut `Cmd+Shift+1`, action `Send Escape Sequence`, value `[57Q`. Neovim receives `\x1b[57Q`, translates to `<F2>`, keymap toggles nvim-tree show/hide.

**iTerm2 Cmd+Shift+O setup:** Same approach — shortcut `Cmd+Shift+O`, action `Send Escape Sequence`, value `[57R`. Neovim receives `\x1b[57R`, translates to `<F3>`, keymap opens smart file finder.

**Smart file finder** (`<leader>ff` / `<F3>` / Cmd+Shift+O): Fuzzy searches all project files. Typing a query ending with `/` switches to directory-only results (uses `fd --type d`). Pressing `<CR>` on a directory opens nvim-tree, navigates to that folder, expands it, and places the cursor on it. Implemented as a custom `attach_mappings` wrapper around `telescope.builtin.find_files` in `lua/keymaps.lua`.

**Folder icons:** Uses distinct icons for different folder states (default, open, empty, symlink) with `▸`/`▾` arrows to indicate expand/collapse. Indent markers show folder hierarchy. Icons and colors are configured in `lua/plugins/navigation.lua`.

---

## SSH Remote (`lua/ssh_remote/`)

Custom SSH session manager. Flow:
1. `<leader>sr` opens a Telescope picker reading `~/.ssh/config`
2. Selecting a host runs `connect.sh` in a floating terminal
3. `connect.sh` opens an SSH ControlMaster connection, copies `bootstrap.sh` to remote, runs it interactively (checks/installs dependencies, clones nvim config), then drops into a shell
4. `<C-s>` in the picker skips bootstrap and opens a direct SSH session
5. Active sessions shown with `●` prefix in picker

---

## Env Manager (`lua/env-manager.lua`)

Auto-loads `.env` from `cwd` on startup. Parses `KEY=VALUE` lines (handles quotes, inline comments). Sets vars into Neovim's process environment.

`<leader>en` opens a floating `.env` editor (syntax highlighted as shell):
- `<CR>` in normal mode → save and close
- `:w` → save without closing
- `q` / `<Esc>` → close without saving

---

## Popnav (`lua/plugins/popnav.lua`)

Custom popup navigator that manages three floating panels as a group:
1. **Terminal** — persistent floating terminal
2. **Cheatsheet** — keymap reference popup
3. **Claude** — Claude Code panel (with session picker on first open)

---

## Notes & Decisions

- **Motion remapping** uses `vim.cmd("nnoremap ...")` — `vim.keymap.set` and `vim.api.nvim_set_keymap` both fail for single-character key remaps on Neovim 0.12.1.
- **LSP** uses native Neovim 0.11+ API (`vim.lsp.config` / `vim.lsp.enable`) in `lua/lsp.lua`. The `lua/plugins/lsp.lua` plugin spec also configures via `vim.lsp.config` — there is intentional overlap; the plugin file handles lazy-loading behavior.
- **Auto-save** is on by default (1s inactivity). Toggle with `<leader>ta`.
- **Folding** uses `foldmethod=indent` with all folds open by default (`foldlevel=99`).
- **Clipboard** is synced with system clipboard (`unnamedplus`).
- **Black formatter** uses the full pyenv path (`~/.pyenv/versions/3.13.3/bin/black`) to avoid pyenv shim timeouts.
- **Copilot** suggestions are disabled natively (panel=false, suggestion=false) and routed entirely through nvim-cmp as a source.
- **Claude Code sessions**: first `<leader>at` shows a picker (new/continue/resume); subsequent toggles skip the picker until `<leader>as` resets it.
- **Invisible characters** are shown (`tab`, `trail`, `nbsp`).
- **DAP debugpy** is sourced from Mason's install (`~/.local/share/nvim/mason/packages/debugpy/venv/bin/python`), not project venvs.
