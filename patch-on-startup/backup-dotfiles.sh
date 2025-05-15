#!/usr/bin/env bash
set -euo pipefail

SRC="$HOME/"
DEST="$HOME/MyFiles/dotfiles"

mkdir -p "$DEST"

rsync -a --delete \
  --exclude=".cache" \
  --exclude=".local" \
  --exclude=".Trash" \
  --exclude=".gvfs" \
  --exclude=".dbus" \
  --exclude=".config/google-chrome" \
  --exclude=".mozilla/firefox" \
  --exclude=".thumbnails" \
  "$SRC" "$DEST"