#!/usr/bin/env bash
set -euo pipefail

SRC="$HOME"
DEST="$HOME/MyFiles/dotfiles"

mkdir -p "$DEST"

shopt -s dotglob nullglob
for item in "$SRC"/.*; do
  name=$(basename "$item")
  [[ "$name" == "." || "$name" == ".." ]] && continue
  [[ "$name" == ".cache" || "$name" == ".local" ]] && continue
  cp -a "$item" "$DEST/"
done
