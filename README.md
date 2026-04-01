# Neovim Configuration

A modular, feature-rich Neovim configuration for Python and TypeScript development, built on **lazy.nvim** with 40+ plugins.

![Neovim](https://img.shields.io/badge/Neovim-0.11+-57A143?style=flat&logo=neovim&logoColor=white)
![Lua](https://img.shields.io/badge/Lua-2C2D72?style=flat&logo=lua&logoColor=white)

## Features

- **LSP** — Pyright, TypeScript, Lua, and YAML language servers with full diagnostics
- **Completion** — nvim-cmp with Copilot (highest priority), LSP, path, and buffer sources
- **Formatting** — Auto-format on save via conform.nvim (Black for Python, Prettier for JS/TS)
- **Git** — Gitsigns inline blame, Neogit UI, and Diffview for diffs and file history
- **Debugging** — DAP with UI panels, Python debugpy, and a FastAPI + AWS SSO debug launcher
- **Testing** — Neotest with pytest and Jest adapters, integrated AWS environment setup
- **AI** — GitHub Copilot for completions, Claude Code for chat and complex tasks
- **Custom modules** — Floating terminal, SSH remote manager, environment variable editor, interactive cheatsheet

## Structure

```
~/.config/nvim/
├── init.lua                    # Entry point
├── lua/
│   ├── options.lua             # Editor settings
│   ├── keymaps.lua             # Key mappings (leader = Space)
│   ├── lsp.lua                 # LSP server configuration
│   ├── plugins/
│   │   ├── init.lua            # Lazy.nvim bootstrap
│   │   ├── ui.lua              # Theme, statusline, icons
│   │   ├── navigation.lua      # File tree, Telescope, Harpoon
│   │   ├── git/                # Gitsigns, Neogit, Diffview
│   │   ├── treesitter.lua      # Syntax highlighting
│   │   ├── mason.lua           # LSP/DAP installer
│   │   ├── lsp.lua             # LSP plugin spec
│   │   ├── completion.lua      # nvim-cmp + Copilot
│   │   ├── formatting.lua      # conform.nvim
│   │   ├── ai.lua              # Claude Code integration
│   │   ├── debugger.lua        # DAP configuration
│   │   ├── testing.lua         # Neotest
│   │   ├── zen.lua             # Focus mode
│   │   ├── trouble.lua         # Diagnostics panel
│   │   └── ...                 # More plugin specs
│   ├── floating_terminal.lua   # Persistent floating terminal
│   ├── cheatsheet.lua          # Interactive keybinding reference
│   ├── markdown_preview.lua    # Floating markdown renderer
│   ├── env-manager.lua         # .env file loader and editor
│   ├── ssh_remote/             # SSH session manager
│   └── debug/
│       └── fastapi_aws.lua     # FastAPI + AWS debug launcher
└── lazy-lock.json
```

## Requirements

- **Neovim 0.11+**
- **Git**
- A [Nerd Font](https://www.nerdfonts.com/) for icons
- **Node.js** (for Copilot, Prettier, TypeScript LSP, markdown-preview)
- **Python 3.12+** with a `.venv` in your project (for Pyright, Black, debugpy)
- [ripgrep](https://github.com/BurntSushi/ripgrep) (for Telescope live grep)

## Installation

```bash
# Back up existing config
mv ~/.config/nvim ~/.config/nvim.bak

# Clone
git clone https://github.com/<your-username>/nvim.git ~/.config/nvim

# Open Neovim — lazy.nvim will auto-install all plugins
nvim
```

Mason will prompt to install language servers on first launch. Run `:Mason` to manage them manually.

## Theme

**TokyoNight Night** with extensively customized highlights — bold functions, italic keywords, color-coded diagnostics, and full Treesitter + LSP semantic token coverage. Nightfox is included as an alternative.

## Key Mappings

Leader key is **Space**. Press `<Space>?` to open the built-in cheatsheet.

### Navigation

| Key | Action |
|---|---|
| `<leader>e` | Toggle file tree |
| `<leader>ff` | Find files (Telescope) |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>ha` | Harpoon: add file |
| `<leader>hh` | Harpoon: toggle menu |
| `<leader>h1-4` | Harpoon: jump to bookmark |
| `<C-h/j/k/l>` | Move between splits |

### LSP

| Key | Action |
|---|---|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gt` | Go to type definition |
| `gr` | References |
| `K` | Hover documentation |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code actions |
| `<leader>f` | Format document |
| `<leader>de` | Show diagnostic float |
| `[d` / `]d` | Previous / next diagnostic |

### Git

| Key | Action |
|---|---|
| `<leader>gs` | Neogit status |
| `<leader>gb` | Toggle inline blame |
| `<leader>gh` | Preview hunk |
| `<leader>gr` | Reset hunk |
| `<leader>gd` | Diff hunk |
| `<leader>go` | Open diff view |
| `<leader>gf` | File history |
| `<leader>gm` | Git menu |

### Debugging

| Key | Action |
|---|---|
| `<leader>dc` | Continue / start |
| `<leader>dn` | Step over |
| `<leader>di` | Step into |
| `<leader>do` | Step out |
| `<leader>db` | Toggle breakpoint |
| `<leader>du` | Toggle DAP UI |
| `<leader>dq` | Terminate |
| `<leader>df` | FastAPI + AWS debug |

### Testing

| Key | Action |
|---|---|
| `<leader>nr` | Run nearest test |
| `<leader>nf` | Run file tests |
| `<leader>nd` | Debug nearest test |
| `<leader>ns` | Test summary panel |
| `<leader>no` | Test output panel |
| `<leader>nl` | Run last test |
| `<leader>nx` | Stop test |

### AI

| Key | Action |
|---|---|
| `<leader>at` | Toggle Claude Code |
| `<leader>aa` | Send selection to Claude (visual) |
| `<leader>ab` | Add current file to Claude |
| `<leader>am` | Select model |

### Misc

| Key | Action |
|---|---|
| `<leader>w` | Save |
| `<leader>q` | Quit |
| `<leader>\` | Toggle floating terminal |
| `<leader>z` | Zen mode |
| `<leader>u` | Undo tree |
| `<leader>ta` | Toggle auto-save |
| `<leader>en` | Edit environment variables |
| `<leader>sr` | SSH remote picker |
| `<leader>rp` | Run Python file |
| `<leader>?` | Cheatsheet |

## Completion

Completion sources are prioritized in this order:

1. **Copilot** `[AI]`
2. **LSP** `[LSP]`
3. **Path** `[Path]`
4. **Buffer** `[Buf]`

`<Tab>` accepts, `<S-Tab>` cycles back, `<C-Space>` triggers manually, `<CR>` confirms.

## Custom Modules

### Floating Terminal
Persistent terminal session in a centered floating window. Toggle with `<leader>\`.

### Environment Manager
Auto-loads `.env` from the project root on startup. Open `<leader>en` to view and edit variables in a floating buffer — changes propagate to all child processes.

### SSH Remote
Reads `~/.ssh/config` and presents a picker to connect to remote hosts. Optionally bootstraps git, Neovim, and your config on the remote before connecting.

### FastAPI + AWS Debug
One-keypress flow (`<leader>df`): select AWS profile, authenticate via SSO, start FastAPI with debugpy, and auto-attach the debugger.
