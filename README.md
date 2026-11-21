# .dotfiles

| In this repo | Linked from |
|---|---|
| `nvim/` | `~/.config/nvim` |
| `tmux/tmux.conf` | `~/.tmux.conf` |
| `tmux/theme-dark.conf`, `tmux/theme-light.conf` | `~/.config/tmux/` |
| `bin/theme` (light/dark switch for kitty, tmux, nvim) | `~/.local/bin/theme` |

## Setup

```sh
git clone git@github.com:zuhaib786/.dotfiles.git ~/.dotfiles
~/.dotfiles/install.sh
```

`install.sh` creates the links above. It's safe to re-run, and moves any real file in the way to `<name>.bak.<timestamp>` instead of deleting it.
