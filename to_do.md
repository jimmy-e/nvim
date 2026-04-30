* cmd + o to go to source
- toggle edit mode and read mode for markdown
- markdown support
- typescript / react syntax support
- ai auto suggest
- in line talk to ai
- change theme
- terminal in terminal
- slack integration
- use tmux
  https://www.youtube.com/shorts/PL1EoKjy4iM
* change width of tree  
* copy filename of file in tree
* file explorer: suggestions should start from top, not from bottom
* why is it that when I open a new line with an open `(` before that new line, it automatically doesn't add a `)`, etc for similar syntax
* cmd + f to search only in the file, shift + cmd + f to search strings globally
* telescope find is scoped to a certain folder
    * you are able to remove certain folders from telescope
* cmd + shift + p to auto insert suggestion
* file templates
* terminal names does not show full path, just terminal 1, terminal 2, etc.

  -------------------------------------------


❯ can I have my .tmux.conf be linked to a github repo?

⏺ Yes — common pattern is to keep dotfiles in a git repo and symlink them into $HOME.

  Quick setup

  # 1. Create a dotfiles repo
  mkdir ~/dotfiles && cd ~/dotfiles
  git init

  # 2. Move your config in
  mv ~/.tmux.conf ~/dotfiles/tmux.conf

  # 3. Symlink it back
  ln -s ~/dotfiles/tmux.conf ~/.tmux.conf

  # 4. Commit and push
  git add tmux.conf
  git commit -m "add tmux config"
  gh repo create dotfiles --public --source=. --push

  On a new machine

  git clone https://github.com/<you>/dotfiles.git ~/dotfiles
  ln -s ~/dotfiles/tmux.conf ~/.tmux.conf

  Tips

  - Drop the leading dot in the repo (tmux.conf not .tmux.conf) so files aren't hidden in ls.
  - Add other configs over time: nvim/, zshrc, gitconfig, etc.
  - For managing many symlinks, stow automates it: stow tmux creates the symlinks for you.
  - Alternative: bare-repo method (git --git-dir=$HOME/.dotfiles --work-tree=$HOME) tracks files in place without symlinks — search "dotfiles bare repo" if interested.


  -------------------------------------------

  ❯ what about the changes I make to my iterm2 such as my profile key bindings? are those somewhere that I can save and link to a github profile?

⏺ Yes — iTerm2 stores everything in a plist file you can version-control.

  Where iTerm2 stores settings

  ~/Library/Preferences/com.googlecode.iterm2.plist

  This binary plist contains profiles, key bindings, colors, fonts — everything.

  Recommended approach: point iTerm2 at your dotfiles folder

  iTerm2 has built-in support for this — no symlinks needed.

  1. Move/copy the plist into your dotfiles repo:
  mkdir -p ~/dotfiles/iterm2
  cp ~/Library/Preferences/com.googlecode.iterm2.plist ~/dotfiles/iterm2/
  2. In iTerm2: Settings → General → Preferences
    - Check "Load preferences from a custom folder or URL"
    - Point it at ~/dotfiles/iterm2
    - Set "Save changes" to "Automatically" (saves back to that folder on quit)
  3. Commit and push:
  cd ~/dotfiles
  git add iterm2/
  git commit -m "add iterm2 prefs"
  git push

  On a new machine

  1. Clone the dotfiles repo.
  2. Open iTerm2 settings → point custom folder at ~/dotfiles/iterm2.
  3. Restart iTerm2.

  Notes

  - The file is binary plist. You can convert to readable XML for cleaner diffs:
  plutil -convert xml1 ~/dotfiles/iterm2/com.googlecode.iterm2.plist
  - iTerm2 reads both formats fine.
  - macOS caches preferences — if changes don't appear, run killall cfprefsd after editing externally.
  - Key bindings specifically live under the "New Bookmarks" (per-profile) and "GlobalKeyMap" keys inside the plist.
