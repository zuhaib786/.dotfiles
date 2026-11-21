#!/bin/sh
# Link each config in this repo to where its program looks for it.
# Safe to re-run: existing links are replaced, and a real file or directory in
# the way is moved aside to <name>.bak.<timestamp> first, never deleted.
set -eu

DOT="$(cd "$(dirname "$0")" && pwd)"

link() { # link <path in this repo> <where it should appear>
  src="$DOT/$1"
  dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    backup="$dst.bak.$(date +%Y%m%d%H%M%S)"
    mv "$dst" "$backup"
    echo "moved aside: $dst -> $backup"
  fi
  ln -sfn "$src" "$dst"
  echo "linked: $dst -> $src"
}

link nvim                  "$HOME/.config/nvim"
link tmux/tmux.conf        "$HOME/.tmux.conf"
link tmux/theme-dark.conf  "$HOME/.config/tmux/theme-dark.conf"
link tmux/theme-light.conf "$HOME/.config/tmux/theme-light.conf"
link bin/theme             "$HOME/.local/bin/theme"
