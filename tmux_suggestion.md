# tmux + Neovim Workflow Suggestion

The cleanest setup is usually: `tmux` owns panes and sessions, and Neovim stays focused on editing.

## Recommended Workflow

1. Use `tmux` for layout and persistence.
   Keep one tmux session per project.

   Typical window layout:
   - window 1: Neovim full-screen
   - window 2: shell / git / build / tests
   - window 3: dev server / logs
   - window 4: database / REPL / one-off commands

2. Use Neovim's bottom terminal only for quick inline tasks.

   Good for:
   - short shell commands
   - quick test reruns
   - temporary REPL use
   - commands where staying in editor context matters

   Not ideal for:
   - long-running servers
   - multi-pane terminal workflows
   - session orchestration
   - heavy CLI work

3. Let tmux handle "multiple terminals", not Neovim.
   The recent multi-session terminal work in Neovim is useful, but if you fully adopt tmux, you will probably want fewer terminal features inside Neovim, not more.

## Practical Daily Setup

- Open iTerm2
- Start or attach tmux: `tmux new -As work`
- Use a primary "work" window with an IDE-style layout:
  - left pane: `nvim`
  - top-right pane: agent session 1
  - bottom-right pane: agent session 2, tests, or logs
- Add extra tmux windows for:
  - app server
  - build / tests
  - git / misc shell
- Use Neovim for editing, diagnostics, file navigation, and LSP
- Use tmux for process management and terminal navigation

## Recommended Side-Pane Workflow

If the goal is to have Neovim take up most of the screen while keeping one or two terminals visible for agents, this is the best layout:

- main left pane: Neovim, around 70-80% of the width
- right column: one or two stacked terminal panes for agents, logs, tests, or long-running commands

Recommended split:

- left pane: about 75%
- right column: about 25%
- if using two right-side panes: split the right column 50/50 vertically

This gives you:

- Neovim as the primary workspace
- persistent sidecar terminals you can monitor without leaving the editor
- easy resizing when you need to focus on one side

Ideal behavior:

- do most navigation inside Neovim
- glance right to watch agent output
- jump into the right pane only when you need to type or inspect something
- keep long-running tasks in tmux panes instead of Neovim's embedded terminal

## Good Boundary Between Tools

Neovim:
- editing
- LSP
- telescope
- git signs / neogit
- quick terminal popup if needed

tmux:
- persistent shells
- logs
- servers
- multiple command contexts
- remote sessions
- recovery after disconnect

## Recommendation For This Config

- Keep the bottom terminal, but treat it as a convenience tool window
- Do not try to make Neovim become your full terminal multiplexer
- Add tmux integration for navigation so editor and panes feel unified
- Use tmux side panes for agent sessions you want to monitor continuously

## Ideal Integrations To Add Next

- seamless navigation between Neovim splits and tmux panes
- shared clipboard behavior
- one keybinding to jump between editor and terminal pane
- project tmux session bootstrap script

## Concrete Next Step

If desired, the next implementation step would be:

- a `~/.tmux.conf` baseline
- Neovim <-> tmux pane navigation
- sensible keybindings matching the current layout
- a project startup command that opens:
  - a large left Neovim pane
  - one or two right-side agent panes
  - optional extra tmux windows for server, tests, or logs
